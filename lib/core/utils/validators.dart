// lib/core/utils/validators.dart

class Validators {
  Validators._();

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^\+?[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name is too short';
    return null;
  }

  static String? validateBloodGroup(String? value) {
    const valid = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    if (value == null || !valid.contains(value)) return 'Select a valid blood group';
    return null;
  }

  static String? validateHospitalName(String? value) {
    if (value == null || value.isEmpty) return 'Hospital name is required';
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.length != 6) return 'Enter valid 6-digit OTP';
    return null;
  }

  /// Checks if donor is eligible to donate based on last donation date
  static bool isDonorEligible(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return true;
    final daysSince = DateTime.now().difference(lastDonationDate).inDays;
    return daysSince >= 90;
  }
}
