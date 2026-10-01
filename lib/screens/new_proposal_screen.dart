import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class NewProposalScreen extends StatefulWidget {
  const NewProposalScreen({super.key});
  @override
  State<NewProposalScreen> createState() => _NewProposalScreenState();
}

class _NewProposalScreenState extends State<NewProposalScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  // ---- top row ----
  List<Map<String, dynamic>> _schemes = [];
  int? _schemeId;
  bool _isNewMember = true;

  // ---- NEW: Tagged Karyakarta (SA Code) search ----
  final _karyakartaSearchCtrl = TextEditingController();
  List<Map<String, dynamic>> _karyakartaResults = [];
  Map<String, dynamic>? _selectedKaryakarta; // {sa_code, name, mobile, village}
  bool _searchingKaryakarta = false;

  // ---- existing member ----
  final _fetchCtrl = TextEditingController();
  Map<String, dynamic>? _existingMember;
  bool _fetching = false;
  bool _memberLocked = false; // NEW — true once an existing member is fetched

  // ---- new member: personal ----
  final _fullNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  DateTime? _dob;
  String _gender = 'Female';
  List<Map<String, dynamic>> _gotras = [];
  int? _gotraId;
  String? _gotraName;

  // ---- family & nominee ----
  final _fatherCtrl = TextEditingController();
  final _motherCtrl = TextEditingController();
  final _guardianCtrl = TextEditingController();
  final _nomineeNameCtrl = TextEditingController();
  String _nomineeRelation = 'Father';
  static const _relations = ['Father', 'Mother', 'Spouse', 'Son', 'Daughter', 'Guardian'];

  // ---- address ----
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  String? _stateId, _districtId, _talukaId;
  final _villageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  // ---- documents (attach to the enrollment/proposal record) ----
  PlatformFile? _photoFile;      // photo_file
  PlatformFile? _memberIdFile;   // doc_file (member govt id)
  PlatformFile? _guardianIdFile; // father_doc_file (parent/guardian id)
  PlatformFile? _authFile;       // auth_file (auth / consent letter)

  // ---- fee & payment ----
  double _joiningFee = 0;
  double _perEventFee = 0;
  String _paymentMode = 'Cash';
  bool _agreed = false;
  bool _submitting = false;
  bool _calculating = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final results = await Future.wait([
      _api.getSchemesRaw(),
      _api.getGotras(),
      _api.getStates(),
    ]);
    if (!mounted) return;
    setState(() {
      _schemes = results[0];
      _gotras = results[1];
      _states = results[2];
    });
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
    final list = await _api.getDistricts(id);
    if (mounted) setState(() => _districts = list);
  }

  Future<void> _onDistrictChanged(String? id) async {
    setState(() {
      _districtId = id;
      _talukaId = null;
      _talukas = [];
    });
    if (id == null) return;
    final list = await _api.getTalukas(id);
    if (mounted) setState(() => _talukas = list);
  }

  Future<void> _calcFee() async {
    if (_dob == null || _schemeId == null) return;
    setState(() => _calculating = true);
    final dobStr =
        '${_dob!.year.toString().padLeft(4, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}';
    final res = await _api.calculateSlab(dobStr, _schemeId!);
    if (!mounted) return;
    final data = (res['data'] ?? res) as Map;
    setState(() {
      _joiningFee = double.tryParse('${data['joining_fee'] ?? 0}') ?? 0;
      _perEventFee =
          double.tryParse('${data['per_event_installment'] ?? data['per_event'] ?? 0}') ?? 0;
      _calculating = false;
    });
  }

  Future<void> _fetchExistingMember() async {
    final q = _fetchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _fetching = true);
    final members = await _api.getKaryakartaMembers();
    Map<String, dynamic>? found;
    try {
      found = members.firstWhere((m) =>
      m['id'].toString() == q ||
          (m['mobile']?.toString() ?? '') == q ||
          (m['aadhaar_no']?.toString() ?? '') == q);
    } catch (_) {
      found = null;
    }
    if (!mounted) return;

    if (found == null) {
      setState(() {
        _existingMember = null;
        _fetching = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No member found with that ID/Mobile/Aadhaar')));
      return;
    }

    // NEW — prefill Personal / Family / Address sections so the layout
    // stays the same as "New Member", just locked and pre-populated.
    _fullNameCtrl.text = (found['full_name'] ?? found['name'] ?? '').toString();
    _mobileCtrl.text = (found['mobile'] ?? '').toString();
    _aadhaarCtrl.text = (found['aadhaar_no'] ?? found['aadhaar_number'] ?? '').toString();
    final dobStr = found['dob']?.toString();
    _dob = (dobStr == null || dobStr.isEmpty) ? null : DateTime.tryParse(dobStr);
    final genderStr = (found['gender'] ?? '').toString();
    if (genderStr.isNotEmpty) _gender = genderStr;
    _fatherCtrl.text = (found['father_name'] ?? '').toString();
    _motherCtrl.text = (found['mother_name'] ?? '').toString();
    _guardianCtrl.text = (found['guardian_name'] ?? '').toString();
    _villageCtrl.text = (found['village'] ?? found['village_city'] ?? '').toString();
    _addressCtrl.text = (found['address'] ?? found['full_address'] ?? '').toString();
    _pincodeCtrl.text = (found['pincode'] ?? found['pin_code'] ?? '').toString();

    // Match gotra name -> id from the already-loaded _gotras list.
    final gotraName = (found['gotra'] ?? '').toString();
    if (gotraName.isNotEmpty) {
      final matchGotra = _gotras.where((g) =>
      (g['name'] ?? g['gotra_name'] ?? g['gotra_en'] ?? '').toString() == gotraName);
      if (matchGotra.isNotEmpty) {
        _gotraId = int.tryParse(matchGotra.first['id'].toString());
        _gotraName = gotraName;
      }
    }

    setState(() {
      _existingMember = found;
      _memberLocked = true;
      _fetching = false;
    });

    // Resolve state/district/taluka NAMES back to IDs for the dropdowns.
    // CONFIRM: adjust 'state_name'/'district_name'/'taluka_name' below if
    // your getDistricts()/getTalukas() responses use different key names.
    final stateName = (found['state'] ?? '').toString();
    if (stateName.isNotEmpty) {
      final matchState = _states.where((s) => (s['state_name'] ?? s['name'] ?? '').toString() == stateName);
      if (matchState.isNotEmpty) {
        final stateId = matchState.first['id'].toString();
        final districts = await _api.getDistricts(stateId);
        if (!mounted) return;
        setState(() {
          _stateId = stateId;
          _districts = districts;
        });
        final districtName = (found['district'] ?? '').toString();
        final matchDistrict =
        districts.where((d) => (d['district_name'] ?? d['name'] ?? '').toString() == districtName);
        if (matchDistrict.isNotEmpty) {
          final districtId = matchDistrict.first['id'].toString();
          final talukas = await _api.getTalukas(districtId);
          if (!mounted) return;
          setState(() {
            _districtId = districtId;
            _talukas = talukas;
          });
          final talukaName = (found['taluka'] ?? '').toString();
          final matchTaluka =
          talukas.where((t) => (t['taluka_name'] ?? t['name'] ?? '').toString() == talukaName);
          if (matchTaluka.isNotEmpty) {
            setState(() => _talukaId = matchTaluka.first['id'].toString());
          }
        }
      }
    }

    _calcFee();
  }

  Future<void> _pickFile(void Function(PlatformFile) onPicked) async {
    final res = await FilePicker.platform.pickFiles(type: FileType.any);
    if (res != null && res.files.isNotEmpty) {
      setState(() => onPicked(res.files.first));
    }
  }

  String _pick(Map m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return '';
  }

  Future<void> _searchKaryakarta() async {
    final query = _karyakartaSearchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      _snack('Type SA Code, Name, Mobile or Village to search.');
      return;
    }
    setState(() => _searchingKaryakarta = true);
    try {
      final all = await _api.getKaryakartasRaw();
      final matches = all.where((k) {
        final code = _pick(k, ['sa_code', 'saCode', 'code']).toLowerCase();
        final name = _pick(k, ['full_name', 'name', 'fullName']).toLowerCase();
        final mobile = _pick(k, ['mobile', 'phone']).toLowerCase();
        final village = _pick(k, ['village', 'village_city']).toLowerCase();
        return code.contains(query) ||
            name.contains(query) ||
            mobile.contains(query) ||
            village.contains(query);
      }).map((k) => {
        'sa_code': _pick(k, ['sa_code', 'saCode', 'code']),
        'name': _pick(k, ['full_name', 'name', 'fullName']),
        'mobile': _pick(k, ['mobile', 'phone']),
        'village': _pick(k, ['village', 'village_city']),
      }).toList();

      setState(() => _karyakartaResults = matches);

      if (matches.isEmpty && mounted) {
        _snack('No Karyakarta found for that search.');
      }
    } finally {
      if (mounted) setState(() => _searchingKaryakarta = false);
    }
  }

  Future<void> _submit() async {
    if (_schemeId == null) {
      _snack('Please select a scheme');
      return;
    }
    if (!_isNewMember && _existingMember == null) {
      _snack('Please fetch an existing member record first');
      return;
    }
    // if (_isNewMember && !_formKey.currentState!.validate()) return;
    if (!_formKey.currentState!.validate()) return;
    if (_nomineeNameCtrl.text.trim().isEmpty) {
      _snack('Please enter nominee name');
      return;
    }
    if (!_agreed) {
      _snack('Please accept the trust rules & terms');
      return;
    }

    setState(() => _submitting = true);
    try {
      int memberId;

      if (_isNewMember) {
        // Step 1: create the member profile
        final memberRes = await _api.createKaryakartaMember({
          'full_name': _fullNameCtrl.text.trim(),
          'gotra': _gotraName,
          'dob': _dob != null
              ? '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}'
              : null,
          'gender': _gender,
          'mobile': _mobileCtrl.text.trim(),
          'aadhaar_no': _aadhaarCtrl.text.trim(),
          'father_name': _fatherCtrl.text.trim(),
          'mother_name': _motherCtrl.text.trim(),
          'guardian_name': _guardianCtrl.text.trim(),
          'state': _stateId,
          'district': _districtId,
          'taluka': _talukaId,
          'village': _villageCtrl.text.trim(),
          'full_address': _addressCtrl.text.trim(),
          'pincode': _pincodeCtrl.text.trim(),
        });
        if (memberRes['success'] != true) {
          _snack(memberRes['message']?.toString() ?? 'Failed to create member');
          setState(() => _submitting = false);
          return;
        }
        // CONFIRM with backend: adjust this path if the member id
        // comes back in a different shape (e.g. memberRes['data']['id']).
        final createdMember = (memberRes['data'] is List)
            ? (memberRes['data'] as List).first
            : memberRes['data'];
        memberId = int.parse(createdMember['id'].toString());
      } else {
        memberId = int.parse(_existingMember!['id'].toString());
      }

      // Step 2: create the enrollment/proposal against that member
      final res = await _api.createKaryakartaEnrollment(
        memberId: memberId,
        schemeId: _schemeId!,
        joiningFeePaid: _joiningFee,
        paymentMode: _paymentMode,
        nomineeName: _nomineeNameCtrl.text.trim(),
        nomineeRelation: _nomineeRelation,
        photoFile: _photoFile,
        docFile: _memberIdFile,
        fatherDocFile: _guardianIdFile,
        authFile: _authFile,
      );

      if (!mounted) return;
      setState(() => _submitting = false);
      _snack(res['message']?.toString() ??
          (res['success'] == true ? 'Proposal submitted successfully' : 'Failed to submit proposal'));
      if (res['success'] == true) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack('Error: $e');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Welfare Scheme Proposal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select Welfare Scheme *', border: OutlineInputBorder()),
              value: _schemeId,
              items: _schemes.map((s) {
                final id = int.tryParse(s['id'].toString()) ?? 0;
                return DropdownMenuItem(value: id, child: Text((s['scheme_name'] ?? s['name'] ?? '').toString()));
              }).toList(),
              onChanged: (v) {
                setState(() => _schemeId = v);
                _calcFee();
              },
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // ---- NEW: Tagged Karyakarta (SA Code) ----
            const Text('Tagged Karyakarta (SA Code)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _karyakartaSearchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Type SA Code (e.g. SA4281), Name or Village...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed: _searchingKaryakarta ? null : _searchKaryakarta,
                  child: _searchingKaryakarta
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search, size: 18),
                ),
              ],
            ),
            if (_karyakartaResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._karyakartaResults.map((k) {
                final selected = _selectedKaryakarta != null &&
                    _selectedKaryakarta!['sa_code'] == k['sa_code'];
                return InkWell(
                  onTap: () => setState(() => _selectedKaryakarta = k),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected ? Colors.deepPurple.withOpacity(.08) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: selected ? Colors.deepPurple : Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${k['sa_code']} - ${k['name']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                              Text('${k['village']} • ${k['mobile']}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (selected) const Icon(Icons.check_circle, color: Colors.deepPurple, size: 18),
                      ],
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 8),
            if (_selectedKaryakarta != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_selectedKaryakarta!['sa_code']} - ${_selectedKaryakarta!['name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${_selectedKaryakarta!['village']} | Mob: ${_selectedKaryakarta!['mobile']}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5)),
                  ],
                ),
              )
            else
              Text('No Karyakarta selected yet — search above and tap a result.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 16),

            // ---- Member Registration Mode ----
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('New Member'),
                    selected: _isNewMember,
                    onSelected: (_) => setState(() {
                      _isNewMember = true;
                      _existingMember = null;
                      _memberLocked = false; // NEW — unlock fields for manual entry
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Existing Member'),
                    selected: !_isNewMember,
                    onSelected: (_) => setState(() {
                      _isNewMember = false;
                      _memberLocked = false; // NEW — require fetch before fields populate
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (!_isNewMember) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fetchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Member ID, Mobile, or Aadhaar number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _fetching ? null : _fetchExistingMember,
                    child: _fetching
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Fetch'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ---- 1. Personal Information — shown for BOTH modes, matching
            // the web form. Locked/prefilled once an existing member is fetched.
            const Text('1. Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameCtrl,
              enabled: !_memberLocked,
              decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Gotra *', border: OutlineInputBorder()),
              value: _gotraId,
              items: _gotras.map((g) {
                final id = int.tryParse(g['id'].toString()) ?? 0;
                final name = (g['name'] ?? g['gotra_name'] ?? g['gotra_en'] ?? '').toString();
                return DropdownMenuItem(value: id, child: Text(name));
              }).toList(),
              onChanged: _memberLocked
                  ? null
                  : (v) {
                final match = _gotras.firstWhere((g) => g['id'].toString() == v.toString());
                setState(() {
                  _gotraId = v;
                  _gotraName = (match['name'] ?? match['gotra_name'] ?? match['gotra_en']).toString();
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _memberLocked
                        ? null
                        : () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000, 1, 1),
                        firstDate: DateTime(1930),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _dob = picked);
                        _calcFee();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date of Birth *', border: OutlineInputBorder()),
                      child: Text(_dob == null
                          ? 'dd-mm-yyyy'
                          : '${_dob!.day.toString().padLeft(2, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.year}'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: _memberLocked ? null : (v) => setState(() => _gender = v ?? 'Female'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mobileCtrl,
                    enabled: !_memberLocked,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Mobile Number *', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().length != 10) ? '10 digits required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _aadhaarCtrl,
                    enabled: !_memberLocked,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Aadhaar Number *', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().length != 12) ? '12 digits required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('2. Family & Nominee Details', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fatherCtrl,
                    enabled: !_memberLocked,
                    decoration: const InputDecoration(labelText: 'Father Name *', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _motherCtrl,
                    enabled: !_memberLocked,
                    decoration: const InputDecoration(labelText: 'Mother Name *', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _guardianCtrl,
              enabled: !_memberLocked,
              decoration: const InputDecoration(labelText: 'Guardian Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            const Text('3. Residential Address', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'State *', border: OutlineInputBorder()),
                    value: _stateId,
                    items: _states
                        .map((s) => DropdownMenuItem(
                        value: s['id'].toString(),
                        child: Text((s['state_name'] ?? s['name'] ?? '').toString())))
                        .toList(),
                    onChanged: _memberLocked ? null : _onStateChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'District *', border: OutlineInputBorder()),
                    value: _districtId,
                    items: _districts
                        .map((d) => DropdownMenuItem(
                        value: d['id'].toString(),
                        child: Text((d['district_name'] ?? d['name'] ?? '').toString())))
                        .toList(),
                    onChanged: _memberLocked ? null : _onDistrictChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Taluka *', border: OutlineInputBorder()),
                    value: _talukaId,
                    items: _talukas
                        .map((t) => DropdownMenuItem(
                        value: t['id'].toString(),
                        child: Text((t['taluka_name'] ?? t['name'] ?? '').toString())))
                        .toList(),
                    onChanged: _memberLocked ? null : (v) => setState(() => _talukaId = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _villageCtrl,
                    enabled: !_memberLocked,
                    decoration: const InputDecoration(labelText: 'Village / City *', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              enabled: !_memberLocked,
              decoration: const InputDecoration(labelText: 'Full Residential Address *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pincodeCtrl,
              enabled: !_memberLocked,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'PIN Code *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // ---- nominee (shown for both new & existing) ----
            const Text('Nominee Details', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomineeNameCtrl,
                    decoration: const InputDecoration(labelText: 'Nominee Full Name *', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Nominee Relation *', border: OutlineInputBorder()),
                    value: _nomineeRelation,
                    items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setState(() => _nomineeRelation = v ?? 'Father'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Documents Upload', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _fileButton('Passport Photo', _photoFile, () => _pickFile((f) => _photoFile = f)),
                _fileButton('Member Govt ID', _memberIdFile, () => _pickFile((f) => _memberIdFile = f)),
                _fileButton('Parent/Guardian ID', _guardianIdFile, () => _pickFile((f) => _guardianIdFile = f)),
                _fileButton('Auth/Consent Letter', _authFile, () => _pickFile((f) => _authFile = f)),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Joining Fee', style: TextStyle(fontSize: 11)),
                      Text(_calculating ? '...' : '₹${_joiningFee.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Per-Event', style: TextStyle(fontSize: 11)),
                      Text(_calculating ? '...' : '₹${_perEventFee.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Payment Mode', isDense: true),
                      value: _paymentMode,
                      items: const [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'Online', child: Text('Online')),
                        DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                      ],
                      onChanged: (v) => setState(() => _paymentMode = v ?? 'Cash'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              title: const Text('I agree to all Trust rules, waiting periods and terms & conditions.'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit Proposal to Office'),
              ),
            ),
          ],
        ),
      ),
    );
  }
@override
void dispose() {
_karyakartaSearchCtrl.dispose();
super.dispose();
}

Widget _fileButton(String label, PlatformFile? file, VoidCallback onTap) {
  // Widget _fileButton(String label, PlatformFile? file, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(file == null ? Icons.upload_file : Icons.check_circle, size: 16),
      label: Text(file?.name ?? label, overflow: TextOverflow.ellipsis),
    );
  }
}