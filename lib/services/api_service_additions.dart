// ============================================================
// ADD THESE METHODS INSIDE YOUR EXISTING ApiService CLASS
// (in api_service.dart). Adjust the endpoint URLs / parsing to match
// the pattern your getKaryakartaEnrollments() already uses.
// ============================================================

/// Returns the list of welfare schemes for the "Select Welfare Scheme"
/// dropdown, e.g. [{'id': 'KDS', 'name': 'Kanyadan Yojana (KDS)'}, ...]
Future<List<Map<String, dynamic>>> getWelfareSchemes() async {
  // Example:
  // final res = await _dio.get('/karyakarta/schemes');
  // return List<Map<String, dynamic>>.from(res.data['data']);

  // TEMP mock so the screen compiles/runs before you wire the API:
  return [
    {'id': 'MYS', 'name': 'Mayara Yojana (MYS)'},
    {'id': 'KDS', 'name': 'Kanyadan Yojana (KDS)'},
  ];
}

/// Looks up an existing member by 7-digit Member ID, Mobile, or Aadhaar.
/// Returns null if not found. Keys should match what the screen reads:
/// full_name, gotra, dob (ISO string), gender, mobile, aadhaar,
/// father_name, mother_name, guardian_name, village, address, pin_code.
Future<Map<String, dynamic>?> fetchMemberRecord(String query) async {
  // Example:
  // final res = await _dio.get('/karyakarta/members/lookup', queryParameters: {'q': query});
  // if (res.data['data'] == null) return null;
  // return Map<String, dynamic>.from(res.data['data']);

  return null; // TODO: implement
}

/// Returns the joining fee / per-event contribution for a scheme +
/// calculated age group, e.g. {'joining_fee': 8500, 'per_event': 400,
/// 'age_group': 'Adult (18-60)'}.
Future<Map<String, dynamic>> getSchemeRates(String schemeId, String ageGroup) async {
  // Example:
  // final res = await _dio.get('/karyakarta/schemes/$schemeId/rates', queryParameters: {'age_group': ageGroup});
  // return Map<String, dynamic>.from(res.data['data']);

  return {'joining_fee': 0, 'per_event': 50, 'age_group': ageGroup};
}

/// Submits the full proposal payload built in EnrollmentCreateScreen._submit().
/// Should return {'success': true/false, 'message': '...'}.
Future<Map<String, dynamic>> submitEnrollmentProposal(Map<String, dynamic> payload) async {
  // Example:
  // final res = await _dio.post('/karyakarta/enrollments', data: payload);
  // return {'success': res.data['success'] == true, 'message': res.data['message']};

  return {'success': true, 'message': 'Proposal submitted successfully.'}; // TODO: implement
}