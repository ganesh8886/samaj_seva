// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../utils/constants.dart';
//
// class AddKaryakartaScreen extends StatefulWidget {
//   const AddKaryakartaScreen({super.key});
//
//   @override
//   State<AddKaryakartaScreen> createState() => _AddKaryakartaScreenState();
// }
//
// class _AddKaryakartaScreenState extends State<AddKaryakartaScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _api = ApiService();
//   bool _submitting = false;
//
//   // Required fields
//   final _fullName = TextEditingController();
//   final _fatherName = TextEditingController();
//   final _aadhaar = TextEditingController();
//   final _mobile = TextEditingController();
//   DateTime? _dob;
//   String _gender = 'Male';
//
//   // Optional fields
//   final _panNumber = TextEditingController();
//   final _altMobile = TextEditingController();
//   final _email = TextEditingController();
//   final _pin = TextEditingController();
//   final _stateId = TextEditingController();
//   final _districtId = TextEditingController();
//   final _cityId = TextEditingController();
//   final _taluka = TextEditingController();
//   final _pinCode = TextEditingController();
//   final _address = TextEditingController();
//   final _gotra = TextEditingController();
//   final _occupation = TextEditingController();
//   final _education = TextEditingController();
//
//   @override
//   void dispose() {
//     for (final c in [
//       _fullName, _fatherName, _aadhaar, _mobile, _panNumber, _altMobile,
//       _email, _pin, _stateId, _districtId, _cityId, _taluka, _pinCode,
//       _address, _gotra, _occupation, _education,
//     ]) {
//       c.dispose();
//     }
//     super.dispose();
//   }
//
//   Future<void> _pickDob() async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(now.year - 25),
//       firstDate: DateTime(1930),
//       lastDate: now,
//     );
//     if (picked != null) setState(() => _dob = picked);
//   }
//
//   String _fmtDate(DateTime d) =>
//       '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
//
//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_dob == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Please select date of birth')));
//       return;
//     }
//
//     setState(() => _submitting = true);
//
//     final payload = {
//       "full_name": _fullName.text.trim(),
//       "father_name": _fatherName.text.trim(),
//       "date_of_birth": _fmtDate(_dob!),
//       "gender": _gender,
//       "aadhaar_number": _aadhaar.text.trim(),
//       "mobile_number": _mobile.text.trim(),
//       "status": "pending",
//       if (_panNumber.text.trim().isNotEmpty) "pan_number": _panNumber.text.trim(),
//       if (_altMobile.text.trim().isNotEmpty) "alternate_mobile": _altMobile.text.trim(),
//       if (_email.text.trim().isNotEmpty) "email": _email.text.trim(),
//       if (_pin.text.trim().isNotEmpty) "pin": _pin.text.trim(),
//       if (_stateId.text.trim().isNotEmpty) "state_id": _stateId.text.trim(),
//       if (_districtId.text.trim().isNotEmpty) "district_id": _districtId.text.trim(),
//       if (_cityId.text.trim().isNotEmpty) "city_id": _cityId.text.trim(),
//       if (_taluka.text.trim().isNotEmpty) "taluka_tehsil": _taluka.text.trim(),
//       if (_pinCode.text.trim().isNotEmpty) "pin_code": _pinCode.text.trim(),
//       if (_address.text.trim().isNotEmpty) "full_address": _address.text.trim(),
//       if (_gotra.text.trim().isNotEmpty) "gotra": _gotra.text.trim(),
//       if (_occupation.text.trim().isNotEmpty) "occupation": _occupation.text.trim(),
//       if (_education.text.trim().isNotEmpty) "education": _education.text.trim(),
//     };
//
//     try {
//       final res = await _api.createKaryakarta(payload);
//       if (!mounted) return;
//       setState(() => _submitting = false);
//
//       if (res['success'] == false) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(res['message']?.toString() ?? 'Failed to add karyakarta')),
//         );
//         return;
//       }
//
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Karyakarta added successfully')));
//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _submitting = false);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }
//
//   InputDecoration _dec(String label) => InputDecoration(
//     labelText: label,
//     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Karyakarta'),
//         backgroundColor: AppColors.primary,
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             const Text('Required Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//             const SizedBox(height: 10),
//             TextFormField(
//               controller: _fullName,
//               decoration: _dec('Full Name *'),
//               validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _fatherName,
//               decoration: _dec('Father Name *'),
//               validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//             ),
//             const SizedBox(height: 12),
//             InkWell(
//               onTap: _pickDob,
//               child: InputDecorator(
//                 decoration: _dec('Date of Birth *'),
//                 child: Text(_dob == null ? 'Select date' : _fmtDate(_dob!)),
//               ),
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: _gender,
//               decoration: _dec('Gender *'),
//               items: const [
//                 DropdownMenuItem(value: 'Male', child: Text('Male')),
//                 DropdownMenuItem(value: 'Female', child: Text('Female')),
//                 DropdownMenuItem(value: 'Other', child: Text('Other')),
//               ],
//               onChanged: (v) => setState(() => _gender = v ?? 'Male'),
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _aadhaar,
//               decoration: _dec('Aadhaar Number *'),
//               keyboardType: TextInputType.number,
//               maxLength: 12,
//               validator: (v) {
//                 if (v == null || v.trim().isEmpty) return 'Required';
//                 if (v.trim().length != 12) return 'Must be 12 digits';
//                 return null;
//               },
//             ),
//             TextFormField(
//               controller: _mobile,
//               decoration: _dec('Mobile Number *'),
//               keyboardType: TextInputType.phone,
//               maxLength: 10,
//               validator: (v) {
//                 if (v == null || v.trim().isEmpty) return 'Required';
//                 if (v.trim().length != 10) return 'Must be 10 digits';
//                 return null;
//               },
//             ),
//
//             const Divider(height: 30),
//             const Text('Additional Details (optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//             const SizedBox(height: 10),
//             TextFormField(controller: _panNumber, decoration: _dec('PAN Number')),
//             const SizedBox(height: 12),
//             TextFormField(controller: _altMobile, decoration: _dec('Alternate Mobile'), keyboardType: TextInputType.phone),
//             const SizedBox(height: 12),
//             TextFormField(controller: _email, decoration: _dec('Email'), keyboardType: TextInputType.emailAddress),
//             const SizedBox(height: 12),
//             TextFormField(controller: _pin, decoration: _dec('Login PIN'), keyboardType: TextInputType.number, obscureText: true),
//             const SizedBox(height: 12),
//             TextFormField(controller: _stateId, decoration: _dec('State ID')),
//             const SizedBox(height: 12),
//             TextFormField(controller: _districtId, decoration: _dec('District ID')),
//             const SizedBox(height: 12),
//             TextFormField(controller: _cityId, decoration: _dec('City ID')),
//             const SizedBox(height: 12),
//             TextFormField(controller: _taluka, decoration: _dec('Taluka / Tehsil')),
//             const SizedBox(height: 12),
//             TextFormField(controller: _pinCode, decoration: _dec('Pin Code'), keyboardType: TextInputType.number),
//             const SizedBox(height: 12),
//             TextFormField(controller: _address, decoration: _dec('Full Address'), maxLines: 2),
//             const SizedBox(height: 12),
//             TextFormField(controller: _gotra, decoration: _dec('Gotra')),
//             const SizedBox(height: 12),
//             TextFormField(controller: _occupation, decoration: _dec('Occupation')),
//             const SizedBox(height: 12),
//             TextFormField(controller: _education, decoration: _dec('Education')),
//
//             const SizedBox(height: 24),
//             SizedBox(
//               height: 48,
//               child: ElevatedButton(
//                 onPressed: _submitting ? null : _submit,
//                 style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//                 child: _submitting
//                     ? const SizedBox(
//                   height: 22, width: 22,
//                   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                 )
//                     : const Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
//
// class AddKaryakartaScreen extends StatefulWidget {
//   const AddKaryakartaScreen({super.key});
//   @override
//   State<AddKaryakartaScreen> createState() => _AddKaryakartaScreenState();
// }
//
// class _AddKaryakartaScreenState extends State<AddKaryakartaScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _api = ApiService();
//   bool _loading = false;
//
//   final _fullName = TextEditingController();
//   final _fatherName = TextEditingController();
//   final _dob = TextEditingController();
//   final _gender = TextEditingController(text: 'Male');
//   final _aadhaar = TextEditingController();
//   final _pan = TextEditingController();
//   final _mobile = TextEditingController();
//   final _altMobile = TextEditingController();
//   final _email = TextEditingController();
//   final _state = TextEditingController();
//   final _district = TextEditingController();
//   final _taluka = TextEditingController();
//   final _village = TextEditingController();
//   final _address = TextEditingController();
//   final _pincode = TextEditingController();
//   final _gotra = TextEditingController();
//   final _occupation = TextEditingController();
//   final _education = TextEditingController();
//
//   Future<void> _pickDob() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(1990, 1, 1),
//       firstDate: DateTime(1940),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       _dob.text =
//       "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
//       setState(() {});
//     }
//   }
//
//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _loading = true);
//
//     final payload = {
//       "full_name": _fullName.text.trim(),
//       "father_name": _fatherName.text.trim(),
//       "dob": _dob.text.trim(),
//       "gender": _gender.text.trim(),
//       "aadhaar_no": _aadhaar.text.trim(),
//       "pan_no": _pan.text.trim(),
//       "mobile": _mobile.text.trim(),
//       "alt_mobile": _altMobile.text.trim(),
//       "email": _email.text.trim(),
//       "state": _state.text.trim(),
//       "district": _district.text.trim(),
//       "taluka": _taluka.text.trim(),
//       "village": _village.text.trim(),
//       "full_address": _address.text.trim(),
//       "pincode": _pincode.text.trim(),
//       "gotra": _gotra.text.trim(),
//       "occupation": _occupation.text.trim(),
//       "education": _education.text.trim(),
//     };
//
//     try {
//       final res = await _api.createKaryakarta(payload);
//       if (!mounted) return;
//       if (res['success'] == true) {
//         final code = res['data']?['karyakarta_code'] ?? '';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Karyakarta created${code.isNotEmpty ? ' ($code)' : ''}")),
//         );
//         Navigator.pop(context, true); // true = tell caller to refresh list
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(res['message']?.toString() ?? "Failed to create karyakarta")),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }
//
//   Widget _field(String label, TextEditingController c, {bool required = false, TextInputType? type}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: TextFormField(
//         controller: c,
//         keyboardType: type,
//         decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
//         validator: required ? (v) => (v == null || v.trim().isEmpty) ? "$label is required" : null : null,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Karyakarta")),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             _field("Full Name", _fullName, required: true),
//             _field("Father Name", _fatherName, required: true),
//             TextFormField(
//               controller: _dob,
//               readOnly: true,
//               onTap: _pickDob,
//               decoration: const InputDecoration(labelText: "DOB (YYYY-MM-DD)", border: OutlineInputBorder()),
//               validator: (v) => (v == null || v.isEmpty) ? "DOB is required" : null,
//             ),
//             const SizedBox(height: 14),
//             DropdownButtonFormField<String>(
//               value: _gender.text,
//               decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
//               items: const [
//                 DropdownMenuItem(value: "Male", child: Text("Male")),
//                 DropdownMenuItem(value: "Female", child: Text("Female")),
//                 DropdownMenuItem(value: "Other", child: Text("Other")),
//               ],
//               onChanged: (v) => setState(() => _gender.text = v ?? "Male"),
//             ),
//             const SizedBox(height: 14),
//             _field("Aadhaar No", _aadhaar, required: true, type: TextInputType.number),
//             _field("PAN No", _pan),
//             _field("Mobile", _mobile, required: true, type: TextInputType.phone),
//             _field("Alt Mobile", _altMobile, type: TextInputType.phone),
//             _field("Email", _email, type: TextInputType.emailAddress),
//             _field("State", _state, required: true),
//             _field("District", _district, required: true),
//             _field("Taluka", _taluka),
//             _field("Village", _village),
//             _field("Full Address", _address),
//             _field("Pincode", _pincode, type: TextInputType.number),
//             _field("Gotra", _gotra),
//             _field("Occupation", _occupation),
//             _field("Education", _education),
//             const SizedBox(height: 12),
//             SizedBox(
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _submit,
//                 child: _loading
//                     ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                     : const Text("Save Karyakarta"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';

class AddKaryakartaScreen extends StatefulWidget {
  const AddKaryakartaScreen({super.key});
  @override
  State<AddKaryakartaScreen> createState() => _AddKaryakartaScreenState();
}

class _AddKaryakartaScreenState extends State<AddKaryakartaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _loading = false;

  final _fullName = TextEditingController();
  final _fatherName = TextEditingController();
  final _dob = TextEditingController();
  String _gender = 'Male';
  final _aadhaar = TextEditingController();
  final _pan = TextEditingController();
  final _mobile = TextEditingController();
  final _altMobile = TextEditingController();
  final _email = TextEditingController();

  // NEW: cascading working-area dropdowns (Section 2 in the web form)
  String? _state;
  String? _district;
  String? _taluka;
  final _village = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();

  // NEW: Section 3 fields
  final _gotra = TextEditingController();
  final _occupation = TextEditingController();
  final _education = TextEditingController();

  // NEW: Section 4 - documents + portal password
  PlatformFile? _passportPhoto;
  PlatformFile? _govtIdProof;
  PlatformFile? _authConsentLetter;
  final _password = TextEditingController(text: 'Suthar@2026');

  // TODO: replace this static demo map with real location-master data from
  // your backend (e.g. _api.getStates() / getDistricts(state) / getTalukas(district)).
  final Map<String, Map<String, List<String>>> _locationData = const {
    'Gujarat': {
      'Banaskantha': ['Amirgadh', 'Vav', 'Tharad', 'Palanpur'],
      'Ahmedabad': ['Daskroi', 'Sanand', 'Viramgam'],
    },
    'Rajasthan': {
      'Jodhpur': ['Bilara', 'Phalodi', 'Osian'],
      'Udaipur': ['Girwa', 'Salumbar'],
    },
  };

  // TODO: replace with a real gotra list from your backend / config master.
  final List<String> _gotraOptions = const [
    'Dayama', 'Suthar', 'Panchal', 'Vishwakarma', 'Bhandari', 'Rathod',
  ];

  List<String> get _districtOptions =>
      _state == null ? [] : _locationData[_state]!.keys.toList();
  List<String> get _talukaOptions =>
      (_state == null || _district == null) ? [] : _locationData[_state]![_district]!;

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dob.text =
      "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  // NEW: generic file picker used by the 3 document upload tiles
  Future<void> _pickFile(void Function(PlatformFile) onPicked) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() => onPicked(result.files.first));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passportPhoto == null || _govtIdProof == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passport Photo and Govt ID Proof are required")),
      );
      return;
    }
    setState(() => _loading = true);

    final payload = {
      "full_name": _fullName.text.trim(),
      "father_name": _fatherName.text.trim(),
      "dob": _dob.text.trim(),
      "gender": _gender,
      "aadhaar_no": _aadhaar.text.trim(),
      "pan_no": _pan.text.trim(),
      "mobile": _mobile.text.trim(),
      "alt_mobile": _altMobile.text.trim(),
      "email": _email.text.trim(),
      "state": _state ?? '',
      "district": _district ?? '',
      "taluka": _taluka ?? '',
      "village": _village.text.trim(),
      "full_address": _address.text.trim(),
      "pincode": _pincode.text.trim(),
      "gotra": _gotra.text.trim(),
      "occupation": _occupation.text.trim(),
      "education": _education.text.trim(),
      "initial_password": _password.text.trim(),
    };

    try {
      final res = await _api.createKaryakarta(
        payload,
        passportPhoto: _passportPhoto,
        govtIdProof: _govtIdProof,
        authConsentLetter: _authConsentLetter,
      );
      if (!mounted) return;
      if (res['success'] == true) {
        final code = res['data']?['karyakarta_code'] ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Karyakarta submitted for approval${code.isNotEmpty ? ' ($code)' : ''}")),
        );
        Navigator.pop(context, true); // true = tell caller to refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message']?.toString() ?? "Failed to create karyakarta")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---- shared helpers ----

  Widget _sectionHeader(String number, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF6A5AE0),
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          // Expanded lets long titles (e.g. "ASSIGNED WORKING AREA & ADDRESS
          // (LIVE LOCATION MASTER)") wrap onto a second line on narrow phones
          // instead of overflowing off the right edge of the screen.
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5, color: Color(0xFF2A1E6E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {bool required = false, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(labelText: required ? "$label *" : label, border: const OutlineInputBorder()),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? "$label is required" : null : null,
      ),
    );
  }

  // // NEW: tile used for the 3 document upload fields
  // Widget _fileTile(String label, PlatformFile? file, VoidCallback onTap, {bool required = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 14),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(required ? "$label *" : label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  //         const SizedBox(height: 6),
  //         Row(
  //           children: [
  //             OutlinedButton(onPressed: onTap, child: const Text("Choose File")),
  //             const SizedBox(width: 10),
  //             Expanded(
  //               child: Text(
  //                 file?.name ?? "No file chosen",
  //                 overflow: TextOverflow.ellipsis,
  //                 style: TextStyle(color: file == null ? Colors.grey.shade600 : Colors.black87, fontSize: 12),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // NEW: tile used for the 3 document upload fields
  Widget _fileTile(String label, PlatformFile? file, VoidCallback onTap, {bool required = false}) {
    // Use MediaQuery so the "Choose File" button never claims more than
    // ~45% of the screen width — the rest is guaranteed to the Expanded
    // filename text, which is what was overflowing on narrower phones.
    final screenWidth = MediaQuery.of(context).size.width;
    final maxButtonWidth = screenWidth * 0.45;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(required ? "$label *" : label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxButtonWidth),
                child: OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    "Choose File",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  file?.name ?? "No file chosen",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: file == null ? Colors.grey.shade600 : Colors.black87, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register New Karyakarta")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "New Karyakarta Application (Social Activist)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              "Enter applicant details. Application will be submitted for Admin Review & Approval.",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const Divider(height: 28),

            // ---- Section 1: Basic Personal Information ----
            _sectionHeader("1", "Basic Personal Information"),
            _field("Full Name", _fullName, required: true),
            _field("Father / Husband Name", _fatherName, required: true),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextFormField(
                controller: _dob,
                readOnly: true,
                onTap: _pickDob,
                decoration: const InputDecoration(labelText: "Date of Birth *", border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "DOB is required" : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: "Gender *", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male (पुरुष)")),
                  DropdownMenuItem(value: "Female", child: Text("Female (महिला)")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (v) => setState(() => _gender = v ?? "Male"),
              ),
            ),
            _field("Aadhaar Number (12 Digit)", _aadhaar, required: true, type: TextInputType.number),
            _field("PAN Number (Optional)", _pan),
            _field("Mobile (Portal User ID)", _mobile, required: true, type: TextInputType.phone),
            _field("Alternate Mobile", _altMobile, type: TextInputType.phone),
            _field("Email ID", _email, type: TextInputType.emailAddress),

            // ---- Section 2: Assigned Working Area & Address ----
            _sectionHeader("2", "Assigned Working Area & Address (Live Location Master)"),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<String>(
                value: _state,
                decoration: const InputDecoration(labelText: "State *", border: OutlineInputBorder()),
                items: _locationData.keys
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _state = v;
                  _district = null;
                  _taluka = null;
                }),
                validator: (v) => v == null ? "State is required" : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<String>(
                value: _district,
                decoration: const InputDecoration(labelText: "District *", border: OutlineInputBorder()),
                items: _districtOptions
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: _state == null
                    ? null
                    : (v) => setState(() {
                  _district = v;
                  _taluka = null;
                }),
                validator: (v) => v == null ? "District is required" : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<String>(
                value: _taluka,
                decoration: const InputDecoration(labelText: "Taluka / Tehsil *", border: OutlineInputBorder()),
                items: _talukaOptions
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: _district == null ? null : (v) => setState(() => _taluka = v),
                validator: (v) => v == null ? "Taluka is required" : null,
              ),
            ),
            _field("Village / City", _village, required: true),
            _field("Full Residential Address", _address, required: true),
            _field("PIN Code", _pincode, required: true, type: TextInputType.number),

            // ---- Section 3: Samaj & Background Information ----
            _sectionHeader("3", "Samaj & Background Information"),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue v) {
                  if (v.text.isEmpty) return _gotraOptions;
                  return _gotraOptions.where(
                          (o) => o.toLowerCase().contains(v.text.toLowerCase()));
                },
                onSelected: (v) => setState(() => _gotra.text = v),
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: (v) => _gotra.text = v,
                    decoration: const InputDecoration(
                      labelText: "Gotra * (Searchable Dropdown)",
                      hintText: "Search Gotra",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Gotra is required" : null,
                  );
                },
              ),
            ),
            _field("Occupation", _occupation, required: true),
            _field("Education", _education, required: true),

            // ---- Section 4: Document Uploads & Portal Password Control ----
            _sectionHeader("4", "Document Uploads & Portal Password Control"),
            _fileTile("Passport Photo", _passportPhoto,
                    () => _pickFile((f) => _passportPhoto = f), required: true),
            _fileTile("Govt ID Proof", _govtIdProof,
                    () => _pickFile((f) => _govtIdProof = f), required: true),
            _fileTile("Auth / Consent Letter", _authConsentLetter,
                    () => _pickFile((f) => _authConsentLetter = f)),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextFormField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: "Initial Portal Login Password *",
                  helperText: "Default: Suthar@2026",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Password is required" : null,
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6A5AE0)),
                      child: _loading
                          ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text("Submit Karyakarta for Approval"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}