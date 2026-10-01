// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
//
// class AddMemberScreen extends StatefulWidget {
//   const AddMemberScreen({super.key});
//   @override
//   State<AddMemberScreen> createState() => _AddMemberScreenState();
// }
//
// class _AddMemberScreenState extends State<AddMemberScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _api = ApiService();
//   bool _loading = false;
//
//   final _karyakartaId = TextEditingController();
//   final _fullName = TextEditingController();
//   final _gotra = TextEditingController();
//   final _dob = TextEditingController();
//   final _gender = TextEditingController(text: 'Male');
//   final _mobile = TextEditingController();
//   final _aadhaar = TextEditingController();
//   final _fatherName = TextEditingController();
//   final _motherName = TextEditingController();
//   final _nomineeName = TextEditingController();
//   final _nomineeRelation = TextEditingController();
//   final _state = TextEditingController();
//   final _district = TextEditingController();
//   final _taluka = TextEditingController();
//   final _village = TextEditingController();
//   final _address = TextEditingController();
//   final _pincode = TextEditingController();
//
//   Future<void> _pickDob() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(1998, 1, 1),
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
//       "karyakarta_id": int.tryParse(_karyakartaId.text.trim()) ?? 0,
//       "full_name": _fullName.text.trim(),
//       "gotra": _gotra.text.trim(),
//       "dob": _dob.text.trim(),
//       "gender": _gender.text.trim(),
//       "mobile": _mobile.text.trim(),
//       "aadhaar_no": _aadhaar.text.trim(),
//       "father_name": _fatherName.text.trim(),
//       "mother_name": _motherName.text.trim(),
//       "nominee_name": _nomineeName.text.trim(),
//       "nominee_relation": _nomineeRelation.text.trim(),
//       "state": _state.text.trim(),
//       "district": _district.text.trim(),
//       "taluka": _taluka.text.trim(),
//       "village": _village.text.trim(),
//       "address": _address.text.trim(),
//       "pincode": _pincode.text.trim(),
//     };
//
//     try {
//       final res = await _api.createMember(payload);
//       if (!mounted) return;
//       if (res['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Member created")),
//         );
//         Navigator.pop(context, true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(res['message']?.toString() ?? "Failed to create member")),
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
//       appBar: AppBar(title: const Text("Add Member")),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             _field("Karyakarta ID", _karyakartaId, required: true, type: TextInputType.number),
//             _field("Full Name", _fullName, required: true),
//             _field("Gotra", _gotra),
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
//             _field("Mobile", _mobile, required: true, type: TextInputType.phone),
//             _field("Aadhaar No", _aadhaar, required: true, type: TextInputType.number),
//             _field("Father Name", _fatherName, required: true),
//             _field("Mother Name", _motherName),
//             _field("Nominee Name", _nomineeName),
//             _field("Nominee Relation", _nomineeRelation),
//             _field("State", _state, required: true),
//             _field("District", _district, required: true),
//             _field("Taluka", _taluka),
//             _field("Village", _village),
//             _field("Address", _address),
//             _field("Pincode", _pincode, type: TextInputType.number),
//             const SizedBox(height: 12),
//             SizedBox(
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _submit,
//                 child: _loading
//                     ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                     : const Text("Save Member"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/karyakarta_model.dart';
import '../services/api_service.dart';
import '../services/api_service_additions.dart';

/// NOTE on assumptions you may need to tweak:
/// - KaryakartaModel is assumed to expose `id` (int) and `fullName` (String).
/// - getGotras() / getStates() / getDistricts() / getTalukas() are assumed to
///   return List<Map<String,dynamic>> where each item has 'id' and 'name'.
///   If your backend uses different keys, adjust the `g['name']`, `s['name']`
///   etc. references below.
/// - This screen calls `_api.createMemberWithFiles(...)`, a new method you
///   need to add to ApiService (see the api_service_additions.dart snippet).

class AddMemberScreen extends StatefulWidget {
  final int? editMemberId; // NEW — pass a member's `id` to edit instead of create
  const AddMemberScreen({super.key, this.editMemberId});
  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _saving = false;
  bool _loadingExisting = false; // NEW
  bool get _isEditMode => widget.editMemberId != null; // NEW

  // Assigned karyakarta
  List<KaryakartaModel> _karyakartas = [];
  int? _selectedKaryakartaId;

  // Section 1 — personal info
  final _fullNameCtrl = TextEditingController();
  List<Map<String, dynamic>> _gotras = [];
  String? _selectedGotra;
  DateTime? _dob;
  String _gender = 'Female';
  final _mobileCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();

  // Section 2 — family & nominee
  final _fatherCtrl = TextEditingController();
  final _motherCtrl = TextEditingController();
  final _guardianCtrl = TextEditingController();
  final _nomineeNameCtrl = TextEditingController();
  String _nomineeRelation = 'Father';

  // Section 3 — residential
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  String? _selectedStateId;
  String? _selectedDistrictId;
  String? _selectedTalukaId;
  final _villageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  // Section 4 — documents & password
  PlatformFile? _passportPhoto;
  PlatformFile? _govtIdProof;
  PlatformFile? _authConsentLetter;
  final _passwordCtrl = TextEditingController(text: 'Suthar@2026');

  int get _calculatedAge {
    if (_dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - _dob!.year;
    if (now.month < _dob!.month || (now.month == _dob!.month && now.day < _dob!.day)) age--;
    return age;
  }

  @override
  void initState() {
    super.initState();
    _loadKaryakartas();
    _loadGotras();
    _loadStates();
    if (_isEditMode) _loadExistingMember(); // NEW
  }

  // NEW — fetches GET /members/{id} and prefills every field
  Future<void> _loadExistingMember() async {
    setState(() => _loadingExisting = true);
    final m = await _api.getMemberById(widget.editMemberId.toString());
    if (m != null && mounted) {
      _fullNameCtrl.text = m.fullName;
      _selectedGotra = m.gotra.isEmpty ? null : m.gotra;
      _dob = DateTime.tryParse(m.dob);
      _gender = m.gender.isEmpty ? 'Female' : m.gender;
      _mobileCtrl.text = m.mobile;
      _aadhaarCtrl.text = m.aadhaarNo;
      _fatherCtrl.text = m.fatherName;
      _motherCtrl.text = m.motherName;
      _guardianCtrl.text = m.guardianName.isNotEmpty ? m.guardianName : m.husbandName;
      _nomineeNameCtrl.text = m.nomineeName;
      _nomineeRelation = m.nomineeRelation.isNotEmpty ? m.nomineeRelation : 'Father';
      _villageCtrl.text = m.village;
      _addressCtrl.text = m.address;
      _pincodeCtrl.text = m.pincode;
      _selectedKaryakartaId = m.karyakartaId == 0 ? null : m.karyakartaId;
      _passwordCtrl.text = ''; // NEW — edit mode: blank means "keep current password"

      // Resolve state/district/taluka NAMES (from API) back to the IDs your
      // dropdowns use, by matching on `name` once each list is loaded.
      final states = await _api.getStates();
      if (mounted) setState(() => _states = states);
      final matchState = states.where((s) => s['state_name']?.toString() == m.state);
      if (matchState.isNotEmpty) {
        final stateId = matchState.first['id']?.toString();
        _selectedStateId = stateId;
        if (stateId != null) {
          final districts = await _api.getDistricts(stateId);
          if (mounted) setState(() => _districts = districts);
          final matchDistrict = districts.where((d) => d['district_name']?.toString() == m.district);
          if (matchDistrict.isNotEmpty) {
            final districtId = matchDistrict.first['id']?.toString();
            _selectedDistrictId = districtId;
            if (districtId != null) {
              final talukas = await _api.getTalukas(districtId);
              if (mounted) setState(() => _talukas = talukas);
              final matchTaluka = talukas.where((t) => t['taluka_name']?.toString() == m.taluka);
              if (matchTaluka.isNotEmpty) {
                _selectedTalukaId = matchTaluka.first['id']?.toString();
              }
            }
          }
        }
      }
    }
    if (mounted) setState(() => _loadingExisting = false);
  }

  Future<void> _loadKaryakartas() async {
    final list = await _api.getKaryakartas();
    if (mounted) setState(() => _karyakartas = list);
  }

  Future<void> _loadGotras() async {
    final list = await _api.getGotras();
    if (mounted) setState(() => _gotras = list);
  }

  Future<void> _loadStates() async {
    final list = await _api.getStates();
    if (mounted) setState(() => _states = list);
  }

  Future<void> _onStateChanged(String? stateId) async {
    setState(() {
      _selectedStateId = stateId;
      _selectedDistrictId = null;
      _selectedTalukaId = null;
      _districts = [];
      _talukas = [];
    });
    if (stateId != null) {
      final list = await _api.getDistricts(stateId);
      if (mounted) setState(() => _districts = list);
    }
  }

  Future<void> _onDistrictChanged(String? districtId) async {
    setState(() {
      _selectedDistrictId = districtId;
      _selectedTalukaId = null;
      _talukas = [];
    });
    if (districtId != null) {
      final list = await _api.getTalukas(districtId);
      if (mounted) setState(() => _talukas = list);
    }
  }

  Future<void> _pickFile(void Function(PlatformFile) onPicked) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      onPicked(result.files.first);
      setState(() {});
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select Date of Birth')));
      return;
    }
    setState(() => _saving = true);

    final payload = {
      'karyakarta_id': _selectedKaryakartaId,
      'full_name': _fullNameCtrl.text.trim(),
      'gotra': _selectedGotra,
      'dob': _fmtDate(_dob!),
      'gender': _gender,
      'mobile': _mobileCtrl.text.trim(),
      'aadhaar_no': _aadhaarCtrl.text.trim(),
      'father_name': _fatherCtrl.text.trim(),
      'mother_name': _motherCtrl.text.trim(),
      'guardian_name': _guardianCtrl.text.trim(),
      'nominee_name': _nomineeNameCtrl.text.trim(),
      'nominee_relation': _nomineeRelation,
      'state': _selectedStateId,
      'district': _selectedDistrictId,
      'taluka': _selectedTalukaId,
      'village': _villageCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim(),
      'portal_password': _passwordCtrl.text.trim(),
    };

    Map<String, dynamic> res;
    if (_isEditMode) {
      // Edit mode: JSON PUT, no file re-upload, password only sent if changed
      final updatePayload = Map<String, dynamic>.from(payload);
      if (_passwordCtrl.text.trim().isEmpty) {
        updatePayload.remove('portal_password');
      }
      res = await _api.updateMember(widget.editMemberId.toString(), updatePayload);
    } else {
      res = await _api.createMemberWithFiles(
        payload,
        passportPhoto: _passportPhoto,
        govtIdProof: _govtIdProof,
        authConsentLetter: _authConsentLetter,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['message']?.toString() ??
          (res['success'] == true ? 'Member saved' : 'Failed to save member')),
    ));

    if (res['success'] == true) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _mobileCtrl.dispose();
    _aadhaarCtrl.dispose();
    _fatherCtrl.dispose();
    _motherCtrl.dispose();
    _guardianCtrl.dispose();
    _nomineeNameCtrl.dispose();
    _villageCtrl.dispose();
    _addressCtrl.dispose();
    _pincodeCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Register New Member')),
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Member Details: ${_fullNameCtrl.text}' : 'Register New Member')),
      body: _loadingExisting
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              child: DropdownButtonFormField<int>(
                value: _selectedKaryakartaId,
                decoration: const InputDecoration(
                  labelText: 'Assigned Social Activist (Karyakarta / SA Code) *',
                  border: OutlineInputBorder(),
                ),
                items: _karyakartas
                    .map((k) => DropdownMenuItem(value: k.id, child: Text(k.fullName)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedKaryakartaId = v),
              ),
            ),
            const SizedBox(height: 16),
            _sectionHeader('1', 'PERSONAL INFORMATION'),
            _sectionCard(
              child: Column(children: [
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: _isEditMode
                        ? 'Update Portal Password (Leave blank to keep existing password)'
                        : 'Initial Portal Login Password *',
                    helperText: _isEditMode ? 'Leave blank to keep current password' : 'Default suggestion: Suthar@2026',
                    border: const OutlineInputBorder(),
                  ),
                  validator: _isEditMode
                      ? null
                      : (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedGotra,
                  decoration: const InputDecoration(labelText: 'Gotra *', border: OutlineInputBorder()),
                  items: _gotras
                      .map((g) => DropdownMenuItem(
                      value: g['gotra_en']?.toString(),
                      child: Text(g['gotra_en']?.toString() ?? '')))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGotra = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDob,
                  child: InputDecorator(
                    decoration:
                    const InputDecoration(labelText: 'Date of Birth *', border: OutlineInputBorder()),
                    child: Text(_dob == null ? 'dd-mm-yyyy' : _fmtDate(_dob!)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _gender = v ?? 'Female'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration:
                  const InputDecoration(labelText: 'Calculated Age', border: OutlineInputBorder()),
                  enabled: false,
                  controller: TextEditingController(text: _dob == null ? '' : '$_calculatedAge'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration:
                  const InputDecoration(labelText: '10-Digit Mobile *', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().length != 10) ? 'Enter 10-digit mobile' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _aadhaarCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  decoration: const InputDecoration(
                      labelText: '12-Digit Aadhaar Number', border: OutlineInputBorder()),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            _sectionHeader('2', 'FAMILY & NOMINEE INFORMATION'),
            _sectionCard(
              child: Column(children: [
                TextFormField(
                    controller: _fatherCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Father Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _motherCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Mother Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _guardianCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Husband / Guardian Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomineeNameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nominee Full Name *', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _nomineeRelation,
                  decoration:
                  const InputDecoration(labelText: 'Nominee Relation *', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Father', child: Text('Father (पिता)')),
                    DropdownMenuItem(value: 'Mother', child: Text('Mother (माता)')),
                    DropdownMenuItem(value: 'Spouse', child: Text('Spouse (पति/पत्नी)')),
                    DropdownMenuItem(value: 'Son', child: Text('Son (पुत्र)')),
                    DropdownMenuItem(value: 'Daughter', child: Text('Daughter (पुत्री)')),
                  ],
                  onChanged: (v) => setState(() => _nomineeRelation = v ?? 'Father'),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            _sectionHeader('3', 'RESIDENTIAL AREA & ADDRESS (LOCATION MASTER)'),
            _sectionCard(
              child: Column(children: [
                DropdownButtonFormField<String>(
                  value: _selectedStateId,
                  decoration: const InputDecoration(labelText: 'State *', border: OutlineInputBorder()),
                  items: _states
                      .map((s) =>
                      DropdownMenuItem(value: s['id']?.toString(), child: Text(s['state_name']?.toString() ?? '')))
                      .toList(),
                  onChanged: _onStateChanged,
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedDistrictId,
                  decoration: const InputDecoration(labelText: 'District *', border: OutlineInputBorder()),
                  items: _districts
                      .map((d) =>
                      DropdownMenuItem(value: d['id']?.toString(), child: Text(d['district_name']?.toString() ?? '')))
                      .toList(),
                  onChanged: _onDistrictChanged,
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedTalukaId,
                  decoration:
                  const InputDecoration(labelText: 'Taluka / Tehsil *', border: OutlineInputBorder()),
                  items: _talukas
                      .map((t) =>
                      DropdownMenuItem(value: t['id']?.toString(), child: Text(t['taluka_name']?.toString() ?? '')))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTalukaId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _villageCtrl,
                  decoration:
                  const InputDecoration(labelText: 'Village / City *', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Full Residential Address *', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pincodeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(labelText: 'PIN Code *', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().length != 6) ? 'Enter 6-digit PIN' : null,
                ),
              ]),
            ),
            const SizedBox(height: 16),
            _sectionHeader('4', 'DOCUMENTS UPLOAD & PORTAL PASSWORD SECURITY'),
            _sectionCard(
              child: Column(children: [
                _filePickerRow('Upload Passport Photo', _passportPhoto, () => _pickFile((f) => _passportPhoto = f)),
                const SizedBox(height: 12),
                _filePickerRow('Upload Govt ID Proof', _govtIdProof, () => _pickFile((f) => _govtIdProof = f)),
                const SizedBox(height: 12),
                _filePickerRow(
                    'Upload Auth / Terms Letter', _authConsentLetter, () => _pickFile((f) => _authConsentLetter = f)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Initial Portal Login Password *',
                    helperText: 'Default suggestion: Suthar@2026',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                        height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save Member Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String number, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        CircleAvatar(radius: 12, child: Text(number, style: const TextStyle(fontSize: 12))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
      ]),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _filePickerRow(String label, PlatformFile? file, VoidCallback onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(children: [
          OutlinedButton(onPressed: onPick, child: const Text('Choose File')),
          const SizedBox(width: 12),
          Expanded(child: Text(file?.name ?? 'No file chosen', overflow: TextOverflow.ellipsis)),
        ]),
      ],
    );
  }
}