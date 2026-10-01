import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
// import 'package/constants/app_constants.dart';

/// 8-"page" Scheme Enrollment wizard, opened from Services -> Members -> Add.
///
/// Page order (see _stepTitles below):
/// 1. Member Type & Scheme
/// 2. Personal Details
/// 3. Family Details
/// 4. Contact Details
/// 5. Documents Details
/// 6. Joining Fee & Instalment Details
/// 7. Review & Confirm  (this page's NEXT button triggers submit)
/// 8. Response from Office (read-only, shown after successful submit)
class SchemeEnrollmentScreen extends StatefulWidget {
  const SchemeEnrollmentScreen({super.key});

  @override
  State<SchemeEnrollmentScreen> createState() =>
      _SchemeEnrollmentScreenState();
}

class _SchemeEnrollmentScreenState extends State<SchemeEnrollmentScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  static const List<String> _stepTitles = [
    'Member & Scheme',
    'Personal Details',
    'Family Details',
    'Contact Details',
    'Documents Details',
    'Joining Fee & Instalment',
    'Review & Confirm',
    'Proposal Details',
  ];
  static int get _totalSteps => _stepTitles.length;

  // ---- Step 1: Member Type + Scheme ----
  String _memberType = 'Existing Member'; // 'New Member' | 'Existing Member'
  final TextEditingController _memberIdController = TextEditingController();
  bool _isSearching = false;
  String? _foundMemberName;
  String? _selectedScheme;

  // ---- Step 2: Personal Details ----
  final TextEditingController _fullNameController = TextEditingController();
  String? _gender; // auto-filled from scheme, still editable as fallback
  DateTime? _dob;
  int? _age;
  String? _gotra;
  final List<String> _gotraList = [
    'Adichwal (अड़ीचवाल)', 'Anival (अणीवाल)', 'Achu (आचू)', 'Ambiya (आंबीया)',
    'Asdev (आसदेव)', 'Asdanya (असदन्या)', 'Egan (ईगन)', 'Odhana (ओढाणा)',
    'Kangsiya (कांगसिया)', 'Karal (करल)', 'Kunecha (कुणेचा)', 'Kuntal (कुन्तल)',
    'Kulariya (कुलरिया)', 'Kavlecha (कवलेचा)', 'Kogesh (कोगेश)', 'Khokha (खोखा)',
    'Khichi (खीची)', 'Gaur (गौड़)', 'Goyal (गोयल)', 'Gaipal (गैपाल)',
    'Gugariya (गुगरिया)', 'Chatrecha (चत्रेचा)', 'Chavalared (चावलारेड)',
    'Chandak (चांडक)', 'Choyal (चोयल)', 'Choiyal (चोइयल)', 'Chundha (चूंघा)',
    'Chhariya (छड़िया)', 'Chhabad (छाबड़)', 'Jadam (जादम)', 'Jadaul (जाडौल)',
    'Jalaniya (जालणिया)', 'Jalodiya (जलोदिया)', 'Jammd (जाम्मड)',
    'Jayalwal (जायलवाल)', 'Jopaliya (जुपेलीया)', 'Joping (जोपिंग)',
    'Johad (जोहड)', 'Jhans (झांस)', 'Dadahala (दादाहाला)',
    'Dayama (डामा / दायमा)', 'Debda (डिबडा / देबड़ा)', 'Doyal (डोडिया / डोयल)',
    'Dorak (दौरक)', 'Dhanerva (धनरवा)', 'Dheer (धीर)', 'Dugrecha (धूगरेचा)',
    'Dugeshwar (धूगेश्वर)', 'Nagdiwal (नगाडीवाल)', 'Nagal (नागल)',
    'Nibhad (निबड)', 'Nisan (निसाण)', 'Pakharbad (पार्करबाड)',
    'Palecha (पालेचा)', 'Patodiya (पोटोडिया)', 'Pidwa (पिडवा)',
    'Pidiyar (पिडयार)', 'Pingal (पिंगल)', 'Pipdan (पीपदान)',
    'Prebhasiya (प्रभाषाया)', 'Poleriya (पोलेरीया)', 'Bambhaniya (बाम्भणिया)',
    'Bakhrecha (बाखरेचा)', 'Baghmar (बाघमार)', 'Balaya (बाल्या / बलाया)',
    'Baldeva (बालदेवा)', 'Baradwa (बाराडवा / बरड़वा)', 'Bhadrecha (भद्रेचा)',
    'Bhambhoriya (भंभोरिया)', 'Bhachnecha (भाचनेचा)', 'Bhadaniyah (भदानाया)',
    'Bhurtia (भुरटिया)', 'Brahma Dixit (ब्रह्म दीक्षित)', 'Bundal (बूंढल / बूंदल)',
    'Bundal - Bhati (बूंढल - भटी)', 'Bundiwal (बूंदीवाल)',
    'Bundard (बुंदड / बूंदरड़)', 'Baigad (बैंगड़)', 'Bairad (बैराड)',
    'Makvana (मकवाणा)', 'Marotiya (मरोटिया)', 'Mahil (माहिल)',
    'Mankar (मांकड़ / मानकर)', 'Mandan (मांडण)', 'Mangalrao (मंगलराव)',
    'Motiyar (मोतियार)', 'Rananga (रारांगा)', 'Rajwan (राजवान)',
    'Ralad (रालाड)', 'Roham (रोहम)', 'Rop (रोप)', 'Vans (वन)', 'Vain (वैन)',
    'Waraad (वरड)', 'Sanvalodiya (सांवलदीया)', 'Sambhiya (सांबिया)',
    'Sand (सांड)', 'Sanjha (सांझा)', 'Sany (सांय)', 'Sogar (सोगर)',
    'Sigana (सिगाना)', 'Singhad (सिघड़ / सींघड़)', 'Siniwal (सीणीवाल)',
    'Silg (सिलीग / सिलग)', 'Seel (सील)', 'Suvakam (सुवकम)', 'Sokha (सोखा)',
    'Subhayan (सुभया / सुभयान)', 'Imraniya (इमरणिया)', 'Indraniya (इन्द्राणिया)',
  ];

  // ---- Step 3: Family Details ----
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _husbandNameController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _nomineeNameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  bool _hasHusband = false;
  bool _hasGuardian = false;

  // ---- Step 4: Contact Details ----
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _state;
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  // ---- Step 5: Documents Details ----
  final TextEditingController _aadhaarNoController = TextEditingController();
  String? _aadhaarFileName;
  final TextEditingController _guardianAadhaarNoController =
  TextEditingController();
  String? _guardianAadhaarFileName;
  String? _photoFileName;
  String? _authLetterFileName;

  // ---- Step 6: Joining Fee & Instalment Details ----
  String _paymentMode = 'Cash'; // 'Cash' | 'Online'
  bool _agreedTerms = false;

  // ---- Step 8: Response from Office ----
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _proposalNo;
  DateTime? _proposalDate;

  @override
  void dispose() {
    _pageController.dispose();
    _memberIdController.dispose();
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _husbandNameController.dispose();
    _guardianNameController.dispose();
    _nomineeNameController.dispose();
    _relationController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _pinController.dispose();
    _aadhaarNoController.dispose();
    _guardianAadhaarNoController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------

  void _goNext() {
    final reviewStepIndex = _totalSteps - 2; // "Review & Confirm"
    final responseStepIndex = _totalSteps - 1; // "Proposal Details"

    if (_currentStep == responseStepIndex) {
      // Done reviewing the office response -> close the wizard.
      Navigator.pop(context);
      return;
    }

    if (_currentStep == reviewStepIndex) {
      if (!_agreedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please accept the Terms & Conditions to continue.')),
        );
        return;
      }
      _submitEnrollment();
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    // Don't allow going back from the final "office response" page.
    if (_currentStep == _totalSteps - 1) return;
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  // ---------------------------------------------------------------------
  // Actions / business logic
  // ---------------------------------------------------------------------

  Future<void> _searchMember() async {
    setState(() => _isSearching = true);
    // TODO: replace with a real API call, e.g.
    // final member = await _api.getMemberById(_memberIdController.text);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isSearching = false;
      _foundMemberName = 'SUNITABEN RAJUBHAI SUTHAR'; // demo result
    });
  }

  /// Gender is auto-decided by the scheme rule (Kanyadan -> Female,
  /// Putra Vivah -> Male). Falls back to manual selection for other schemes.
  void _applyGenderFromScheme() {
    if (_selectedScheme == 'kanyadan') {
      _gender = 'Female';
    } else if (_selectedScheme == 'putra_vivah') {
      _gender = 'Male';
    }
  }

  bool get _genderIsAutoLocked =>
      _selectedScheme == 'kanyadan' || _selectedScheme == 'putra_vivah';

  /// TODO: replace with real age-group / fee-master lookup from backend.
  Map<String, dynamic> _feeDetailsForAge(int? age) {
    if (age == null) {
      return {'group': '-', 'joiningFee': 0, 'instalment': 0};
    }
    if (age <= 18) {
      return {'group': '0 - 18 yrs', 'joiningFee': 501, 'instalment': 100};
    } else if (age <= 35) {
      return {'group': '19 - 35 yrs', 'joiningFee': 1001, 'instalment': 200};
    } else if (age <= 60) {
      return {'group': '36 - 60 yrs', 'joiningFee': 1501, 'instalment': 300};
    } else {
      return {'group': '60+ yrs', 'joiningFee': 2001, 'instalment': 500};
    }
  }

  /// Simulated file picker. Replace with `image_picker` / `file_picker`
  /// package calls in a real build, e.g.:
  ///   final picked = await ImagePicker().pickImage(source: ImageSource.camera);
  Future<void> _pickFile(void Function(String fileName) onPicked) async {
    await Future.delayed(const Duration(milliseconds: 400));
    onPicked('document_${DateTime.now().millisecondsSinceEpoch}.jpg');
  }

  Future<void> _submitEnrollment() async {
    setState(() => _isSubmitting = true);
    // TODO: call your real submit-enrollment API here with all collected
    // fields (member type, scheme, personal/family/contact/document details,
    // fee & payment mode) and use its response for proposal no / date instead
    // of the demo values below.
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
      _proposalNo =
      'PROP-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 100000}';
      _proposalDate = DateTime.now();
      _currentStep++;
    });
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _downloadProposal() {
    // TODO: generate/download a PDF of the proposal, e.g. via your `pdf`
    // generation service or a backend endpoint that returns the file.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading proposal...')),
    );
  }

  void _shareProposal() {
    // TODO: wire up `share_plus` (or similar) to share the proposal file/text.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing proposal...')),
    );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F6),
      // appBar: AppBar(
      //   title: const Text('Services_Enrollment'),
      //   centerTitle: false,
      //   backgroundColor: const Color(0xFFF3F3F6),
      //   foregroundColor: Colors.black87,
      //   elevation: 0,
      // ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scheme Enrollment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  // color: Colors.indigo,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildStepIndicator(),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [
                    _buildStep1(),
                    _buildStep2Personal(),
                    _buildStep3Family(),
                    _buildStep4Contact(),
                    _buildStep5Documents(),
                    _buildStep6Fee(),
                    _buildStep7Review(),
                    _buildStep8Response(),
                  ],
                ),
              ),
                  const Divider(height: 24),
                  _buildNavButtons(),
                ],
              ),
            ),
          ),
        ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          // backgroundColor: Colors.indigo,
          backgroundColor: AppColors.primary,
          child: Text(
            '${_currentStep + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Text('of  $_totalSteps  ·  ${_stepTitles[_currentStep]}',
            style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  // ---------- Step 1: Member Type + Search / Scheme selection ----------
  InputDecoration _containerDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose Member Type :',
              style: TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('New Member'),
                  value: 'New Member',
                  groupValue: _memberType,
                  onChanged: (v) => setState(() {
                    _memberType = v!;
                    _foundMemberName = null;
                  }),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Existing Member'),
                  value: 'Existing Member',
                  groupValue: _memberType,
                  onChanged: (v) => setState(() {
                    _memberType = v!;
                    _foundMemberName = null;
                  }),
                ),
              ),
            ],
          ),
          if (_memberType == 'Existing Member') ...[
            const SizedBox(height: 12),
            const Text('Enter Member ID/Aadhaar :',
                style: TextStyle(fontWeight: FontWeight.w500)),
            TextField(
              controller: _memberIdController,
              // decoration: const InputDecoration(
              //     hintText: 'Enter Member ID or Aadhaar No.'),
              decoration: _containerDecoration('Enter Member ID or Aadhaar No.'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Center(
              child:
              OutlinedButton(
                onPressed: _isSearching ? null : _searchMember,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('SEARCH',
                    // style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
            if (_isSearching) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 4),
              const Text('Loading...',
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
            ],
            if (_foundMemberName != null) ...[
              const SizedBox(height: 16),
              const Text('Member ID :', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Text(_memberIdController.text),
              ),
              const SizedBox(height: 12),
              const Text('Member Name :', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Text(
                  _foundMemberName!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
          const SizedBox(height: 16),
          const Text('You are eligible in this Scheme:',
              style: TextStyle(fontWeight: FontWeight.w500)),
          DropdownButtonFormField<String>(
            value: _selectedScheme,
            hint: const Text('Click to Select'),
            decoration: _containerDecoration(''),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: const [
              DropdownMenuItem(value: 'kanyadan', child: Text('Kanyadan Yojana')),
              DropdownMenuItem(
                  value: 'putra_vivah', child: Text('Putra Vivah Yojana')),
            ],
            onChanged: (v) => setState(() {
              _selectedScheme = v;
              _applyGenderFromScheme();
            }),
          ),
        ],
      ),
    );
  }

  // ---------- Step 2: Personal Details ----------
  final _step2FormKey = GlobalKey<FormState>(); // declare once at class level, similarly _step3FormKey, _step4FormKey

  Widget _buildStep2Personal() {
    return SingleChildScrollView(
        child: Form(
          key: _step2FormKey,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Personal Details'),
          const SizedBox(height: 12),
          const Text('Member Name :', style: TextStyle(color: Colors.black54)),
          TextFormField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.characters,
            // decoration:
            // const InputDecoration(hintText: 'ENTER FULL NAME AS PER DOCS'),
            decoration: _containerDecoration('ENTER FULL NAME AS PER DOCS'),
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          // const Text('Gotra :', style: TextStyle(color: Colors.black54)),
          // DropdownButtonFormField<String>(
          //   value: _gotra,
          //   hint: const Text('Search & Select Gotra'),
          //   isExpanded: true,
          //   icon: const Icon(Icons.keyboard_arrow_down),
          //   decoration: _containerDecoration(''),
          //   items: const [
          //     DropdownMenuItem(value: 'gotra_1', child: Text('Gotra 1')),
          //     DropdownMenuItem(value: 'gotra_2', child: Text('Gotra 2')),
          //   ],
          //   onChanged: (v) => setState(() => _gotra = v),
          //   validator: (v) => v == null ? 'Please select a Gotra' : null,
          // ),
          const Text('Gotra :', style: TextStyle(color: Colors.black54)),
          FormField<String>(
            initialValue: _gotra,
            validator: (v) => _gotra == null ? 'Please select a Gotra' : null,
            builder: (FormFieldState<String> field) {
              return InkWell(
                onTap: () async {
                  final selected = await _showGotraPicker(context);
                  if (selected != null) {
                    setState(() => _gotra = selected);
                    field.didChange(selected);
                  }
                },
                child: InputDecorator(
                  decoration: _containerDecoration('Search & Select Gotra').copyWith(
                    suffixIcon: const Icon(Icons.keyboard_arrow_down),
                    errorText: field.errorText,
                  ),
                  child: Text(
                    _gotra ?? 'Search & Select Gotra',
                    style: TextStyle(
                      color: _gotra == null ? Colors.black54 : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date of Birth :',
                        style: TextStyle(color: Colors.black54)),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2008, 1, 1),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _dob = picked;
                            _age = _calculateAge(picked);
                          });
                        }
                      },
                      child: InputDecorator(
                        // decoration: InputDecoration(
                        //   hintText: 'DD-MM-YYYY',
                        decoration: _containerDecoration('DD-MM-YYYY').copyWith(
                          suffixIcon: const Icon(Icons.calendar_today, size: 18),
                          errorText: _dob == null ? 'Date of birth is required' : null,
                        ),
                        child: Text(
                          _dob == null
                              ? ''
                              : '${_dob!.day.toString().padLeft(2, '0')}-'
                              '${_dob!.month.toString().padLeft(2, '0')}-'
                              '${_dob!.year}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Age :', style: TextStyle(color: Colors.black54)),
                    InputDecorator(
                      decoration: _containerDecoration('').copyWith(
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      child: Text(_age?.toString() ?? '-',
                          style: const TextStyle(color: Colors.black87)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Gender :', style: TextStyle(color: Colors.black54)),
          if (_genderIsAutoLocked)
            InputDecorator(
              decoration: _containerDecoration('').copyWith(
                filled: true,
                fillColor: Colors.grey.shade100,
                // helperText: _selectedScheme == 'kanyadan'
                    // ? 'Auto-set: Kanyadan scheme is for the bride (Female).'
                    // : 'Auto-set: Putra Vivah scheme is for the groom (Male).',
              ),
              child: Text(_gender ?? '-'),
            )
          else
            DropdownButtonFormField<String>(
              value: _gender,
              hint: const Text('Select Gender'),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              decoration: _containerDecoration(''),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _gender = v),
              validator: (v) => v == null ? 'Please select a gender' : null,
            ),
        ],
      ),
        ),
    );
  }

  // ---------- Step 3: Family Details ----------
  Widget _buildStep3Family() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Family Details'),
          const SizedBox(height: 12),
          _labeledField('Father Name :', _fatherNameController,
              hint: "ENTER FATHER'S NAME"),
          const SizedBox(height: 16),
          _labeledField('Mother Name :', _motherNameController,
              hint: "ENTER MOTHER'S NAME"),
          const SizedBox(height: 16),
          _labeledField('Husband Name :', _husbandNameController,
              hint: "ENTER HUSBAND'S NAME (if applicable)"),
          const SizedBox(height: 16),
          _labeledField('Guardian Name :', _guardianNameController,
              hint: 'ENTER GUARDIAN NAME (if applicable)'),
          const SizedBox(height: 16),
          _labeledField('Nominee Name :', _nomineeNameController,
              hint: 'ENTER NOMINEE NAME'),
          const SizedBox(height: 16),
          _labeledField('Relation :', _relationController,
              hint: 'RELATION WITH NOMINEE (e.g. Son, Daughter, Spouse)'),
        ],
      ),
    );
  }

  // ---------- Step 4: Contact Details ----------
  Widget _buildStep4Contact() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Contact Details'),
          const SizedBox(height: 12),
          const Text('Mobile No. :', style: TextStyle(color: Colors.black54)),
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            // decoration: const InputDecoration(
            //     hintText: 'ENTER 10-DIGIT MOBILE NUMBER', counterText: ''),
            decoration: _containerDecoration('ENTER 10-DIGIT MOBILE NUMBER')
                .copyWith(counterText: ''),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Mobile number is required';
              if (v.length != 10) return 'Enter a valid 10-digit number';
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text('Email :', style: TextStyle(color: Colors.black54)),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            // decoration: const InputDecoration(hintText: 'ENTER EMAIL ADDRESS'),
            decoration: _containerDecoration('ENTER EMAIL ADDRESS'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null; // remove this line if email is mandatory
              final ok = RegExp(r'^[\w.\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim());
              return ok ? null : 'Enter a valid email address';
            },
          ),
          const SizedBox(height: 16),
          const Text('State :', style: TextStyle(color: Colors.black54)),
          // TODO: replace with a real State master list / API-driven dropdown.
          DropdownButtonFormField<String>(
            value: _state,
            hint: const Text('Select State'),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            decoration: _containerDecoration(''),
            items: const [
              DropdownMenuItem(value: 'gujarat', child: Text('Gujarat')),
              DropdownMenuItem(
                  value: 'maharashtra', child: Text('Maharashtra')),
              DropdownMenuItem(
                  value: 'rajasthan', child: Text('Rajasthan')),
            ],
            onChanged: (v) => setState(() => _state = v),
            validator: (v) => v == null ? 'Please select a state' : null,
          ),

          const SizedBox(height: 16),
          // TODO: replace District/Village with cascading dropdowns fed by
          // the selected State once a location master/API is available.
          _labeledField('District :', _districtController,
              hint: 'ENTER DISTRICT'),
          const SizedBox(height: 16),
          _labeledField('Village :', _villageController,
              hint: 'ENTER VILLAGE / CITY'),
          const SizedBox(height: 16),
          const Text('Address :', style: TextStyle(color: Colors.black54)),
          TextField(
            controller: _addressController,
            maxLines: 3,
            // decoration:
            // const InputDecoration(hintText: 'ENTER FULL POSTAL ADDRESS'),
            decoration: _containerDecoration('ENTER FULL POSTAL ADDRESS'),
          ),
          const SizedBox(height: 16),
          const Text('Pin :', style: TextStyle(color: Colors.black54)),
          TextFormField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            // decoration:
            // const InputDecoration(hintText: 'ENTER PIN CODE', counterText: ''),
            decoration: _containerDecoration('ENTER PIN CODE')
                .copyWith(counterText: ''),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Pin code is required';
              if (v.length != 6) return 'Enter a valid 6-digit pin code';
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ---------- Step 5: Documents Details ----------
  Widget _buildStep5Documents() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Documents Details'),
          const SizedBox(height: 12),
          const Text('Aadhaar No. :', style: TextStyle(color: Colors.black54)),
          TextField(
            controller: _aadhaarNoController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            // decoration: const InputDecoration(
            //     hintText: 'ENTER 12-DIGIT AADHAAR NO.', counterText: ''),
            decoration: _containerDecoration('ENTER 12-DIGIT AADHAAR NO.')
                .copyWith(counterText: ''),
          ),
          _uploadRow(
            label: 'Upload Aadhaar',
            fileName: _aadhaarFileName,
            onTap: () => _pickFile((name) => setState(() => _aadhaarFileName = name)),
          ),
          const SizedBox(height: 20),
          const Text('Father/Guardian Aadhaar No. :',
              style: TextStyle(color: Colors.black54)),
          TextField(
            controller: _guardianAadhaarNoController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            // decoration: const InputDecoration(
            //     hintText: 'ENTER 12-DIGIT AADHAAR NO.', counterText: ''),
            decoration: _containerDecoration('ENTER 12-DIGIT AADHAAR NO.')
                .copyWith(counterText: ''),
          ),
          _uploadRow(
            label: 'Upload Father/Guardian Aadhaar',
            fileName: _guardianAadhaarFileName,
            onTap: () => _pickFile(
                    (name) => setState(() => _guardianAadhaarFileName = name)),
          ),
          const SizedBox(height: 20),
          const Text('Photo :', style: TextStyle(color: Colors.black54)),
          _uploadRow(
            label: 'Upload Photo',
            fileName: _photoFileName,
            onTap: () => _pickFile((name) => setState(() => _photoFileName = name)),
          ),
          const SizedBox(height: 20),
          const Text('Auth Letter :', style: TextStyle(color: Colors.black54)),
          _uploadRow(
            label: 'Upload Auth Letter',
            fileName: _authLetterFileName,
            onTap: () =>
                _pickFile((name) => setState(() => _authLetterFileName = name)),
          ),
        ],
      ),
    );
  }

  Widget _uploadRow({
    required String label,
    required String? fileName,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.upload_file, size: 18),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(width: 12),
          if (fileName != null)
            Expanded(
              child: Text(
                fileName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Step 6: Joining Fee & Instalment Details ----------
  Widget _buildStep6Fee() {
    final fee = _feeDetailsForAge(_age);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Joining Fee & Instalment Details'),
          const SizedBox(height: 12),
          _infoCard(
            child: Column(
              children: [
                _readOnlyRow('Age Group', fee['group'].toString()),
                _readOnlyRow('Joining Fee', '₹ ${fee['joiningFee']}'),
                _readOnlyRow('Instalment Amount', '₹ ${fee['instalment']}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Payment Mode :', style: TextStyle(color: Colors.black54)),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Cash'),
                  value: 'Cash',
                  groupValue: _paymentMode,
                  onChanged: (v) => setState(() => _paymentMode = v!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online'),
                  value: 'Online',
                  groupValue: _paymentMode,
                  onChanged: (v) => setState(() => _paymentMode = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _agreedTerms,
            onChanged: (v) => setState(() => _agreedTerms = v ?? false),
            title: const Text('I agree to the Terms & Conditions'),
          ),
        ],
      ),
    );
  }
  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: child,
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ---------- Step 7: Review & Confirm ----------
  Widget _buildStep7Review() {
    final fee = _feeDetailsForAge(_age);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Review & Confirm'),
          const SizedBox(height: 12),
          _infoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewGroup('Member & Scheme', {
                  'Member Type': _memberType,
                  'Scheme': _selectedScheme ?? '-',
                }),
                _reviewGroup('Personal Details', {
                  'Name': _fullNameController.text,
                  'Gotra': _gotra ?? '-',
                  'DOB': _dob == null
                      ? '-'
                      : '${_dob!.day.toString().padLeft(2, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.year}',
                  'Age': _age?.toString() ?? '-',
                  'Gender': _gender ?? '-',
                }),
                _reviewGroup('Family Details', {
                  'Father Name': _fatherNameController.text,
                  'Mother Name': _motherNameController.text,
                  'Husband Name': _husbandNameController.text,
                  'Guardian Name': _guardianNameController.text,
                  'Nominee Name': _nomineeNameController.text,
                  'Relation': _relationController.text,
                }),
                _reviewGroup('Contact Details', {
                  'Mobile No.': _mobileController.text,
                  'Email': _emailController.text,
                  'State': _state ?? '-',
                  'District': _districtController.text,
                  'Village': _villageController.text,
                  'Address': _addressController.text,
                  'Pin': _pinController.text,
                }),
                _reviewGroup('Documents Details', {
                  'Aadhaar No.': _aadhaarNoController.text,
                  'Aadhaar Upload': _aadhaarFileName ?? 'Not uploaded',
                  'Father/Guardian Aadhaar No.':
                  _guardianAadhaarNoController.text,
                  'Father/Guardian Aadhaar Upload':
                  _guardianAadhaarFileName ?? 'Not uploaded',
                  'Photo Upload': _photoFileName ?? 'Not uploaded',
                  'Auth Letter Upload': _authLetterFileName ?? 'Not uploaded',
                }),
                _reviewGroup('Joining Fee & Instalment', {
                  'Age Group': fee['group'].toString(),
                  'Joining Fee': '₹ ${fee['joiningFee']}',
                  'Instalment Amount': '₹ ${fee['instalment']}',
                  'Payment Mode': _paymentMode,
                  'Terms Accepted': _agreedTerms ? 'Yes' : 'No',
                }),
              ],
            ),
          ),
          if (_isSubmitting) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
            const SizedBox(height: 4),
            const Text('Submitting enrollment...',
                style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _reviewGroup(String title, Map<String, String> fields) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  // fontWeight: FontWeight.w600, color: Colors.indigo)),
                  fontWeight: FontWeight.w600, color: AppColors.primary)),
          const Divider(),
          ...fields.entries.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 160,
                    child: Text(e.key,
                        style: const TextStyle(color: Colors.black54)),
                  ),
                  Expanded(
                    child: Text(
                      e.value.isEmpty ? '-' : e.value,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Step 8: Response from Office ----------
  Widget _buildStep8Response() {
    if (!_isSubmitted) {
      return const Center(child: Text('Awaiting submission...'));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 12),
          _sectionHeader('Response from Office'),
          const SizedBox(height: 12),
          _infoCard(
            child: Column(
              children: [
                _readOnlyRow('Proposal No.', _proposalNo ?? '-'),
                _readOnlyRow(
                  'Date of Creation',
                  _proposalDate == null
                      ? '-'
                      : '${_proposalDate!.day.toString().padLeft(2, '0')}-'
                      '${_proposalDate!.month.toString().padLeft(2, '0')}-'
                      '${_proposalDate!.year}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareProposal,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('SHARE'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _downloadProposal,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('DOWNLOAD'),
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.indigo,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Shared helpers ----------

  Widget _sectionHeader(String title) {
    return Text(
      '$title :',
      style: const TextStyle(
          fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
    );
  }
  Widget _labeledField(String label, TextEditingController controller,
      {String? hint, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        TextFormField(
          controller: controller,
          decoration: _containerDecoration(hint ?? ''),
          validator: validator,
        ),
      ],
    );
  }

  // int _calculateAge(DateTime dob) {
  //   final today = DateTime.now();
  //   int age = today.year - dob.year;
  //   if (today.month < dob.month ||
  //       (today.month == dob.month && today.day < dob.day)) {
  //     age--;
  //   }
  //   return age;
  // }
  //
  // Widget _buildNavButtons() {
  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<String?> _showGotraPicker(BuildContext context) async {
    String query = '';
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _gotraList
                .where((g) => g.toLowerCase().contains(query.toLowerCase()))
                .toList();
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search Gotra',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setModalState(() => query = v),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No Gotra found'))
                          : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final gotra = filtered[index];
                          return ListTile(
                            title: Text(gotra),
                            onTap: () => Navigator.pop(context, gotra),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNavButtons() {
    final reviewStepIndex = _totalSteps - 2;
    final responseStepIndex = _totalSteps - 1;
    String nextLabel;
    if (_currentStep == reviewStepIndex) {
      nextLabel = 'SUBMIT';
    } else if (_currentStep == responseStepIndex) {
      nextLabel = 'DONE';
    } else {
      nextLabel = 'NEXT';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep != responseStepIndex)
          TextButton(
            onPressed: _goBack,
            child: Text(_currentStep == 0 ? 'CANCEL' : 'BACK'),
          )
        else
          const SizedBox.shrink(),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _goNext,
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.indigo,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(nextLabel),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1, // Services tab active (this screen lives under Services)
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      // selectedItemColor: Colors.indigo,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.black54,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      onTap: (index) {
        // Pop back to Services/Dashboard and let those screens handle the tab.
        Navigator.pop(context);
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Services'),
        BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Reports'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Profile'),
      ],
    );
  }
}