import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 4-step "Claim Request Form" flow:
/// Step 1: Select scheme + search member -> eligibility check
/// Step 2: OTP verify + marriage date + upload docs
/// Step 3: Bank details + account verification
/// Step 4: Final claim request confirmation (share/download, close)
class ClaimRequestScreen extends StatefulWidget {
  const ClaimRequestScreen({super.key});

  @override
  State<ClaimRequestScreen> createState() => _ClaimRequestScreenState();
}

class _ClaimRequestScreenState extends State<ClaimRequestScreen> {
  int _step = 0; // 0..3 => displayed as "1 of 4".."4 of 4"

  // ---- Step 1 state ----
  String? _selectedScheme;
  final _memberIdController = TextEditingController();
  String _memberName = '';
  bool _isSearching = false;
  bool _isEligible = false;

  // ---- Step 2 state ----
  final _otpController = TextEditingController();
  bool _otpVerified = false;
  DateTime? _marriageDate;
  String? _uploadedDocName;

  // ---- Step 3 state ----
  final _ifscController = TextEditingController();
  String _bankBranchName = '';
  final _accountNumberController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  String _accountHolderName = '';
  bool _accountVerified = false;

  // ---- Step 4 state ----
  String _claimRequestNo = '';
  DateTime? _claimRequestDate;

  static const _schemeId = 'KDS000001';
  static const _schemeName = 'KANYA DAN (KDS)';

  @override
  void dispose() {
    _memberIdController.dispose();
    _otpController.dispose();
    _ifscController.dispose();
    _accountNumberController.dispose();
    _confirmAccountController.dispose();
    super.dispose();
  }

  // ---------------- ACTIONS (replace TODOs with your real API calls) ----------------

  Future<void> _handleSearch() async {
    setState(() {
      _isSearching = true;
      _isEligible = false;
    });
    // TODO: call your real "search member / check eligibility" API here
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isSearching = false;
      _isEligible = true;
      _memberName = 'SUNITABEN RAJUBHAI SUTHAR';
    });
  }

  void _handleVerifyOtp() {
    // TODO: call your real "verify OTP" API here
    setState(() => _otpVerified = true);
    _showSnack('OTP verified');
  }

  Future<void> _pickMarriageDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _marriageDate = picked);
  }

  void _pickDocument() {
    // TODO: hook up file_picker / image_picker package here
    setState(() => _uploadedDocName = 'document.pdf');
  }

  void _handleVerifyAccount() {
    if (_accountNumberController.text.isEmpty) {
      _showSnack('Enter account number');
      return;
    }
    if (_accountNumberController.text != _confirmAccountController.text) {
      _showSnack('Account numbers do not match');
      return;
    }
    // TODO: call your real "penny-drop / account verify" API here
    setState(() {
      _accountVerified = true;
      _accountHolderName = 'SUNITABEN RAJUBHAI SUTHAR';
    });
  }

  void _handleSubmit() {
    if (!_accountVerified) {
      _showSnack('Please verify the account first');
      return;
    }
    // TODO: call your real "submit claim" API here
    setState(() {
      _claimRequestNo = 'CRN0000001';
      _claimRequestDate = DateTime.now();
      _step = 3;
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _goNext() => setState(() => _step = (_step + 1).clamp(0, 3));

  String _fmtDate(DateTime? d) {
    if (d == null) return 'DD-MM-YYYY';
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   title: const Text('Services_claims_register'),
      //   centerTitle: false,
      //   backgroundColor: AppColors.background,
      //   foregroundColor: Colors.black87,
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Padding(
          // padding: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(child: _buildStepBody()),
              ),
              const SizedBox(height: 12),
              _buildFooterButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Claim Request Form',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const Spacer(),
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.primary,
          child: Text(
            '${_step + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),
        const Text('of  4'),
      ],
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep4();
    }
  }

  Widget _buildFooterButton() {
    switch (_step) {
      case 0:
        return Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _isEligible ? _goNext : null,
            style: _pillButtonStyle,
            child: const Text('NEXT'),
          ),
        );
      case 1:
        return Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _goNext,
            style: _pillButtonStyle,
            child: const Text('NEXT'),
          ),
        );
      case 2:
        return Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: _pillButtonStyle,
            child: const Text('SUBMIT'),
          ),
        );
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                // TODO: hook up share/download (e.g. share_plus, or generate a PDF)
                _showSnack('Share/Download coming soon');
              },
              child: const Text('SHARE/DOWNLOAD'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: _pillButtonStyle,
              child: const Text('CLOSE'),
            ),
          ],
        );
    }
  }

  // ---- STEP 1 : scheme select + search + eligibility ----
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Scheme:', style: _labelStyle),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedScheme,
          decoration: _fieldDecoration('Click to Select'),
          items: const [
            DropdownMenuItem(value: 'KDS', child: Text('KANYA DAN (KDS)')),
          ],
          onChanged: (v) => setState(() => _selectedScheme = v),
        ),
        const SizedBox(height: 16),
        const Text('Enter Member ID/SchemeID/Aadhaar :', style: _labelStyle),
        const SizedBox(height: 6),
        TextField(
          controller: _memberIdController,
          decoration: _fieldDecoration('Enter Member ID/SchemeID/Aadhaar'),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _isSearching ? null : _handleSearch,
            style: _pillButtonStyle,
            child: const Text('SEARCH'),
          ),
        ),
        if (_isSearching) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.primary,
          ),
          const SizedBox(height: 6),
          const Center(child: Text('Loading...')),
        ],
        if (_isEligible) ...[
          const SizedBox(height: 20),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _readOnlyField('Member ID :', _memberIdController.text)),
              const SizedBox(width: 12),
              Expanded(child: _readOnlyField('Scheme ID :', _schemeId)),
            ],
          ),
          const SizedBox(height: 12),
          _readOnlyField('Member Name :', _memberName),
          const SizedBox(height: 20),
          const Center(
            child: Column(
              children: [
                Text('Congratulations!',
                    style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('You are eligible for Claim',
                    style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ---- STEP 2 : OTP + marriage date + docs ----
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter OTP to next process',
            style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
        Text('OTP sent to regd. mobile XXXXXX1234',
            style: TextStyle(color: AppColors.success.withOpacity(0.85), fontSize: 12)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('Enter OTP'),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _handleVerifyOtp,
              style: _pillButtonStyle,
              child: const Text('VERIFY'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _readOnlyField('Member ID :', _memberIdController.text)),
            const SizedBox(width: 12),
            Expanded(child: _readOnlyField('Scheme ID :', _schemeId)),
          ],
        ),
        const SizedBox(height: 12),
        _readOnlyField('Member Name :', _memberName),
        const SizedBox(height: 12),
        _readOnlyField('Scheme Name :', _schemeName),
        const SizedBox(height: 16),
        const Text('Date of Marriage:', style: _labelStyle),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickMarriageDate,
          child: InputDecorator(
            decoration: _fieldDecoration(null).copyWith(
              suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
            ),
            child: Text(_fmtDate(_marriageDate)),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Upload Docs.:', style: _labelStyle),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickDocument,
          child: InputDecorator(
            decoration: _fieldDecoration('Select Docs').copyWith(
              suffixIcon: const Icon(Icons.upload_file, size: 18, color: AppColors.primary),
            ),
            child: Text(_uploadedDocName ?? ''),
          ),
        ),
      ],
    );
  }

  // ---- STEP 3 : bank details + verify account ----
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bank Details :', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Enter IFSC:', style: _labelStyle),
        const SizedBox(height: 6),
        TextField(
          controller: _ifscController,
          decoration: _fieldDecoration('SBIN0009862'),
          onChanged: (v) {
            // TODO: call your real IFSC lookup API and set _bankBranchName from it
            setState(() => _bankBranchName = 'State Bank of India, Luvana');
          },
        ),
        const SizedBox(height: 16),
        const Text('Bank & Branch Name :', style: _labelStyle),
        const SizedBox(height: 6),
        _readOnlyField('', _bankBranchName, dense: true),
        const SizedBox(height: 16),
        const Text('Enter Account Number:', style: _labelStyle),
        const SizedBox(height: 6),
        TextField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          decoration: _fieldDecoration('12345678901'),
        ),
        const SizedBox(height: 16),
        const Text('Confirm Account Number:', style: _labelStyle),
        const SizedBox(height: 6),
        TextField(
          controller: _confirmAccountController,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: _fieldDecoration('***********'),
        ),
        const SizedBox(height: 16),
        const Text('Account Holder Name:', style: _labelStyle),
        const SizedBox(height: 6),
        _readOnlyField('', _accountHolderName, dense: true),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _handleVerifyAccount,
            style: _pillButtonStyle,
            child: const Text('VERIFY AC'),
          ),
        ),
      ],
    );
  }

  // ---- STEP 4 : final confirmation ----
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Claim Request Details:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Claim Request No.:', style: _labelStyle),
        const SizedBox(height: 4),
        _readOnlyField('', _claimRequestNo, dense: true),
        const SizedBox(height: 16),
        const Text('Date of Claim Request:', style: _labelStyle),
        const SizedBox(height: 4),
        _readOnlyField('', _fmtDate(_claimRequestDate), dense: true),
      ],
    );
  }

  // ---- shared helpers/styles ----
  static const _labelStyle = TextStyle(fontSize: 13, color: AppColors.textDark);

  InputDecoration _fieldDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: AppColors.cardBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  static final ButtonStyle _pillButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
    disabledForegroundColor: Colors.white70,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  );

  Widget _readOnlyField(String label, String value, {bool dense = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.cardBg,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      onTap: (index) {
        if (index == 1) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined), activeIcon: Icon(Icons.people_alt), label: 'Services'),
        BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Reports'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined), activeIcon: Icon(Icons.account_circle), label: 'Profile'),
      ],
    );
  }
}