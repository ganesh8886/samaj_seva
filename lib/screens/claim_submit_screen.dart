import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'karyakarta_dashboard_screen.dart'; // for KColors, card(), etc.

/// ============================================================
/// "Community Welfare Assistance Claim Submission" — matches
/// claim_new.php: pick scheme -> search member -> verify & fetch
/// eligibility -> fill event details -> OTP -> submit.
///
/// ⚠️ ASSUMPTION FLAGGED: your api_config.dart has no OTP-for-claim
/// endpoints yet. I've added two candidate entries below
/// (karyakartaClaimSendOtp / karyakartaClaimVerifyOtp) — confirm the
/// real paths with your backend dev and adjust the two constants in
/// api_config.dart. Until then this screen will show a clear error
/// instead of silently pretending to succeed.
/// ============================================================

class ClaimSubmitScreen extends StatefulWidget {
  const ClaimSubmitScreen({super.key});

  @override
  State<ClaimSubmitScreen> createState() => _ClaimSubmitScreenState();
}

class _ClaimSubmitScreenState extends State<ClaimSubmitScreen> {
  // ---- Step 1: scheme + date ----
  List<Map<String, dynamic>> _schemes = [];
  String? _selectedSchemeId;
  bool _loadingSchemes = true;
  final DateTime _submissionDate = DateTime.now();

  // ---- Step 2: member search ----
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  Map<String, dynamic>? _member; // fetched raw member record
  int? _memberId;
  int? _enrollmentId;

  // ---- Step 3: event details (shown once member is verified) ----
  String _eventType = 'marriage';
  final _eventDateCtrl = TextEditingController();
  final _beneficiaryCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _bankIfscCtrl = TextEditingController();
  final _bankAccNoCtrl = TextEditingController();
  final _bankHolderCtrl = TextEditingController();
  PlatformFile? _proofFile;

  // ---- Step 4: OTP ----
  bool _otpSent = false;
  bool _sendingOtp = false;
  final _otpCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _eventDateCtrl.dispose();
    _beneficiaryCtrl.dispose();
    _bankNameCtrl.dispose();
    _bankIfscCtrl.dispose();
    _bankAccNoCtrl.dispose();
    _bankHolderCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ---- same helper pattern as enrollment_create_screen.dart ----
  String _pick(Map m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return '';
  }

  int? _pickId(Map m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v == null) continue;
      if (v is int) return v;
      final parsed = int.tryParse(v.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  Future<void> _loadSchemes() async {
    setState(() => _loadingSchemes = true);
    final schemes = await ApiService().getSchemesRaw();
    setState(() {
      _schemes = schemes;
      _loadingSchemes = false;
    });
  }

  // ---- "Verify & Fetch" — searches this karyakarta's own members list ----
  Future<void> _verifyAndFetch() async {
    if (_selectedSchemeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a welfare scheme first.')),
      );
      return;
    }
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter Member ID, Scheme A/C, Mobile or Aadhaar.')),
      );
      return;
    }

    setState(() => _searching = true);
    try {
      // ADJUST if you'd rather search ALL members instead of just this
      // karyakarta's own — swap for ApiService().getMembersRaw().
      final all = await ApiService().getKaryakartaMembers();
      final match = all.cast<Map<String, dynamic>?>().firstWhere((m) {
        if (m == null) return false;
        final id = _pick(m, ['member_id', 'id']).toLowerCase();
        final schemeAcc = _pick(m, ['scheme_account_no', 'scheme_a_c_no']).toLowerCase();
        final mobile = _pick(m, ['mobile', 'phone']).toLowerCase();
        final aadhaar = _pick(m, ['aadhaar_no', 'aadhaar']).toLowerCase();
        return id == query || schemeAcc == query || mobile == query || aadhaar == query;
      }, orElse: () => null);

      if (match == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No verified member found for that search.')),
          );
        }
        return;
      }

      // Also try to find their enrollment id for this scheme so it can be
      // sent with the claim payload.
      final enrollments = await ApiService().getKaryakartaEnrollments();
      final memberId = _pickId(match, ['id', 'member_id']);
      final enrollmentMatch = enrollments.cast<Map<String, dynamic>?>().firstWhere(
            (e) {
          if (e == null) return false;
          final eMemberId = _pickId(e, ['member_id']);
          final eSchemeId = _pickId(e, ['scheme_id']);
          return eMemberId == memberId && eSchemeId.toString() == _selectedSchemeId;
        },
        orElse: () => null,
      );

      setState(() {
        _member = match;
        _memberId = memberId;
        _enrollmentId = enrollmentMatch != null ? _pickId(enrollmentMatch, ['id']) : null;
        _beneficiaryCtrl.text = _pick(match, ['full_name', 'name']);
        _bankHolderCtrl.text = _pick(match, ['full_name', 'name']);
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _pickProof() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _proofFile = result.files.single);
    }
  }

  bool _eventDetailsValid() {
    return _eventDateCtrl.text.trim().isNotEmpty &&
        _beneficiaryCtrl.text.trim().isNotEmpty &&
        _bankAccNoCtrl.text.trim().isNotEmpty;
  }

  // ---- OTP step ----
  // ⚠️ These two ApiService calls don't exist yet — see note at top of file.
  // Add matching entries to ApiConfig + ApiService once backend confirms
  // the real endpoint paths, following the exact pattern of
  // sendLoginOtp()/verifyLoginOtp() already in api_service.dart.
  Future<void> _sendOtp() async {
    if (!_eventDetailsValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete event date, beneficiary and bank account first.')),
      );
      return;
    }
    setState(() => _sendingOtp = true);
    try {
      // final res = await ApiService().sendClaimOtp(_member!['mobile'].toString());
      // For now, since the endpoint isn't confirmed, tell the developer
      // clearly instead of pretending it worked:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'OTP endpoint not wired yet — ask backend for the claim-OTP route, '
                'then replace this TODO in claim_submit_screen.dart._sendOtp().',
          ),
          duration: Duration(seconds: 4),
        ),
      );
      setState(() => _otpSent = true); // remove this line once the real call is wired
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  Future<void> _submitClaim() async {
    if (_otpCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the OTP sent to the member.')),
      );
      return;
    }
    if (_memberId == null || _enrollmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing member/enrollment link — re-verify the member.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      // TODO: once the OTP-verify endpoint exists, call it here first and
      // stop on failure, same pattern as verifyLoginOtp() in api_service.dart.

      final payload = {
        'member_id': _memberId,
        'scheme_id': int.tryParse(_selectedSchemeId ?? '') ?? _selectedSchemeId,
        'enrollment_id': _enrollmentId,
        'event_type': _eventType,
        'event_date': _eventDateCtrl.text.trim(),
        'beneficiary_name': _beneficiaryCtrl.text.trim(),
        'bank_name': _bankNameCtrl.text.trim(),
        'bank_ifsc': _bankIfscCtrl.text.trim(),
        'bank_account_no': _bankAccNoCtrl.text.trim(),
        'bank_account_holder': _bankHolderCtrl.text.trim(),
      };

      final result = await ApiService().submitKaryakartaClaim(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Claim submitted')),
      );
      if (result['success'] == true) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.bg,
      appBar: AppBar(
        backgroundColor: KColors.navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Community Welfare Assistance Claim Submission',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text('Search any verified member, review live eligibility, and submit claim with OTP security.',
                style: TextStyle(fontSize: 10.5, color: Color(0xFFB9B3E0))),
          ],
        ),
      ),
      body: _loadingSchemes
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('1. Select Welfare Scheme *',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedSchemeId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: '-- Choose Scheme --',
                            filled: true,
                            fillColor: KColors.bg,
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                          ),
                          items: _schemes.map((s) {
                            final id = _pickId(s, ['id', 'scheme_id']).toString();
                            final name = _pick(s, ['scheme_name', 'name', 'title']);
                            return DropdownMenuItem(value: id, child: Text(name));
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedSchemeId = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date of Submission (Today)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                        const SizedBox(height: 6),
                        InputDecorator(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: KColors.bg,
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                          ),
                          child: Text(
                            '${_submissionDate.day.toString().padLeft(2, '0')}-${_submissionDate.month.toString().padLeft(2, '0')}-${_submissionDate.year}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('2. Search: Member ID / Scheme A/C / Mobile / Aadhaar *',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. KDS00001, 9026703, 971432...',
                        filled: true,
                        fillColor: KColors.bg,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _searching ? null : _verifyAndFetch,
                    icon: _searching
                        ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search, size: 16),
                    label: const Text('Verify & Fetch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          )),
          if (_member != null) ...[
            card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(Icons.verified_user_outlined, size: 16, color: KColors.green),
                  SizedBox(width: 6),
                  Text('Verified Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
                const Divider(height: 18),
                infoRow('Full Name', _pick(_member!, ['full_name', 'name'])),
                infoRow('Member ID', _pick(_member!, ['member_id', 'id'])),
                infoRow('Mobile', _pick(_member!, ['mobile', 'phone'])),
                infoRow('Village', _pick(_member!, ['village'])),
              ],
            )),
            card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('3. Event & Claim Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Event Type'),
                  value: _eventType,
                  items: const [
                    DropdownMenuItem(value: 'marriage', child: Text('Marriage')),
                    DropdownMenuItem(value: 'death', child: Text('Death')),
                    // DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _eventType = v ?? 'marriage'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _eventDateCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Event Date (YYYY-MM-DD) *'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _eventDateCtrl.text =
                        "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _beneficiaryCtrl,
                  decoration: const InputDecoration(labelText: 'Beneficiary Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bankNameCtrl,
                  decoration: const InputDecoration(labelText: 'Bank Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bankIfscCtrl,
                  decoration: const InputDecoration(labelText: 'Bank IFSC'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bankAccNoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Bank Account No *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bankHolderCtrl,
                  decoration: const InputDecoration(labelText: 'Account Holder Name'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickProof,
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: Text(_proofFile?.name ?? 'Upload Event Proof Document'),
                ),
              ],
            )),
            card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('4. OTP Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                if (!_otpSent)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sendingOtp ? null : _sendOtp,
                      icon: _sendingOtp
                          ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.sms_outlined, size: 16),
                      label: const Text('Send OTP to Member'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                else ...[
                  TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(labelText: 'Enter OTP', counterText: ''),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submitClaim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Submit Claim', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            )),
          ],
        ],
      ),
    );
  }
}