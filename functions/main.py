# functions/main.py
# ============================================================
#  RaktSetu – DRE (Donor-Request Engine) Cloud Function
#  Triggered by: Firestore onCreate on /blood_requests/{requestId}
#  Language: Python 3.11+
#  Runtime: Firebase Cloud Functions (2nd Gen)
# ============================================================

import logging
from firebase_functions import firestore_fn, options
from firebase_admin import initialize_app, firestore, messaging
from google.cloud.firestore_v1.base_query import FieldFilter
from math import radians, cos, sin, asin, sqrt

initialize_app()
logger = logging.getLogger(__name__)

# ─── Constants ────────────────────────────────────────────────────────────────

MIN_DONORS_REQUIRED = 3
DONATION_COOLDOWN_DAYS = 90
SEARCH_RADII_KM = [5.0, 10.0, 20.0]

# Compatible blood group mapping (who can donate to whom)
COMPATIBLE_DONORS: dict[str, list[str]] = {
    "A+":  ["A+", "A-", "O+", "O-"],
    "A-":  ["A-", "O-"],
    "B+":  ["B+", "B-", "O+", "O-"],
    "B-":  ["B-", "O-"],
    "AB+": ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"],
    "AB-": ["A-", "B-", "AB-", "O-"],
    "O+":  ["O+", "O-"],
    "O-":  ["O-"],
}

# ─── Haversine Distance ───────────────────────────────────────────────────────

def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Returns distance in km between two lat/lng points."""
    R = 6371.0
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    return R * 2 * asin(sqrt(a))

# ─── Cloud Function Trigger ───────────────────────────────────────────────────

@firestore_fn.on_document_created(
    document="blood_requests/{requestId}",
    region="asia-south1",
    memory=options.MemoryOption.MB_256,
)
def on_request_created(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    """
    DRE Algorithm:
    1. Read the new request (blood group + hospital location).
    2. Find eligible donors using recursive radius expansion.
    3. Send FCM push notifications to all matched donors.
    """
    if event.data is None:
        logger.warning("No data in event snapshot, skipping.")
        return

    request_id = event.params["requestId"]
    data = event.data.to_dict()

    required_blood_group: str = data.get("requestedBloodGroup", "")
    hospital_loc = data.get("hospitalLocation")  # GeoPoint-like object

    if not required_blood_group or not hospital_loc:
        logger.error(f"[{request_id}] Missing blood group or location. Aborting.")
        return

    seeker_lat = hospital_loc.latitude
    seeker_lon = hospital_loc.longitude
    compatible_groups = COMPATIBLE_DONORS.get(required_blood_group, [required_blood_group])

    logger.info(f"[{request_id}] Processing for blood group {required_blood_group} at ({seeker_lat}, {seeker_lon})")

    db = firestore.client()
    matched_donors: list[dict] = []

    # ── Phase 3: Recursive Radius Expansion ──────────────────────────────────
    for radius_km in SEARCH_RADII_KM:
        logger.info(f"[{request_id}] Searching within {radius_km} km...")
        candidates = _query_donors_in_radius(
            db, seeker_lat, seeker_lon, radius_km, compatible_groups
        )
        eligible = _filter_eligible(candidates)
        logger.info(f"[{request_id}] Found {len(eligible)} eligible donors at {radius_km}km")

        if len(eligible) >= MIN_DONORS_REQUIRED:
            matched_donors = eligible
            break

    if not matched_donors:
        logger.warning(f"[{request_id}] No donors found. Marking as no_donors.")
        db.collection("blood_requests").document(request_id).update(
            {"status": "no_donors_found"}
        )
        return

    # ── Phase 3: Send FCM Notifications ──────────────────────────────────────
    _notify_donors(matched_donors, request_id, required_blood_group, data)

    # Update the request with notified donor IDs
    db.collection("blood_requests").document(request_id).update({
        "notifiedDonorIds": [d["uid"] for d in matched_donors],
        "status": "pending",
    })
    logger.info(f"[{request_id}] Notified {len(matched_donors)} donors successfully.")


# ─── Helper: Query Donors ─────────────────────────────────────────────────────

def _query_donors_in_radius(
    db,
    center_lat: float,
    center_lon: float,
    radius_km: float,
    blood_groups: list[str],
) -> list[dict]:
    """
    Queries Firestore for donors matching blood groups.
    Applies bounding-box pre-filter, then exact Haversine check.
    """
    from datetime import datetime, timedelta

    # Approximate degree offset for bounding box
    lat_delta = radius_km / 111.0
    lon_delta = radius_km / (111.0 * cos(radians(center_lat)))

    min_lat = center_lat - lat_delta
    max_lat = center_lat + lat_delta

    results: list[dict] = []

    for bg in blood_groups:
        docs = (
            db.collection("users")
            .where(filter=FieldFilter("role", "==", "donor"))
            .where(filter=FieldFilter("bloodGroup", "==", bg))
            .where(filter=FieldFilter("isAvailable", "==", True))
            .stream()
        )

        for doc in docs:
            d = doc.to_dict()
            d["uid"] = doc.id
            loc = d.get("location")
            if loc is None:
                continue
            dlat, dlon = loc.latitude, loc.longitude

            # Bounding box fast filter
            if not (min_lat <= dlat <= max_lat):
                continue

            # Exact Haversine distance
            dist = haversine_km(center_lat, center_lon, dlat, dlon)
            if dist <= radius_km:
                d["_distance_km"] = dist
                results.append(d)

    # Deduplicate by uid (a donor may match multiple blood groups)
    seen: set[str] = set()
    unique: list[dict] = []
    for d in sorted(results, key=lambda x: x["_distance_km"]):
        if d["uid"] not in seen:
            seen.add(d["uid"])
            unique.append(d)

    return unique


# ─── Helper: Eligibility Filter ──────────────────────────────────────────────

def _filter_eligible(donors: list[dict]) -> list[dict]:
    """Filters out donors who donated within the last 90 days."""
    from datetime import datetime, timezone, timedelta

    cutoff = datetime.now(timezone.utc) - timedelta(days=DONATION_COOLDOWN_DAYS)
    eligible: list[dict] = []

    for d in donors:
        last_donation = d.get("lastDonationDate")
        if last_donation is None:
            eligible.append(d)
        elif hasattr(last_donation, "ToDatetime"):
            # Firestore Timestamp
            dt = last_donation.ToDatetime().replace(tzinfo=timezone.utc)
            if dt < cutoff:
                eligible.append(d)

    return eligible


# ─── Helper: FCM Notifications ───────────────────────────────────────────────

def _notify_donors(
    donors: list[dict],
    request_id: str,
    blood_group: str,
    request_data: dict,
) -> None:
    """Sends high-priority FCM push notifications to all matched donors."""
    hospital = request_data.get("hospitalName", "the hospital")

    messages: list[messaging.Message] = []
    for donor in donors:
        token = donor.get("fcmToken")
        if not token:
            continue
        messages.append(
            messaging.Message(
                token=token,
                notification=messaging.Notification(
                    title=f"🚨 URGENT: {blood_group} Blood Needed!",
                    body=f"A patient at {hospital} urgently needs {blood_group} blood. Can you help?",
                ),
                data={
                    "requestId": request_id,
                    "bloodGroup": blood_group,
                    "type": "blood_request",
                },
                android=messaging.AndroidConfig(
                    priority="high",
                    notification=messaging.AndroidNotification(
                        channel_id="raktsetu_emergency",
                        priority=messaging.AndroidNotificationPriority.MAX,
                        sound="default",
                    ),
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            sound="default",
                            badge=1,
                            content_available=True,
                        )
                    )
                ),
            )
        )

    if messages:
        batch_response = messaging.send_each(messages)
        logger.info(
            f"FCM: {batch_response.success_count} sent, {batch_response.failure_count} failed"
        )
