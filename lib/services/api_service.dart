// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/karyakarta_model.dart';
// import '../models/member_model.dart';
// import '../models/scheme_model.dart';
// import '../utils/api_config.dart';
// import '../models/proposal_model.dart';
// import '../models/dashboard_stats_model.dart';
// import '../models/enrollment_model.dart';
// import '../models/claim_model.dart';
// import '../models/receipt_model.dart';
// import '../models/contribution_batch_model.dart';
// import '../models/member_contribution_model.dart';
// import 'package:file_picker/file_picker.dart';
// import '../models/karyakarta_session.dart';
//
//
// /// Thin wrapper around http calls. Keep all network logic here so
// /// screens stay simple.
//
// class ApiService {
//   // ---- Singleton setup ----
//   ApiService._internal();
//   static final ApiService _instance = ApiService._internal();
//   factory ApiService() => _instance;
//   // NEW — needed so screens can build the WebView URL with the active token
//   String? get authToken => _token;
//   // --------------------------
//   String? _token;
//   Map<String, dynamic>? _user;
//   String? _deviceId;
//
//   static const _tokenKey = 'auth_token';
//   static const _userKey = 'auth_user';
//   static const _deviceIdKey = 'device_id';
//
//   Future<void> loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString(_tokenKey);
//     // debugPrint("🔑 TOKEN LOADED ON START: $_token");   // TEMP DEBUG
//     debugPrint("🔑 TOKEN LOADED ON START: ${_token == null ? 'null' : '${_token!.substring(0, 8)}...'}");
//     final userJson = prefs.getString(_userKey);
//     if (userJson != null) _user = jsonDecode(userJson);
//   }
//
//   /// Returns a stable device id, generating and persisting one on first use.
//   Future<String> _getDeviceId() async {
//     if (_deviceId != null) return _deviceId!;
//     final prefs = await SharedPreferences.getInstance();
//     String? id = prefs.getString(_deviceIdKey);
//     if (id == null) {
//       id = 'flutter-${DateTime.now().millisecondsSinceEpoch}-${(1000 + (DateTime.now().microsecond % 9000))}';
//       await prefs.setString(_deviceIdKey, id);
//     }
//     _deviceId = id;
//     return id;
//   }
//
//   Future<void> _setUser(Map<String, dynamic> user) async {
//     _user = user;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_userKey, jsonEncode(user));
//   }
//
//   Map<String, dynamic>? get currentUser => _user;
//   List<String> get permissions =>
//       List<String>.from(_user?['permissions'] ?? const []);
//   String? get roleName => _user?['role'] as String?;
//
//   Future<void> setToken(String token) async {
//     _token = token;
//     // debugPrint("🔑 TOKEN SAVED: $_token");   // TEMP DEBUG
//     debugPrint("🔑 TOKEN SAVED: ${_token!.substring(0, 8)}...");
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//   }
//   Future<void> clearToken() async {
//     _token = null;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//   }
//
//   bool get isLoggedIn => _token != null;
//
//   /// Calls the backend logout endpoint, then always clears local
//   /// session data (token + cached user) — even if the API call fails —
//   /// so the user is never stuck "logged in" on the device.
//   Future<Map<String, dynamic>> logout() async {
//     try {
//       final res = await http.post(
//         Uri.parse(ApiConfig.logout),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       return {
//         "success": data['status'] == 'success' || data['success'] == true,
//         "message": data['message'] ?? 'Logged out successfully',
//         ...data,
//       };
//     } catch (e) {
//       return {"success": false, "message": "Logout failed: $e"};
//     } finally {
//       await clearToken();
//       _user = null;
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_userKey);
//     }
//   }
//   /// Fetches the logged-in user's own profile from GET /auth/profile
//   /// and merges it into the cached `_user` map so `currentUser`,
//   /// `roleName`, etc. stay in sync with what the server actually has.
//   Future<Map<String, dynamic>?> getProfile() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.profile),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       final profile = Map<String, dynamic>.from(data['data']);
//       // keep local cached user merged with freshest server data
//       await _setUser({..._user ?? {}, ...profile});
//       return profile;
//     } catch (e) {
//       debugPrint("🔴 getProfile error: $e");
//       return null;
//     }
//   }
//
//   // NEW — add this method anywhere inside class ApiService,
//   // e.g. right after getSchemesRaw()
//   Future<List<Map<String, dynamic>>> getKaryakartasRaw() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartas),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartasRaw error: $e");
//       return [];
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getEnrollmentsRaw() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.enrollments),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getEnrollmentsRaw error: $e");
//       return [];
//     }
//   }
//   // ---------------- AUTH ----------------
//   Future<Map<String, dynamic>> login(String username, String password) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.login),
//       headers: ApiConfig.headers(),
//       body: jsonEncode({"username": username, "password": password}),
//     );
//     final data = _handle(res);
//
//     final isSuccess = data['status'] == 'success';
//     if (isSuccess && data['data'] != null) {
//       final userData = Map<String, dynamic>.from(data['data']);
//       userData['role'] = (userData['role'] ?? 'admin').toString();
//       if (userData['token'] != null) {
//         await setToken(userData['token']);
//       }
//       await _setUser(userData);
//       if (userData['role'] == 'karyakarta') {
//         KaryakartaSession.saCode = userData['sa_code']?.toString() ?? '';
//         KaryakartaSession.fullName = userData['name']?.toString() ?? 'Karyakarta';
//         KaryakartaSession.mobile = userData['mobile']?.toString() ?? '';
//         KaryakartaSession.village = userData['village']?.toString() ?? '';
//       }
//     }
//
//     debugPrint("🟢 LOGIN → status=${data['status']} isSuccess=$isSuccess role=${_user?['role']}");
//
//     return {
//       ...data,
//       "success": isSuccess,
//       "message": data['message'] ?? (isSuccess ? "Login successful" : "Login failed"),
//     };
//   }
//
//   /// True once the backend confirms this user already has a PIN set.
//   bool get pinIsSet => _user?['pin_set'] == true;
//
//   Future<Map<String, dynamic>> sendLoginOtp(String username) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.sendLoginOtp),
//       headers: ApiConfig.headers(),
//       body: jsonEncode({"phone": username}),
//     );
//     return _handle(res);
//   }
//
//   Future<Map<String, dynamic>> verifyLoginOtp(String username, String otp) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.verifyLoginOtp),
//       headers: ApiConfig.headers(),
//       body: jsonEncode({"phone": username, "otp": otp}),
//     );
//     return _handle(res);
//   }
//
//   Future<Map<String, dynamic>> setPin(String username, String pin) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.setPin),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"phone": username, "pin": pin}),
//     );
//     return _handle(res);
//   }
//
//   Future<Map<String, dynamic>> pinLogin(String username, String pin) async {
//     final deviceId = await _getDeviceId();
//     final res = await http.post(
//       Uri.parse(ApiConfig.pinLogin),
//       headers: ApiConfig.headers(),
//       body: jsonEncode({"phone": username, "pin": pin, "device_id": deviceId}),
//     );
//     final data = _handle(res);
//     if (data['success'] == true && data['token'] != null) {
//       await setToken(data['token']);
//       if (data['user'] != null) await _setUser(Map<String, dynamic>.from(data['user']));
//     }
//     return data;
//   }
//
//   Future<Map<String, dynamic>> sendForgotPinOtp(String username) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.forgotPinSendOtp),
//       headers: ApiConfig.headers(),
//       body: jsonEncode({"phone": username}),
//     );
//     return _handle(res);
//   }
//
//   Future<Map<String, dynamic>> verifyForgotPinOtp(String username, String otp) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.forgotPinVerifyOtp),
//       headers: ApiConfig.headers(),
//       body: jsonEncode({"phone": username, "otp": otp}),
//     );
//     return _handle(res);
//   }
//
//   Future<Map<String, dynamic>> resetPin(String username, String pin) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.resetPin),
//       headers: ApiConfig.headers(),
//       body: jsonEncode({"phone": username, "pin": pin}),
//     );
//     return _handle(res);
//   }
//
//   // ---------------- DASHBOARD ----------------
//
//   Future<DashboardStatsModel> getDashboardStats() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.dashboardStats),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final statsJson = Map<String, dynamic>.from(data['data'] ?? {});
//       return DashboardStatsModel.fromJson(statsJson);
//     } catch (_) {
//       return DashboardStatsModel.demo();
//     }
//   }
//   // ---------------- PAYMENT MASTER REGISTER (Collection Manage) ----------------
//
//   /// GET /api/payment/master-register?type=collection[&category=joining_fee|contribution]
//   Future<List<Map<String, dynamic>>> getMasterRegister({
//     String type = 'collection',
//     String? category,
//   }) async {
//     try {
//       final uri = Uri.parse(ApiConfig.paymentMasterRegister).replace(queryParameters: {
//         "type": type,
//         if (category != null) "category": category,
//       });
//       final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getMasterRegister error: $e");
//       return [];
//     }
//   }
//
//   // GET /api/collections/dashboard
//   Future<Map<String, dynamic>> getCollectionsDashboard() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.collectionsDashboard),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return {};
//       return Map<String, dynamic>.from(data['data']);
//     } catch (e) {
//       debugPrint("🔴 getCollectionsDashboard error: $e");
//       return {};
//     }
//   }
//
//   // ---------------- CLAIMS (raw — matches real API fields) ----------------
//
//   /// GET /api/claims[?status=pending|settled|rejected|paid|submitted]
//   Future<List<Map<String, dynamic>>> getClaimsRaw({String? status}) async {
//     try {
//       final uri = Uri.parse(ApiConfig.claims).replace(queryParameters: {
//         if (status != null && status.isNotEmpty) "status": status,
//       });
//       final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getClaimsRaw error: $e");
//       return [];
//     }
//   }
//   /// Mints a short-lived, single-purpose share token so the admin PHP pages
//   /// (member_card.php, policy_dastavej.php, proposal_doc.php) can validate the
//   /// request. NEVER pass `authToken` directly into those URLs — they check
//   /// against a `sss_shared_tokens` row, not the login API token.
//   // Future<String?> getDocumentShareToken({
//   //   required String docType,
//   //   required String recordId,
//   // }) async {
//   //   try {
//   //     final res = await http.post(
//   //       Uri.parse(ApiConfig.documentShareToken),
//   //       headers: ApiConfig.headers(token: _token),
//   //       body: jsonEncode({"doc_type": docType, "record_id": recordId}),
//   //     );
//   //     debugPrint("🔑 share_token [$docType/$recordId] → ${res.statusCode}: ${res.body}");
//   //     final data = _handle(res);
//   //     final d = data['data'];
//   //     final tok = (d is Map ? d['token'] : null) ?? data['token'];
//   //     return tok?.toString();
//   //   } catch (e) {
//   //     debugPrint("🔴 getDocumentShareToken error: $e");
//   //     return null;
//   //   }
//   // }
//   /// Last error from getDocumentShareToken(), so the UI can show the real reason.
//   String? lastShareTokenError;
//
//   Future<String?> getDocumentShareToken({
//     required String docType,
//     required String recordId,
//   }) async {
//     lastShareTokenError = null;
//     try {
//       final res = await http
//           .post(
//         Uri.parse(ApiConfig.documentShareToken),
//         headers: ApiConfig.headers(token: _token),
//         body: jsonEncode({"doc_type": docType, "record_id": recordId}),
//       )
//           .timeout(const Duration(seconds: 20));
//
//       debugPrint("🔑 share_token [$docType/$recordId] → ${res.statusCode}: ${res.body}");
//
//       Map<String, dynamic> body;
//       try {
//         body = jsonDecode(res.body) as Map<String, dynamic>;
//       } catch (_) {
//         lastShareTokenError = res.statusCode == 404
//             ? 'share_token.php not found on server (404)'
//             : 'Server returned an invalid response (${res.statusCode})';
//         return null;
//       }
//
//       if (res.statusCode < 200 || res.statusCode >= 300) {
//         lastShareTokenError =
//             body['message']?.toString() ?? 'Request failed (${res.statusCode})';
//         return null;
//       }
//
//       final d = body['data'];
//       final tok = (d is Map ? d['token'] : null) ?? body['token'];
//       if (tok == null || tok.toString().isEmpty) {
//         lastShareTokenError = 'Server did not return a token';
//         return null;
//       }
//       return tok.toString();
//     } catch (e) {
//       debugPrint("🔴 getDocumentShareToken error: $e");
//       lastShareTokenError = 'Network error: $e';
//       return null;
//     }
//   }
//   // Reads a list from many possible response shapes:
//   // {data:[...]}, {data:{items:[...]}}, or a bare [...]
//   List<Map<String, dynamic>> _extractList(dynamic body) {
//     dynamic raw = body;
//     if (raw is Map) {
//       raw = raw['data'] ?? raw['items'] ?? raw['result'] ?? raw['gotras'] ??
//           raw['states'] ?? raw['districts'] ?? raw['talukas'] ?? [];
//     }
//     if (raw is Map) {
//       raw = raw['items'] ?? raw['list'] ?? raw['data'] ?? [];
//     }
//     if (raw is! List) return [];
//     return raw
//         .whereType<Map>()
//         .map((e) => Map<String, dynamic>.from(e))
//         .toList();
//   }
//
//   Future<List<Map<String, dynamic>>> _getMasterList(String url, String tag) async {
//     try {
//       final res = await http.get(Uri.parse(url), headers: ApiConfig.headers(token: _token));
//       debugPrint("📍 $tag [$url] → ${res.statusCode}: ${res.body}");
//       if (res.statusCode < 200 || res.statusCode >= 300) return [];
//       final decoded = jsonDecode(res.body);
//       final list = _extractList(decoded);
//       debugPrint("📍 $tag parsed ${list.length} items");
//       return list;
//     } catch (e) {
//       debugPrint("🔴 $tag error: $e");
//       return [];
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getGotras() =>
//       _getMasterList(ApiConfig.gotra, 'gotras');
//
//   Future<List<Map<String, dynamic>>> getStates() =>
//       _getMasterList(ApiConfig.states, 'states');
//
//   Future<List<Map<String, dynamic>>> getDistricts(String stateId) =>
//       _getMasterList(ApiConfig.districtsByState(stateId), 'districts[$stateId]');
//
//   Future<List<Map<String, dynamic>>> getTalukas(String districtId) =>
//       _getMasterList(ApiConfig.talukasByDistrict(districtId), 'talukas[$districtId]');
//
//   // ---------------- ADMIN NOTIFICATIONS ----------------
//
//   // GET /api/notifications
//   Future<List<Map<String, dynamic>>> getAdminNotifications() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.adminNotifications),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getAdminNotifications error: $e");
//       return [];
//     }
//   }
//
//   // ---------------- KARYAKARTA ----------------
//
//   Future<Map<String, dynamic>> createKaryakarta(
//       Map<String, dynamic> payload, {
//         PlatformFile? passportPhoto,
//         PlatformFile? govtIdProof,
//         PlatformFile? authConsentLetter,
//       }) async {
//     final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.createKaryakarta));
//
//     if (_token != null) request.headers["X-API-Token"] = _token!;
//     request.headers["Accept"] = "application/json";
//
//     payload.forEach((key, value) {
//       request.fields[key] = value?.toString() ?? '';
//     });
//
//     Future<void> attach(String field, PlatformFile? file) async {
//       if (file == null) return;
//       if (file.bytes != null) {
//         request.files.add(http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
//       } else if (file.path != null) {
//         request.files.add(await http.MultipartFile.fromPath(field, file.path!, filename: file.name));
//       }
//     }
//
//     await attach('passport_photo', passportPhoto);
//     await attach('govt_id_proof', govtIdProof);
//     await attach('auth_consent_letter', authConsentLetter);
//
//     final streamed = await request.send();
//     final res = await http.Response.fromStream(streamed);
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> createMemberWithFiles(
//       Map<String, dynamic> payload, {
//         PlatformFile? passportPhoto,
//         PlatformFile? govtIdProof,
//         PlatformFile? authConsentLetter,
//       }) async {
//     final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.members));
//
//     if (_token != null) request.headers["X-API-Token"] = _token!;
//     request.headers["Accept"] = "application/json";
//
//     payload.forEach((key, value) {
//       if (value != null) request.fields[key] = value.toString();
//     });
//
//     Future<void> attach(String field, PlatformFile? file) async {
//       if (file == null) return;
//       if (file.bytes != null) {
//         request.files.add(http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
//       } else if (file.path != null) {
//         request.files.add(await http.MultipartFile.fromPath(field, file.path!, filename: file.name));
//       }
//     }
//
//     await attach('passport_photo', passportPhoto);
//     await attach('govt_id_proof', govtIdProof);
//     await attach('auth_consent_letter', authConsentLetter);
//
//     final streamed = await request.send();
//     final res = await http.Response.fromStream(streamed);
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//   /// Fetches the full profile used by KaryakartaProfileScreen.
//   /// Your backend's GET /karyakartas/{id} returns one FLAT object (same
//   /// shape as the list API — full_name, dob, state, gotra, status,
//   /// created_at, etc. all top-level). The profile screen UI expects it
//   /// grouped under personal / working_area / samaj, so we regroup it here
//   /// instead of touching the screen.
//   Future<Map<String, dynamic>> getKaryakartaProfile(int id) async {
//     final res = await http.get(
//       Uri.parse(ApiConfig.karyakartaProfile(id.toString())),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     // Backend can wrap the payload in "data" or return it flat — handle both.
//     final raw = Map<String, dynamic>.from(data['data'] ?? data);
//
//     return {
//       ...raw,
//       'personal': {
//         'full_name': raw['full_name'],
//         'father_name': raw['father_name'],
//         'dob': raw['dob'],
//         'gender': raw['gender'],
//         'mobile': raw['mobile'],
//         'aadhaar_no': raw['aadhaar_no'],
//         'pan_no': raw['pan_no'],
//       },
//       'working_area': {
//         'state': raw['state'],
//         'district': raw['district'],
//         'taluka': raw['taluka'],
//         'village': raw['village'],
//         'pincode': raw['pincode'],
//         'full_address': raw['full_address'],
//       },
//       'samaj': {
//         'gotra': raw['gotra'],
//         'occupation': raw['occupation'],
//         'education': raw['education'],
//         'date_of_joining': raw['created_at'],
//       },
//       'karyakarta_code': raw['karyakarta_code'],
//       'status': raw['status'],
//       'assigned_members': raw['assigned_members'] ?? [],
//       'policies': raw['policies'] ?? [],
//       'claims': raw['claims'] ?? [],
//       'commission_ledger': raw['commission_ledger'] ?? [],
//       'collections': raw['collections'] ?? [],
//     };
//   }
//   Future<Map<String, dynamic>> updateKaryakartaStatus(String id, String status) async {
//     final res = await http.patch(
//       Uri.parse(ApiConfig.karyakartaStatus(id)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"status": status}),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Status updated' : 'Failed to update status'),
//       ...data,
//     };
//   }
//
//   // NEW — PUT /api/karyakartas/{id}
//   Future<Map<String, dynamic>> updateKaryakarta(String id, Map<String, dynamic> payload) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.karyakartaProfile(id)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Karyakarta updated' : 'Failed to update karyakarta'),
//       ...data,
//     };
//   }
//
//   // NEW — DELETE /api/karyakartas/{id}
//   Future<Map<String, dynamic>> deleteKaryakarta(String id) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.karyakartaProfile(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Karyakarta deleted' : 'Failed to delete karyakarta'),
//       ...data,
//     };
//   }
//
//   Future<List<KaryakartaModel>> getKaryakartas() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartas),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return list.map((e) => KaryakartaModel.fromJson(Map<String, dynamic>.from(e))).toList();
//     } catch (_) {
//       return [];
//     }
//   }
// // NEW
// //   Future<Map<String, dynamic>> karyakartaLogin(String username, String password) async {
// //     final res = await http.post(
// //       Uri.parse(ApiConfig.karyakartaLogin),
// //       headers: ApiConfig.headers(),
// //       body: jsonEncode({"username": username, "password": password}),
// //     );
// //     final data = _handle(res);
// //
// //     final isSuccess = data['status'] == 'success';
// //     if (isSuccess && data['data'] != null) {
// //       final userData = Map<String, dynamic>.from(data['data']);
// //       userData['role'] ??= 'karyakarta';
// //       if (userData['token'] != null) {
// //         await setToken(userData['token']);
// //       }
// //       await _setUser(userData);
// //
// //       // NEW — populate the session used by the dashboard UI
// //       KaryakartaSession.saCode = userData['sa_code']?.toString() ?? '';
// //       KaryakartaSession.fullName = userData['name']?.toString() ?? 'Karyakarta';
// //       KaryakartaSession.mobile = userData['mobile']?.toString() ?? '';
// //       KaryakartaSession.village = userData['village']?.toString() ?? '';
// //     }
// //
// //     debugPrint("🟠 KARYAKARTA LOGIN → status=${data['status']} isSuccess=$isSuccess role=${_user?['role']}");
// //
// //     // IMPORTANT: computed keys go LAST so raw backend fields can't overwrite them
// //     return {
// //       ...data,
// //       "success": isSuccess,
// //       "message": data['message'] ?? (isSuccess ? "Login successful" : "Login failed"),
// //     };
// //   }
//   Future<Map<String, dynamic>> karyakartaLogin(String username, String password) async {
//     final cleanUser = username.trim();
//     final cleanPass = password.trim();
//
//     try {
//       // Build clean payload: send username/password, and only attach
//       // mobile if numeric or sa_code/karyakarta_code if alphanumeric.
//       final Map<String, dynamic> bodyData = {
//         "username": cleanUser,
//         "password": cleanPass,
//       };
//
//       if (RegExp(r'^[0-9]{10}$').hasMatch(cleanUser)) {
//         bodyData["mobile"] = cleanUser;
//       } else {
//         bodyData["karyakarta_code"] = cleanUser;
//         bodyData["sa_code"] = cleanUser;
//       }
//
//       final res = await http.post(
//         Uri.parse(ApiConfig.karyakartaLogin),
//         headers: ApiConfig.headers(),
//         body: jsonEncode(bodyData),
//       );
//
//       final data = _handle(res);
//       final isSuccess = data['status'] == 'success' || data['success'] == true;
//
//       if (isSuccess && data['data'] != null) {
//         final userData = Map<String, dynamic>.from(data['data']);
//         userData['role'] ??= 'karyakarta';
//
//         final token = userData['token'] ?? data['token'];
//         if (token != null) {
//           await setToken(token.toString());
//         }
//         await _setUser(userData);
//
//         // Populate session for Dashboard
//         KaryakartaSession.saCode = (userData['karyakarta_code'] ?? userData['sa_code'] ?? cleanUser).toString();
//         KaryakartaSession.fullName = (userData['full_name'] ?? userData['name'] ?? 'Karyakarta').toString();
//         KaryakartaSession.mobile = (userData['mobile'] ?? userData['phone'] ?? '').toString();
//         KaryakartaSession.village = (userData['village'] ?? userData['working_area'] ?? '').toString();
//         final photoDoc = (userData['photo_doc'] ?? '').toString();
//         KaryakartaSession.photoUrl = photoDoc.isNotEmpty ? ApiConfig.bannerImageUrl(photoDoc) : '';
//       }
//
//       debugPrint("🟠 KARYAKARTA LOGIN → status=${data['status']} isSuccess=$isSuccess role=${_user?['role']}");
//
//       return {
//         ...data,
//         "success": isSuccess,
//         "message": data['message'] ?? (isSuccess ? "Login successful" : "Invalid karyakarta credentials"),
//       };
//     } catch (e) {
//       debugPrint("🔴 karyakartaLogin error: $e");
//       return {"success": false, "message": "Login error: $e"};
//     }
//   }
//
//       final data = _handle(res);
//       final isSuccess = data['status'] == 'success' || data['success'] == true;
//
//       if (isSuccess && data['data'] != null) {
//         final userData = Map<String, dynamic>.from(data['data']);
//         userData['role'] ??= 'karyakarta';
//
//         final token = userData['token'] ?? data['token'];
//         if (token != null) {
//           await setToken(token.toString());
//         }
//         await _setUser(userData);
//
//         // Populate session for Dashboard
//         KaryakartaSession.saCode = (userData['karyakarta_code'] ?? userData['sa_code'] ?? cleanUser).toString();
//         KaryakartaSession.fullName = (userData['full_name'] ?? userData['name'] ?? 'Karyakarta').toString();
//         KaryakartaSession.mobile = (userData['mobile'] ?? userData['phone'] ?? '').toString();
//         KaryakartaSession.village = (userData['village'] ?? userData['working_area'] ?? '').toString();
//         final photoDoc = (userData['photo_doc'] ?? '').toString();
//         KaryakartaSession.photoUrl = photoDoc.isNotEmpty ? ApiConfig.bannerImageUrl(photoDoc) : '';
//       }
//
//       debugPrint("🟠 KARYAKARTA LOGIN → status=${data['status']} isSuccess=$isSuccess role=${_user?['role']}");
//
//       return {
//         ...data,
//         "success": isSuccess,
//         "message": data['message'] ?? (isSuccess ? "Login successful" : "Invalid karyakarta credentials"),
//       };
//     } catch (e) {
//       debugPrint("🔴 karyakartaLogin error: $e");
//       return {"success": false, "message": "Login error: $e"};
//     }
//   }
//   // ---------------- MEMBER (self-service) ----------------
//
//   Future<Map<String, dynamic>> memberLogin(String username, String password) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.memberLogin),
//       headers: ApiConfig.headers(),
//       body: jsonEncode({"username": username, "password": password}),
//     );
//     final data = _handle(res);
//
//     final isSuccess = data['status'] == 'success';
//     if (isSuccess && data['data'] != null) {
//       final userData = Map<String, dynamic>.from(data['data']);
//       userData['role'] = (userData['role'] ?? 'member').toString();
//       if (userData['token'] != null) {
//         await setToken(userData['token']);
//       }
//       await _setUser(userData);
//     }
//
//     debugPrint("🟣 MEMBER LOGIN → status=${data['status']} isSuccess=$isSuccess role=${_user?['role']}");
//
//     return {
//       ...data,
//       "success": isSuccess,
//       "message": data['message'] ?? (isSuccess ? "Login successful" : "Login failed"),
//     };
//   }
//
//   // GET /api/member/dashboard
//   Future<Map<String, dynamic>> getMemberDashboard() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.memberDashboard),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return {};
//       return Map<String, dynamic>.from(data['data']);
//     } catch (e) {
//       debugPrint("🔴 getMemberDashboard error: $e");
//       return {};
//     }
//   }
//
//   // GET /api/member/profile
//   // Future<Map<String, dynamic>?> getMemberSelfProfile() async {
//   //   try {
//   //     final res = await http.get(
//   //       Uri.parse(ApiConfig.memberProfile),
//   //       headers: ApiConfig.headers(token: _token),
//   //     );
//   //     final data = _handle(res);
//   //     if (data['data'] == null) return null;
//   //     return Map<String, dynamic>.from(data['data']);
//   //   } catch (e) {
//   //     debugPrint("🔴 getMemberSelfProfile error: $e");
//   //     return null;
//   //   }
//   // }
//   //
//   // // GET /api/member/schemes — used as the member's "enrollments" list
//   // Future<List<Map<String, dynamic>>> getMemberSchemes() async {
//   Future<Map<String, dynamic>?> getMemberSelfProfile() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.memberProfile),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final raw = data['data'] ?? data;
//       if (raw == null || (raw is Map && raw.isEmpty)) return null;
//       final profile = Map<String, dynamic>.from(raw);
//       // Normalize gotra, state, district, taluka, village with database join fallbacks
//       profile['gotra'] = profile['gotra'] ?? profile['gotra_name'];
//       profile['state'] = profile['state'] ?? profile['state_name'];
//       profile['district'] = profile['district'] ?? profile['district_name'];
//       profile['taluka'] = profile['taluka'] ?? profile['taluka_name'] ?? profile['tehsil'];
//       profile['village'] = profile['village'] ?? profile['village_name'];
//       profile['address'] = profile['address'] ?? profile['full_address'];
//       return profile;
//     } catch (e) {
//       debugPrint("🔴 getMemberSelfProfile error: $e");
//       return null;
//     }
//   }
//
// // PUT /api/member/profile — member updates alt mobile, address, and/or password
//   Future<Map<String, dynamic>> updateMemberProfile({
//     String? altMobile,
//     String? address,
//     String? password,
//   }) async {
//     try {
//       final body = <String, dynamic>{
//         if (altMobile != null && altMobile.trim().isNotEmpty) "alt_mobile": altMobile.trim(),
//         if (address != null && address.trim().isNotEmpty) "address": address.trim(),
//         if (password != null && password.isNotEmpty) "password": password,
//       };
//       final res = await http.put(
//         Uri.parse(ApiConfig.memberProfile),
//         headers: ApiConfig.headers(token: _token),
//         body: jsonEncode(body),
//       );
//       final data = _handle(res);
//       return {
//         "success": data['status'] == 'success' || data['success'] == true,
//         "message": data['message'] ??
//             (data['status'] == 'success' ? 'Profile updated successfully' : 'Failed to update profile'),
//         ...data,
//       };
//     } catch (e) {
//       return {"success": false, "message": "Update failed: $e"};
//     }
//   }
//
//   // GET /api/member/schemes — used as the member's "enrollments" list
//   Future<List<Map<String, dynamic>>> getMemberSchemes() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.memberSchemes),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getMemberSchemes error: $e");
//       return [];
//     }
//   }
//   Future<List<Map<String, dynamic>>> getMemberEnrollments() => getMemberSchemes();
//
//   // No single-scheme endpoint was provided, so we find it from the full list.
//   Future<Map<String, dynamic>?> getMemberEnrollmentById(String id) async {
//     final list = await getMemberSchemes();
//     try {
//       return list.firstWhere((e) => e['id'].toString() == id);
//     } catch (_) {
//       return null;
//     }
//   }
//
//   // GET /api/member/payments
//   Future<Map<String, dynamic>> getMemberPayments() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.memberPayments),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return {"receipts": [], "pending_dues_amount": 0};
//       return Map<String, dynamic>.from(data['data']);
//     } catch (e) {
//       debugPrint("🔴 getMemberPayments error: $e");
//       return {"receipts": [], "pending_dues_amount": 0};
//     }
//   }
//   Future<List<Map<String, dynamic>>> getMemberCollections() async {
//     final payments = await getMemberPayments();
//     final receipts = (payments['receipts'] as List?) ?? [];
//     return receipts.map((r) {
//       final m = Map<String, dynamic>.from(r);
//       m['collection_date'] = m['created_at'];
//       return m;
//     }).toList();
//   }
//   Future<Map<String, dynamic>> createMemberCollection(Map<String, dynamic> payload) async {
//     return {"success": false, "message": "Not available for member accounts."};
//   }
//
//   // GET /api/member/claims
//   Future<List<Map<String, dynamic>>> getMemberClaims() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.memberClaims),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getMemberClaims error: $e");
//       return [];
//     }
//   }
//
//   // POST /api/member/claims (multipart — supports an optional proof-of-event file)
//   Future<Map<String, dynamic>> submitMemberClaim(
//       Map<String, dynamic> payload, {
//         PlatformFile? proofFile,
//       }) async {
// void _attachAuthHeaders(http.MultipartRequest request) {
// request.headers["Accept"] = "application/json";
// if (_token != null && _token!.isNotEmpty) {
// request.headers["Authorization"] = "Bearer $_token";
// request.headers["X-API-Token"] = _token!;
// }
// }
//
//     payload.forEach((key, value) {
//       if (value != null) request.fields[key] = value.toString();
//     });
//
//     if (proofFile != null) {
//       if (proofFile.bytes != null) {
//         request.files.add(http.MultipartFile.fromBytes('proof_doc', proofFile.bytes!, filename: proofFile.name));
//       } else if (proofFile.path != null) {
//         request.files.add(await http.MultipartFile.fromPath('proof_doc', proofFile.path!, filename: proofFile.name));
//       }
//     }
//
//     final streamed = await request.send();
//     final res = await http.Response.fromStream(streamed);
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Claim submitted successfully' : 'Failed to submit claim'),
//       ...data,
//     };
//   }
//
//   // No single-claim endpoint was provided, so we find it from the full list.
//   Future<Map<String, dynamic>?> getMemberClaimById(String id) async {
//     final list = await getMemberClaims();
//     try {
//       return list.firstWhere((c) => c['id'].toString() == id);
//     } catch (_) {
//       return null;
//     }
//   }
//
//   // GET /api/member/notifications
//   Future<List<Map<String, dynamic>>> getMemberNotifications() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.memberNotifications),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getMemberNotifications error: $e");
//       return [];
//     }
//   }
//   Future<List<Map<String, dynamic>>> getMemberMembers() async => [];
//
//   Future<Map<String, dynamic>?> getMemberPvcCard(String memberId) async => null;
//
//   // No commission endpoint for members (commission belongs to karyakartas).
//   Future<List<Map<String, dynamic>>> getMemberCommissions() async => [];
//   // ---------------- MEMBERS ----------------
//
//   Future<Map<String, dynamic>> createMember(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.members),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<List<MemberModel>> getMembers() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.members),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return list.map((e) => MemberModel.fromJson(Map<String, dynamic>.from(e))).toList();
//     } catch (_) {
//       return [];
//     }
//   }
//
//   Future<MemberModel?> getMemberById(String id) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.memberById(id)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       return MemberModel.fromJson(Map<String, dynamic>.from(data['data']));
//     } catch (_) {
//       return null;
//     }
//   }
//
//   Future<List<MemberModel>> searchMembers(String query) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.memberSearch(query)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return list.map((e) => MemberModel.fromJson(Map<String, dynamic>.from(e))).toList();
//     } catch (_) {
//       return [];
//     }
//   }
//
//   Future<Map<String, dynamic>> updateMember(String id, Map<String, dynamic> payload) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.memberById(id)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> toggleMemberStatus(String id, String status) async {
//     final res = await http.patch(
//       Uri.parse(ApiConfig.memberStatus(id)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"status": status}),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> deleteMember(String id) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.memberById(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   // ---------------- ENROLLMENTS ----------------
//
//   Future<Map<String, dynamic>> createEnrollment(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.enrollments),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<List<EnrollmentModel>> getEnrollments() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.enrollments),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return list.map((e) => EnrollmentModel.fromJson(Map<String, dynamic>.from(e))).toList();
//     } catch (_) {
//       return [];
//     }
//   }
//
//   Future<EnrollmentModel?> getEnrollmentById(String id) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.enrollmentById(id)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       return EnrollmentModel.fromJson(Map<String, dynamic>.from(data['data']));
//     } catch (_) {
//       return null;
//     }
//   }
//
//   Future<Map<String, dynamic>> approveEnrollment(String id) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.approveEnrollment(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> rejectEnrollment(String id, String reason) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.rejectEnrollment(id)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"rejection_reason": reason}),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> deleteEnrollment(String id) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.enrollmentById(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//   // ---------------- ENROLLMENTS -----------
//   // NEW — fetches enrollments for the logged-in karyakarta (real API, not mock)
//   Future<List<Map<String, dynamic>>> getKaryakartaEnrollments() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaEnrollments),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaEnrollments error: $e");
//       return [];
//     }
//   }
//   Future<Map<String, dynamic>?> getKaryakartaEnrollmentById(String id) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaEnrollmentById(id)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       return Map<String, dynamic>.from(data['data']);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaEnrollmentById error: $e");
//       return null;
//     }
//   }
//   Future<List<Map<String, dynamic>>> getMembersRaw() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.members),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getMembersRaw error: $e");
//       return [];
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getSchemesRaw() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.schemes),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getSchemesRaw error: $e");
//       return [];
//     }
//   }
//   // NEW — fetches dashboard summary for the logged-in karyakarta (Home tab)
//   Future<Map<String, dynamic>> getKaryakartaDashboard() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaDashboard),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return {};
//       return Map<String, dynamic>.from(data['data']);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaDashboard error: $e");
//       return {};
//     }
//   }
//
//   // NEW — GET /api/karyakarta/profile (logged-in karyakarta's own profile)
//   Future<Map<String, dynamic>?> getKaryakartaSelfProfile() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaSelfProfile),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       return Map<String, dynamic>.from(data['data']);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaSelfProfile error: $e");
//       return null;
//     }
//   }
//
//   // NEW — PUT /api/karyakarta/profile (updates profile details)
//   Future<Map<String, dynamic>> updateKaryakartaSelfProfile({
//     String? altMobile,
//     String? fullAddress,
//     String? password,
//   }) async {
//     try {
//       final body = <String, dynamic>{
//         if (altMobile != null && altMobile.trim().isNotEmpty) "alt_mobile": altMobile.trim(),
//         if (fullAddress != null && fullAddress.trim().isNotEmpty) "full_address": fullAddress.trim(),
//         if (password != null && password.isNotEmpty) "password": password,
//       };
//
//       final res = await http.put(
//         Uri.parse(ApiConfig.karyakartaSelfProfile),
//         headers: ApiConfig.headers(token: _token),
//         body: jsonEncode(body),
//       );
//       final data = _handle(res);
//       return {
//         "success": data['status'] == 'success' || data['success'] == true,
//         "message": data['message'] ??
//             (data['status'] == 'success' ? 'Profile updated successfully' : 'Failed to update profile'),
//         ...data,
//       };
//     } catch (e) {
//       debugPrint("🔴 updateKaryakartaSelfProfile error: $e");
//       return {"success": false, "message": "Update failed: $e"};
//     }
//   }
//
//   // NEW — GET /api/karyakarta/members (members registered by this karyakarta)
//   Future<List<Map<String, dynamic>>> getKaryakartaMembers() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaMembers),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaMembers error: $e");
//       return [];
//     }
//   }
//
//   // NEW — GET /api/karyakarta/members/{member_id}/pvc-card
//   Future<Map<String, dynamic>?> getKaryakartaMemberPvcCard(String memberId) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaMemberPvcCard(memberId)),
//         // Uri.parse(ApiConfig.karyakartaMemberPvcCard(memberId, _token)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       return Map<String, dynamic>.from(data['data']);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaMemberPvcCard error: $e");
//       return null;
//     }
//   }
//
//   // NEW — POST /api/karyakarta/members (create a member under this karyakarta)
//   Future<Map<String, dynamic>> createKaryakartaMember(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.karyakartaMembers),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Member created successfully' : 'Failed to create member'),
//       ...data,
//     };
//   }
//   // NEW — member self-enrollment (POST /api/member/schemes).
// // CONFIRM the exact path/payload shape with backend before relying on this.
//   Future<Map<String, dynamic>> submitMemberEnrollment(
//       Map<String, dynamic> payload, {
//         PlatformFile? fatherDocFile,
//         PlatformFile? authFile,
//         PlatformFile? docFile,
//         PlatformFile? photoFile,
//       }) async {
//     final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.memberSchemes));
//     if (_token != null) request.headers["X-API-Token"] = _token!;
//     request.headers["Accept"] = "application/json";
//
//     payload.forEach((key, value) {
//       if (value != null) request.fields[key] = value.toString();
//     });
//
//     Future<void> attach(String field, PlatformFile? file) async {
//       if (file == null) return;
//       if (file.bytes != null) {
//         request.files.add(http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
//       } else if (file.path != null) {
//         request.files.add(await http.MultipartFile.fromPath(field, file.path!, filename: file.name));
//       }
//     }
//
//     await attach('father_doc_file', fatherDocFile);
//     await attach('auth_file', authFile);
//     await attach('doc_file', docFile);
//     await attach('photo_file', photoFile);
//
//     final streamed = await request.send();
//     final res = await http.Response.fromStream(streamed);
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ?? (data['status'] == 'success' ? 'Proposal submitted' : 'Failed to submit proposal'),
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> createKaryakartaEnrollment({
//     required int memberId,
//     required int schemeId,
//     required double joiningFeePaid,
//     required String paymentMode,
//     required String nomineeName, // NEW
//     String? nomineeRelation, // NEW — optional
//     PlatformFile? fatherDocFile,
//     PlatformFile? authFile,
//     PlatformFile? docFile,
//     PlatformFile? photoFile,
//   }) async {
//     final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.karyakartaEnrollments));
//
//     if (_token != null) request.headers["X-API-Token"] = _token!;
//     request.headers["Accept"] = "application/json";
//
//     request.fields['member_id'] = memberId.toString();
//     request.fields['scheme_id'] = schemeId.toString();
//     request.fields['joining_fee_paid'] = joiningFeePaid.toString();
//     request.fields['payment_mode'] = paymentMode;
//     request.fields['nominee_name'] = nomineeName; // NEW
//     if (nomineeRelation != null && nomineeRelation.trim().isNotEmpty) {
//       request.fields['nominee_relation'] = nomineeRelation; // NEW
//     }
//
//     Future<void> attach(String field, PlatformFile? file) async {
//       if (file == null) return;
//       if (file.bytes != null) {
//         request.files.add(http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
//       } else if (file.path != null) {
//         request.files.add(await http.MultipartFile.fromPath(field, file.path!, filename: file.name));
//       }
//     }
//
//     await attach('father_doc_file', fatherDocFile);
//     await attach('auth_file', authFile);
//     await attach('doc_file', docFile);
//     await attach('photo_file', photoFile);
//
//     final streamed = await request.send();
//     final res = await http.Response.fromStream(streamed);
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ?? (data['status'] == 'success' ? 'Enrollment created successfully' : 'Failed to create enrollment'),
//       ...data,
//     };
//   }
//   // NEW — multipart version of createKaryakartaMember(), for screens that
// // also attach passport photo / govt ID / auth letter files. Posts to the
// // karyakarta-scoped endpoint so the backend correctly derives karyakarta_id
// // from the auth token — same endpoint createKaryakartaMember() uses, just
// // as multipart instead of JSON.
//   Future<Map<String, dynamic>> createKaryakartaMemberWithFiles(
//       Map<String, dynamic> payload, {
//         PlatformFile? passportPhoto,
//         PlatformFile? govtIdProof,
//         PlatformFile? authConsentLetter,
//       }) async {
//     final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.karyakartaMembers));
//
//     if (_token != null) request.headers["X-API-Token"] = _token!;
//     request.headers["Accept"] = "application/json";
//
//     payload.forEach((key, value) {
//       if (value != null) request.fields[key] = value.toString();
//     });
//
//     Future<void> attach(String field, PlatformFile? file) async {
//       if (file == null) return;
//       if (file.bytes != null) {
//         request.files.add(http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
//       } else if (file.path != null) {
//         request.files.add(await http.MultipartFile.fromPath(field, file.path!, filename: file.name));
//       }
//     }
//
//     await attach('passport_photo', passportPhoto);
//     await attach('govt_id_proof', govtIdProof);
//     await attach('auth_consent_letter', authConsentLetter);
//
//     final streamed = await request.send();
//     final res = await http.Response.fromStream(streamed);
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Member created successfully' : 'Failed to create member'),
//       ...data,
//     };
//   }
//
//   // ---------------- PROPOSALS ----------------
//
//   Future<List<ProposalModel>> getProposals({String? status}) async {
//     try {
//       final uri = Uri.parse(ApiConfig.membershipProposals).replace(
//         queryParameters: status != null ? {"status": status} : null,
//       );
//       final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return list.map((e) => ProposalModel.fromJson(e)).toList();
//     } catch (e) {
//       debugPrint("🔴 getProposals error: $e");
//       return [];
//     }
//   }
//
//   Future<void> approveProposal(String proposalNo) async {
//     try {
//       final res = await http.post(
//         Uri.parse(ApiConfig.approveProposal(proposalNo)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       _handle(res);
//     } catch (_) {
//       // no-op in dummy mode — pretend it succeeded
//     }
//   }
//
//   Future<void> rejectProposal(String proposalNo) async {
//     try {
//       final res = await http.post(
//         Uri.parse(ApiConfig.rejectProposal(proposalNo)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       _handle(res);
//     } catch (_) {
//       // no-op in dummy mode
//     }
//   }
//   // NEW — POST /api/karyakarta/claims
//   Future<Map<String, dynamic>> submitKaryakartaClaim(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.karyakartaClaims),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Claim submitted successfully' : 'Failed to submit claim'),
//       ...data,
//     };
//   }
//   // NEW — GET /api/karyakarta/claims (list)
//   Future<List<Map<String, dynamic>>> getKaryakartaClaims() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaClaims),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaClaims error: $e");
//       return [];
//     }
//   }
//   Future<Map<String, dynamic>?> getKaryakartaClaimById(String id) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaClaimById(id)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final raw = data['data'];
//       if (raw == null) return null;
//       if (raw is List) {
//         if (raw.isEmpty) return null;
//         return Map<String, dynamic>.from(raw.first);
//       }
//       return Map<String, dynamic>.from(raw);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaClaimById error: $e");
//       return null;
//     }
//   }
//
//   // NEW — POST /api/karyakarta/collections
//   Future<Map<String, dynamic>> createKaryakartaCollection(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.karyakartaCollections),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Collection recorded successfully' : 'Failed to record collection'),
//       ...data,
//     };
//   }
//
//   // NEW — GET /api/karyakarta/collections
//   Future<List<Map<String, dynamic>>> getKaryakartaCollections() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaCollections),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaCollections error: $e");
//       return [];
//     }
//   }
//
//   // NEW — GET /api/karyakarta/commissions
//   Future<List<Map<String, dynamic>>> getKaryakartaCommissions() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaCommissions),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaCommissions error: $e");
//       return [];
//     }
//   }
//
//   // ---------------- KARYAKARTA NOTIFICATIONS ----------------
//
//   // NEW — GET /api/karyakarta/notifications
//   Future<List<Map<String, dynamic>>> getKaryakartaNotifications() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaNotifications),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaNotifications error: $e");
//       return [];
//     }
//   }
//   // ---------------- TRANSACTIONS / LEDGER (NEW) ----------------
//
//   Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.transactions),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Transaction recorded' : 'Failed to record transaction'),
//       ...data,
//     };
//   }
//   Future<Map<String, dynamic>> addState(String name) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.states),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"name": name}),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//
//   Future<Map<String, dynamic>> addDistrict(String stateId, String name) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.addDistrict),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"state_id": stateId, "name": name}),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//
//   Future<Map<String, dynamic>> addTaluka(String districtId, String name) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.addTaluka),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"district_id": districtId, "name": name}),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//   /// Single call for the Account Manage screen — returns both the summary
//   /// cards (stats) and the ledger table (transactions) in one response,
//   /// matching GET /api/accounting/ledger.
//   Future<Map<String, dynamic>> getLedger({
//     String? entryType,       // 'credit' | 'debit' — null = All Entries
//     String? category,        // maps to "All Heads" filter
//     String? karyakartaSaCode,// maps to "All Karyakartas" filter
//     String? dateFrom,        // yyyy-MM-dd
//     String? dateTo,          // yyyy-MM-dd
//     String? search,          // txn no / party / head search box
//     int limit = 100,
//   }) async {
//     try {
//       final uri = Uri.parse(ApiConfig.accountingLedger).replace(queryParameters: {
//         if (entryType != null) "entry_type": entryType,
//         if (category != null) "category": category,
//         if (karyakartaSaCode != null) "sa_code": karyakartaSaCode,
//         if (dateFrom != null) "date_from": dateFrom,
//         if (dateTo != null) "date_to": dateTo,
//         if (search != null && search.isNotEmpty) "search": search,
//         "limit": limit.toString(),
//       });
//       final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
//       final data = _handle(res);
//       final payload = Map<String, dynamic>.from(data['data'] ?? {});
//       final stats = Map<String, dynamic>.from(payload['stats'] ?? {});
//       final txns = List<Map<String, dynamic>>.from(payload['transactions'] ?? []);
//       return {"stats": stats, "transactions": txns};
//     } catch (e) {
//       debugPrint("🔴 getLedger error: $e");
//       return {"stats": <String, dynamic>{}, "transactions": <Map<String, dynamic>>[]};
//     }
//   }
//
//   Future<Map<String, dynamic>> deleteTransaction(String id) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.transactionById(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>?> getOrganizationProfile() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.organizationProfile),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       return Map<String, dynamic>.from(data['data']);
//     } catch (e) {
//       debugPrint("🔴 getOrganizationProfile error: $e");
//       return null;
//     }
//   }
//
//   Future<Map<String, dynamic>> updateOrganizationProfile(Map<String, dynamic> payload) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.organizationProfile),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ?? (data['status'] == 'success' ? 'Profile updated' : 'Failed to update profile'),
//       ...data,
//     };
//   }
//
//   // Future<List<Map<String, dynamic>>> getDistricts(String stateId) async {
//   //   try {
//   //     final res = await http.get(
//   //       Uri.parse(ApiConfig.districtsByState(stateId)), // was ApiConfig.districts(stateId)
//   //       headers: ApiConfig.headers(token: _token),
//   //     );
//   //     final data = _handle(res);
//   //     final list = (data['data'] as List?) ?? [];
//   //     return List<Map<String, dynamic>>.from(list);
//   //   } catch (_) {
//   //     return [];
//   //   }
//   // }
//   //
//   // Future<List<Map<String, dynamic>>> getTalukas(String districtId) async {
//   //   try {
//   //     final res = await http.get(
//   //       Uri.parse(ApiConfig.talukasByDistrict(districtId)), // was ApiConfig.talukas(districtId)
//   //       headers: ApiConfig.headers(token: _token),
//   //     );
//   //     final data = _handle(res);
//   //     final list = (data['data'] as List?) ?? [];
//   //     return List<Map<String, dynamic>>.from(list);
//   //   } catch (_) {
//   //     return [];
//   //   }
//   // }
//   Future<Map<String, dynamic>> addGotra(String nameEn, String nameHi) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.gotra),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"name_en": nameEn, "name_hi": nameHi}),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//
//   Future<Map<String, dynamic>> updateGotra(String id, String nameEn, String nameHi) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.gotraById(id)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"name_en": nameEn, "name_hi": nameHi}),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//
//   Future<Map<String, dynamic>> deleteGotra(String id) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.gotraById(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//
//   Future<Map<String, dynamic>> addSchemeSlab(String schemeId, Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.schemeSlabs(schemeId)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//
//   Future<Map<String, dynamic>> deleteSchemeSlab(String slabId) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.schemeSlabById(slabId)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//
//   // ---------------- BANK ACCOUNTS (NEW) ----------------
//
//   Future<List<Map<String, dynamic>>> getBankAccounts({String? status}) async {
//     try {
//       final uri = Uri.parse(ApiConfig.bankAccounts).replace(
//         queryParameters: status != null ? {"status": status} : null,
//       );
//       final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getBankAccounts error: $e");
//       return [];
//     }
//   }
//
//   Future<Map<String, dynamic>> createBankAccount(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.bankAccounts),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   // ---------------- COMMISSION PAYOUTS (NEW) ----------------
//
//   Future<Map<String, dynamic>> createCommissionPayout(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.commissionPayouts),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Commission payout created' : 'Failed to create payout'),
//       ...data,
//     };
//   }
//
//   Future<List<Map<String, dynamic>>> getCommissionPayouts({
//     String? status,
//     String? karyakartaId,
//     String? dateFrom,
//     String? dateTo,
//   }) async {
//     try {
//       final uri = Uri.parse(ApiConfig.commissionPayouts).replace(queryParameters: {
//         if (status != null) "status": status,
//         if (karyakartaId != null) "karyakarta_id": karyakartaId,
//         if (dateFrom != null) "date_from": dateFrom,
//         if (dateTo != null) "date_to": dateTo,
//       });
//       final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getCommissionPayouts error: $e");
//       return [];
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getCommissionRules() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.commissionRules),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getCommissionRules error: $e");
//       return [];
//     }
//   }
//
//   Future<Map<String, dynamic>> addCommissionRule(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.commissionRules),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ?? (data['status'] == 'success' ? 'Commission rule saved' : 'Failed to save rule'),
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> deleteCommissionRule(String id) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.commissionRuleById(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//
//   Future<Map<String, dynamic>> addBanner(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.banners),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//
//   Future<Map<String, dynamic>> deleteBanner(String id) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.bannerById(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {"success": data['status'] == 'success' || data['success'] == true, "message": data['message'], ...data};
//   }
//
//   // ---------------- KARYAKARTA COMMISSION SUMMARY (NEW) ----------------
//   Future<List<Map<String, dynamic>>> getKaryakartaCommissionsSummary({
//     String? dateFrom,
//     String? dateTo,
//   }) async {
//     if (roleName != 'karyakarta') {
//       debugPrint("ℹ️ getKaryakartaCommissionsSummary skipped — no admin endpoint exists for this role ($roleName)");
//       return [];
//     }
//     try {
//       final uri = Uri.parse(ApiConfig.karyakartaCommissionsSummary).replace(queryParameters: {
//         if (dateFrom != null) "date_from": dateFrom,
//         if (dateTo != null) "date_to": dateTo,
//       });
//       final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaCommissionsSummary error: $e");
//       return [];
//     }
//   }
//   // ---------------- CLAIM PAYOUTS (NEW) ----------------
//
//   Future<List<Map<String, dynamic>>> getClaimPayouts({
//     String? dateFrom,
//     String? dateTo,
//   }) async {
//     try {
//       final uri = Uri.parse(ApiConfig.claimPayouts).replace(queryParameters: {
//         if (dateFrom != null) "date_from": dateFrom,
//         if (dateTo != null) "date_to": dateTo,
//       });
//       final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getClaimPayouts error: $e");
//       return [];
//     }
//   }
//
//   Future<Map<String, dynamic>> createClaimPayout(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.claimPayouts),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Claim payout created' : 'Failed to create claim payout'),
//       ...data,
//     };
//   }
//
//   // ---------------- GENERIC PAYMENTS (NEW — dashboard "Make Payment" button) ----------------
//
//   Future<Map<String, dynamic>> createPayment(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.payments),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'] ??
//           (data['status'] == 'success' ? 'Payment recorded' : 'Failed to record payment'),
//       ...data,
//     };
//   }
//
//   // ---------------- COMMISSION REPORT (NEW) ----------------
//
//   Future<List<Map<String, dynamic>>> getCommissionReport({
//     String? dateFrom,
//     String? dateTo,
//   }) async {
//     try {
//       final uri = Uri.parse(ApiConfig.commissionReport).replace(queryParameters: {
//         if (dateFrom != null) "date_from": dateFrom,
//         if (dateTo != null) "date_to": dateTo,
//       });
//       final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getCommissionReport error: $e");
//       return [];
//     }
//   }
//
//   // ---------------- BANNERS ----------------
//
// // NEW — GET /api/banners
//   Future<List<Map<String, dynamic>>> getBanners() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.banners),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (e) {
//       debugPrint("🔴 getBanners error: $e");
//       return [];
//     }
//   }
//
//   // ---------------- SCHEMES ----------------
//
//   Future<List<SchemeModel>> getSchemes() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.schemes),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return list.map((e) => SchemeModel.fromJson(Map<String, dynamic>.from(e))).toList();
//     } catch (_) {
//       return [];
//     }
//   }
//
//   Future<Map<String, dynamic>> createScheme(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.schemes),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> updateScheme(String schemeId, Map<String, dynamic> payload) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.schemeById(schemeId)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<List<Map<String, dynamic>>> getSchemeSlabs(String schemeId) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.schemeSlabs(schemeId)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return List<Map<String, dynamic>>.from(list);
//     } catch (_) {
//       return [];
//     }
//   }
//
//   Future<Map<String, dynamic>> calculateSlab(String dob, int schemeId) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.calculateSlab),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"dob": dob, "scheme_id": schemeId}),
//     );
//     return _handle(res);
//   }
//
//   // ---------------- CLAIMS ----------------
//
//   Future<Map<String, dynamic>> submitClaim(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.claims),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<List<ClaimModel>> getClaims() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.claims),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return list.map((e) => ClaimModel.fromJson(Map<String, dynamic>.from(e))).toList();
//     } catch (_) {
//       return [];
//     }
//   }
//
//   Future<ClaimModel?> getClaimById(String id) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.claimById(id)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       return ClaimModel.fromJson(Map<String, dynamic>.from(data['data']));
//     } catch (_) {
//       return null;
//     }
//   }
//
//   Future<Map<String, dynamic>> approveClaim(String id,
//       {required double approvedAmount, String? remarks}) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.approveClaim(id)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({
//         "approved_amount": approvedAmount,
//         if (remarks != null) "remarks": remarks,
//       }),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> rejectClaim(String id, String reason) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.rejectClaim(id)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"rejection_reason": reason}),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> deleteClaim(String id) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.claimById(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   // ---------------- RECEIPTS ----------------
//
//   Future<Map<String, dynamic>> createReceipt(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.receipts),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<List<ReceiptModel>> getReceipts() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.receipts),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return list.map((e) => ReceiptModel.fromJson(Map<String, dynamic>.from(e))).toList();
//     } catch (_) {
//       return [];
//     }
//   }
//
//   Future<ReceiptModel?> getReceiptById(String id) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.receiptById(id)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       return ReceiptModel.fromJson(Map<String, dynamic>.from(data['data']));
//     } catch (_) {
//       return null;
//     }
//   }
//
//   Future<Map<String, dynamic>> deleteReceipt(String id) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.receiptById(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   // ---------------- CONTRIBUTION BATCHES ----------------
//
//   Future<Map<String, dynamic>> createContributionBatch(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.contributionBatches),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<List<ContributionBatchModel>> getContributionBatches() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.contributionBatches),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return list
//           .map((e) => ContributionBatchModel.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//     } catch (_) {
//       return [];
//     }
//   }
//
//   Future<ContributionBatchModel?> getContributionBatchById(String id) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.contributionBatchById(id)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       return ContributionBatchModel.fromJson(Map<String, dynamic>.from(data['data']));
//     } catch (_) {
//       return null;
//     }
//   }
//
//   Future<Map<String, dynamic>> settleContributionBatch(String id) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.settleContributionBatch(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   // ---------------- MEMBER CONTRIBUTIONS ----------------
//
//   Future<Map<String, dynamic>> recordMemberContribution(Map<String, dynamic> payload) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.memberContributions),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode(payload),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<List<MemberContributionModel>> getMemberContributions() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.memberContributions),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       final list = (data['data'] as List?) ?? [];
//       return list
//           .map((e) => MemberContributionModel.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//     } catch (_) {
//       return [];
//     }
//   }
//
//   Future<MemberContributionModel?> getMemberContributionById(String id) async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.memberContributionById(id)),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return null;
//       return MemberContributionModel.fromJson(Map<String, dynamic>.from(data['data']));
//     } catch (_) {
//       return null;
//     }
//   }
//
//   Future<Map<String, dynamic>> updateMemberContributionStatus(String id, String status) async {
//     final res = await http.put(
//       Uri.parse(ApiConfig.memberContributionStatus(id)),
//       headers: ApiConfig.headers(token: _token),
//       body: jsonEncode({"status": status}),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   Future<Map<String, dynamic>> deleteMemberContribution(String id) async {
//     final res = await http.delete(
//       Uri.parse(ApiConfig.memberContributionById(id)),
//       headers: ApiConfig.headers(token: _token),
//     );
//     final data = _handle(res);
//     return {
//       "success": data['status'] == 'success' || data['success'] == true,
//       "message": data['message'],
//       ...data,
//     };
//   }
//
//   // ---------------- MASTERS ----------------
//
//   // Future<List<Map<String, dynamic>>> getGotras() async {
//   //   try {
//   //     final res = await http.get(
//   //       Uri.parse(ApiConfig.gotra),
//   //       headers: ApiConfig.headers(token: _token),
//   //     );
//   //     final data = _handle(res);
//   //     final list = (data['data'] as List?) ?? [];
//   //     return List<Map<String, dynamic>>.from(list);
//   //   } catch (_) {
//   //     return [];
//   //   }
//   // }
//   //
//   // Future<List<Map<String, dynamic>>> getStates() async {
//   //   try {
//   //     final res = await http.get(
//   //       Uri.parse(ApiConfig.states),
//   //       headers: ApiConfig.headers(token: _token),
//   //     );
//   //     final data = _handle(res);
//   //     final list = (data['data'] as List?) ?? [];
//   //     return List<Map<String, dynamic>>.from(list);
//   //   } catch (_) {
//   //     return [];
//   //   }
//   // }
//   // NEW — GET /api/karyakarta/collections-summary (stats for the Collections tab)
//   Future<Map<String, dynamic>> getKaryakartaCollectionsSummary() async {
//     try {
//       final res = await http.get(
//         Uri.parse(ApiConfig.karyakartaCollectionsSummary),
//         headers: ApiConfig.headers(token: _token),
//       );
//       final data = _handle(res);
//       if (data['data'] == null) return {};
//       return Map<String, dynamic>.from(data['data']);
//     } catch (e) {
//       debugPrint("🔴 getKaryakartaCollectionsSummary error: $e");
//       return {};
//     }
//   }
//   // ---------------- helpers ----------------
//   // Map<String, dynamic> _handle(http.Response res) {
//   //   debugPrint("API ${res.request?.url} -> ${res.statusCode}: ${res.body}"); // TEMP debug
//   //
//   //   Map<String, dynamic> body = {};
//   Map<String, dynamic> _handle(http.Response res) {
//     if (kDebugMode) {
//       debugPrint("API ${res.request?.url} -> ${res.statusCode}: ${res.body}");
//     }
//
//     Map<String, dynamic> body = {};
//     if (res.body.isNotEmpty) {
//       try {
//         body = jsonDecode(res.body) as Map<String, dynamic>;
//       } catch (_) {
//         // Server didn't return valid JSON (e.g. HTML error page)
//         throw Exception("Server returned invalid response (${res.statusCode})");
//       }
//     }
//
//     if (res.statusCode >= 200 && res.statusCode < 300) {
//       return body;
//     }
//
//     // Non-2xx but valid JSON — let the caller see success:false + message
//     // instead of losing it to an exception.
//     if (body.containsKey('message') || body.containsKey('success')) {
//       return {
//         "success": false,
//         "message": body['message'] ?? "Request failed (${res.statusCode})",
//         ...body,
//       };
//     }
//
//     throw Exception("API error ${res.statusCode}: ${res.body}");
//   }
// }

import 'dart:async';
import 'dart:convert';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/karyakarta_model.dart';
import '../models/member_model.dart';
import '../models/scheme_model.dart';
import '../utils/api_config.dart';
import '../models/proposal_model.dart';
import '../models/dashboard_stats_model.dart';
import '../models/enrollment_model.dart';
import '../models/claim_model.dart';
import '../models/receipt_model.dart';
import '../models/contribution_batch_model.dart';
import '../models/member_contribution_model.dart';
import 'package:file_picker/file_picker.dart';
import '../models/karyakarta_session.dart';

/// Thin wrapper around http calls. Keep all network logic here so
/// screens stay simple.
class ApiService {
  // ---- Singleton setup ----
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // FIXED: Added timeout configuration
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const Duration _longTimeout = Duration(seconds: 60); // For file uploads

  String? get authToken => _token;

  String? _token;
  Map<String, dynamic>? _user;
  String? _deviceId;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _deviceIdKey = 'device_id';

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    debugPrint(
        "🔑 TOKEN LOADED ON START: ${_token == null ? 'null' : '${_token!.substring(0, 8)}...'}");
    final userJson = prefs.getString(_userKey);
    if (userJson != null) _user = jsonDecode(userJson);
  }

  /// Returns a stable device id, generating and persisting one on first use.
  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_deviceIdKey);
    if (id == null) {
      id =
      'flutter-${DateTime.now().millisecondsSinceEpoch}-${(1000 + (DateTime.now().microsecond % 9000))}';
      await prefs.setString(_deviceIdKey, id);
    }
    _deviceId = id;
    return id;
  }

  Future<void> _setUser(Map<String, dynamic> user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Map<String, dynamic>? get currentUser => _user;
  List<String> get permissions =>
      List<String>.from(_user?['permissions'] ?? const []);
  String? get roleName => _user?['role'] as String?;

  Future<void> setToken(String token) async {
    _token = token;
    debugPrint("🔑 TOKEN SAVED: ${_token!.substring(0, 8)}...");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  bool get isLoggedIn => _token != null;

  /// Helper to attach standardized auth headers to multipart requests
  void _attachAuthHeaders(http.MultipartRequest request) {
    request.headers["Accept"] = "application/json";
    if (_token != null && _token!.isNotEmpty) {
      request.headers["Authorization"] = "Bearer $_token";
      request.headers["X-API-Token"] = _token!;
    }
  }

  /// Calls the backend logout endpoint, then always clears local
  /// session data (token + cached user) — even if the API call fails —
  /// so the user is never stuck "logged in" on the device.
  Future<Map<String, dynamic>> logout() async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.logout),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      return {
        "success": data['status'] == 'success' || data['success'] == true,
        "message": data['message'] ?? 'Logged out successfully',
        ...data,
      };
    } catch (e) {
      return {"success": false, "message": "Logout failed: $e"};
    } finally {
      await clearToken();
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    }
  }

  /// Fetches the logged-in user's own profile from GET /auth/profile
  /// and merges it into the cached `_user` map so `currentUser`,
  /// `roleName`, etc. stay in sync with what the server actually has.
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.profile),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      final profile = Map<String, dynamic>.from(data['data']);
      await _setUser({..._user ?? {}, ...profile});
      return profile;
    } catch (e) {
      debugPrint("🔴 getProfile error: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getKaryakartasRaw() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartas),
        headers: ApiConfig.headers(token: _token),
      ).timeout(_defaultTimeout); // FIXED: Added timeout
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getKaryakartasRaw error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getEnrollmentsRaw() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.enrollments),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getEnrollmentsRaw error: $e");
      return [];
    }
  }


  // ---------------- AUTH ----------------
  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse(ApiConfig.login),
      headers: ApiConfig.headers(),
      body: jsonEncode({"username": username, "password": password}),
    ).timeout(_defaultTimeout); // FIXED: Added timeout
    final data = _handle(res);

    final isSuccess = data['status'] == 'success';
    if (isSuccess && data['data'] != null) {
      final userData = Map<String, dynamic>.from(data['data']);
      userData['role'] = (userData['role'] ?? 'admin').toString();
      if (userData['token'] != null) {
        await setToken(userData['token']);
      }
      await _setUser(userData);
      if (userData['role'] == 'karyakarta') {
        KaryakartaSession.saCode = userData['sa_code']?.toString() ?? '';
        KaryakartaSession.fullName = userData['name']?.toString() ?? 'Karyakarta';
        KaryakartaSession.mobile = userData['mobile']?.toString() ?? '';
        KaryakartaSession.village = userData['village']?.toString() ?? '';
      }
    }

    debugPrint(
        "🟢 LOGIN → status=${data['status']} isSuccess=$isSuccess role=${_user?['role']}");

    return {
      ...data,
      "success": isSuccess,
      "message": data['message'] ?? (isSuccess ? "Login successful" : "Login failed"),
    };
  }

  bool get pinIsSet => _user?['pin_set'] == true;

  Future<Map<String, dynamic>> sendLoginOtp(String username) async {
    final res = await http.post(
      Uri.parse(ApiConfig.sendLoginOtp),
      headers: ApiConfig.headers(),
      body: jsonEncode({"username": username}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> verifyLoginOtp(String username, String otp) async {
    final res = await http.post(
      Uri.parse(ApiConfig.verifyLoginOtp),
      headers: ApiConfig.headers(),
      body: jsonEncode({"phone": username, "otp": otp}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> setPin(String username, String pin) async {
    final res = await http.post(
      Uri.parse(ApiConfig.setPin),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"phone": username, "pin": pin}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> pinLogin(String username, String pin) async {
    final deviceId = await _getDeviceId();
    final res = await http.post(
      Uri.parse(ApiConfig.pinLogin),
      headers: ApiConfig.headers(),
      body: jsonEncode({"phone": username, "pin": pin, "device_id": deviceId}),
    );
    final data = _handle(res);
    if (data['success'] == true && data['token'] != null) {
      await setToken(data['token']);
      if (data['user'] != null) {
        await _setUser(Map<String, dynamic>.from(data['user']));
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> sendForgotPinOtp(String username) async {
    final res = await http.post(
      Uri.parse(ApiConfig.forgotPinSendOtp),
      headers: ApiConfig.headers(),
      body: jsonEncode({"phone": username}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> verifyForgotPinOtp(
      String username, String otp) async {
    final res = await http.post(
      Uri.parse(ApiConfig.forgotPinVerifyOtp),
      headers: ApiConfig.headers(),
      body: jsonEncode({"phone": username, "otp": otp}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> resetPin(String username, String pin) async {
    final res = await http.post(
      Uri.parse(ApiConfig.resetPin),
      headers: ApiConfig.headers(),
      body: jsonEncode({"phone": username, "pin": pin}),
    );
    return _handle(res);
  }

  // ---------------- DASHBOARD ----------------
  Future<DashboardStatsModel> getDashboardStats() async {
    final res = await http.get(
      Uri.parse(ApiConfig.dashboardStats),
      headers: ApiConfig.headers(token: _token),
    ).timeout(_defaultTimeout);
    final data = _handle(res);
    if (data['success'] == false) {
      throw Exception(data['message'] ?? 'Failed to load dashboard');
    }
    return DashboardStatsModel.fromJson(Map<String, dynamic>.from(data['data'] ?? {}));
  }

  // ---------------- PAYMENT MASTER REGISTER ----------------
  Future<List<Map<String, dynamic>>> getMasterRegister({
    String type = 'collection',
    String? category,
  }) async {
    try {
      final uri =
      Uri.parse(ApiConfig.paymentMasterRegister).replace(queryParameters: {
        "type": type,
        if (category != null) "category": category,
      });
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getMasterRegister error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getCollectionsDashboard() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.collectionsDashboard),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return {};
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getCollectionsDashboard error: $e");
      return {};
    }
  }

  // ---------------- CLAIMS (raw) ----------------
  Future<List<Map<String, dynamic>>> getClaimsRaw({String? status}) async {
    try {
      final uri = Uri.parse(ApiConfig.claims).replace(queryParameters: {
        if (status != null && status.isNotEmpty) "status": status,
      });
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getClaimsRaw error: $e");
      return [];
    }
  }

  String? lastShareTokenError;

  Future<String?> getDocumentShareToken({
    required String docType,
    required String recordId,
  }) async {
    lastShareTokenError = null;
    try {
      final res = await http
          .post(
        Uri.parse(ApiConfig.documentShareToken),
        headers: ApiConfig.headers(token: _token),
        body: jsonEncode({"doc_type": docType, "record_id": recordId}),
      )
          .timeout(const Duration(seconds: 20));

      debugPrint(
          "🔑 share_token [$docType/$recordId] → ${res.statusCode}: ${res.body}");

      Map<String, dynamic> body;
      try {
        body = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        lastShareTokenError = res.statusCode == 404
            ? 'share_token.php not found on server (404)'
            : 'Server returned an invalid response (${res.statusCode})';
        return null;
      }

      if (res.statusCode < 200 || res.statusCode >= 300) {
        lastShareTokenError =
            body['message']?.toString() ?? 'Request failed (${res.statusCode})';
        return null;
      }

      final d = body['data'];
      final tok = (d is Map ? d['token'] : null) ?? body['token'];
      if (tok == null || tok.toString().isEmpty) {
        lastShareTokenError = 'Server did not return a token';
        return null;
      }
      return tok.toString();
    } catch (e) {
      debugPrint("🔴 getDocumentShareToken error: $e");
      lastShareTokenError = 'Network error: $e';
      return null;
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic body) {
    dynamic raw = body;
    if (raw is Map) {
      raw = raw['data'] ??
          raw['items'] ??
          raw['result'] ??
          raw['gotras'] ??
          raw['states'] ??
          raw['districts'] ??
          raw['talukas'] ??
          [];
    }
    if (raw is Map) {
      raw = raw['items'] ?? raw['list'] ?? raw['data'] ?? [];
    }
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getMasterList(
      String url, String tag) async {
    try {
      final res =
      await http.get(Uri.parse(url), headers: ApiConfig.headers(token: _token));
      debugPrint("📍 $tag [$url] → ${res.statusCode}: ${res.body}");
      if (res.statusCode < 200 || res.statusCode >= 300) return [];
      final decoded = jsonDecode(res.body);
      final list = _extractList(decoded);
      debugPrint("📍 $tag parsed ${list.length} items");
      return list;
    } catch (e) {
      debugPrint("🔴 $tag error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getGotras() =>
      _getMasterList(ApiConfig.gotra, 'gotras');

  Future<List<Map<String, dynamic>>> getStates() =>
      _getMasterList(ApiConfig.states, 'states');

  Future<List<Map<String, dynamic>>> getDistricts(String stateId) =>
      _getMasterList(ApiConfig.districtsByState(stateId), 'districts[$stateId]');

  Future<List<Map<String, dynamic>>> getTalukas(String districtId) =>
      _getMasterList(
          ApiConfig.talukasByDistrict(districtId), 'talukas[$districtId]');

  // ---------------- ADMIN NOTIFICATIONS ----------------
  Future<List<Map<String, dynamic>>> getAdminNotifications() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.adminNotifications),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getAdminNotifications error: $e");
      return [];
    }
  }
  // ---- NEW: Claim PDF token (member) ----
  Future<Map<String, dynamic>?> getMemberClaimPdfToken(String claimId) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberClaimPdfToken(claimId)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getMemberClaimPdfToken error: $e");
      return null;
    }
  }

  // ---- NEW: Receipt PDF token (member) ----
  Future<Map<String, dynamic>?> getMemberReceiptPdfToken(String receiptId) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberReceiptPdfToken(receiptId)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getMemberReceiptPdfToken error: $e");
      return null;
    }
  }
  // ---- NEW: Search Karyakarta by SA code (member) ----
  Future<Map<String, dynamic>?> searchKaryakartaByCode(String code) async {
    try {
      final uri = Uri.parse(ApiConfig.memberSearchKaryakarta)
          .replace(queryParameters: {"code": code.trim()});
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      if (data['data'] == null) return null;
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 searchKaryakartaByCode error: $e");
      return null;
    }
  }

  // ---------------- KARYAKARTA ----------------
  Future<Map<String, dynamic>> createKaryakarta(
      Map<String, dynamic> payload, {
        PlatformFile? passportPhoto,
        PlatformFile? govtIdProof,
        PlatformFile? authConsentLetter,
      }) async {
    final request =
    http.MultipartRequest('POST', Uri.parse(ApiConfig.createKaryakarta));
    _attachAuthHeaders(request);

    payload.forEach((key, value) {
      request.fields[key] = value?.toString() ?? '';
    });

    Future<void> attach(String field, PlatformFile? file) async {
      if (file == null) return;
      if (file.bytes != null) {
        request.files.add(
            http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath(field, file.path!,
            filename: file.name));
      }
    }

    await attach('passport_photo', passportPhoto);
    await attach('govt_id_proof', govtIdProof);
    await attach('auth_consent_letter', authConsentLetter);

    final streamed = await request.send().timeout(_longTimeout); // FIXED: Added longer timeout for uploads
    final res = await http.Response.fromStream(streamed);
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>> createMemberWithFiles(
      Map<String, dynamic> payload, {
        PlatformFile? passportPhoto,
        PlatformFile? govtIdProof,
        PlatformFile? authConsentLetter,
      }) async {
    final request =
    http.MultipartRequest('POST', Uri.parse(ApiConfig.members));
    _attachAuthHeaders(request);

    payload.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    Future<void> attach(String field, PlatformFile? file) async {
      if (file == null) return;
      if (file.bytes != null) {
        request.files.add(
            http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath(field, file.path!,
            filename: file.name));
      }
    }

    await attach('passport_photo', passportPhoto);
    await attach('govt_id_proof', govtIdProof);
    await attach('auth_consent_letter', authConsentLetter);

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>> getKaryakartaProfile(int id) async {
    final res = await http.get(
      Uri.parse(ApiConfig.karyakartaProfile(id.toString())),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    final raw = Map<String, dynamic>.from(data['data'] ?? data);

    return {
      ...raw,
      'personal': {
        'full_name': raw['full_name'],
        'father_name': raw['father_name'],
        'dob': raw['dob'],
        'gender': raw['gender'],
        'mobile': raw['mobile'],
        'aadhaar_no': raw['aadhaar_no'],
        'pan_no': raw['pan_no'],
      },
      'working_area': {
        'state': raw['state'],
        'district': raw['district'],
        'taluka': raw['taluka'],
        'village': raw['village'],
        'pincode': raw['pincode'],
        'full_address': raw['full_address'],
      },
      'samaj': {
        'gotra': raw['gotra'],
        'occupation': raw['occupation'],
        'education': raw['education'],
        'date_of_joining': raw['created_at'],
      },
      'karyakarta_code': raw['karyakarta_code'],
      'status': raw['status'],
      'assigned_members': raw['assigned_members'] ?? [],
      'policies': raw['policies'] ?? [],
      'claims': raw['claims'] ?? [],
      'commission_ledger': raw['commission_ledger'] ?? [],
      'collections': raw['collections'] ?? [],
    };
  }

  Future<Map<String, dynamic>> updateKaryakartaStatus(
      String id, String status) async {
    final res = await http.patch(
      Uri.parse(ApiConfig.karyakartaStatus(id)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"status": status}),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Status updated'
              : 'Failed to update status'),
      ...data,
    };
  }

  Future<Map<String, dynamic>> updateKaryakarta(
      String id, Map<String, dynamic> payload) async {
    final res = await http.put(
      Uri.parse(ApiConfig.karyakartaProfile(id)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Karyakarta updated'
              : 'Failed to update karyakarta'),
      ...data,
    };
  }

  Future<Map<String, dynamic>> deleteKaryakarta(String id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.karyakartaProfile(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Karyakarta deleted'
              : 'Failed to delete karyakarta'),
      ...data,
    };
  }

  Future<List<KaryakartaModel>> getKaryakartas() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartas),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return list
          .map((e) => KaryakartaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  DateTime? _loginLockedUntil;

  Future<Map<String, dynamic>> karyakartaLogin(String username, String password) async {
    final cleanUser = username.trim();
    final cleanPass = password.trim();

    // Client-side guard: don't hit the server again while we know
    // it's still rate-limiting us — this avoids resetting/extending
    // the server's own lockout window.
    if (_loginLockedUntil != null && DateTime.now().isBefore(_loginLockedUntil!)) {
      final remaining = _loginLockedUntil!.difference(DateTime.now());
      final mins = remaining.inMinutes + 1;
      return {
        "success": false,
        "message": "Too many attempts. Please wait about $mins minute(s) before trying again.",
      };
    }

    try {
      // Confirmed via direct API testing: the backend only needs
      // "username" + "password". Sending karyakarta_code / sa_code /
      // mobile alongside it was interfering with the backend's login logic.
      final Map<String, dynamic> bodyData = {
        "username": cleanUser,
        "password": cleanPass,
      };

      // debugPrint("🟡 karyakartaLogin URL → ${ApiConfig.karyakartaLogin}");
      // debugPrint("🟡 karyakartaLogin payload → ${jsonEncode(bodyData)}");

      final res = await http.post(
        Uri.parse(ApiConfig.karyakartaLogin),
        headers: ApiConfig.headers(),
        body: jsonEncode(bodyData),
      ).timeout(_defaultTimeout); // FIXED: Added timeout

      // debugPrint("🟡 karyakartaLogin RAW RESPONSE (${res.statusCode}) → ${res.body}");
      if (kDebugMode) {
        debugPrint("karyakartaLogin → status ${res.statusCode}");
      }

      if (res.statusCode == 429) {
        // Remember the lockout locally so we don't keep retrying and
        // extending it. Adjust the 15 here if your backend's window differs.
        _loginLockedUntil = DateTime.now().add(const Duration(minutes: 15));
      }

      final data = _handle(res);
      final isSuccess = data['status'] == 'success' || data['success'] == true;

      if (isSuccess && data['data'] != null) {
        final userData = Map<String, dynamic>.from(data['data']);
        userData['role'] ??= 'karyakarta';

        final token = userData['token'] ?? data['token'];
        if (token != null) {
          await setToken(token.toString());
        }
        await _setUser(userData);

        KaryakartaSession.saCode =
            (userData['karyakarta_code'] ?? userData['sa_code'] ?? cleanUser)
                .toString();
        KaryakartaSession.fullName =
            (userData['full_name'] ?? userData['name'] ?? 'Karyakarta')
                .toString();
        KaryakartaSession.mobile =
            (userData['mobile'] ?? userData['phone'] ?? '').toString();
        KaryakartaSession.village =
            (userData['village'] ?? userData['working_area'] ?? '').toString();
        final photoDoc = (userData['photo_doc'] ?? '').toString();
        KaryakartaSession.photoUrl =
        photoDoc.isNotEmpty ? ApiConfig.bannerImageUrl(photoDoc) : '';

        // NEW — keep the numeric IDs from the login response
        KaryakartaSession.karyakartaId =
            int.tryParse(userData['karyakarta_id']?.toString() ?? '') ?? 0;
        KaryakartaSession.userId =
            int.tryParse(userData['user_id']?.toString() ?? '') ?? 0;
      }

      debugPrint(
          "🟠 KARYAKARTA LOGIN → status=${data['status']} isSuccess=$isSuccess role=${_user?['role']}");

      return {
        ...data,
        "success": isSuccess,
        "message": data['message'] ??
            (isSuccess
                ? "Login successful"
                : "Invalid username or password"),
      };
    } catch (e) {
      debugPrint("🔴 karyakartaLogin error: $e");
      return {"success": false, "message": "Login error: $e"};
    }
  }

  // ---------------- MEMBER (self-service) ----------------
  Future<Map<String, dynamic>> memberLogin(
      String username, String password) async {
    final res = await http.post(
      Uri.parse(ApiConfig.memberLogin),
      headers: ApiConfig.headers(),
      body: jsonEncode({"username": username, "password": password}),
    );
    final data = _handle(res);

    final isSuccess = data['status'] == 'success';
    if (isSuccess && data['data'] != null) {
      final userData = Map<String, dynamic>.from(data['data']);
      userData['role'] = (userData['role'] ?? 'member').toString();
      if (userData['token'] != null) {
        await setToken(userData['token']);
      }
      await _setUser(userData);
    }

    debugPrint(
        "🟣 MEMBER LOGIN → status=${data['status']} isSuccess=$isSuccess role=${_user?['role']}");

    return {
      ...data,
      "success": isSuccess,
      "message": data['message'] ?? (isSuccess ? "Login successful" : "Login failed"),
    };
  }

  Future<Map<String, dynamic>> getMemberDashboard() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberDashboard),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return {};
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getMemberDashboard error: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>?> getMemberSelfProfile() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberProfile),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final raw = data['data'] ?? data;
      if (raw == null || (raw is Map && raw.isEmpty)) return null;
      final profile = Map<String, dynamic>.from(raw);
      profile['gotra'] = profile['gotra'] ?? profile['gotra_name'];
      profile['state'] = profile['state'] ?? profile['state_name'];
      profile['district'] = profile['district'] ?? profile['district_name'];
      profile['taluka'] =
          profile['taluka'] ?? profile['taluka_name'] ?? profile['tehsil'];
      profile['village'] = profile['village'] ?? profile['village_name'];
      profile['address'] = profile['address'] ?? profile['full_address'];
      return profile;
    } catch (e) {
      debugPrint("🔴 getMemberSelfProfile error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> updateMemberProfile({
    String? altMobile,
    String? address,
    String? password,
  }) async {
    try {
      final body = <String, dynamic>{
        if (altMobile != null && altMobile.trim().isNotEmpty)
          "alt_mobile": altMobile.trim(),
        if (address != null && address.trim().isNotEmpty)
          "address": address.trim(),
        if (password != null && password.isNotEmpty) "password": password,
      };
      final res = await http.put(
        Uri.parse(ApiConfig.memberProfile),
        headers: ApiConfig.headers(token: _token),
        body: jsonEncode(body),
      );
      final data = _handle(res);
      return {
        "success": data['status'] == 'success' || data['success'] == true,
        "message": data['message'] ??
            (data['status'] == 'success'
                ? 'Profile updated successfully'
                : 'Failed to update profile'),
        ...data,
      };
    } catch (e) {
      return {"success": false, "message": "Update failed: $e"};
    }
  }

  Future<List<Map<String, dynamic>>> getMemberSchemes() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberSchemes),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getMemberSchemes error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMemberEnrollments() => getMemberSchemes();

  Future<Map<String, dynamic>?> getMemberEnrollmentById(String id) async {
    final list = await getMemberSchemes();
    try {
      return list.firstWhere((e) => e['id'].toString() == id);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getMemberPayments() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberPayments),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) {
        return {"receipts": [], "pending_dues_amount": 0};
      }
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getMemberPayments error: $e");
      return {"receipts": [], "pending_dues_amount": 0};
    }
  }

  Future<List<Map<String, dynamic>>> getMemberCollections() async {
    final payments = await getMemberPayments();
    final receipts = (payments['receipts'] as List?) ?? [];
    return receipts.map((r) {
      final m = Map<String, dynamic>.from(r);
      m['collection_date'] = m['created_at'];
      return m;
    }).toList();
  }

  Future<Map<String, dynamic>> createMemberCollection(
      Map<String, dynamic> payload) async {
    return {"success": false, "message": "Not available for member accounts."};
  }

  Future<List<Map<String, dynamic>>> getMemberClaims() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberClaims),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getMemberClaims error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> submitMemberClaim(
      Map<String, dynamic> payload, {
        PlatformFile? proofFile,
      }) async {
    final request =
    http.MultipartRequest('POST', Uri.parse(ApiConfig.memberClaims));
    _attachAuthHeaders(request);

    payload.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    if (proofFile != null) {
      if (proofFile.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
            'proof_doc', proofFile.bytes!,
            filename: proofFile.name));
      } else if (proofFile.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'proof_doc', proofFile.path!,
            filename: proofFile.name));
      }
    }

    final streamed = await request.send().timeout(_longTimeout); // FIXED: Added longer timeout for uploads
    final res = await http.Response.fromStream(streamed);
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Claim submitted successfully'
              : 'Failed to submit claim'),
      ...data,
    };
  }

  Future<Map<String, dynamic>?> getMemberClaimById(String id) async {
    final list = await getMemberClaims();
    try {
      return list.firstWhere((c) => c['id'].toString() == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMemberNotifications() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberNotifications),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getMemberNotifications error: $e");
      return [];
    }
  }

  // GET /api/member/pending-dues
  Future<List<Map<String, dynamic>>> getMemberPendingDues() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberPendingDues),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data']?['pending_dues'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getMemberPendingDues error: $e");
      return [];
    }
  }

  // POST /api/member/pay-dues
  Future<Map<String, dynamic>> payMemberDues({
    required List<int> dueIds,
    required String paymentMode,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.memberPayDues),
        headers: ApiConfig.headers(token: _token),
        body: jsonEncode({"due_ids": dueIds, "payment_mode": paymentMode}),
      );
      final data = _handle(res);
      return {
        "success": data['status'] == 'success' || data['success'] == true,
        "message": data['message'] ??
            (data['status'] == 'success' ? 'Payment processed successfully' : 'Payment failed'),
        ...data,
      };
    } catch (e) {
      debugPrint("🔴 payMemberDues error: $e");
      return {"success": false, "message": "Payment failed: $e"};
    }
  }

  Future<List<Map<String, dynamic>>> getMemberMembers() async => [];
  Future<Map<String, dynamic>?> getMemberPvcCard(String memberId) async => null;
  Future<List<Map<String, dynamic>>> getMemberCommissions() async => [];

  // ---------------- MEMBERS ----------------
  Future<Map<String, dynamic>> createMember(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.members),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<List<MemberModel>> getMembers() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.members),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return list
          .map((e) => MemberModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<MemberModel?> getMemberById(String id) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberById(id)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return MemberModel.fromJson(Map<String, dynamic>.from(data['data']));
    } catch (_) {
      return null;
    }
  }

  Future<List<MemberModel>> searchMembers(String query) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberSearch(query)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return list
          .map((e) => MemberModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> updateMember(
      String id, Map<String, dynamic> payload) async {
    final res = await http.put(
      Uri.parse(ApiConfig.memberById(id)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>> toggleMemberStatus(
      String id, String status) async {
    final res = await http.patch(
      Uri.parse(ApiConfig.memberStatus(id)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"status": status}),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>> deleteMember(String id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.memberById(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  // ---------------- ENROLLMENTS ----------------
  Future<Map<String, dynamic>> createEnrollment(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.enrollments),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<List<EnrollmentModel>> getEnrollments() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.enrollments),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return list
          .map((e) => EnrollmentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<EnrollmentModel?> getEnrollmentById(String id) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.enrollmentById(id)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return EnrollmentModel.fromJson(Map<String, dynamic>.from(data['data']));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> approveEnrollment(String id) async {
    final res = await http.put(
      Uri.parse(ApiConfig.approveEnrollment(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>> rejectEnrollment(
      String id, String reason) async {
    final res = await http.put(
      Uri.parse(ApiConfig.rejectEnrollment(id)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"rejection_reason": reason}),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>> deleteEnrollment(String id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.enrollmentById(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<List<Map<String, dynamic>>> getKaryakartaEnrollments() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaEnrollments),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getKaryakartaEnrollments error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getKaryakartaEnrollmentById(String id) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaEnrollmentById(id)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getKaryakartaEnrollmentById error: $e");
      return null;
    }
  }

  // ---------------- ENROLLMENT CREATE SCREEN (NEW) ----------------
  // These back EnrollmentCreateScreen. Written with `http` (this file's
  // existing pattern) — NOT `dio`, which this class doesn't use anywhere.

  /// List of welfare schemes for the "Select Welfare Scheme" dropdown.
  Future<List<Map<String, dynamic>>> getWelfareSchemes() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaWelfareSchemes),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getWelfareSchemes error: $e");
      // Fallback so the dropdown still renders while the backend is wired up.
      return [];
    }
  }

  /// Looks up an existing member by 7-digit Member ID, Mobile, or Aadhaar.
  /// Returns null if not found.
  Future<Map<String, dynamic>?> fetchMemberRecord(String query) async {
    try {
      final uri = Uri.parse(ApiConfig.karyakartaMemberLookup)
          .replace(queryParameters: {"q": query.trim()});
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      if (data['data'] == null) return null;
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 fetchMemberRecord error: $e");
      return null;
    }
  }

  /// Joining fee / per-event contribution for a scheme + calculated age group.
  Future<Map<String, dynamic>> getSchemeRates(String schemeId, String ageGroup) async {
    try {
      final uri = Uri.parse(ApiConfig.karyakartaSchemeRates(schemeId))
          .replace(queryParameters: {"age_group": ageGroup});
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      if (data['data'] == null) {
        return {'joining_fee': 0, 'per_event': 0, 'age_group': ageGroup};
      }
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getSchemeRates error: $e");
      return {'joining_fee': 0, 'per_event': 0, 'age_group': ageGroup};
    }
  }

  /// Submits the proposal payload built in EnrollmentCreateScreen._submit().
  ///
  /// CAUTION: this posts plain JSON to the SAME endpoint
  /// (ApiConfig.karyakartaEnrollments) that createKaryakartaEnrollment()
  /// above already posts to as multipart/form-data (with file uploads).
  /// Only use this method if EnrollmentCreateScreen has NO file fields —
  /// otherwise your backend needs to accept both JSON and multipart on
  /// the same route, or you should just call createKaryakartaEnrollment()
  /// instead of duplicating this.
  Future<Map<String, dynamic>> submitEnrollmentProposal(
      Map<String, dynamic> payload) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.karyakartaEnrollments),
        headers: ApiConfig.headers(token: _token),
        body: jsonEncode(payload),
      );
      final data = _handle(res);
      return {
        "success": data['status'] == 'success' || data['success'] == true,
        "message": data['message'] ??
            (data['status'] == 'success'
                ? 'Proposal submitted successfully.'
                : 'Failed to submit proposal.'),
        ...data,
      };
    } catch (e) {
      debugPrint("🔴 submitEnrollmentProposal error: $e");
      return {"success": false, "message": "Submit failed: $e"};
    }
  }

  Future<List<Map<String, dynamic>>> getMembersRaw() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.members),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getMembersRaw error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSchemesRaw() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.schemes),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getSchemesRaw error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getKaryakartaDashboard() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaDashboard),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return {};
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getKaryakartaDashboard error: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>?> getKaryakartaSelfProfile() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaSelfProfile),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getKaryakartaSelfProfile error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> updateKaryakartaSelfProfile({
    String? altMobile,
    String? fullAddress,
    String? password,
  }) async {
    try {
      final body = <String, dynamic>{
        if (altMobile != null && altMobile.trim().isNotEmpty)
          "alt_mobile": altMobile.trim(),
        if (fullAddress != null && fullAddress.trim().isNotEmpty)
          "full_address": fullAddress.trim(),
        if (password != null && password.isNotEmpty) "password": password,
      };

      final res = await http.put(
        Uri.parse(ApiConfig.karyakartaSelfProfile),
        headers: ApiConfig.headers(token: _token),
        body: jsonEncode(body),
      );
      final data = _handle(res);
      return {
        "success": data['status'] == 'success' || data['success'] == true,
        "message": data['message'] ??
            (data['status'] == 'success'
                ? 'Profile updated successfully'
                : 'Failed to update profile'),
        ...data,
      };
    } catch (e) {
      debugPrint("🔴 updateKaryakartaSelfProfile error: $e");
      return {"success": false, "message": "Update failed: $e"};
    }
  }

  Future<List<Map<String, dynamic>>> getKaryakartaMembers() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaMembers),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getKaryakartaMembers error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getKaryakartaMemberPvcCard(
      String memberId) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaMemberPvcCard(memberId)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getKaryakartaMemberPvcCard error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> createKaryakartaMember(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.karyakartaMembers),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Member created successfully'
              : 'Failed to create member'),
      ...data,
    };
  }

  Future<Map<String, dynamic>> submitMemberEnrollment(
      Map<String, dynamic> payload, {
        PlatformFile? fatherDocFile,
        PlatformFile? authFile,
        PlatformFile? docFile,
        PlatformFile? photoFile,
      }) async {
    final request =
    http.MultipartRequest('POST', Uri.parse(ApiConfig.memberSchemes));
    _attachAuthHeaders(request);

    payload.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    Future<void> attach(String field, PlatformFile? file) async {
      if (file == null) return;
      if (file.bytes != null) {
        request.files.add(
            http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath(field, file.path!,
            filename: file.name));
      }
    }

    await attach('father_doc_file', fatherDocFile);
    await attach('auth_file', authFile);
    await attach('doc_file', docFile);
    await attach('photo_file', photoFile);

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Proposal submitted'
              : 'Failed to submit proposal'),
      ...data,
    };
  }

  Future<Map<String, dynamic>> createKaryakartaEnrollment({
    required int memberId,
    required int schemeId,
    required double joiningFeePaid,
    required String paymentMode,
    required String nomineeName,
    String? nomineeRelation,
    PlatformFile? fatherDocFile,
    PlatformFile? authFile,
    PlatformFile? docFile,
    PlatformFile? photoFile,
  }) async {
    final request = http.MultipartRequest(
        'POST', Uri.parse(ApiConfig.karyakartaEnrollments));
    _attachAuthHeaders(request);

    request.fields['member_id'] = memberId.toString();
    request.fields['scheme_id'] = schemeId.toString();
    request.fields['joining_fee_paid'] = joiningFeePaid.toString();
    request.fields['payment_mode'] = paymentMode;
    request.fields['nominee_name'] = nomineeName;
    if (nomineeRelation != null && nomineeRelation.trim().isNotEmpty) {
      request.fields['nominee_relation'] = nomineeRelation;
    }

    Future<void> attach(String field, PlatformFile? file) async {
      if (file == null) return;
      if (file.bytes != null) {
        request.files.add(
            http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath(field, file.path!,
            filename: file.name));
      }
    }

    await attach('father_doc_file', fatherDocFile);
    await attach('auth_file', authFile);
    await attach('doc_file', docFile);
    await attach('photo_file', photoFile);

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Enrollment created successfully'
              : 'Failed to create enrollment'),
      ...data,
    };
  }

  Future<Map<String, dynamic>> createKaryakartaMemberWithFiles(
      Map<String, dynamic> payload, {
        PlatformFile? passportPhoto,
        PlatformFile? govtIdProof,
        PlatformFile? authConsentLetter,
      }) async {
    final request =
    http.MultipartRequest('POST', Uri.parse(ApiConfig.karyakartaMembers));
    _attachAuthHeaders(request);

    payload.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    Future<void> attach(String field, PlatformFile? file) async {
      if (file == null) return;
      if (file.bytes != null) {
        request.files.add(
            http.MultipartFile.fromBytes(field, file.bytes!, filename: file.name));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath(field, file.path!,
            filename: file.name));
      }
    }

    await attach('passport_photo', passportPhoto);
    await attach('govt_id_proof', govtIdProof);
    await attach('auth_consent_letter', authConsentLetter);

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Member created successfully'
              : 'Failed to create member'),
      ...data,
    };
  }

  // ---------------- PROPOSALS ----------------
  Future<List<ProposalModel>> getProposals({String? status}) async {
    try {
      final uri = Uri.parse(ApiConfig.membershipProposals).replace(
        queryParameters: status != null ? {"status": status} : null,
      );
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return list.map((e) => ProposalModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("🔴 getProposals error: $e");
      return [];
    }
  }

  Future<void> approveProposal(String proposalNo) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.approveProposal(proposalNo)),
        headers: ApiConfig.headers(token: _token),
      );
      _handle(res);
    } catch (_) {}
  }

  Future<void> rejectProposal(String proposalNo) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.rejectProposal(proposalNo)),
        headers: ApiConfig.headers(token: _token),
      );
      _handle(res);
    } catch (_) {}
  }

  // ---------------- KARYAKARTA CLAIMS ----------------
  Future<Map<String, dynamic>> submitKaryakartaClaim(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.karyakartaClaims),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Claim submitted successfully'
              : 'Failed to submit claim'),
      ...data,
    };
  }

  Future<List<Map<String, dynamic>>> getKaryakartaClaims() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaClaims),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getKaryakartaClaims error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getKaryakartaClaimById(String id) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaClaimById(id)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final raw = data['data'];
      if (raw == null) return null;
      if (raw is List) {
        if (raw.isEmpty) return null;
        return Map<String, dynamic>.from(raw.first);
      }
      return Map<String, dynamic>.from(raw);
    } catch (e) {
      debugPrint("🔴 getKaryakartaClaimById error: $e");
      return null;
    }
  }

  // ---------------- KARYAKARTA COLLECTIONS ----------------
  Future<Map<String, dynamic>> createKaryakartaCollection(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.karyakartaCollections),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Collection recorded successfully'
              : 'Failed to record collection'),
      ...data,
    };
  }

  Future<List<Map<String, dynamic>>> getKaryakartaCollections() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaCollections),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getKaryakartaCollections error: $e");
      return [];
    }
  }

  // Future<List<Map<String, dynamic>>> getKaryakartaCommissions() async {
  //   try {
  //     final res = await http.get(
  //       Uri.parse(ApiConfig.karyakartaCommissions),
  //       headers: ApiConfig.headers(token: _token),
  //     );
  // ---------------- DIRECT COLLECT + CLAIM BATCH DETAIL (NEW) ----------------

  /// GET /api/karyakarta/collections/member-dues?query=...
  /// Returns { member: {...}, pending_dues: [...] } or null if not found.
  Future<Map<String, dynamic>?> getKaryakartaMemberPendingDues(String query) async {
    try {
      final uri = Uri.parse(ApiConfig.karyakartaMemberPendingDues)
          .replace(queryParameters: {"query": query.trim()});
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      final raw = data['data'];
      if (raw is Map && raw['member'] != null) {
        return Map<String, dynamic>.from(raw);
      }
      return null;
    } catch (e) {
      debugPrint("🔴 getKaryakartaMemberPendingDues error: $e");
      return null;
    }
  }

  /// POST /api/karyakarta/collections/pay-dues
  Future<Map<String, dynamic>> payKaryakartaMemberDues({
    required String memberId,
    required List<String> dueIds,
    required String paymentMode,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.karyakartaPayMemberDues),
        headers: ApiConfig.headers(token: _token),
        body: jsonEncode({
          "member_id": memberId,
          "due_ids": dueIds,
          "payment_mode": paymentMode,
        }),
      );
      final data = _handle(res);
      return {
        "success": data['status'] == 'success' || data['success'] == true,
        "message": data['message'] ??
            (data['status'] == 'success'
                ? 'Payment recorded successfully'
                : 'Payment failed'),
        ...data,
      };
    } catch (e) {
      debugPrint("🔴 payKaryakartaMemberDues error: $e");
      return {"success": false, "message": "Payment failed: $e"};
    }
  }

  /// GET /api/karyakarta/claim-batches/{claimId}
  Future<Map<String, dynamic>?> getKaryakartaClaimBatchDetail(String claimId) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaClaimBatchDetail(claimId)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final raw = data['data'];
      if (raw == null) return null;
      return Map<String, dynamic>.from(raw);
    } catch (e) {
      debugPrint("🔴 getKaryakartaClaimBatchDetail error: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getKaryakartaCommissions() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaCommissions),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getKaryakartaCommissions error: $e");
      return [];
    }
  }

  // ---------------- KARYAKARTA NOTIFICATIONS ----------------
  Future<List<Map<String, dynamic>>> getKaryakartaNotifications() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaNotifications),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getKaryakartaNotifications error: $e");
      return [];
    }
  }

  // ---------------- TRANSACTIONS / LEDGER ----------------
  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.transactions),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Transaction recorded'
              : 'Failed to record transaction'),
      ...data,
    };
  }

  Future<Map<String, dynamic>> addState(String name) async {
    final res = await http.post(
      Uri.parse(ApiConfig.states),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"name": name}),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  Future<Map<String, dynamic>> addDistrict(String stateId, String name) async {
    final res = await http.post(
      Uri.parse(ApiConfig.addDistrict),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"state_id": stateId, "name": name}),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  Future<Map<String, dynamic>> addTaluka(
      String districtId, String name) async {
    final res = await http.post(
      Uri.parse(ApiConfig.addTaluka),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"district_id": districtId, "name": name}),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  Future<Map<String, dynamic>> getLedger({
    String? entryType,
    String? category,
    String? karyakartaSaCode,
    String? dateFrom,
    String? dateTo,
    String? search,
    int limit = 100,
  }) async {
    try {
      final uri =
      Uri.parse(ApiConfig.accountingLedger).replace(queryParameters: {
        if (entryType != null) "entry_type": entryType,
        if (category != null) "category": category,
        if (karyakartaSaCode != null) "sa_code": karyakartaSaCode,
        if (dateFrom != null) "date_from": dateFrom,
        if (dateTo != null) "date_to": dateTo,
        if (search != null && search.isNotEmpty) "search": search,
        "limit": limit.toString(),
      });
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      final payload = Map<String, dynamic>.from(data['data'] ?? {});
      final stats = Map<String, dynamic>.from(payload['stats'] ?? {});
      final txns =
      List<Map<String, dynamic>>.from(payload['transactions'] ?? []);
      return {"stats": stats, "transactions": txns};
    } catch (e) {
      debugPrint("🔴 getLedger error: $e");
      return {
        "stats": <String, dynamic>{},
        "transactions": <Map<String, dynamic>>[]
      };
    }
  }

  Future<Map<String, dynamic>> deleteTransaction(String id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.transactionById(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>?> getOrganizationProfile() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.organizationProfile),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getOrganizationProfile error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> updateOrganizationProfile(
      Map<String, dynamic> payload) async {
    final res = await http.put(
      Uri.parse(ApiConfig.organizationProfile),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Profile updated'
              : 'Failed to update profile'),
      ...data,
    };
  }

  Future<Map<String, dynamic>> addGotra(String nameEn, String nameHi) async {
    final res = await http.post(
      Uri.parse(ApiConfig.gotra),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"name_en": nameEn, "name_hi": nameHi}),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  Future<Map<String, dynamic>> updateGotra(
      String id, String nameEn, String nameHi) async {
    final res = await http.put(
      Uri.parse(ApiConfig.gotraById(id)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"name_en": nameEn, "name_hi": nameHi}),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  Future<Map<String, dynamic>> deleteGotra(String id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.gotraById(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  Future<Map<String, dynamic>> addSchemeSlab(
      String schemeId, Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.schemeSlabs(schemeId)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  Future<Map<String, dynamic>> deleteSchemeSlab(String slabId) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.schemeSlabById(slabId)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  // ---------------- BANK ACCOUNTS ----------------
  Future<List<Map<String, dynamic>>> getBankAccounts({String? status}) async {
    try {
      final uri = Uri.parse(ApiConfig.bankAccounts).replace(
        queryParameters: status != null ? {"status": status} : null,
      );
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getBankAccounts error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> createBankAccount(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.bankAccounts),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  // ---------------- COMMISSION PAYOUTS ----------------
  Future<Map<String, dynamic>> createCommissionPayout(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.commissionPayouts),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Commission payout created'
              : 'Failed to create payout'),
      ...data,
    };
  }

  Future<List<Map<String, dynamic>>> getCommissionPayouts({
    String? status,
    String? karyakartaId,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final uri =
      Uri.parse(ApiConfig.commissionPayouts).replace(queryParameters: {
        if (status != null) "status": status,
        if (karyakartaId != null) "karyakarta_id": karyakartaId,
        if (dateFrom != null) "date_from": dateFrom,
        if (dateTo != null) "date_to": dateTo,
      });
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getCommissionPayouts error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCommissionRules() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.commissionRules),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getCommissionRules error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> addCommissionRule(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.commissionRules),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Commission rule saved'
              : 'Failed to save rule'),
      ...data,
    };
  }

  Future<Map<String, dynamic>> deleteCommissionRule(String id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.commissionRuleById(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  Future<Map<String, dynamic>> addBanner(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.banners),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  Future<Map<String, dynamic>> deleteBanner(String id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.bannerById(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data
    };
  }

  Future<List<Map<String, dynamic>>> getKaryakartaCommissionsSummary({
    String? dateFrom,
    String? dateTo,
  }) async {
    if (roleName != 'karyakarta') {
      debugPrint(
          "ℹ️ getKaryakartaCommissionsSummary skipped — no admin endpoint exists for this role ($roleName)");
      return [];
    }
    try {
      final uri = Uri.parse(ApiConfig.karyakartaCommissionsSummary)
          .replace(queryParameters: {
        if (dateFrom != null) "date_from": dateFrom,
        if (dateTo != null) "date_to": dateTo,
      });
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getKaryakartaCommissionsSummary error: $e");
      return [];
    }
  }

  // ---------------- CLAIM PAYOUTS ----------------
  Future<List<Map<String, dynamic>>> getClaimPayouts({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final uri =
      Uri.parse(ApiConfig.claimPayouts).replace(queryParameters: {
        if (dateFrom != null) "date_from": dateFrom,
        if (dateTo != null) "date_to": dateTo,
      });
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getClaimPayouts error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> createClaimPayout(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.claimPayouts),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Claim payout created'
              : 'Failed to create claim payout'),
      ...data,
    };
  }

  // ---------------- GENERIC PAYMENTS ----------------
  Future<Map<String, dynamic>> createPayment(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.payments),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'] ??
          (data['status'] == 'success'
              ? 'Payment recorded'
              : 'Failed to record payment'),
      ...data,
    };
  }

  // ---------------- COMMISSION REPORT ----------------
  Future<List<Map<String, dynamic>>> getCommissionReport({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final uri =
      Uri.parse(ApiConfig.commissionReport).replace(queryParameters: {
        if (dateFrom != null) "date_from": dateFrom,
        if (dateTo != null) "date_to": dateTo,
      });
      final res = await http.get(uri, headers: ApiConfig.headers(token: _token));
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getCommissionReport error: $e");
      return [];
    }
  }

  // ---------------- BANNERS ----------------
  Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.banners),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      debugPrint("🔴 getBanners error: $e");
      return [];
    }
  }

  // ---------------- SCHEMES ----------------
  Future<List<SchemeModel>> getSchemes() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.schemes),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return list
          .map((e) => SchemeModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createScheme(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.schemes),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>> updateScheme(
      String schemeId, Map<String, dynamic> payload) async {
    final res = await http.put(
      Uri.parse(ApiConfig.schemeById(schemeId)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<List<Map<String, dynamic>>> getSchemeSlabs(String schemeId) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.schemeSlabs(schemeId)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> calculateSlab(String dob, int schemeId) async {
    final res = await http.post(
      Uri.parse(ApiConfig.calculateSlab),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"dob": dob, "scheme_id": schemeId}),
    );
    return _handle(res);
  }

  // ---------------- CLAIMS ----------------
  Future<Map<String, dynamic>> submitClaim(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.claims),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<List<ClaimModel>> getClaims() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.claims),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return list
          .map((e) => ClaimModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ClaimModel?> getClaimById(String id) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.claimById(id)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return ClaimModel.fromJson(Map<String, dynamic>.from(data['data']));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> approveClaim(String id,
      {required double approvedAmount, String? remarks}) async {
    final res = await http.put(
      Uri.parse(ApiConfig.approveClaim(id)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({
        "approved_amount": approvedAmount,
        if (remarks != null) "remarks": remarks,
      }),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>> rejectClaim(String id, String reason) async {
    final res = await http.put(
      Uri.parse(ApiConfig.rejectClaim(id)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"rejection_reason": reason}),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>> deleteClaim(String id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.claimById(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  // ---------------- RECEIPTS ----------------
  Future<Map<String, dynamic>> createReceipt(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.receipts),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<List<ReceiptModel>> getReceipts() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.receipts),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return list
          .map((e) => ReceiptModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ReceiptModel?> getReceiptById(String id) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.receiptById(id)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return ReceiptModel.fromJson(Map<String, dynamic>.from(data['data']));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> deleteReceipt(String id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.receiptById(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  // ---------------- CONTRIBUTION BATCHES ----------------
  Future<Map<String, dynamic>> createContributionBatch(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.contributionBatches),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<List<ContributionBatchModel>> getContributionBatches() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.contributionBatches),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return list
          .map((e) =>
          ContributionBatchModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ContributionBatchModel?> getContributionBatchById(String id) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.contributionBatchById(id)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return ContributionBatchModel.fromJson(
          Map<String, dynamic>.from(data['data']));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> settleContributionBatch(String id) async {
    final res = await http.put(
      Uri.parse(ApiConfig.settleContributionBatch(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  // ---------------- MEMBER CONTRIBUTIONS ----------------
  Future<Map<String, dynamic>> recordMemberContribution(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiConfig.memberContributions),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode(payload),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<List<MemberContributionModel>> getMemberContributions() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberContributions),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      final list = (data['data'] as List?) ?? [];
      return list
          .map((e) =>
          MemberContributionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<MemberContributionModel?> getMemberContributionById(String id) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.memberContributionById(id)),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return null;
      return MemberContributionModel.fromJson(
          Map<String, dynamic>.from(data['data']));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> updateMemberContributionStatus(
      String id, String status) async {
    final res = await http.put(
      Uri.parse(ApiConfig.memberContributionStatus(id)),
      headers: ApiConfig.headers(token: _token),
      body: jsonEncode({"status": status}),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  Future<Map<String, dynamic>> deleteMemberContribution(String id) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.memberContributionById(id)),
      headers: ApiConfig.headers(token: _token),
    );
    final data = _handle(res);
    return {
      "success": data['status'] == 'success' || data['success'] == true,
      "message": data['message'],
      ...data,
    };
  }

  // ---------------- KARYAKARTA COLLECTIONS SUMMARY ----------------
  Future<Map<String, dynamic>> getKaryakartaCollectionsSummary() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.karyakartaCollectionsSummary),
        headers: ApiConfig.headers(token: _token),
      );
      final data = _handle(res);
      if (data['data'] == null) return {};
      return Map<String, dynamic>.from(data['data']);
    } catch (e) {
      debugPrint("🔴 getKaryakartaCollectionsSummary error: $e");
      return {};
    }
  }

// ---------------- RESPONSE HANDLER ----------------
// FIXED: Added timeout wrapper for consistent error handling
//   Future<T> _withTimeout<T>(Future<T> future, {Duration? timeout}) async {
//     try {
//       return await future.timeout(timeout ?? _defaultTimeout);
//     } catch (e) {
//       if (e is TimeoutException) {
//         throw Exception("Request timed out. Please check your connection and try again.");
//       }
//       rethrow;
//     }
//   }
  // (deleted)

  Map<String, dynamic> _handle(http.Response res) {
    if (kDebugMode) {
      debugPrint("API ${res.request?.url} -> ${res.statusCode}: ${res.body}");
    }

    Map<String, dynamic> body = {};
    if (res.body.isNotEmpty) {
      try {
        body = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception("Server error (${res.statusCode}). Please contact support.");
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    if (body.containsKey('message') || body.containsKey('success')) {
      return {
        "success": false,
        "message": body['message'] ?? "Request failed (${res.statusCode})",
        ...body,
      };
    }

    throw Exception("API error ${res.statusCode}: ${res.body}");
  }
}