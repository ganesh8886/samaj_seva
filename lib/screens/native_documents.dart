import 'package:flutter/material.dart';
import '../utils/api_config.dart';
import 'native_documents.dart';

const _navy = Color(0xFF1B1442);
const _amber = Color(0xFFF2A93B);
const _paper = Color(0xFFFFFEFB);
const _brown = Color(0xFF92400E);
const _stage = Colors.white;

// ------------------------------------------------------------
// helpers
// ------------------------------------------------------------
bool _empty(dynamic v) => v == null || v.toString().trim().isEmpty || v.toString() == 'null';

String _s(dynamic v) => _empty(v) ? '-' : v.toString().trim();

/// First non-empty value for any of [keys], looking through [maps] in order.
String _pick(List<Map<String, dynamic>?> maps, List<String> keys) {
  for (final m in maps) {
    if (m == null) continue;
    for (final k in keys) {
      if (!_empty(m[k])) return m[k].toString().trim();
    }
  }
  return '-';
}

String _date10(String v) => (v.length >= 10 && v != '-') ? v.substring(0, 10) : v;

String _dobAge(String dob) {
  final d = DateTime.tryParse(_date10(dob));
  if (d == null) return dob;
  final n = DateTime.now();
  int a = n.year - d.year;
  if (n.month < d.month || (n.month == d.month && n.day < d.day)) a--;
  return '${_date10(dob)} ($a वर्ष)';
}

String _guardian(Map<String, dynamic>? m, Map<String, dynamic>? e) {
  final h = _pick([m, e], ['husband_name']);
  if (h != '-') return h;
  return _pick([m, e], ['father_name', 'guardian_name']);
}

String _photoOf(Map<String, dynamic>? m) {
  final p = (m?['photo_doc'] ?? '').toString().trim();
  if (p.isEmpty) return '';
  return p.startsWith('http') ? p : ApiConfig.bannerImageUrl(p);
}

Widget _logo({double size = 60}) => Image.network(
  '${ApiConfig.mediaBaseUrl}/assets/logo.jpeg',
  width: size,
  height: size,
  fit: BoxFit.contain,
  errorBuilder: (_, __, ___) => Icon(Icons.groups, size: size * 0.7, color: _navy),
);

Widget _photoBox(String url, {double size = 100, double radius = 14}) => Container(
  width: size,
  height: size,
  padding: const EdgeInsets.all(3),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: _navy, width: 2),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(radius - 3),
    child: url.isEmpty
        ? _logo(size: size)
        : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _logo(size: size)),
  ),
);

class _Barcode extends StatelessWidget {
  final String code;
  final double height;
  const _Barcode(this.code, {this.height = 26});
  @override
  Widget build(BuildContext context) {
    final units = (code.isEmpty ? '0' : code).codeUnits;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(46, (i) {
          final w = ((units[i % units.length] * (i + 3)) % 4) + 1;
          return Container(
            width: w * 0.9,
            height: height,
            color: Colors.black,
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
          );
        }),
      ),
      const SizedBox(height: 3),
      Text(code, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    ]);
  }
}

// ------------------------------------------------------------
// Generic swipeable portrait viewer
// Every page is designed at [pageSize] and scaled to fit the screen.
// ------------------------------------------------------------
class _PagedViewer extends StatefulWidget {
  final String title;
  final List<Widget> pages;
  final List<String> labels;
  final Size pageSize;
  final Widget? bottom;
  const _PagedViewer({
    required this.title,
    required this.pages,
    required this.labels,
    required this.pageSize,
    this.bottom,
  });
  @override
  State<_PagedViewer> createState() => _PagedViewerState();
}

class _PagedViewerState extends State<_PagedViewer> {
  final _c = PageController(viewportFraction: 0.94);
  int _i = 0;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _stage,
      appBar: AppBar(title: Text(widget.title), backgroundColor: _navy, foregroundColor: Colors.white),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _c,
                itemCount: widget.pages.length,
                onPageChanged: (i) => setState(() => _i = i),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: widget.pageSize.width,
                        height: widget.pageSize.height,
                        child: widget.pages[i],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(widget.labels[_i], style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pages.length, (i) {
                final sel = i == _i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: sel ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    // color: sel ? _amber : Colors.white24,
                    color: sel ? _amber : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            if (widget.pages.length > 1)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                // child: Text('← swipe →', style: TextStyle(color: Colors.white38, fontSize: 10.5)),
                 child: Text('← swipe →', style: TextStyle(color: Colors.grey, fontSize: 10.5)),
              ),
            if (widget.bottom != null) widget.bottom!,
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

Widget _pdfButton(VoidCallback onTap, {String label = 'Print / Download PDF'}) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5B4DF0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),
  ),
);

// ============================================================
// MEMBER PVC CARD (front + back, portrait, swipe)
// ============================================================
class MemberCardScreen extends StatelessWidget {
  final Map<String, dynamic> member;
  final String saCode;
  const MemberCardScreen({super.key, required this.member, required this.saCode});

  @override
  Widget build(BuildContext context) {
    return _PagedViewer(
      title: 'Member PVC Card',
      pageSize: const Size(300, 480),
      labels: const ['Front  (सामने)', 'Back  (पीछे)'],
      pages: [_PvcFront(m: member, saCode: saCode), _PvcBack(m: member)],
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: _paper,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: _amber.withOpacity(.75), width: 3),
);

Widget _cardKv(String l, String v) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 3.5),
  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 92, child: Text(l, style: TextStyle(color: Colors.grey.shade600, fontSize: 11))),
    Expanded(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
  ]),
);

class _PvcFront extends StatelessWidget {
  final Map<String, dynamic> m;
  final String saCode;
  const _PvcFront({required this.m, required this.saCode});

  @override
  Widget build(BuildContext context) {
    final village = _pick([m], ['village', 'village_name']);
    final taluka = _pick([m], ['taluka', 'taluka_name', 'tehsil']);
    return Container(
      decoration: _cardDeco(),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Container(
          width: double.infinity,
          color: _navy,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: const Column(children: [
            Text('।। श्री विश्वकर्माय नमः ।।', style: TextStyle(color: _amber, fontSize: 10.5, fontWeight: FontWeight.bold)),
            SizedBox(height: 3),
            Text('समस्त सुथार समाज सेवा समिति',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text('एस.डी. चेरीटेबल ट्रस्ट (रजि. नं. ई/1786/ब.का.)', style: TextStyle(color: Colors.white70, fontSize: 9)),
          ]),
        ),
        const SizedBox(height: 22),
        _photoBox(_photoOf(m), size: 104),
        const SizedBox(height: 10),
        Text(_pick([m], ['full_name', 'member_name']), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFEDEBFB), borderRadius: BorderRadius.circular(20)),
          child: Text('MEMBER ID: ${_pick([m], ['member_id'])}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
        ),
        const SizedBox(height: 5),
        const Text('SAMAJ PARIVAR (समाज सदस्य)',
            style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 10.5)),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _amber.withOpacity(.45)),
          ),
          child: Column(children: [
            _cardKv('पिता / पति', _guardian(m, null)),
            _cardKv('गौत्र', _pick([m], ['gotra', 'gotra_name'])),
            _cardKv('मोबाइल', _pick([m], ['mobile'])),
            _cardKv('गांव / क्षेत्र', '$village, $taluka'),
            _cardKv('कार्यकर्ता कोड', _pick([m], ['karyakarta_code', 'sa_code']) != '-' ? _pick([m], ['karyakarta_code', 'sa_code']) : _s(saCode)),
          ]),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          color: _navy,
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: const Text('हेड ऑफिस: चांगडा, तह. थराद, जि. बनासकांठा (गुजरात)',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}

class _PvcBack extends StatelessWidget {
  final Map<String, dynamic> m;
  const _PvcBack({required this.m});

  @override
  Widget build(BuildContext context) {
    final name = _pick([m], ['full_name', 'member_name']);
    final first = name == '-' ? '' : name.split(' ').first.toUpperCase();
    Widget bullet(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('• $t', style: const TextStyle(fontSize: 10.5, height: 1.35)),
    );
    return Container(
      decoration: _cardDeco(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Center(child: Text('नियम व संस्था निर्देश', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
        const Divider(),
        bullet('यह कार्ड सुथार समाज सेवा समिति परिवार कल्याण योजना का आधिकारिक सदस्य कार्ड है।'),
        bullet('समय पर योजना सहयोग राशि जमा कराकर रसीद अवश्य प्राप्त करें।'),
        bullet('कार्ड खो जाने पर तुरंत अपने अधिकृत कार्यकर्ता या मुख्यालय को सूचित करें।'),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _amber.withOpacity(.45)),
            ),
            child: const Column(children: [
              Text('Suthar Samaj Seva Samiti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text('Managed by SD CHARITABLE TRUST', style: TextStyle(fontSize: 10, color: Color(0xFF92400E))),
              Text('CHANGDA, RAH, VAV-THARAD, GUJARAT - 385565', style: TextStyle(fontSize: 8.5, color: Colors.black54)),
              SizedBox(height: 4),
              Text('8141904121 / 9979776815', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              Text('sampark@sutharsamajseva.org', style: TextStyle(fontSize: 9, color: Colors.black54)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _amber.withOpacity(.45)),
            ),
            child: Center(child: _Barcode('MEM${_pick([m], ['member_id'])}-$first', height: 34)),
          ),
        ),
        const Spacer(),
        const Divider(height: 14, color: _amber),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
            const Text('सदस्य के हस्ताक्षर', style: TextStyle(fontSize: 8.5, color: Colors.grey)),
          ]),
          const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('शांतिलाल डी. सुथार', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5, color: Color(0xFF92400E))),
            Text('संस्थापक / अधिकृत हस्ताक्षर', style: TextStyle(fontSize: 8.5, color: Colors.grey)),
          ]),
        ]),
      ]),
    );
  }
}

// ============================================================
// Shared portrait "paper" page (used by certificate/dastavej/proposal)
// ============================================================
const Size _docSize = Size(440, 640);

Widget _paperPage({required List<Widget> children, CrossAxisAlignment align = CrossAxisAlignment.stretch}) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: _brown, borderRadius: BorderRadius.circular(14)),
    child: Container(
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _amber, width: 1.2),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: ClipRect(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(crossAxisAlignment: align, children: children),
        ),
      ),
    ),
  );
}

Widget _docHeader(String pillText) => Column(children: [
  const Text('।। श्री विश्वकर्माय नमः ।।', style: TextStyle(color: _brown, fontSize: 10.5, fontWeight: FontWeight.bold)),
  const SizedBox(height: 3),
  const Text('SUTHAR SAMAJ SEVA SAMITI,\nGUJARAT & RAJASTHAN',
      textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _navy, height: 1.25)),
  const SizedBox(height: 3),
  const Text('एस.डी. चेरीटेबल ट्रस्ट द्वारा संचालित (रजि. नं. ई/1786/ब.का.)',
      textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Colors.black54)),
  const Text('मुख्य कार्यालय: चांगडा, तह. राह (वाव-थराद), जिला बनासकांठा, गुजरात - 385565',
      textAlign: TextAlign.center, style: TextStyle(fontSize: 8.5, color: Colors.black54)),
  const SizedBox(height: 8),
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(20)),
    child: Text(pillText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
  ),
]);

TextSpan _b(String t) => TextSpan(
  text: ' $t ',
  style: const TextStyle(fontWeight: FontWeight.w800, color: _navy, decoration: TextDecoration.underline),
);

Widget _sigRow(String left, String leftSub, String right, String rightSub) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(left, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
      Text(leftSub, style: const TextStyle(fontSize: 8.5, color: Colors.grey)),
    ]),
    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(right, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: _brown)),
      Text(rightSub, style: const TextStyle(fontSize: 8.5, color: Colors.grey)),
    ]),
  ],
);

Widget _verifyBox(String title, String sub, String tag) => Container(
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: const Color(0xFFFFFBEB),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _amber.withOpacity(.6)),
  ),
  child: Row(children: [
    const Icon(Icons.qr_code_2_rounded, size: 58, color: Colors.black87),
    const SizedBox(width: 10),
    Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5)),
        Text(sub, style: const TextStyle(fontSize: 8.5, color: Colors.black54)),
        Text(tag, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF3730A3))),
      ]),
    ),
  ]),
);

// ============================================================
// MEMBERSHIP CERTIFICATE (portrait)
// ============================================================
class MemberCertificateScreen extends StatelessWidget {
  final Map<String, dynamic> member;
  final String saCode;
  final String saName;
  final String schemeNames;
  final VoidCallback? onPdf;
  const MemberCertificateScreen({
    super.key,
    required this.member,
    this.saCode = '',
    this.saName = '',
    this.schemeNames = '',
    this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    final m = member;
    final name = _pick([m], ['full_name', 'member_name']);
    final sa = _pick([m], ['karyakarta_code', 'sa_code']) != '-' ? _pick([m], ['karyakarta_code', 'sa_code']) : _s(saCode);
    final kName = _pick([m], ['karyakarta_name']) != '-' ? _pick([m], ['karyakarta_name']) : _s(saName);
    final regDate = _date10(_pick([m], ['created_at', 'joining_date', 'registration_date']));

    final page = _paperPage(children: [
      _docHeader('आधिकारिक सदस्यता प्रमाण-पत्र'),
      const SizedBox(height: 18),
      Center(child: _photoBox('', size: 92)),
      const SizedBox(height: 16),
      Text.rich(
        TextSpan(style: const TextStyle(fontSize: 13, height: 1.9, color: Colors.black87), children: [
          const TextSpan(text: 'प्रमाणित किया जाता है कि'),
          _b(name),
          const TextSpan(text: ', सुपुत्र / पत्नी श्री'),
          _b(_guardian(m, null)),
          const TextSpan(text: ', गौत्र'),
          _b(_pick([m], ['gotra', 'gotra_name'])),
          const TextSpan(text: ', निवासी'),
          _b(_pick([m], ['village', 'village_name'])),
          const TextSpan(text: ', तह.'),
          _b(_pick([m], ['taluka', 'taluka_name', 'tehsil'])),
          const TextSpan(text: '(जि.'),
          _b('${_pick([m], ['district', 'district_name'])}, ${_pick([m], ['state', 'state_name'])}'),
          const TextSpan(text: ') संस्था के अधिकृत आजीवन सदस्य पंजीकृत हैं।'),
        ]),
      ),
      const SizedBox(height: 10),
      Text.rich(TextSpan(style: const TextStyle(fontSize: 13, height: 1.8), children: [
        const TextSpan(text: 'आपका स्थायी सदस्य क्रमांक (Member ID): '),
        TextSpan(text: _pick([m], ['member_id']), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3730A3))),
        const TextSpan(text: ' है।'),
      ])),
      if (schemeNames.trim().isNotEmpty) ...[
        const SizedBox(height: 4),
        Text.rich(TextSpan(style: const TextStyle(fontSize: 12.5), children: [
          const TextSpan(text: 'संलग्न योजनाएं: '),
          TextSpan(text: schemeNames, style: const TextStyle(fontWeight: FontWeight.w800)),
        ])),
      ],
      const SizedBox(height: 10),
      const Text('संस्था के कल्याणकारी कार्यों में आपके सहयोग के लिए धन्यवाद। आशा है आप समाज हित एवं संगठन के नियमों का निष्ठापूर्वक पालन करेंगे।',
          style: TextStyle(fontSize: 9.5, color: Color(0xFFB45309), height: 1.5)),
      const SizedBox(height: 26),
      _verifyBox('SCAN TO VERIFY', 'Member Official Record Verification', 'Tag SA: $sa'),
      const SizedBox(height: 34),
      const Divider(color: _amber),
      const SizedBox(height: 6),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('पंजीकरण दिनांक: $regDate', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10)),
            const Text('Head Office: Changda (Tharad, Gujarat)', style: TextStyle(fontSize: 8, color: Colors.grey)),
          ]),
        ),
      ]),
      const SizedBox(height: 18),
      _sigRow(kName, 'कार्यकर्ता के हस्ताक्षर', 'शांतिलाल डी. सुथार', 'संस्थापक / अध्यक्ष के हस्ताक्षर'),
    ]);

    return _PagedViewer(
      title: 'Membership Certificate',
      pageSize: _docSize,
      labels: const ['Certificate (प्रमाण-पत्र)'],
      pages: [page],
      bottom: onPdf == null ? null : _pdfButton(onPdf!),
    );
  }
}

// ============================================================
// ENROLLMENT DOCUMENT (Proposal form / Policy Dastavej)
// - [enrollment] = scheme enrollment map from API
// - [member]     = optional member profile map (dob, father, gotra, address ...)
// ============================================================
class EnrollmentDocScreen extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  final bool isPolicy; // true = Dastavej, false = Proposal
  final String saCode;
  final String saName;
  final Map<String, dynamic>? member;
  final VoidCallback? onPdf;
  const EnrollmentDocScreen({
    super.key,
    required this.enrollment,
    required this.isPolicy,
    required this.saCode,
    required this.saName,
    this.member,
    this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    final e = enrollment;
    final status = _s(e['status'] ?? e['enrollment_status']);
    final approved = status.toLowerCase() == 'approved';

    Widget? bottom;
    final banner = (isPolicy && !approved)
        ? Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(10)),
      child: Text('This policy is "$status". The official Dastavej is issued only for approved policies.',
          style: const TextStyle(fontSize: 11.5)),
    )
        : null;
    if (banner != null || onPdf != null) {
      bottom = Column(children: [
        if (banner != null) banner,
        if (onPdf != null) _pdfButton(onPdf!, label: isPolicy ? 'Download Dastavej PDF' : 'Download Proposal PDF'),
      ]);
    }

    return _PagedViewer(
      title: isPolicy ? 'Policy Dastavej' : 'Proposal Details',
      pageSize: _docSize,
      labels: isPolicy
          ? const ['Certificate (प्रमाण-पत्र)', 'Terms & Clauses (नियम)']
          : const ['Proposal Form (प्रस्ताव फॉर्म)'],
      pages: isPolicy ? [_dastavejPage1(), _dastavejPage2()] : [_proposalPage()],
      bottom: bottom,
    );
  }

  // ---------- values ----------
  String get _memberName => _pick([member, enrollment], ['full_name', 'member_name']);
  String get _memberId {
    final v = _pick([member], ['member_id']);
    return v != '-' ? v : _pick([enrollment], ['member_code', 'member_id']);
  }
  String get _sa {
    final v = _pick([enrollment, member], ['karyakarta_code', 'sa_code']);
    return v != '-' ? v : _s(saCode);
  }
  String get _schemeLine {
    final n = _pick([enrollment], ['scheme_name']);
    final c = _pick([enrollment], ['scheme_code']);
    return c == '-' ? n : '$n ($c)';
  }

  // ---------- Dastavej page 1 ----------
  Widget _dastavejPage1() {
    final e = enrollment;
    final nomName = _pick([e, member], ['nominee_name']);
    final nomRel = _pick([e, member], ['nominee_relation']);
    return _paperPage(children: [
      _docHeader('योजना सदस्यता प्रमाण-पत्र (CERTIFICATE OF SCHEME ENROLLMENT)'),
      const SizedBox(height: 18),
      Center(child: _photoBox('', size: 92)),
      const SizedBox(height: 16),
      Text.rich(
        TextSpan(style: const TextStyle(fontSize: 13, height: 1.9, color: Colors.black87), children: [
          const TextSpan(text: 'प्रमाणित किया जाता है कि'),
          _b(_memberName),
          const TextSpan(text: ', सुपुत्र / पत्नी श्री'),
          _b(_guardian(member, e)),
          const TextSpan(text: ', गौत्र'),
          _b(_pick([member, e], ['gotra', 'gotra_name'])),
          const TextSpan(text: ', निवासी'),
          _b(_pick([member, e], ['village', 'village_name'])),
          const TextSpan(text: ', तह.'),
          _b(_pick([member, e], ['taluka', 'taluka_name', 'tehsil'])),
          const TextSpan(text: '(जि.'),
          _b(_pick([member, e], ['district', 'district_name'])),
          const TextSpan(text: ') संस्था की कल्याणकारी योजना'),
          _b(_schemeLine),
          const TextSpan(text: 'में पंजीकृत है।'),
        ]),
      ),
      const SizedBox(height: 8),
      Text.rich(TextSpan(style: const TextStyle(fontSize: 12.5, height: 1.8), children: [
        const TextSpan(text: 'योजना खाता संख्या (Scheme A/C No): '),
        TextSpan(text: _pick([e], ['scheme_account_no']), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3730A3))),
        const TextSpan(text: '   |   सदस्य आईडी: '),
        TextSpan(text: _memberId, style: const TextStyle(fontWeight: FontWeight.w800)),
      ])),
      const SizedBox(height: 4),
      Text.rich(TextSpan(style: const TextStyle(fontSize: 12.5), children: [
        const TextSpan(text: 'नामांकित व्यक्ति (Nominee): '),
        TextSpan(text: nomRel == '-' ? nomName : '$nomName ($nomRel)', style: const TextStyle(fontWeight: FontWeight.w800)),
      ])),
      const SizedBox(height: 30),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _amber.withOpacity(.6)),
        ),
        child: Row(children: [
          const Icon(Icons.qr_code_2_rounded, size: 52),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('DIGITAL POLICY RECORD', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10)),
              Text('पंजीकरण दिनांक: ${_date10(_pick([e], ['approved_at', 'created_at']))}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              Text('कार्यकर्ता कोड: $_sa', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('प्रति अवसर सहयोग दर', style: TextStyle(fontSize: 8.5, color: Color(0xFF3730A3))),
            Text('₹${_pick([e], ['per_event_installment'])}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF3730A3))),
          ]),
        ]),
      ),
      const SizedBox(height: 60),
      const Divider(color: _amber),
      const SizedBox(height: 4),
      _sigRow('पंजीकरण स्थान: चांगडा (थराद)', 'Head Office, Banaskantha (Gujarat)', 'शांतिलाल डी. सुथार', 'संस्थापक / अध्यक्ष के हस्ताक्षर'),
      const SizedBox(height: 8),
      Center(child: Text(_s(saName), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11))),
      const Center(child: Text('कार्यकर्ता के हस्ताक्षर', style: TextStyle(fontSize: 8.5, color: Colors.grey))),
    ]);
  }

  // ---------- Dastavej page 2 ----------
  Widget _dastavejPage2() {
    Widget rule(String t, {bool warn = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('• $t',
          style: TextStyle(fontSize: 12, height: 1.5, color: warn ? const Color(0xFFBE123C) : Colors.black87, fontWeight: warn ? FontWeight.bold : FontWeight.w500)),
    );
    return _paperPage(children: [
      const Center(
        child: Text('योजना नियम, शर्तें एवं दावा प्रक्रिया निर्देश\n(POLICY TERMS & CLAUSES)',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _navy)),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('खाता संख्या: ${_pick([enrollment], ['scheme_account_no'])}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
        Text('सदस्य: $_memberName', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
      ]),
      Text('योजना: $_schemeLine', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
      const Divider(color: Colors.black26),
      const SizedBox(height: 6),
      const Text('योजना नियम (संक्षेप)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      const SizedBox(height: 8),
      rule('सदस्यता के प्रारंभिक लॉक अवधि में कोई सहायता देय नहीं।'),
      rule('विवाह/आकस्मिक घटना के 15 दिनों के भीतर कार्यकर्ता या हेल्पलाइन 8141904121 को सूचित करें।'),
      rule('प्रत्येक अवसर पर सूचना के 10 दिनों के भीतर सहयोग राशि जमा करें।'),
      rule('लगातार 3 अवसरों तक राशि जमा न करने पर सदस्यता स्वतः निलंबित हो जाएगी।', warn: true),
      // TODO: replace/extend with the full clauses text from your web policy_dastavej.php
    ]);
  }

  // ---------- Proposal page ----------
  Widget _proposalPage() {
    final e = enrollment;
    final m = member;

    Widget cell(String l, String v, {Color? vc}) => Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 6, bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: TextStyle(fontSize: 8, color: Colors.grey.shade600)),
          Text(v, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: vc ?? Colors.black87)),
        ]),
      ),
    );
    Widget section(String title, List<Widget> rows) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black26)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: _navy)),
        const Divider(height: 8),
        ...rows,
      ]),
    );

    final aadhaar = !_empty(m?['aadhaar_no']) || !_empty(e['aadhaar_no']);
    final dob = _pick([m, e], ['dob']);
    final wait = _pick([e], ['waiting_period_months', 'waiting_period']);

    return _paperPage(children: [
      Column(children: [
        const Text('।। श्री विश्वकर्माय नमः ।।', style: TextStyle(color: _brown, fontSize: 10, fontWeight: FontWeight.bold)),
        const Text('SUTHAR SAMAJ SEVA SAMITI, GUJARAT & RAJASTHAN',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: _navy)),
        const Text('एस.डी. चेरीटेबल ट्रस्ट द्वारा संचालित (रजि. नं. ई/1786/ब.का.) | मुख्य कार्यालय: चांगडा, तह. राह (वाव-थराद)',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: Colors.black54)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(20)),
          child: const Text('कल्याणकारी योजना प्रस्ताव फॉर्म (PROPOSAL APPLICATION FORM)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9.5)),
        ),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF8F7FC), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
        child: Row(children: [
          _Barcode(_pick([e], ['proposal_no']), height: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Row(children: [
              cell('योजना (Scheme Name):', _schemeLine),
              cell('आवेदन दिनांक (Date):', _date10(_pick([e], ['created_at']))),
              cell('कार्यकर्ता (SA Code):', _sa, vc: const Color(0xFF3730A3)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 8),
      section('1. आवेदक / सदस्य की व्यक्तिगत जानकारी (PERSONAL DETAILS)', [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(children: [
              Row(children: [cell('पूरा नाम (Full Name):', _memberName), cell('गोत्र (Gotra):', _pick([m, e], ['gotra', 'gotra_name']))]),
              Row(children: [cell('जन्म तिथि व आयु (DOB & Age):', dob == '-' ? '-' : _dobAge(dob)), cell('लिंग (Gender):', _pick([m, e], ['gender']))]),
              Row(children: [
                cell('मोबाइल नंबर (Mobile No):', _pick([m, e], ['mobile', 'member_mobile'])),
                cell('पहचान सत्यापन (Identity):', aadhaar ? '[Aadhaar Verified]' : 'Pending', vc: aadhaar ? const Color(0xFF0F766E) : Colors.orange.shade800),
              ]),
            ]),
          ),
          _photoBox(_photoOf(m), size: 64, radius: 8),
        ]),
      ]),
      section('2. पारिवारिक एवं नॉमिनी विवरण (FAMILY & NOMINEE DETAILS)', [
        Row(children: [cell('पिता (Father):', _pick([m, e], ['father_name'])), cell('माता (Mother):', _pick([m, e], ['mother_name']))]),
        Row(children: [cell('पति (Husband):', _pick([m, e], ['husband_name'])), cell('अभिभावक (Guardian):', _pick([m, e], ['guardian_name']))]),
        Row(children: [cell('नॉमिनी का पूरा नाम (Nominee Name):', _pick([e, m], ['nominee_name'])), cell('नॉमिनी से संबंध (Nominee Relation):', _pick([e, m], ['nominee_relation']))]),
      ]),
      section('3. संपर्क एवं आवासीय पता (RESIDENTIAL ADDRESS & LOCATION)', [
        Row(children: [
          cell('राज्य (State):', _pick([m, e], ['state', 'state_name'])),
          cell('जिला (District):', _pick([m, e], ['district', 'district_name'])),
        ]),
        Row(children: [
          cell('तहसील / तालुका (Taluka):', _pick([m, e], ['taluka', 'taluka_name', 'tehsil'])),
          cell('गांव / शहर (Village/City):', _pick([m, e], ['village', 'village_name'])),
        ]),
        Row(children: [cell('पूर्ण आवासीय पता (Full Address):', _pick([m, e], ['address', 'full_address'])), cell('पिन कोड (PIN Code):', _pick([m, e], ['pincode']))]),
      ]),
      Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
        decoration: BoxDecoration(color: const Color(0xFFE8F8F5), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF16A085).withOpacity(.4))),
        child: Row(children: [
          cell('प्रवेश शुल्क (JOINING FEE):', '₹${_pick([e], ['joining_fee'])}', vc: const Color(0xFF0F766E)),
          cell('प्रति अवसर सहयोग (PER-EVENT):', '₹${_pick([e], ['per_event_installment'])}', vc: const Color(0xFF0F766E)),
          cell('भुगतान माध्यम (PAYMENT MODE):', _pick([e], ['payment_mode'])),
          cell('प्रतीक्षा अवधि (WAITING PERIOD):', wait == '-' ? '-' : (RegExp(r'^\d+$').hasMatch(wait) ? '$wait महीने' : wait)),
        ]),
      ),
      const SizedBox(height: 8),
      const Text(
        'शपथ पत्र (Declaration): मैं प्रमाणित करता/करती हूँ कि ऊपर दी गई समस्त जानकारी पूर्णतः सत्य है। मैं संस्था के नियमों, प्रतीक्षा अवधि एवं समय पर सहयोग राशि जमा करने के नियमों का पालन करूँगा/करूँगी।',
        style: TextStyle(fontSize: 8, color: Colors.black54, height: 1.4),
      ),
      const SizedBox(height: 22),
      _sigRow('आवेदक के हस्ताक्षर (Member Sign)', '', _s(saName), 'कार्यकर्ता के हस्ताक्षर (SA Sign)'),
    ]);
  }
}

