import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';
import 'enrollment_create_screen.dart';
import 'login_screen.dart';
import 'member_registration_screen.dart';
import 'pvc_card_webview_screen.dart';
import 'member_card_screen.dart';
import 'enrollment_doc_screen.dart';
import 'package:file_picker/file_picker.dart' show PlatformFile;

// ============================================================
// THEME
// ============================================================
class KColors {
  static const primary = Color(0xFF6A5AE0);
  static const navy = Color(0xFF241C4F);
  static const navyDark = Color(0xFF1B1442);
  static const green = Color(0xFF16A085);
  static const orange = Color(0xFFC97C0F);
  static const red = Color(0xFFE0522F);
  static const blue = Color(0xFF2F7DE1);
  static const bg = Color(0xFFF7F6FB);
  static const navActive = Color(0xFFF2A93B);
  static const navInactive = Color(0xFF8B8B8B);
}

// ============================================================
// MODELS (mock data / DTOs used elsewhere in the app)
// ============================================================
class KMember {
  final String id, name, gotra, mobile, village, status;
  final int schemes;
  KMember(this.id, this.name, this.gotra, this.mobile, this.village, this.schemes, this.status);
}

class KEnrollment {
  final String proposalNo, schemeId, memberName, memberId, scheme, status;
  final int joiningFee, perEvent;
  KEnrollment(this.proposalNo, this.schemeId, this.memberName, this.memberId, this.scheme,
      this.joiningFee, this.perEvent, this.status);
}

class KClaim {
  final String claimId, memberName, memberId, scheme, event, submittedBy, status;
  final int benefit;
  KClaim(this.claimId, this.memberName, this.memberId, this.scheme, this.event, this.submittedBy,
      this.benefit, this.status);
}

class KOldClaim {
  final String claimId, batchId, beneficiary, benId, event, date, paidPending, dateOfPayment;
  final int totalMembers, totalCollection, collected, expected;
  KOldClaim(this.claimId, this.batchId, this.beneficiary, this.benId, this.event, this.date,
      this.totalMembers, this.totalCollection, this.paidPending, this.collected, this.expected,
      this.dateOfPayment);
}

class KCommission {
  final String proposalNo, memberName, memberId, scheme, category, status;
  final int joiningFee, commission;
  KCommission(this.proposalNo, this.memberName, this.memberId, this.scheme, this.category,
      this.joiningFee, this.commission, this.status);
}

// ============================================================
// SESSION
// ============================================================
class MemberSession {
  static String saCode = '';
  static String fullName = 'Member';
  static String mobile = '';
  static String village = '';
  static String photoUrl = '';
  static String memberId = '';
  static String gotra = '';
  static String taluka = '';
  static String district = '';
  static String status = '';
  static String karyakartaCode = '';
  static String karyakartaName = '';
  static String karyakartaMobile = '';

  static void clear() {
    saCode = '';
    fullName = 'Member';
    mobile = '';
    village = '';
    photoUrl = '';
    memberId = '';
    gotra = '';
    taluka = '';
    district = '';
    status = '';
    karyakartaCode = '';
    karyakartaName = '';
    karyakartaMobile = '';
  }
}

String get kSaCode => MemberSession.saCode;
String get kFullName => MemberSession.fullName;
String get kMobile => MemberSession.mobile;
String get kVillage => MemberSession.village;
String get kPhotoUrl => MemberSession.photoUrl;
String get kMemberId => MemberSession.memberId;
String get kGotra => MemberSession.gotra;
String get kTaluka => MemberSession.taluka;
String get kDistrict => MemberSession.district;
String get kStatus => MemberSession.status;
String get kKaryakartaCode => MemberSession.karyakartaCode;
String get kKaryakartaName => MemberSession.karyakartaName;
String get kKaryakartaMobile => MemberSession.karyakartaMobile;

// ============================================================
// MAIN SHELL
// ============================================================
class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});
  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMemberProfile();
  }

  Future<void> _loadMemberProfile() async {
    final profile = await ApiService().getMemberSelfProfile();
    if (!mounted || profile == null) return;
    setState(() {
      MemberSession.saCode = profile['member_code']?.toString() ?? MemberSession.saCode;
      MemberSession.fullName = profile['full_name']?.toString() ?? MemberSession.fullName;
      MemberSession.mobile = profile['mobile']?.toString() ?? MemberSession.mobile;
      MemberSession.village = profile['village']?.toString() ?? MemberSession.village;
      final photoDoc = (profile['photo_doc'] ?? '').toString();
      MemberSession.photoUrl = photoDoc.isNotEmpty ? ApiConfig.bannerImageUrl(photoDoc) : '';
      MemberSession.memberId = profile['member_id']?.toString() ?? MemberSession.memberId;
      MemberSession.gotra = profile['gotra']?.toString() ?? MemberSession.gotra;
      MemberSession.taluka = profile['taluka']?.toString() ?? MemberSession.taluka;
      MemberSession.district = profile['district']?.toString() ?? MemberSession.district;
      MemberSession.status = profile['status']?.toString() ?? MemberSession.status;
      MemberSession.karyakartaCode = profile['karyakarta_code']?.toString() ?? MemberSession.karyakartaCode;
      MemberSession.karyakartaName = profile['karyakarta_name']?.toString() ?? MemberSession.karyakartaName;
      MemberSession.karyakartaMobile =
          profile['karyakarta_mobile']?.toString() ?? MemberSession.karyakartaMobile;
    });
  }

  // Reports tab is intentionally dropped for members.
  static const _navItems = [
    (label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    (label: 'Services', icon: Icons.people_alt_outlined, activeIcon: Icons.people_alt),
    (label: 'Profile', icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle),
  ];

  late final _sections = [
    _HomeTab(onNavigate: (i) => setState(() => _navIndex = i)),
    const _ServicesSection(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: IndexedStack(index: _navIndex.clamp(0, _sections.length - 1), children: _sections)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Future<void> _showNotifications() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final notifications = await ApiService().getMemberNotifications();

    if (!mounted) return;
    Navigator.of(context).pop();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => notifications.isEmpty
            ? ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No new notifications')),
            ),
          ],
        )
            : ListView.separated(
          controller: controller,
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final n = notifications[i];
            final msg = (n['message'] ?? '').toString();
            return ListTile(
              leading: const Icon(Icons.notifications_none, color: KColors.primary),
              title: Text(
                '${n['title'] ?? 'Notification'}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.isNotEmpty) Text(msg, style: const TextStyle(fontSize: 12.5)),
                  if (n['created_at'] != null)
                    Text('${n['created_at']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: KColors.navyDark,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          if (_navIndex != 0)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _navIndex = 0),
              child: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: const Color(0xFFF2A93B), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.bolt, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUTHAR SAMAJ SEVA SAMITI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'Member Portal (${kMemberId.isNotEmpty ? kMemberId : kSaCode})',
                  style: const TextStyle(color: Color(0xFFF2A93B), fontSize: 11),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _showNotifications,
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _navIndex = 2),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
              padding: const EdgeInsets.all(3),
              child: memberAvatar(radius: 14, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final selected = _navIndex == i;
            final color = selected ? KColors.navActive : KColors.navInactive;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _navIndex = i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(selected ? item.activeIcon : item.icon, color: color, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ============================================================
// SHARED WIDGETS
// ============================================================
Widget sectionHeader(String title, String subtitle, {Widget? action}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
            ],
          ),
        ),
        if (action != null) action,
      ],
    ),
  );
}

Widget statusBadge(String status) {
  Color c;
  switch (status.toUpperCase()) {
    case 'ACTIVE':
    case 'APPROVED':
    case 'PAID':
      c = KColors.green;
      break;
    case 'PENDING':
      c = KColors.red;
      break;
    default:
      c = Colors.grey;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: c.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
    child: Text(status, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 11)),
  );
}

Widget infoRow(String label, String value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 118, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5))),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        ),
      ],
    ),
  );
}

Widget card(Widget child) => Container(
  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 6, offset: const Offset(0, 2))],
  ),
  child: child,
);

final ValueNotifier<int> kServicesSubTab = ValueNotifier<int>(0);

Future<void> openSecureDoc(
    BuildContext context, {
      required String docType,
      required String recordId,
      required String title,
      required String Function(String token) urlBuilder,
    }) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  if (recordId.isEmpty) {
    messenger.showSnackBar(SnackBar(content: Text('Missing ID — cannot open $title.')));
    return;
  }
  final token = await ApiService().getDocumentShareToken(docType: docType, recordId: recordId);
  if (token == null) {
    messenger.showSnackBar(SnackBar(content: Text('Could not generate a secure link for $title.')));
    return;
  }
  navigator.push(MaterialPageRoute(builder: (_) => PvcCardWebViewScreen(url: urlBuilder(token), title: title)));
}

Future<void> openProposalDoc(BuildContext c, Map<String, dynamic> e) {
  final id = (e['id'] ?? '').toString();
  return openSecureDoc(
    c,
    docType: 'proposal',
    recordId: id,
    title: 'Proposal Form',
    urlBuilder: (t) => ApiConfig.karyakartaEnrollmentProposalWebUrl(id, t),
  );
}

Future<void> openDastavejDoc(BuildContext c, Map<String, dynamic> e) {
  final id = (e['id'] ?? '').toString();
  return openSecureDoc(
    c,
    docType: 'policy',
    recordId: id,
    title: 'Dastavej (Policy Document)',
    urlBuilder: (t) => ApiConfig.karyakartaEnrollmentDastavejWebUrl(id, t),
  );
}

Future<void> openMemberCard(BuildContext c, {required String recordId, required String type}) {
  return openSecureDoc(
    c,
    docType: type,
    recordId: recordId,
    title: type == 'certificate' ? 'Membership Certificate' : 'Smart PVC ID',
    urlBuilder: (t) => ApiConfig.karyakartaMemberPvcCardWebUrl(recordId, t, type: type),
  );
}

Widget memberAvatar({double radius = 20, double? fontSize}) {
  final photo = kPhotoUrl;
  final initial = kFullName.trim().isNotEmpty ? kFullName.trim()[0].toUpperCase() : 'M';
  final size = radius * 2;
  final effectiveFontSize = fontSize ?? radius * 0.7;

  Widget fallback() => CircleAvatar(
    radius: radius,
    backgroundColor: const Color(0xFFF2A93B),
    child: Text(initial, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: effectiveFontSize)),
  );

  if (photo.trim().isEmpty) return fallback();

  return ClipOval(
    child: Image.network(
      photo,
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: size,
          height: size,
          color: const Color(0xFFF2A93B),
          child: const Center(
            child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          ),
        );
      },
      errorBuilder: (context, error, stack) => fallback(),
    ),
  );
}

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});
  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  late Future<List<Map<String, dynamic>>> _future;
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getBanners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final banners = snapshot.data ?? [];

        if (loading) {
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            height: 120,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
            child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }

        if (banners.isEmpty) return _placeholderBanner();

        return Column(
          children: [
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final b = banners[i];
                  final imageUrl = ApiConfig.bannerImageUrl((b['image_url'] ?? '').toString());
                  final title = (b['title'] ?? '').toString();
                  final targetLink = (b['target_link'] ?? '').toString();

                  return GestureDetector(
                    onTap: targetLink.trim().isEmpty ? null : () {},
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.grey.shade200),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                            },
                            errorBuilder: (context, error, stack) => _imageFallback(title),
                          ),
                          Positioned(
                            top: 6,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(4)),
                              child: const Text('AD', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (banners.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (i) {
                  final sel = i == _index;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: sel ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(color: sel ? KColors.primary : Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                  );
                }),
              ),
            ],
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _imageFallback(String title) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFF2A93B), Color(0xFFE0522F)], begin: Alignment.centerLeft, end: Alignment.centerRight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title.isNotEmpty ? title : 'Advertisement',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 90,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF2A93B), Color(0xFFE0522F)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Advertisement Space', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 3),
                  Text('Your banner ad will appear here', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget searchBar(String hint, {Widget? trailing}) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
  child: Row(children: [
    Expanded(
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    ),
    if (trailing != null) ...[const SizedBox(width: 8), trailing],
  ]),
);

Widget primaryButton(String label, IconData icon, {Color? color, VoidCallback? onTap}) {
  return ElevatedButton.icon(
    onPressed: onTap ?? () {},
    icon: Icon(icon, size: 16),
    label: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
    style: ElevatedButton.styleFrom(
      backgroundColor: color ?? KColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
    ),
  );
}

Widget emptyState(IconData icon, String text) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 60),
  child: Column(children: [
    Icon(icon, size: 44, color: Colors.grey.shade300),
    const SizedBox(height: 12),
    Text(text, style: TextStyle(color: Colors.grey.shade500, fontSize: 13.5)),
  ]),
);

Widget subTabStrip(List<String> labels, int selected, ValueChanged<int> onSelect) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: List.generate(labels.length, (i) {
          final sel = selected == i;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              selected: sel,
              onSelected: (_) => onSelect(i),
              label: Text(labels[i], style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.black87)),
              selectedColor: KColors.primary,
              backgroundColor: KColors.bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }),
      ),
    ),
  );
}

class StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const StatTile({super.key, required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label.toUpperCase(), style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            const Spacer(),
            CircleAvatar(radius: 13, backgroundColor: color.withOpacity(.12), child: Icon(icon, size: 14, color: color)),
          ]),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ============================================================
// 1) HOME
// ============================================================
class _HomeTab extends StatefulWidget {
  final void Function(int) onNavigate;
  const _HomeTab({required this.onNavigate});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getMemberDashboard();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService().getMemberDashboard();
    });
    await _future;
  }

  // Future<void> _openPvcCard() async {
  //   final authToken = ApiService().authToken ?? '';
  //   final memberId = kMemberId;
  //   if (memberId.isEmpty || authToken.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Missing member ID or session token — cannot open PVC card.')),
  //     );
  //     return;
  //   }
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (_) => PvcCardWebViewScreen(
  //         url: ApiConfig.karyakartaMemberPvcCardWebUrl(memberId, authToken, type: 'id_card'),
  //         title: 'Smart PVC ID',
  //       ),
  //     ),
  //   );
  // }
  // OLD (_HomeTabState._openPvcCard) – whole method body
// NEW
  Future<void> _openPvcCard() async {
    if (kMemberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member ID missing — cannot open PVC card.')),
      );
      return;
    }
    await openMemberCard(context, recordId: kMemberId, type: 'id_card');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? {};
        final stats = Map<String, dynamic>.from(data['stats'] ?? {});

        final totalMembers = (stats['enrolled_schemes_count'] ?? 0).toString();
        final pendingEnrollments = (stats['pending_proposals'] ?? 0).toString();
        final totalCollections = (stats['total_paid'] ?? 0).toString();
        final earnedCommission = (stats['pending_dues'] ?? 0).toString();
        final recentEnrollments = (data['enrolled_schemes'] as List?) ?? [];

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: KColors.navy, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text('नमस्ते, $kFullName', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      memberAvatar(radius: 26, fontSize: 20),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFF2A93B), borderRadius: BorderRadius.circular(6)),
                        child: Text('ID: ${kMemberId.isNotEmpty ? kMemberId : kSaCode}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: KColors.green, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          (kStatus.toLowerCase() == 'active' || kStatus.toLowerCase() == 'verified')
                              ? 'VERIFIED MEMBER'
                              : (kStatus.isNotEmpty ? kStatus.toUpperCase() : 'ACTIVE SA'),
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    if (kGotra.isNotEmpty || kVillage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          const Icon(Icons.account_tree_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Gotra: ${kGotra.isEmpty ? '-' : kGotra} • $kVillage'
                                  '${kTaluka.isNotEmpty ? ', $kTaluka' : ''}'
                                  '${kDistrict.isNotEmpty ? ' ($kDistrict)' : ''}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ),
                    Row(children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(kVillage, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.phone, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(kMobile, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                    if (kKaryakartaCode.isNotEmpty || kKaryakartaName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(children: [
                          const Icon(Icons.badge_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Tagged Karyakarta: $kKaryakartaCode - $kKaryakartaName'
                                  '${kKaryakartaMobile.isNotEmpty ? ' ($kKaryakartaMobile)' : ''}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const AdBanner(),
              if (loading)
                const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()))
              else ...[
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatTile(label: 'Active Welfare Schemes', value: totalMembers, icon: Icons.groups, color: KColors.primary),
                    StatTile(label: 'Pending Proposals', value: pendingEnrollments, icon: Icons.hourglass_empty, color: KColors.orange),
                    StatTile(label: 'Total Paid', value: '₹$totalCollections', icon: Icons.account_balance_wallet, color: KColors.green),
                    StatTile(label: 'Pending Community Dues', value: '₹$earnedCommission', icon: Icons.payments, color: const Color(0xFF9B59B6)),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Wrap(spacing: 8, runSpacing: 8, children: [
                    primaryButton(
                      'Join New Scheme',
                      Icons.add_circle_outline,
                      color: KColors.navActive,
                      onTap: () async {
                        final created = await Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const EnrollmentCreateScreen(isMemberSelfEnroll: true)));
                        if (created == true) _refresh();
                      },
                    ),
                    primaryButton(
                      'Submit Claim',
                      Icons.upload_file,
                      color: KColors.green,
                      onTap: () {
                        kServicesSubTab.value = 2; // Claims sub-tab
                        widget.onNavigate(1);
                      },
                    ),
                    primaryButton('My Smart PVC ID', Icons.badge_outlined, color: KColors.navy, onTap: _openPvcCard),
                  ]),
                ),
                sectionHeader('My Welfare Scheme Accounts', 'All registered policies and scheme statuses.'),
                if (recentEnrollments.isEmpty)
                  card(emptyState(Icons.inbox_outlined, 'No enrollments submitted yet.'))
                else
                  ...recentEnrollments.map((raw) {
                    final e = Map<String, dynamic>.from(raw as Map);
                    final status = (e['status'] ?? e['enrollment_status'] ?? '-').toString();
                    final acc = (e['scheme_account_no'] ?? '').toString();
                    return card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text((e['proposal_no'] ?? '-').toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                          if (status.trim().isNotEmpty) statusBadge(status),
                        ]),
                        const SizedBox(height: 6),
                        infoRow('Scheme A/C ID', acc.isEmpty ? 'Under Review' : acc),
                        infoRow('Scheme', (e['scheme_name'] ?? '-').toString()),
                        infoRow('Joining Fee', '₹${e['joining_fee'] ?? 0}'),
                        infoRow('Per-Event', '₹${e['per_event_installment'] ?? 0}'),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: status.toLowerCase() == 'approved'
                              ? ElevatedButton.icon(
                            onPressed: () => openDastavejDoc(context, e),
                            icon: const Icon(Icons.folder_outlined, size: 16),
                            label: const Text('Policy Dastavej'),
                            style: ElevatedButton.styleFrom(backgroundColor: KColors.navActive, foregroundColor: Colors.black87, elevation: 0),
                          )
                              : OutlinedButton.icon(
                            onPressed: () => openProposalDoc(context, e),
                            icon: const Icon(Icons.description_outlined, size: 16),
                            label: const Text('Proposal PDF'),
                            style: OutlinedButton.styleFrom(foregroundColor: KColors.primary),
                          ),
                        ),
                      ],
                    ));
                  }),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// 2) SERVICES
// ============================================================
class _ServicesSection extends StatefulWidget {
  const _ServicesSection();
  @override
  State<_ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<_ServicesSection> {
  int _sub = 0;
  final _labels = const ['My Profile', 'My Schemes', 'Claims', 'My Payments'];

  @override
  void initState() {
    super.initState();
    kServicesSubTab.addListener(_onSubChange);
  }

  void _onSubChange() {
    if (mounted) setState(() => _sub = kServicesSubTab.value);
  }

  @override
  void dispose() {
    kServicesSubTab.removeListener(_onSubChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        subTabStrip(_labels, _sub, (i) => setState(() => _sub = i)),
        Expanded(
          child: IndexedStack(
            index: _sub,
            children: const [
              _MyProfileTab(),
              _EnrollmentsTab(),
              _ClaimsTab(),
              _PaymentsReceiptsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ---- My Profile ----
class _MyProfileTab extends StatefulWidget {
  const _MyProfileTab();
  @override
  State<_MyProfileTab> createState() => _MyProfileTabState();
}

class _MyProfileTabState extends State<_MyProfileTab> {
  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getMemberSelfProfile();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService().getMemberSelfProfile();
    });
    await _future;
  }

  Future<void> _showPvcCard(Map<String, dynamic> data) =>
      openMemberCard(context, recordId: (data['member_id'] ?? data['id'] ?? '').toString(), type: 'id_card');

  Future<void> _showCertificate(Map<String, dynamic> data) =>
      openMemberCard(context, recordId: (data['member_id'] ?? data['id'] ?? '').toString(), type: 'certificate');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              sectionHeader('Official Member Profile', 'Your registered personal, family, and assigned Karyakarta details.'),
              if (loading)
                const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()))
              else if (data == null)
                card(emptyState(Icons.error_outline, 'Failed to load profile. Pull down to retry.'))
              else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showPvcCard(data),
                          icon: const Icon(Icons.badge_outlined, size: 16),
                          label: const Text('Smart PVC ID'),
                          style: ElevatedButton.styleFrom(backgroundColor: KColors.primary, foregroundColor: Colors.white, elevation: 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showCertificate(data),
                          icon: const Icon(Icons.workspace_premium_outlined, size: 16),
                          label: const Text('Certificate'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF2A93B), foregroundColor: Colors.black87, elevation: 0),
                        ),
                      ),
                    ]),
                  ),
                  card(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.person_outline, size: 16, color: KColors.primary),
                        SizedBox(width: 6),
                        Text('Personal Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ]),
                      const Divider(height: 18),
                      infoRow('Member ID', (data['member_id'] ?? '-').toString(), bold: true),
                      infoRow('Full Name', (data['full_name'] ?? '-').toString()),
                      infoRow('Gotra', (data['gotra'] ?? '-').toString()),
                      infoRow('Date of Birth', (data['dob'] ?? '-').toString()),
                      infoRow('Gender', (data['gender'] ?? '-').toString()),
                      infoRow('Mobile (User ID)', (data['mobile'] ?? '-').toString()),
                      infoRow('Aadhaar Status',
                          (data['aadhaar_no'] != null && data['aadhaar_no'].toString().trim().isNotEmpty)
                              ? 'Linked & Verified' : 'Pending'),
                      infoRow('Status', (data['status'] ?? '-').toString()),
                    ],
                  )),
                  card(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.family_restroom_outlined, size: 16, color: KColors.green),
                        SizedBox(width: 6),
                        Text('Family & Nominee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ]),
                      const Divider(height: 18),
                      infoRow('Father Name', (data['father_name'] ?? '-').toString()),
                      infoRow('Mother Name', (data['mother_name'] ?? '-').toString()),
                      infoRow(
                        'Husband/Guardian',
                        ((data['husband_name'] ?? '').toString().trim().isNotEmpty ? data['husband_name'] : (data['guardian_name'] ?? '-')).toString(),
                      ),
                      infoRow('Nominee Name', (data['nominee_name'] ?? '-').toString()),
                      infoRow('Nominee Relation', (data['nominee_relation'] ?? '-').toString()),
                      infoRow('Member ID', kMemberId.isNotEmpty ? kMemberId : kSaCode, bold: true),
                      infoRow('Village', kVillage),
                    ],
                  )),
                  card(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.location_on_outlined, size: 16, color: KColors.orange),
                        SizedBox(width: 6),
                        Text('Area & Karyakarta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ]),
                      const Divider(height: 18),
                      infoRow('State', (data['state'] ?? '-').toString()),
                      infoRow('District', (data['district'] ?? '-').toString()),
                      infoRow('Taluka', (data['taluka'] ?? '-').toString()),
                      infoRow('Village/City', (data['village'] ?? '-').toString()),
                      infoRow('Address', (data['address'] ?? '-').toString()),
                      infoRow('Pincode', (data['pincode'] ?? '-').toString()),
                      const Divider(height: 18),
                      infoRow('Tagged Karyakarta (SA)', (data['karyakarta_code'] ?? '-').toString(), bold: true),
                      infoRow('Karyakarta Name', (data['karyakarta_name'] ?? '-').toString()),
                      infoRow('Karyakarta Mobile', (data['karyakarta_mobile'] ?? '-').toString()),
                    ],
                  )),
                ],
            ],
          ),
        );
      },
    );
  }
}

// ---- Scheme Enrollments ----
class _EnrollmentsTab extends StatefulWidget {
  const _EnrollmentsTab();
  @override
  State<_EnrollmentsTab> createState() => _EnrollmentsTabState();
}

class _EnrollmentsTabState extends State<_EnrollmentsTab> {
  late Future<List<Map<String, dynamic>>> _future;
  List<Map<String, dynamic>> _all = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await ApiService().getMemberEnrollments();
    _all = data;
    return data;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((e) {
      final proposal = (e['proposal_no'] ?? '').toString().toLowerCase();
      final schemeAcc = (e['scheme_account_no'] ?? '').toString().toLowerCase();
      final scheme = (e['scheme_name'] ?? '').toString().toLowerCase();
      final karyakartaCode = (e['karyakarta_code'] ?? '').toString().toLowerCase();
      final karyakartaName = (e['karyakarta_name'] ?? '').toString().toLowerCase();
      return proposal.contains(q) || schemeAcc.contains(q) || scheme.contains(q) || karyakartaCode.contains(q) || karyakartaName.contains(q);
    }).toList();
  }

  Future<void> _viewEnrollmentDetail(String id) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    final detail = await ApiService().getMemberEnrollmentById(id);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not load enrollment details.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Text(detail['proposal_no']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            infoRow('Scheme A/C No', '${detail['scheme_account_no'] ?? '-'}'),
            infoRow('Scheme', '${detail['scheme_name'] ?? '-'} (${detail['short_code'] ?? '-'})'),
            infoRow('Tagged Karyakarta', '${detail['karyakarta_code'] ?? '-'} - ${detail['karyakarta_name'] ?? '-'}'),
            infoRow('Age at Joining', '${detail['age_at_joining'] ?? '-'}'),
            infoRow('Joining Fee', '₹${detail['joining_fee'] ?? '0'}'),
            infoRow('Per-Event Rate', '₹${detail['per_event_installment'] ?? '0'}'),
            infoRow('Payment Mode', '${detail['payment_mode'] ?? '-'}'),
            infoRow('Payment Status', '${detail['payment_status'] ?? '-'}'),
            infoRow('Enrollment Status', '${detail['status'] ?? detail['enrollment_status'] ?? '-'}'),
            infoRow('Date of Joining', '${detail['created_at'] ?? '-'}'),
            if ((detail['rejection_reason'] ?? '').toString().trim().isNotEmpty)
              infoRow('Rejection Reason', detail['rejection_reason'].toString()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              sectionHeader(
                'My Schemes & Proposals',
                '',
                action: primaryButton(
                  'New',
                  Icons.add,
                  onTap: () async {
                    final created =
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EnrollmentCreateScreen(isMemberSelfEnroll: true)));
                    if (created == true) _refresh();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search Proposal, Member, Scheme...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              if (loading)
                const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()))
              else if (snapshot.hasError)
                card(emptyState(Icons.error_outline, 'Failed to load enrollments. Pull down to retry.'))
              else if (_filtered.isEmpty)
                  card(emptyState(Icons.inbox_outlined, 'No enrollments found.'))
                else
                  ..._filtered.map((e) {
                    final proposalNo = (e['proposal_no'] ?? '-').toString();
                    final schemeAccNo = (e['scheme_account_no'] ?? '-').toString();
                    final schemeName = (e['scheme_name'] ?? '-').toString();
                    final karyakartaCode = (e['karyakarta_code'] ?? '-').toString();
                    final karyakartaName = (e['karyakarta_name'] ?? '-').toString();
                    final joiningDate = (e['created_at'] ?? '-').toString();
                    final joiningFee = (e['joining_fee'] ?? '0').toString();
                    final perEvent = (e['per_event_installment'] ?? '0').toString();
                    final status = (e['status'] ?? e['enrollment_status'] ?? '-').toString();

                    return card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(proposalNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                          statusBadge(status),
                        ]),
                        const SizedBox(height: 8),
                        infoRow('Scheme A/C No', schemeAccNo),
                        infoRow('Scheme', schemeName),
                        infoRow('Date of Joining', joiningDate),
                        infoRow('Tagged Karyakarta', '$karyakartaCode - $karyakartaName'),
                        infoRow('Joining Fee', '₹$joiningFee'),
                        infoRow('Per-Event Rate', '₹$perEvent'),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => openProposalDoc(context, e),
                              icon: const Icon(Icons.description_outlined, size: 16),
                              label: const Text('Proposal'),
                              style: OutlinedButton.styleFrom(foregroundColor: KColors.primary),
                            ),
                          ),
                          if (status.toLowerCase() == 'approved') ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => openDastavejDoc(context, e),
                                icon: const Icon(Icons.folder_outlined, size: 16),
                                label: const Text('Dastavej'),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF2A93B), foregroundColor: Colors.black87, elevation: 0),
                              ),
                            ),
                          ],
                        ]),
                      ],
                    ));
                  }),
            ],
          ),
        );
      },
    );
  }
}

// ---- Claims ----
class _ClaimsTab extends StatefulWidget {
  const _ClaimsTab();
  @override
  State<_ClaimsTab> createState() => _ClaimsTabState();
}

class _ClaimsTabState extends State<_ClaimsTab> {
  late Future<List<Map<String, dynamic>>> _future;
  List<Map<String, dynamic>> _all = [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await ApiService().getMemberClaims();
    _all = data;
    return data;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _openClaimForm(Map<String, dynamic> detail) => openSecureDoc(
    context,
    docType: 'claim',
    recordId: (detail['id'] ?? '').toString(),
    title: 'Claim Application Form',
    urlBuilder: (t) => ApiConfig.karyakartaClaimDocWebUrl((detail['id'] ?? '').toString(), t),
  );

  Future<void> _viewClaimDetail(String id) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    final detail = await ApiService().getMemberClaimById(id);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not load claim details.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Row(children: [
              Expanded(child: Text(detail['proposal_no']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ]),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openClaimForm(detail),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: const Text('View Claim Form'),
                style: OutlinedButton.styleFrom(foregroundColor: KColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            infoRow('Member', '${detail['member_name'] ?? '-'} (${detail['member_mobile'] ?? '-'})'),
            infoRow('Scheme', '${detail['scheme_name'] ?? '-'} (${detail['proposal_no'] ?? '-'})'),
            infoRow('Event Type', (detail['event_type'] ?? '-').toString()),
            infoRow('Event Date', (detail['event_date'] ?? '-').toString()),
            infoRow('Beneficiary', (detail['beneficiary_name'] ?? '-').toString()),
            infoRow('Bank', '${detail['bank_name'] ?? '-'} • ${detail['bank_ifsc'] ?? '-'}'),
            infoRow('Account No', (detail['bank_account_no'] ?? '-').toString()),
            infoRow('Account Holder', (detail['bank_account_holder'] ?? '-').toString()),
            infoRow('Calculated Amount', '₹${detail['calculated_amount'] ?? '0'}'),
            infoRow('Approved Amount', '₹${detail['approved_amount'] ?? '0'}'),
            infoRow('Net Payable', '₹${detail['net_payable_amount'] ?? '0'}', bold: true),
            infoRow('Status', (detail['status'] ?? '-').toString()),
            infoRow('Submitted By', (detail['submitted_by_type'] ?? '-').toString()),
            infoRow('Created At', (detail['created_at'] ?? '-').toString()),
            if ((detail['rejection_reason'] ?? '').toString().trim().isNotEmpty)
              infoRow('Rejection Reason', detail['rejection_reason'].toString()),
          ],
        ),
      ),
    );
  }

  Future<void> _showSubmitClaimSheet() async {
    final approvedPolicies = (await ApiService().getMemberEnrollments())
        .where((e) => (e['status'] ?? e['enrollment_status'] ?? '').toString().toLowerCase() == 'approved')
        .toList();

    if (!mounted) return;

    if (approvedPolicies.isEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 40, color: KColors.orange),
            const SizedBox(height: 12),
            const Text('No Active Approved Policies Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 6),
            const Text(
              'You must have an active approved policy account to submit an assistance claim.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EnrollmentCreateScreen(isMemberSelfEnroll: true)));
              },
              child: const Text('Join a Scheme'),
            ),
          ]),
        ),
      );
      return;
    }

    Map<String, dynamic>? selectedPolicy;
    PlatformFile? proofFile;
    String eventType = 'marriage';
    final eventDateCtrl = TextEditingController();
    final beneficiaryCtrl = TextEditingController();
    final bankNameCtrl = TextEditingController();
    final bankIfscCtrl = TextEditingController();
    final bankAccNoCtrl = TextEditingController();
    final bankHolderCtrl = TextEditingController(text: kFullName);
    bool submitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          Future<void> submit() async {
            String? err;
            if (selectedPolicy == null) {
              err = 'Please select your active policy.';
            } else if (eventDateCtrl.text.trim().isEmpty) {
              err = 'Please select the event date.';
            } else if (proofFile == null) {
              err = 'Please upload the event proof document.';
            } else if (bankNameCtrl.text.trim().isEmpty ||
                bankIfscCtrl.text.trim().isEmpty ||
                bankAccNoCtrl.text.trim().isEmpty ||
                bankHolderCtrl.text.trim().isEmpty) {
              err = 'Please fill all bank details.';
            }
            if (err != null) {
              ScaffoldMessenger.of(sheetCtx).showSnackBar(SnackBar(content: Text(err)));
              return;
            }

            setSheetState(() => submitting = true);

            final payload = {
              "member_id": kMemberId,
              "scheme_id": selectedPolicy!['scheme_id'],
              "enrollment_id": selectedPolicy!['id'],
              "event_type": eventType,
              "event_date": eventDateCtrl.text.trim(),
              "beneficiary_name": beneficiaryCtrl.text.trim().isNotEmpty ? beneficiaryCtrl.text.trim() : kFullName,
              "bank_name": bankNameCtrl.text.trim(),
              "bank_ifsc": bankIfscCtrl.text.trim(),
              "bank_account_no": bankAccNoCtrl.text.trim(),
              "bank_account_holder": bankHolderCtrl.text.trim(),
            };

            Map<String, dynamic> result;
            try {
              result = await ApiService().submitMemberClaim(payload, proofFile: proofFile);
            } catch (e) {
              result = {"success": false, "message": "Could not submit claim: $e"};
            }

            if (!mounted) return;

            if (result['success'] == true) {
              Navigator.of(sheetCtx).pop();
              _refresh();
            } else {
              setSheetState(() => submitting = false);
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Claim submitted')));
          }

          return Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Submit New Claim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(labelText: 'Select Your Active Policy'),
                    items: approvedPolicies
                        .map((p) => DropdownMenuItem(value: p, child: Text('${p['proposal_no'] ?? '-'} • ${p['scheme_name'] ?? '-'}')))
                        .toList(),
                    onChanged: (v) => setSheetState(() => selectedPolicy = v),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
                      if (picked != null && picked.files.isNotEmpty) {
                        setSheetState(() => proofFile = picked.files.first);
                      }
                    },
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: Text(proofFile?.name ?? 'Upload Event Proof Document *'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Event Type'),
                    value: eventType,
                    items: const [
                      DropdownMenuItem(value: 'marriage', child: Text('Marriage')),
                      DropdownMenuItem(value: 'death', child: Text('Death')),
                      // DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setSheetState(() => eventType = v ?? 'marriage'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: eventDateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Event Date (YYYY-MM-DD)'),
                    onTap: () async {
                      final picked = await showDatePicker(context: sheetCtx, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) {
                        setSheetState(() {
                          eventDateCtrl.text =
                          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: beneficiaryCtrl, decoration: const InputDecoration(labelText: 'Beneficiary Name')),
                  const SizedBox(height: 12),
                  TextField(controller: bankNameCtrl, decoration: const InputDecoration(labelText: 'Bank Name')),
                  const SizedBox(height: 12),
                  TextField(controller: bankIfscCtrl, decoration: const InputDecoration(labelText: 'Bank IFSC')),
                  const SizedBox(height: 12),
                  TextField(controller: bankAccNoCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bank Account No')),
                  const SizedBox(height: 12),
                  TextField(controller: bankHolderCtrl, decoration: const InputDecoration(labelText: 'Account Holder Name')),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: submitting
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Submit Claim', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              sectionHeader(
                'Assistance Claims Master Directory',
                '',
                action: primaryButton('Submit', Icons.upload_file, color: KColors.green, onTap: _showSubmitClaimSheet),
              ),
              if (loading)
                const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()))
              else if (snapshot.hasError)
                card(emptyState(Icons.error_outline, 'Failed to load claims. Pull down to retry.'))
              else if (_all.isEmpty)
                  card(emptyState(Icons.inbox_outlined, 'No claims submitted yet.'))
                else
                  ..._all.map((c) {
                    final claimNo = (c['claim_request_no'] ?? c['claim_no'] ?? '-').toString();
                    final memberName = (c['member_name'] ?? '-').toString();
                    final memberMobile = (c['member_mobile'] ?? '-').toString();
                    final submittedBy = (c['submitted_by_type'] ?? '-').toString();
                    final amount = (c['net_payable_amount'] ?? c['calculated_amount'] ?? '0').toString();
                    final status = (c['status'] ?? '-').toString();
                    final id = (c['id'] ?? '').toString();

                    return card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(claimNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                          statusBadge(status),
                        ]),
                        const SizedBox(height: 8),
                        infoRow('Member', '$memberName — $memberMobile'),
                        infoRow('Scheme A/C', (c['scheme_account_no'] ?? c['account_no'] ?? '-').toString()),
                        infoRow('Event Date', (c['event_date'] ?? '-').toString()),
                        infoRow('Submitted By', submittedBy),
                        infoRow('Net Assistance', '₹$amount', bold: true),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: id.isEmpty
                                ? null
                                : () => openSecureDoc(
                              context,
                              docType: 'claim',
                              recordId: id,
                              title: 'Claim Application Form',
                              urlBuilder: (t) => ApiConfig.karyakartaClaimDocWebUrl(id, t),
                            ),
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                            label: const Text('View PDF'),
                            style: OutlinedButton.styleFrom(foregroundColor: KColors.primary),
                          ),
                        ),
                      ],
                    ));
                  }),
            ],
          ),
        );
      },
    );
  }
}

// ---- My Payments & Receipts ----
class _PaymentsReceiptsTab extends StatefulWidget {
  const _PaymentsReceiptsTab();
  @override
  State<_PaymentsReceiptsTab> createState() => _PaymentsReceiptsTabState();
}

class _PaymentsReceiptsTabState extends State<_PaymentsReceiptsTab> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getMemberPayments();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService().getMemberPayments();
    });
    await _future;
  }

  String _categoryLabel(String type) {
    switch (type.toLowerCase()) {
      case 'joining_fee':
        return 'JOINING FEE';
      case 'contribution':
        return 'CONTRIBUTION';
      default:
        return type.isEmpty ? '-' : type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? {};
        final receipts = (data['receipts'] as List?) ?? [];
        final pendingDues = num.tryParse('${data['pending_dues_amount'] ?? 0}') ?? 0;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              sectionHeader(
                'My Contribution Receipts & Payments',
                '',
                action: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: (pendingDues > 0 ? KColors.red : KColors.green).withOpacity(.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    pendingDues > 0 ? '₹$pendingDues Due' : 'All Dues Paid',
                    style: TextStyle(color: pendingDues > 0 ? KColors.red : KColors.green, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
              if (loading)
                const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()))
              else if (snapshot.hasError)
                card(emptyState(Icons.error_outline, 'Failed to load payments. Pull down to retry.'))
              else if (receipts.isEmpty)
                  card(emptyState(Icons.receipt_long_outlined, 'No payment receipts yet.'))
                else
                  ...receipts.map((r) {
                    final m = Map<String, dynamic>.from(r);
                    final receiptNo = (m['receipt_no'] ?? '-').toString();
                    final type = (m['type'] ?? '').toString();
                    final amount = (m['amount'] ?? '0').toString();
                    final mode = (m['payment_mode'] ?? '-').toString();
                    final date = (m['created_at'] ?? '-').toString();
                    final schemeName = (m['scheme_name'] ?? '').toString();
                    final collectedBy = (m['collected_by'] ?? '-').toString();
                    final receiptPdfUrl = (m['receipt_pdf_url'] ?? '').toString();

                    return card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(receiptNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: KColors.primary.withOpacity(.12), borderRadius: BorderRadius.circular(6)),
                            child: Text(_categoryLabel(type), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: KColors.primary)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        if (schemeName.isNotEmpty) infoRow('Scheme', schemeName),
                        infoRow('Payment Mode', mode),
                        infoRow('Amount Paid', '₹$amount', bold: true),
                        infoRow('Date & Time', date),
                        infoRow('Collected By', collectedBy),
                        if (receiptPdfUrl.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => PvcCardWebViewScreen(url: receiptPdfUrl, title: 'Receipt'))),
                              icon: const Icon(Icons.print_outlined, size: 16),
                              label: const Text('View'),
                              style: OutlinedButton.styleFrom(foregroundColor: KColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ));
                  }),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// 3) REPORTS (Commission — accessible internally, not in bottom nav)
// ============================================================
class _ReportsSection extends StatelessWidget {
  const _ReportsSection();

  @override
  Widget build(BuildContext context) => const _CommissionTab();
}

class _CommissionTab extends StatefulWidget {
  const _CommissionTab();
  @override
  State<_CommissionTab> createState() => _CommissionTabState();
}

class _CommissionTabState extends State<_CommissionTab> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getMemberCommissions();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService().getMemberCommissions();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final list = snapshot.data ?? [];

        num totalEarned = 0, settled = 0, pending = 0;
        for (final c in list) {
          final amt = num.tryParse('${c['commission'] ?? 0}') ?? 0;
          totalEarned += amt;
          if ((c['status'] ?? '').toString().toUpperCase() == 'PAID') {
            settled += amt;
          } else {
            pending += amt;
          }
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatTile(label: 'Total Earned', value: '₹$totalEarned', icon: Icons.savings_outlined, color: Colors.black87),
                  StatTile(label: 'Settled & Disbursed', value: '₹$settled', icon: Icons.check_circle_outline, color: KColors.green),
                  StatTile(label: 'Pending Payout', value: '₹$pending', icon: Icons.hourglass_bottom, color: const Color(0xFF9B59B6)),
                ],
              ),
              sectionHeader('Commission & Incentive Statements', 'Regular enrollments, promotional offers, and disbursement settlements.'),
              if (loading)
                const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()))
              else if (snapshot.hasError)
                card(emptyState(Icons.error_outline, 'Failed to load commissions. Pull down to retry.'))
              else if (list.isEmpty)
                  card(emptyState(Icons.inbox_outlined, 'No commission records yet.'))
                else
                  ...list.map((c) => card(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text('${c['proposal_no'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        statusBadge('${c['status'] ?? '-'}'),
                      ]),
                      const SizedBox(height: 8),
                      infoRow('Member', '${c['member_name'] ?? '-'} (${c['member_id'] ?? '-'})'),
                      infoRow('Scheme', '${c['scheme_name'] ?? '-'}'),
                      infoRow('Category', '${c['category'] ?? '-'}'),
                      infoRow('Joining Fee', '₹${c['joining_fee'] ?? '0'}'),
                      infoRow('Commission', '₹${c['commission'] ?? '0'}', bold: true),
                    ],
                  ))),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// 4) PROFILE
// ============================================================
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();
  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _altMobile = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  bool _saving = false;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ApiService().getMemberSelfProfile();
    if (!mounted || data == null) return;
    setState(() {
      MemberSession.saCode = data['member_code']?.toString() ?? MemberSession.saCode;
      MemberSession.fullName = data['full_name']?.toString() ?? MemberSession.fullName;
      MemberSession.mobile = data['mobile']?.toString() ?? MemberSession.mobile;
      MemberSession.village = data['village']?.toString() ?? MemberSession.village;
      final photoDoc = (data['photo_doc'] ?? '').toString();
      MemberSession.photoUrl = photoDoc.isNotEmpty ? ApiConfig.bannerImageUrl(photoDoc) : '';
      _altMobile.text = data['alt_mobile']?.toString() ?? '';
      _address.text = (data['address'] ?? data['full_address'] ?? '').toString();
    });
  }

  // NOTE: ApiService().updateMemberProfile(altMobile:, password:) must exist
  // in api_service.dart — it is not redefined here since it belongs to that
  // service layer, not to this widget.
  Future<void> _save() async {
    if (_saving) return;
    final alt = _altMobile.text.trim();
    if (alt.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(alt)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid 10-digit alternate mobile.')));
      return;
    }
    setState(() => _saving = true);
    final r = await ApiService().updateMemberProfile(
        altMobile: alt, address: _address.text.trim(), password: _password.text);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Done')));
    if (r['success'] == true) _password.clear();
  }

  @override
  void dispose() {
    _altMobile.dispose();
    _address.dispose();
    _password.dispose();
    super.dispose();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout of the Member Portal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _doLogout();
            },
            child: const Text('Logout', style: TextStyle(color: KColors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _doLogout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    final result = await ApiService().logout();

    if (!mounted) return;
    setState(() => _loggingOut = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Logged out')));

    MemberSession.clear();

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        sectionHeader('Manage Member Profile', 'Update your contact and login details.'),
        card(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow('SA Code', kSaCode, bold: true),
                  infoRow('Full Name', kFullName, bold: true),
                  infoRow('Primary Mobile', kMobile),
                  infoRow('Assigned Village', kVillage),
                ],
              ),
            ),
            const SizedBox(width: 12),
            memberAvatar(radius: 36, fontSize: 26),
          ],
        )),
        card(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alternate Contact Mobile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _altMobile,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Alternate Mobile',
                filled: true,
                fillColor: KColors.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Full Residential Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _address,
              decoration: InputDecoration(
                filled: true,
                fillColor: KColors.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Change Login Password (Optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Leave blank to keep existing password',
                filled: true,
                fillColor: KColors.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Update Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        )),
        card(
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loggingOut ? null : _confirmLogout,
              icon: const Icon(Icons.logout, size: 18, color: KColors.red),
              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, color: KColors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: KColors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
