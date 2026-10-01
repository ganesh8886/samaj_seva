// member_registration_screen.dart
//
// "Register New Samaj Member" screen — matches the 4-section web form:
//   1. Personal Information
//   2. Family & Nominee Information
//   3. Residential Area & Address (Location Master)
//   4. Documents Upload & Portal Password Security
//
// Drop this file into lib/screens/ (or wherever your other screens live)
// and update the import path in members_tab.dart accordingly.
//
// NOTE: File uploads below use a placeholder button (no real file picking).
// If you want actual file selection, add the `file_picker` package to
// pubspec.yaml and wire it into `_pickFile()`.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

// ---- Adjust this import to match where KColors lives in your project ----
import '../theme/k_colors.dart';
import 'karyakarta_dashboard_screen.dart'; // <-- change path if needed
import '../services/api_service.dart';

class MemberRegistrationScreen extends StatefulWidget {
  final String saCode; // e.g. "SA4281"
  final String saName; // e.g. "Govindbhai M. Suthar (Pepar)"

  const MemberRegistrationScreen({
    super.key,
    required this.saCode,
    required this.saName,
  });

  @override
  State<MemberRegistrationScreen> createState() =>
      _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // ---- Section 1: Personal Information ----
  final _fullNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  String? _gotraId;
  String? _gender;
  DateTime? _dob;
  int? _calculatedAge;

  List<Map<String, dynamic>> _gotras = [];
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  // ---- Section 2: Family & Nominee Information ----
  final _fatherNameCtrl = TextEditingController();
  final _motherNameCtrl = TextEditingController();
  final _guardianNameCtrl = TextEditingController();
  final _nomineeNameCtrl = TextEditingController();
  String? _nomineeRelation;

  final List<String> _nomineeRelationOptions = [
    'Father (पिता)',
    'Mother (माता)',
    'Husband (पति)',
    'Wife (पत्नी)',
    'Son (पुत्र)',
    'Daughter (पुत्री)',
  ];

  // ---- Section 3: Residential Area & Address ----
  final _villageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pinCodeCtrl = TextEditingController();
  String? _stateId;
  String? _districtId;
  String? _talukaId;

  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];

  // ---- Section 4: Documents & Password ----
  String? _passportPhotoName;
  String? _govtIdProofName;
  String? _authLetterName;
  final _passwordCtrl = TextEditingController(text: 'Suthar@2026');
  @override
  void initState() {
    super.initState();
    _loadGotras();
    _loadStates();
  }
  String _itemId(Map<String, dynamic> m) =>
      (m['id'] ?? m['gotra_id'] ?? m['state_id'] ?? m['district_id'] ?? m['taluka_id'] ?? '')
          .toString();

  String _itemName(Map<String, dynamic> m) {
    const keys = [
      'name_en', 'name', 'name_hi',
      'gotra_name', 'gotra', 'state_name', 'district_name', 'taluka_name', 'title',
    ];
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    // fallback: first text value that is not an id/date
    for (final e in m.entries) {
      if (e.value is String &&
          !e.key.toLowerCase().contains('id') &&
          !e.key.toLowerCase().contains('at') &&
          (e.value as String).trim().isNotEmpty) {
        return e.value as String;
      }
    }
    return '-';
  }

  String? _nameOf(List<Map<String, dynamic>> list, String? id) {
    if (id == null) return null;
    for (final e in list) {
      if (_itemId(e) == id) return _itemName(e);
    }
    return null;
  }

  Future<void> _loadGotras() async {
    final l = await ApiService().getGotras();
    if (!mounted) return;
    setState(() => _gotras = l);
  }

  Future<void> _loadStates() async {
    final l = await ApiService().getStates();
    if (!mounted) return;
    setState(() => _states = l);
  }

  Future<void> _onStateChanged(String? id) async {
    setState(() {
      _stateId = id;
      _districtId = null;
      _talukaId = null;
      _districts = [];
      _talukas = [];
    });
    if (id == null) return;
    final l = await ApiService().getDistricts(id);
    if (!mounted) return;
    setState(() => _districts = l);
  }

  Future<void> _onDistrictChanged(String? id) async {
    setState(() {
      _districtId = id;
      _talukaId = null;
      _talukas = [];
    });
    if (id == null) return;
    final l = await ApiService().getTalukas(id);
    if (!mounted) return;
    setState(() => _talukas = l);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _mobileCtrl.dispose();
    _aadhaarCtrl.dispose();
    _fatherNameCtrl.dispose();
    _motherNameCtrl.dispose();
    _guardianNameCtrl.dispose();
    _nomineeNameCtrl.dispose();
    _villageCtrl.dispose();
    _addressCtrl.dispose();
    _pinCodeCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1930),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _calculatedAge = _ageFromDob(picked, now);
      });
    }
  }

  int _ageFromDob(DateTime dob, DateTime now) {
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  // Real file picker — updates the passed-in field via onPicked(fileName).
  Future<void> _pickFile(String fieldLabel, void Function(String) onPicked) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      onPicked(result.files.single.name);
    }
  }

  // void _saveMember() {
  //   if (!_formKey.currentState!.validate()) return;
  //   if (_dob == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select Date of Birth')),
  //     );
  //     return;
  //   }
  //   if (_gotra == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select Gotra')),
  //     );
  //     return;
  //   }
  //
  //   // TODO: replace with your actual API/save call
  //   final payload = {
  //     'sa_code': widget.saCode,
  //     'full_name': _fullNameCtrl.text.trim(),
  //     'gotra': _gotra,
  //     'dob': _fmtDate(_dob!),
  //     'age': _calculatedAge,
  //     'gender': _gender,
  //     'mobile': _mobileCtrl.text.trim(),
  //     'aadhaar': _aadhaarCtrl.text.trim(),
  //     'father_name': _fatherNameCtrl.text.trim(),
  //     'mother_name': _motherNameCtrl.text.trim(),
  //     'guardian_name': _guardianNameCtrl.text.trim(),
  //     'nominee_name': _nomineeNameCtrl.text.trim(),
  //     'nominee_relation': _nomineeRelation,
  //     'state': _state,
  //     'district': _district,
  //     'taluka': _taluka,
  //     'village': _villageCtrl.text.trim(),
  //     'address': _addressCtrl.text.trim(),
  //     'pin_code': _pinCodeCtrl.text.trim(),
  //     'passport_photo': _passportPhotoName,
  //     'govt_id_proof': _govtIdProofName,
  //     'auth_letter': _authLetterName,
  //     'initial_password': _passwordCtrl.text,
  //   };
  //
  //   debugPrint('Saving member: $payload');
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Member saved successfully')),
  //   );
  //   Navigator.of(context).pop(payload); // return data to caller (e.g. My Members list)
  // }
  bool _saving = false;

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date of Birth')),
      );
      return;
    }
    if (_gotraId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Gotra')),
      );
      return;
    }
    if (_stateId == null || _districtId == null || _talukaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select State, District and Taluka')),
      );
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);

    // Field names match POST /api/karyakarta/members exactly.
    // (sa_code / age / files / password are dropped — the backend derives
    // karyakarta_id from the auth token and this endpoint doesn't take files.)
    final payload = {
      'full_name': _fullNameCtrl.text.trim(),
      'gotra': _nameOf(_gotras, _gotraId),
      'dob':
      '${_dob!.year.toString().padLeft(4, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
      'gender': _gender,
      'mobile': _mobileCtrl.text.trim(),
      'aadhaar_no': _aadhaarCtrl.text.trim(),
      'father_name': _fatherNameCtrl.text.trim(),
      'mother_name': _motherNameCtrl.text.trim(),
      'guardian_name': _guardianNameCtrl.text.trim(),
      'nominee_name': _nomineeNameCtrl.text.trim(),
      'nominee_relation': _nomineeRelation,
      'state': _nameOf(_states, _stateId),
      'district': _nameOf(_districts, _districtId),
      'taluka': _nameOf(_talukas, _talukaId),
      'village': _villageCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'pincode': _pinCodeCtrl.text.trim(),
    };

    final result = await ApiService().createKaryakartaMember(payload);

    if (!mounted) return;
    setState(() => _saving = false);

    final success = result['success'] == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ??
            (success ? 'Member saved successfully' : 'Failed to save member')),
      ),
    );

    if (success) {
      Navigator.of(context).pop(result['data']); // returns {member_id, member_code} to My Members list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        automaticallyImplyLeading: false, // 👈 stops Flutter from adding its own back arrow
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Register New Samaj Member',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const Text(
                    'Complete personal profile with auto-locked Karyakarta tag & live location master.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _lockedSaCard(),
            const SizedBox(height: 16),
            _sectionCard(
              index: '1',
              title: 'PERSONAL INFORMATION',
              children: [
                _twoCol(
                  _textField(_fullNameCtrl, 'Full Name (as per documents) *',
                      hint: 'Member Full Name', required: true),
                  _apiDropdown('Gotra *', _gotraId, _gotras,
                      hint: 'Select Gotra',
                      onChanged: (v) => setState(() => _gotraId = v)),
                ),
                _twoCol(
                  _dateField(),
                  _dropdown('Gender *', _gender, _genderOptions,
                      hint: 'Select Gender',
                      onChanged: (v) => setState(() => _gender = v)),
                ),
                _twoCol(
                  _readOnlyField('Calculated Age',
                      _calculatedAge?.toString() ?? '', hint: 'Auto Calculated'),
                  _textField(_mobileCtrl, 'Mobile Number *',
                      hint: '10-Digit Mobile',
                      keyboardType: TextInputType.phone,
                      required: true,
                      maxLength: 10),
                ),
                _textField(_aadhaarCtrl, 'Aadhaar Number (12 Digit)',
                    hint: '12-Digit Number',
                    keyboardType: TextInputType.number,
                    maxLength: 12),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              index: '2',
              title: 'FAMILY & NOMINEE INFORMATION',
              children: [
                _twoCol(
                  _textField(_fatherNameCtrl, 'Father Name', hint: 'Father Name'),
                  _textField(_motherNameCtrl, 'Mother Name', hint: 'Mother Name'),
                ),
                _twoCol(
                  _textField(_guardianNameCtrl, 'Husband / Guardian Name',
                      hint: 'Husband / Guardian Name'),
                  const SizedBox.shrink(),
                ),
                _twoCol(
                  _textField(_nomineeNameCtrl, 'Nominee Name *',
                      hint: 'Nominee Full Name', required: true),
                  _dropdown('Nominee Relation *', _nomineeRelation,
                      _nomineeRelationOptions,
                      onChanged: (v) => setState(() => _nomineeRelation = v)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              index: '3',
              title: 'RESIDENTIAL AREA & ADDRESS (LOCATION MASTER)',
              children: [
                _twoCol(
                  _apiDropdown('State *', _stateId, _states,
                      onChanged: _onStateChanged),
                  _apiDropdown('District *', _districtId, _districts,
                      onChanged: _onDistrictChanged),
                ),
                _twoCol(
                  _apiDropdown('Taluka / Tehsil *', _talukaId, _talukas,
                      onChanged: (v) => setState(() => _talukaId = v)),
                  _textField(_villageCtrl, 'Village / City *',
                      hint: 'Village Name', required: true),
                ),
                _twoCol(
                  _textField(_addressCtrl, 'Full Residential Address *',
                      hint: 'Street, House No, Landmark', required: true),
                  _textField(_pinCodeCtrl, 'PIN Code *',
                      hint: '6-Digit PIN',
                      keyboardType: TextInputType.number,
                      required: true,
                      maxLength: 6),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              index: '4',
              title: 'DOCUMENTS UPLOAD & PORTAL PASSWORD SECURITY',
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = MediaQuery.of(context).size.width < 380;
                    final itemWidth =
                        isNarrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 3;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _fileField('Upload Passport Photo', _passportPhotoName,
                              () => _pickFile('Passport Photo',
                                  (n) => setState(() => _passportPhotoName = n))),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _fileField('Upload Govt ID Proof', _govtIdProofName,
                              () => _pickFile('Govt ID Proof',
                                  (n) => setState(() => _govtIdProofName = n))),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _fileField('Upload Auth / Terms Letter', _authLetterName,
                              () => _pickFile('Auth Letter',
                                  (n) => setState(() => _authLetterName = n))),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _textField(_passwordCtrl, 'Initial Portal Login Password *',
                          required: true),
                      const SizedBox(height: 6),
                      const Text('Default suggestion: Suthar@2026',
                          style: TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saving ? null : _saveMember,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: _saving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Save Member Details'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------------- Reusable pieces ----------------

  Widget _lockedSaCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ASSIGNED SOCIAL ACTIVIST (SA CODE)',
                    style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${widget.saCode} - ${widget.saName}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 13, color: KColors.primary),
                SizedBox(width: 4),
                Text('Locked & Disabled',
                    style: TextStyle(fontSize: 11, color: KColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String index,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: KColors.primary,
                child: Text(index,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children.expand((w) => [w, const SizedBox(height: 14)]),
        ],
      ),
    );
  }

  Widget _twoCol(Widget a, Widget b) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        Expanded(child: b),
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
  );

  Widget _textField(
      TextEditingController ctrl,
      String label, {
        String? hint,
        bool required = false,
        TextInputType? keyboardType,
        int? maxLength,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
        ),
      ],
    );
  }

  Widget _readOnlyField(String label, String value, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(value.isEmpty ? (hint ?? '') : value,
              style: TextStyle(color: value.isEmpty ? Colors.black38 : Colors.black87)),
        ),
      ],
    );
  }

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Date of Birth *'),
        InkWell(
          onTap: _pickDob,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_dob == null ? 'dd-mm-yyyy' : _fmtDate(_dob!),
                    style: TextStyle(color: _dob == null ? Colors.black38 : Colors.black87)),
                const Icon(Icons.calendar_today_outlined, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(
      String label,
      String? value,
      List<String> options, {
        String? hint,
        required void Function(String?) onChanged,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          hint: Text(hint ?? 'Select'),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onChanged,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }
  Widget _apiDropdown(
      String label,
      String? value,
      List<Map<String, dynamic>> items, {
        String? hint,
        required void Function(String?) onChanged,
      }) {
    final ids = items.map((e) => _itemId(e)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        DropdownButtonFormField<String>(
          value: ids.contains(value) ? value : null,
          isExpanded: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          hint: Text(items.isEmpty ? 'Loading...' : (hint ?? 'Select')),
          items: items
              .map((e) => DropdownMenuItem<String>(
            value: _itemId(e),
            child: Text(_itemName(e), overflow: TextOverflow.ellipsis),
          ))
              .toList(),
          onChanged: onChanged,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _fileField(String label, String? fileName, VoidCallback onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.upload_file, size: 16),
          label: Text(
            fileName ?? 'Choose File',
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }
}