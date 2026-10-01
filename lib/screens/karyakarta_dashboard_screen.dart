import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:samaj_seva_suthar/screens/scheme_master_screen.dart';
import '../models/dashboard_stats_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/api_config.dart';
import 'claim_submit_screen.dart';
import 'enrollment_create_screen.dart';
import 'login_screen.dart';
import 'member_dashboard_screen.dart' show openDastavejDoc, kServicesSubTab;
import 'member_registration_screen.dart';
import 'member_card_screen.dart';
import 'enrollment_doc_screen.dart';
import 'pvc_card_webview_screen.dart';
import '../models/karyakarta_session.dart';

/// ============================================================
/// SUTHAR SAMAJ SEVA SAMITI — Karyakarta Portal (Mobile)
/// Single-file, drop-in screen. Push it like:
///   Navigator.push(context, MaterialPageRoute(builder: (_) => const KaryakartaDashboardScreen()));
/// Replace the MOCK DATA block with your ApiService calls later —
/// every list below is shaped so you can swap it for a Future<List<...>>
/// without touching the UI.
///
/// FIX (this version):
///  1) Top bar trailing widget now shows a proper CircleAvatar (was a
///     bare Icons.person) plus a working notification bell icon next
///     to it, both tappable.
///  2) Reports section no longer has the "Notifications" sub-tab chip —
///     only "My Commission" remains, shown directly with no sub-tab
///     strip needed for a single item.
///  3) Profile tab now has a Logout button (with confirmation dialog)
///     in its own card right below "Update Profile".
/// ============================================================

// ---------------- THEME ----------------
class KColors {
  static const primary = Color(0xFF6A5AE0);
  static const navy = Color(0xFF241C4F);
  static const navyDark = Color(0xFF1B1442);
  static const green = Color(0xFF16A085);
  static const orange = Color(0xFFC97C0F);
  static const red = Color(0xFFE0522F);
  static const blue = Color(0xFF2F7DE1);
  static const bg = Color(0xFFF7F6FB);
  // Bottom-nav accent color (matches the orange "Home" active state in the screenshot)
  static const navActive = Color(0xFFF2A93B);
  static const navInactive = Color(0xFF8B8B8B);
}

// ---------------- MODELS (mock data) ----------------
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

String get kSaCode => KaryakartaSession.saCode;
String get kFullName => KaryakartaSession.fullName;
String get kMobile => KaryakartaSession.mobile;
String get kVillage => KaryakartaSession.village;
String get kPhotoUrl => KaryakartaSession.photoUrl;

// ============================================================
// MAIN SHELL
// ============================================================
class KaryakartaDashboardScreen extends StatefulWidget {
  const KaryakartaDashboardScreen({super.key});
  @override
  State<KaryakartaDashboardScreen> createState() => _KaryakartaDashboardScreenState();
}

class _KaryakartaDashboardScreenState extends State<KaryakartaDashboardScreen> {
  // 0 = Home, 1 = Services, 2 = Reports, 3 = Profile
  int _navIndex = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadKaryakartaProfile();
  }
  Future<void> _loadKaryakartaProfile() async {
    final profile = await ApiService().getKaryakartaSelfProfile();
    if (!mounted || profile == null) return;
    setState(() {
      KaryakartaSession.saCode = profile['karyakarta_code']?.toString() ?? KaryakartaSession.saCode;
      KaryakartaSession.fullName = profile['full_name']?.toString() ?? KaryakartaSession.fullName;
      KaryakartaSession.mobile = profile['mobile']?.toString() ?? KaryakartaSession.mobile;
      KaryakartaSession.village = profile['village']?.toString() ?? KaryakartaSession.village;
      // NEW — build the full image URL from the "photo_doc" path returned by the API
      final photoDoc = (profile['photo_doc'] ?? '').toString();
      KaryakartaSession.photoUrl = photoDoc.isNotEmpty ? ApiConfig.bannerImageUrl(photoDoc) : '';
    });
  }

  // Bottom nav definition — icons + labels fixed to match the target design.
  static const _navItems = [
    (label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    (label: 'Services', icon: Icons.people_alt_outlined, activeIcon: Icons.people_alt),
    (label: 'Reports', icon: Icons.description_outlined, activeIcon: Icons.description),
    (label: 'Profile', icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle),
  ];

  List<Widget> get _sections => [
    _HomeTab(onNavigate: (i) => setState(() => _navIndex = i)),
    const _ServicesSection(),
    const _ReportsSection(),
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
            // _buildTopBar(),
            if (_navIndex == 0) _buildTopBar(), // hide top bar on Services (1) & Profile (2)
            Expanded(child: IndexedStack(index: _navIndex, children: _sections)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
  // NEW — fetches and shows real notifications from the API.
  Future<void> _showNotifications() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final notifications = await ApiService().getKaryakartaNotifications();

    if (!mounted) return;
    Navigator.of(context).pop(); // close loader

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
            return ListTile(
              leading: const Icon(Icons.notifications_none, color: KColors.primary),
              title: Text('${n['title'] ?? 'Notification'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((n['message'] ?? '').toString().isNotEmpty) Text('${n['message']}'),
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
          // ---- Back arrow (NEW) — only shown when NOT on Home tab ----
          if (_navIndex != 0)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _navIndex = 0), // go back to Home/Dashboard
              child: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: KColors.navActive,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SUTHAR SAMAJ SEVA SAMITI',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Karyakarta Portal (SA: $kSaCode)',
                    style: const TextStyle(color: KColors.navActive, fontSize: 11)),
              ],
            ),
          ),

          // ---- Notification bell (FIX: was missing / marked in screenshot) ----
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
          // ---- Profile avatar (now shows the real photo from the API when available) ----
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _navIndex = 3),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
              padding: const EdgeInsets.all(3),
              child: karyakartaAvatar(radius: 14, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom navigation bar — fixed to 4 items with correct icons/names,
  /// orange active state, grey inactive state, matching the screenshot.
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
      c = KColors.green; break;
    case 'PENDING':
      c = AppColors.pending; break; // distinct amber, not the same as rejected/red
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
            child: Text(value,
                style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.w500))),
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
/// Shows the karyakarta's profile photo (from photo_doc) if we have one,
/// otherwise falls back to the orange initial-letter circle.
Widget karyakartaAvatar({double radius = 20, double? fontSize}) {
  final photo = kPhotoUrl;
  final initial = kFullName.trim().isNotEmpty ? kFullName.trim()[0].toUpperCase() : 'K';
  final size = radius * 2;
  final effectiveFontSize = fontSize ?? radius * 0.7;

  Widget fallback() => CircleAvatar(
    radius: radius,
    backgroundColor: KColors.navActive,
    child: Text(
      initial,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: effectiveFontSize),
    ),
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
          color: KColors.navActive,
          child: const Center(
            child: SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stack) => fallback(),
    ),
  );
}

/// ---------------- AD BANNER (real API) ----------------
/// Fetches banners from GET /api/banners and shows them as a swipeable
/// strip with dot indicators when there's more than one. Falls back to
/// a placeholder card if the API returns nothing or the image fails.
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
            height: 170,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (banners.isEmpty) {
          return _placeholderBanner();
        }

        return Column(
          children: [
            SizedBox(
              height: 170,
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
                    onTap: targetLink.trim().isEmpty
                        ? null
                        : () {
                      // TODO: hook this up to url_launcher if you want ads to be tappable:
                      // launchUrl(Uri.parse(targetLink));
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.grey.shade200,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) => _imageFallback(title),
                          ),
                          Positioned(
                            top: 6,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.black45, borderRadius: BorderRadius.circular(4)),
                              child: const Text('AD',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
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
                    decoration: BoxDecoration(
                      color: sel ? KColors.primary : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
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
        gradient: LinearGradient(
          colors: [Color(0xFFF2A93B), Color(0xFFE0522F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
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
        gradient: const LinearGradient(
          colors: [KColors.navActive, KColors.red],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Advertisement Space',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 3),
                  Text('Your banner ad will appear here',
                      style: TextStyle(color: Colors.white70, fontSize: 11.5)),
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
/// Fixed (non-scrolling) tab strip. Every chip gets an equal share of the
/// screen width, so all names are always fully visible.
Widget subTabStrip(List<String> labels, int selected, ValueChanged<int> onSelect) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Row(
      children: List.generate(labels.length, (i) {
        final sel = selected == i;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelect(i),
              child: Container(
                height: 38,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: sel ? KColors.primary : KColors.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? KColors.primary : Colors.grey.shade300,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown, // shrinks text slightly if needed, never cuts it
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label.toUpperCase(),
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
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
// 1) HOME  (bottom-nav index 0)
// ============================================================
class _HomeTab extends StatefulWidget {
  final void Function(int) onNavigate;
  const _HomeTab({required this.onNavigate});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late Future<Map<String, dynamic>> _future;

  Future<Map<String, dynamic>> _loadHome() async {
    final results = await Future.wait([
      ApiService().getKaryakartaDashboard(),
      ApiService().getKaryakartaCommissions(),
    ]);
    final data = Map<String, dynamic>.from(results[0] as Map);
    if (data['earned_commission'] == null) {
      num total = 0;
      for (final c in (results[1] as List<Map<String, dynamic>>)) {
        total += num.tryParse('${c['commission'] ?? 0}') ?? 0;
      }
      data['earned_commission'] = total;
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    _future = _loadHome();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadHome();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? {};

        final totalMembers = (data['total_members'] ?? 0).toString();
        final pendingEnrollments = (data['pending_enrollments'] ?? 0).toString();
        final totalCollections = (data['total_collections'] ?? 0).toString();
        // NOTE: backend response has no commission field yet — showing 0
        // until a "earned_commission" key is added to /karyakarta/dashboard.
        final earnedCommission = (data['earned_commission'] ?? 0).toString();

        final recentMembers = (data['recent_members'] as List?) ?? [];
        final recentEnrollments = (data['recent_enrollments'] as List?) ?? [];

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
                        child: Text('नमस्ते, $kFullName',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      karyakartaAvatar(radius: 26, fontSize: 20),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: KColors.navActive, borderRadius: BorderRadius.circular(6)),
                        child: Text(kSaCode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: KColors.green, borderRadius: BorderRadius.circular(6)),
                        child: const Text('ACTIVE SA', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(kVillage, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.phone, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(kMobile, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // ---- Advertisement banner (dummy, replace with API data later) ----
              const AdBanner(),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
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
                    StatTile(label: 'My Members', value: totalMembers, icon: Icons.groups, color: KColors.primary),
                    StatTile(label: 'Pending Proposals', value: pendingEnrollments, icon: Icons.hourglass_empty, color: KColors.orange),
                    StatTile(label: 'Total Collections', value: '₹$totalCollections', icon: Icons.account_balance_wallet, color: KColors.green),
                    // StatTile(label: 'Earned Commission', value: '₹$earnedCommission', icon: Icons.payments, color: const Color(0xFF9B59B6)),
                    StatTile(label: 'Earned Commission', value: '₹$earnedCommission', icon: Icons.payments, color: KColors.orange),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// 2) SERVICES  (bottom-nav index 1)
// Groups: My Members, Scheme Enrollments, Claims, Collections
// ============================================================
class _ServicesSection extends StatefulWidget {
  const _ServicesSection();
  @override
  State<_ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<_ServicesSection> {
  int _sub = 0;
  final _labels = const ['My Members', 'Enrollments', 'Claims', 'Collections'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        subTabStrip(_labels, _sub, (i) => kServicesSubTab.value = i),
        Expanded(
          child: IndexedStack(
            index: _sub,
            children: const [
              _MembersTab(),
              _EnrollmentsTab(),
              _ClaimsTab(),
              _CollectionsTab(),
            ],
          ),
        ),
      ],
    );
  }
}
// ---- My Members ----
class _MembersTab extends StatefulWidget {
  const _MembersTab();
  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  late Future<List<Map<String, dynamic>>> _future;
  List<Map<String, dynamic>> _all = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await ApiService().getKaryakartaMembers();
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
    return _all.where((m) {
      final name = (m['full_name'] ?? '').toString().toLowerCase();
      final id = (m['member_id'] ?? '').toString().toLowerCase();
      final mobile = (m['mobile'] ?? '').toString().toLowerCase();
      final village = (m['village'] ?? '').toString().toLowerCase();
      return name.contains(q) || id.contains(q) || mobile.contains(q) || village.contains(q);
    }).toList();
  }
  // View button → opens full-screen page with 3 cards
  void _viewMemberDetail(Map<String, dynamic> m) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemberDetailScreen(member: m)),
    );
  }
  Future<void> _showPvcCard(Map<String, dynamic> m) async {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MemberCardScreen(member: m, saCode: kSaCode),
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
              sectionHeader('My Members (${_all.length})',
                  '',
                  action: primaryButton(
                    'Add',
                    Icons.person_add_alt_1,
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MemberRegistrationScreen(
                            saCode: kSaCode,
                            saName: kFullName,
                          ),
                        ),
                      );
                      if (result != null) _refresh();
                    },
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search by Member Name, ID, Mobile, Village',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                card(emptyState(Icons.error_outline, 'Failed to load members. Pull down to retry.'))
              else if (_filtered.isEmpty)
                  card(emptyState(Icons.inbox_outlined, 'No members found.'))
                else
                  ..._filtered.map((m) {
                    final name = (m['full_name'] ?? '-').toString();
                    final gotra = (m['gotra'] ?? '').toString();
                    final id = (m['member_id'] ?? '-').toString();
                    final mobile = (m['mobile'] ?? '-').toString();
                    final village = (m['village'] ?? '-').toString();
                    final schemes = (m['active_schemes_count'] ?? 0).toString();
                    final status = (m['status'] ?? 'active').toString();

                    return card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(gotra.isNotEmpty ? '$name  •  $gotra' : name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          statusBadge(status),
                        ]),
                        const SizedBox(height: 8),
                        infoRow('Member ID', id),
                        infoRow('Mobile', mobile),
                        infoRow('Village/Area', village),
                        infoRow('Active Schemes', '$schemes Scheme(s)'),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _viewMemberDetail(m),
                              icon: const Icon(Icons.visibility_outlined, size: 16),
                              label: const Text('View'),
                              style: OutlinedButton.styleFrom(foregroundColor: KColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showPvcCard(m),
                              icon: const Icon(Icons.credit_card, size: 16),
                              label: const Text('PVC Card'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: KColors.navActive,
                                  foregroundColor: Colors.black87,
                                  elevation: 0),
                            ),
                          ),
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
// ============================================================
// FULL-SCREEN MEMBER DETAIL (3 cards, X button on top-right)
// ============================================================
class MemberDetailScreen extends StatelessWidget {
  final Map<String, dynamic> member;
  const MemberDetailScreen({super.key, required this.member});

  /// First non-empty value among the given API keys, else '-'
  String _v(List<String> keys) {
    for (final k in keys) {
      final val = member[k];
      if (val != null) {
        final s = val.toString().trim();
        if (s.isNotEmpty && s != 'null') return s;
      }
    }
    return '-';
  }

  /// Card with icon + title + divider + rows (same style as your screenshot)
  Widget _section(IconData icon, Color color, String title, List<Widget> rows) {
    return card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
        const Divider(height: 20),
        ...rows,
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final aadhaar = _v(['aadhaar_no', 'aadhaar']);

    return Scaffold(
      backgroundColor: KColors.orange,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Top bar with X (close) on the right ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _v(['full_name', 'name']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 26),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ---- 3 cards ----
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                children: [
                  // 1) Personal Details
                  _section(
                    Icons.person_outline,
                    KColors.primary,
                    'Personal Details',
                    [
                      infoRow('Member ID', _v(['member_id', 'id'])),
                      infoRow('Full Name', _v(['full_name', 'name'])),
                      infoRow('Gotra', _v(['gotra', 'gotra_name'])),
                      infoRow('Date of Birth', _v(['dob'])),
                      infoRow('Gender', _v(['gender'])),
                      infoRow('Mobile (User ID)', _v(['mobile'])),
                      infoRow('Aadhaar Status',
                          aadhaar == '-' ? 'Pending' : 'Linked & Verified'),
                      infoRow('Status', _v(['status'])),
                    ],
                  ),

                  // 2) Family & Nominee
                  _section(
                    Icons.family_restroom,
                    KColors.green,
                    'Family & Nominee',
                    [
                      infoRow('Father Name', _v(['father_name'])),
                      infoRow('Mother Name', _v(['mother_name'])),
                      infoRow('Husband/Guardian',
                          _v(['husband_name', 'guardian_name', 'husband_guardian'])),
                      infoRow('Nominee Name', _v(['nominee_name'])),
                      infoRow('Nominee Relation', _v(['nominee_relation'])),
                    ],
                  ),

                  // 3) Area & Karyakarta
                  _section(
                    Icons.location_on_outlined,
                    KColors.orange,
                    'Area & Karyakarta',
                    [
                      infoRow('State', _v(['state', 'state_name'])),
                      infoRow('District', _v(['district', 'district_name'])),
                      infoRow('Taluka / Town',
                          _v(['taluka', 'taluka_name', 'tehsil'])),
                      infoRow('Village / City', _v(['village', 'village_name'])),
                      infoRow('Address', _v(['address', 'full_address'])),
                      infoRow('Pincode', _v(['pincode', 'pin_code'])),
                      infoRow('Active Schemes',
                          '${member['active_schemes_count'] ?? 0}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ---- Scheme Enrollments ----
// NEW — real API-backed version
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
    final data = await ApiService().getKaryakartaEnrollments();
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
      final member = (e['member_name'] ?? '').toString().toLowerCase();
      final scheme = (e['scheme_name'] ?? '').toString().toLowerCase();
      return proposal.contains(q) || member.contains(q) || scheme.contains(q);
    }).toList();
  }
  Future<Map<String, dynamic>?> _memberFor(Map<String, dynamic> e) async {
    final mid = (e['member_id'] ?? '').toString();
    if (mid.isEmpty) return null;
    try {
      final list = await ApiService().getKaryakartaMembers();
      for (final m in list) {
        if ((m['id'] ?? '').toString() == mid || (m['member_id'] ?? '').toString() == mid) return m;
      }
    } catch (_) {}
    return null;
  }

  // NEW — opens the enrollment/proposal detail screen for the given ID.
  Future<void> _viewEnrollmentDetail(String enrollmentId) async {
    if (enrollmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing enrollment ID.')),
      );
      return;
    }

    final match = _all.where((e) => (e['id'] ?? '').toString() == enrollmentId);
    if (match.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrollment not found.')),
      );
      return;
    }

    final memberData = await _memberFor(match.first);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EnrollmentDocScreen(
          enrollment: match.first,
          isPolicy: false,
          saCode: kSaCode,
          saName: kFullName,
          member: memberData ?? {},
        ),
      ),
    );
  }

  // NEW — opens the policy/dastavej document screen for the given enrollment.
  Future<void> _showDastavej(Map<String, dynamic> e) async {
    final memberData = await _memberFor(e);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EnrollmentDocScreen(
          enrollment: e,
          isPolicy: true,
          saCode: kSaCode,
          saName: kFullName,
          member: memberData ?? {},
          onPdf: () => openDastavejDoc(context, e),
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
              sectionHeader('My Scheme Enrollments',
                  '',
                  action: primaryButton(
                    'New',
                    Icons.add,
                    onTap: () async {
                      final created = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EnrollmentCreateScreen()),
                      );
                      if (created == true) {
                        _refresh(); // reload the list so the new enrollment shows up
                      }
                    },
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search Proposal, Member, Scheme...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                card(emptyState(Icons.error_outline, 'Failed to load enrollments. Pull down to retry.'))
              else if (_filtered.isEmpty)
                  card(emptyState(Icons.inbox_outlined, 'No enrollments found.'))
                else
                  ..._filtered.map((e) {
                    final proposalNo = (e['proposal_no'] ?? '-').toString();
                    final schemeAccNo = (e['scheme_account_no'] ?? '-').toString();
                    final memberName = (e['member_name'] ?? '-').toString();
                    final memberMobile = (e['member_mobile'] ?? '-').toString();
                    final schemeName = (e['scheme_name'] ?? '-').toString();
                    final joiningFee = (e['joining_fee'] ?? '0').toString();
                    final perEvent = (e['per_event_installment'] ?? '0').toString();
                    final status = (e['status'] ?? e['enrollment_status'] ?? '-').toString();

                    return card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(proposalNo,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          statusBadge(status),
                        ]),
                        const SizedBox(height: 8),
                        infoRow('Scheme A/C No', schemeAccNo),
                        infoRow('Member', '$memberName ($memberMobile)'),
                        infoRow('Scheme', schemeName),
                        infoRow('Joining Fee', '₹$joiningFee'),
                        infoRow('Per-Event Rate', '₹$perEvent'),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _viewEnrollmentDetail((e['id'] ?? '').toString()),
                              icon: const Icon(Icons.description_outlined, size: 16),
                              label: const Text('View File'),
                              style: OutlinedButton.styleFrom(foregroundColor: KColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showDastavej(e),
                              icon: const Icon(Icons.folder_outlined, size: 16),
                              label: const Text('Dastavej'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KColors.navActive,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                              ),
                            ),
                          ),
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
    final data = await ApiService().getKaryakartaClaims();
    _all = data;
    return data;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _viewClaimDetail(String id) async {
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing claim ID.')),
      );
      return;
    }

    final shareToken = await ApiService().getDocumentShareToken(
      docType: 'claim',
      recordId: id,
    );

    if (!mounted) return;
    if (shareToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService().lastShareTokenError ??
            'Could not generate a secure link for this claim form.')),
      );
      return;
    }

    final url = ApiConfig.karyakartaClaimDocWebUrl(id, shareToken);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PvcCardWebViewScreen(url: url, title: 'Claim Application Form'),
      ),
    );
  }

  // Simple entry form — swap the raw ID fields for pickers
  // (backed by ApiService().getKaryakartaMembers() /
  // getKaryakartaEnrollments()) once you confirm the exact id/scheme_id
  // field names your backend returns for members & enrollments.
  Future<void> _showSubmitClaimSheet() async {
    final memberIdCtrl = TextEditingController();
    final schemeIdCtrl = TextEditingController();
    final enrollmentIdCtrl = TextEditingController();
    String eventType = 'marriage';
    final eventDateCtrl = TextEditingController();
    final beneficiaryCtrl = TextEditingController();
    final bankNameCtrl = TextEditingController();
    final bankIfscCtrl = TextEditingController();
    final bankAccNoCtrl = TextEditingController();
    final bankHolderCtrl = TextEditingController();
    bool submitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Submit New Claim',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  controller: memberIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Member ID'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: schemeIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Scheme ID'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: enrollmentIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Enrollment ID'),
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
                    final picked = await showDatePicker(
                      context: sheetCtx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setSheetState(() {
                        eventDateCtrl.text =
                        "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: beneficiaryCtrl,
                  decoration: const InputDecoration(labelText: 'Beneficiary Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankNameCtrl,
                  decoration: const InputDecoration(labelText: 'Bank Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankIfscCtrl,
                  decoration: const InputDecoration(labelText: 'Bank IFSC'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankAccNoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Bank Account No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankHolderCtrl,
                  decoration: const InputDecoration(labelText: 'Account Holder Name'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitting
                        ? null
                        : () async {
                      if (memberIdCtrl.text.trim().isEmpty ||
                          schemeIdCtrl.text.trim().isEmpty ||
                          enrollmentIdCtrl.text.trim().isEmpty ||
                          eventDateCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(sheetCtx).showSnackBar(
                          const SnackBar(content: Text('Please fill member, scheme, enrollment and event date.')),
                        );
                        return;
                      }
                      setSheetState(() => submitting = true);

                      final payload = {
                        "member_id": int.tryParse(memberIdCtrl.text.trim()) ?? memberIdCtrl.text.trim(),
                        "scheme_id": int.tryParse(schemeIdCtrl.text.trim()) ?? schemeIdCtrl.text.trim(),
                        "enrollment_id": int.tryParse(enrollmentIdCtrl.text.trim()) ?? enrollmentIdCtrl.text.trim(),
                        "event_type": eventType,
                        "event_date": eventDateCtrl.text.trim(),
                        "beneficiary_name": beneficiaryCtrl.text.trim(),
                        "bank_name": bankNameCtrl.text.trim(),
                        "bank_ifsc": bankIfscCtrl.text.trim(),
                        "bank_account_no": bankAccNoCtrl.text.trim(),
                        "bank_account_holder": bankHolderCtrl.text.trim(),
                      };

                      final result = await ApiService().submitKaryakartaClaim(payload);

                      if (!mounted) return;
                      Navigator.of(sheetCtx).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'] ?? 'Claim submitted')),
                      );

                      if (result['success'] == true) _refresh();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: submitting
                        ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Submit Claim', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
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
              sectionHeader('Claims Master',
                  '',
                  action: primaryButton('Submit', Icons.upload_file, color: KColors.green,
                      onTap: () async {
                        final created = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ClaimSubmitScreen()),
                        );
                        if (created == true) _refresh();
                      })),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                card(emptyState(Icons.error_outline, 'Failed to load claims. Pull down to retry.'))
              else if (_all.isEmpty)
                  card(emptyState(Icons.inbox_outlined, 'No claims submitted yet.'))
                else
                  ..._all.map((c) {
                    final claimNo = (c['claim_request_no'] ?? c['claim_no'] ?? '-').toString();
                    final memberName = (c['member_name'] ?? '-').toString();
                    final memberMobile = (c['member_mobile'] ?? '-').toString();
                    final schemeName = (c['scheme_name'] ?? '-').toString();
                    final eventType = (c['event_type'] ?? '-').toString();
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
                        infoRow('Scheme & Event', '$schemeName • $eventType'),
                        infoRow('Submitted By', submittedBy),
                        infoRow('Net Assistance', '₹$amount', bold: true),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: id.isEmpty ? null : () => _viewClaimDetail(id),
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                            label: const Text('View Form'),
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

// // ---- Collections ----
// class _CollectionsTab extends StatefulWidget {
//   const _CollectionsTab();
//   @override
//   State<_CollectionsTab> createState() => _CollectionsTabState();
// }
//
// // class _CollectionsTabState extends State<_CollectionsTab> {
// //   int _tab = 2; // default: Direct Collect (the one tab that's fully wired)
// class _CollectionsTabState extends State<_CollectionsTab> {
//   static const int _defaultTabIndex = 2; // Direct Collect — the fully-wired tab
//   int _tab = _defaultTabIndex;
//   late Future<Map<String, dynamic>> _summaryFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _summaryFuture = ApiService().getKaryakartaCollectionsSummary();
//   }
//
//   Future<void> _refresh() async {
//     setState(() {
//       _summaryFuture = ApiService().getKaryakartaCollectionsSummary();
//     });
//     await _summaryFuture;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _summaryFuture,
//       builder: (context, snapshot) {
//         final loading = snapshot.connectionState == ConnectionState.waiting;
//         final data = snapshot.data ?? {};
//
//         final totalCollections = (data['total_collections'] ?? 0).toString();
//         final todaysCollection = (data['todays_collection'] ?? 0).toString();
//         final eventContributions = (data['event_contributions'] ?? 0).toString();
//         final oldPendingRecovery = (data['old_pending_recovery'] ?? 0).toString();
//
//         final activeClaims = (data['active_claims'] as List?) ?? [];
//         final oldPaidClaims = (data['old_paid_claims'] as List?) ?? [];
//         final myReceipts = (data['my_receipts'] as List?) ?? [];
//
//         final tabLabels = [
//           'Active Claims (${activeClaims.length})',
//           'Old Paid Claims (${oldPaidClaims.length})',
//           'Direct Collect',
//           'My Receipts (${myReceipts.length})',
//         ];
//
//         return RefreshIndicator(
//           onRefresh: _refresh,
//           child: ListView(
//             padding: const EdgeInsets.only(bottom: 24),
//             children: [
//               if (loading)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 40),
//                   child: Center(child: CircularProgressIndicator()),
//                 )
//               else
//                 GridView.count(
//                   crossAxisCount: 2,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
//                   mainAxisSpacing: 12,
//                   crossAxisSpacing: 12,
//                   childAspectRatio: 1.5,
//                   children: [
//                     StatTile(label: 'Total Collections', value: '₹$totalCollections', icon: Icons.receipt_long, color: KColors.green),
//                     StatTile(label: "Today's Collection", value: '₹$todaysCollection', icon: Icons.currency_rupee, color: KColors.primary),
//                     StatTile(label: 'Event Contributions', value: '₹$eventContributions', icon: Icons.volunteer_activism, color: KColors.blue),
//                     StatTile(label: 'Old Pending Recovery', value: '₹$oldPendingRecovery', icon: Icons.history, color: KColors.red),
//                   ],
//                 ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: List.generate(tabLabels.length, (i) {
//                       final sel = _tab == i;
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: ChoiceChip(
//                           label: Text(tabLabels[i], style: TextStyle(fontSize: 12, color: sel ? Colors.white : Colors.black87)),
//                           selected: sel,
//                           onSelected: (_) => setState(() => _tab = i),
//                           selectedColor: KColors.primary,
//                           backgroundColor: Colors.white,
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               if (_tab == 0)
//                 activeClaims.isEmpty
//                     ? card(emptyState(Icons.inbox_outlined, 'No active claims yet.'))
//                     : Column(children: activeClaims.map((raw) {
//                   final c = Map<String, dynamic>.from(raw);
//                   return card(Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('${c['claim_request_no'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                       const SizedBox(height: 6),
//                       infoRow('Member', '${c['member_name'] ?? '-'}'),
//                       infoRow('Scheme', '${c['scheme_name'] ?? '-'}'),
//                       infoRow('Status', '${c['status'] ?? '-'}'),
//                     ],
//                   ));
//                 }).toList())
//               else if (_tab == 1)
//                 oldPaidClaims.isEmpty
//                     ? card(emptyState(Icons.inbox_outlined, 'No old paid claims yet.'))
//                     : Column(children: oldPaidClaims.map((raw) {
//                   final o = Map<String, dynamic>.from(raw);
//                   return card(Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('${o['claim_id'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                       const SizedBox(height: 6),
//                       infoRow('Batch ID', '${o['batch_id'] ?? '-'}'),
//                       infoRow('Beneficiary', '${o['beneficiary'] ?? '-'} (${o['ben_id'] ?? '-'})'),
//                       infoRow('Event', '${o['event'] ?? '-'} • ${o['date'] ?? '-'}'),
//                       infoRow('Total Members', '${o['total_members'] ?? '-'}'),
//                       infoRow('Total Collection', '₹${o['total_collection'] ?? '0'}'),
//                       infoRow('Paid / Pending', '${o['paid_pending'] ?? '-'}'),
//                       infoRow('Collected / Expected', '₹${o['collected'] ?? '0'} / ₹${o['expected'] ?? '0'}'),
//                       infoRow('Date of Payment', '${o['date_of_payment'] ?? '-'}'),
//                     ],
//                   ));
//                 }).toList())
//               else if (_tab == 2)
//                   const _DirectCollectPanel()
//                 else
//                   myReceipts.isEmpty
//                       ? card(emptyState(Icons.receipt_long_outlined, 'No receipts yet.'))
//                       : Column(children: myReceipts.map((raw) {
//                     final r = Map<String, dynamic>.from(raw);
//                     return card(Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('${r['receipt_no'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                         const SizedBox(height: 6),
//                         infoRow('Amount', '₹${r['amount'] ?? '0'}', bold: true),
//                         infoRow('Date', '${r['created_at'] ?? '-'}'),
//                       ],
//                     ));
//                   }).toList()),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// // NEW — "Direct Collect" panel: record a collection + list recorded ones,
// // backed by /api/karyakarta/collections.
// class _DirectCollectPanel extends StatefulWidget {
//   const _DirectCollectPanel();
//   @override
//   State<_DirectCollectPanel> createState() => _DirectCollectPanelState();
// }
//
// class _DirectCollectPanelState extends State<_DirectCollectPanel> {
//   late Future<List<Map<String, dynamic>>> _future;
//   final _memberIdCtrl = TextEditingController();
//   final _enrollmentIdCtrl = TextEditingController();
//   final _amountCtrl = TextEditingController();
//   final _dateCtrl = TextEditingController(
//       text: DateTime.now().toIso8601String().substring(0, 10));
//   String _paymentMode = 'cash';
//   bool _saving = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _future = _load();
//   }
//
//   Future<List<Map<String, dynamic>>> _load() => ApiService().getKaryakartaCollections();
//
//   Future<void> _refresh() async {
//     setState(() {
//       _future = _load();
//     });
//     await _future;
//   }
//
//   Future<void> _submit() async {
//     if (_memberIdCtrl.text.trim().isEmpty ||
//         _enrollmentIdCtrl.text.trim().isEmpty ||
//         _amountCtrl.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill member, enrollment and amount.')),
//       );
//       return;
//     }
//     setState(() => _saving = true);
//
//     final payload = {
//       "member_id": int.tryParse(_memberIdCtrl.text.trim()) ?? _memberIdCtrl.text.trim(),
//       "enrollment_id": int.tryParse(_enrollmentIdCtrl.text.trim()) ?? _enrollmentIdCtrl.text.trim(),
//       "amount": num.tryParse(_amountCtrl.text.trim()) ?? _amountCtrl.text.trim(),
//       "collection_date": _dateCtrl.text.trim(),
//       "payment_mode": _paymentMode,
//     };
//
//     final result = await ApiService().createKaryakartaCollection(payload);
//
//     if (!mounted) return;
//     setState(() => _saving = false);
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(result['message'] ?? 'Collection recorded')),
//     );
//
//     if (result['success'] == true) {
//       _memberIdCtrl.clear();
//       _enrollmentIdCtrl.clear();
//       _amountCtrl.clear();
//       _refresh();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         card(Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Record a Direct Collection',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _memberIdCtrl,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Member ID'),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _enrollmentIdCtrl,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Enrollment ID'),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _amountCtrl,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Amount (₹)'),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _dateCtrl,
//               readOnly: true,
//               decoration: const InputDecoration(labelText: 'Collection Date'),
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                 );
//                 if (picked != null) {
//                   setState(() {
//                     _dateCtrl.text =
//                     "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 10),
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(labelText: 'Payment Mode'),
//               value: _paymentMode,
//               items: const [
//                 DropdownMenuItem(value: 'cash', child: Text('Cash')),
//                 DropdownMenuItem(value: 'online', child: Text('Online')),
//                 // DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
//               ],
//               onChanged: (v) => setState(() => _paymentMode = v ?? 'cash'),
//             ),
//             const SizedBox(height: 14),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _saving ? null : _submit,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: KColors.primary, foregroundColor: Colors.white, elevation: 0,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 child: _saving
//                     ? const SizedBox(height: 18, width: 18,
//                     child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                     : const Text('Record Collection', style: TextStyle(fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ],
//         )),
//         FutureBuilder<List<Map<String, dynamic>>>(
//           future: _future,
//           builder: (context, snap) {
//             if (snap.connectionState == ConnectionState.waiting) {
//               return const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 30),
//                 child: Center(child: CircularProgressIndicator()),
//               );
//             }
//             final list = snap.data ?? [];
//             if (list.isEmpty) {
//               return card(emptyState(Icons.inbox_outlined, 'No collections recorded yet.'));
//             }
//             return Column(
//               children: list.map((c) => card(Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   infoRow('Collection ID', '${c['id'] ?? c['collection_id'] ?? '-'}'),
//                   infoRow('Amount', '₹${c['amount'] ?? '0'}', bold: true),
//                   infoRow('Payment Mode', '${c['payment_mode'] ?? '-'}'),
//                   infoRow('Date', '${c['collection_date'] ?? '-'}'),
//                 ],
//               ))).toList(),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
// ============================================================
// COLLECTIONS SECTION — REWRITE to match the web Karyakarta portal:
//   Dashboard | Master Register | Direct Collect |
//   Current Active Claim | Old Paid Claim
//
// HOW TO APPLY THIS FILE
// -----------------------------------------------------------
// 1. In karyakarta_dashboard_screen.dart, DELETE these existing
//    classes entirely:
//       - _CollectionsTab            (StatefulWidget)
//       - _CollectionsTabState
//       - _DirectCollectPanel        (StatefulWidget)
//       - _DirectCollectPanelState
//
// 2. Paste EVERYTHING below into the same file (anywhere after the
//    shared-widgets section, e.g. right where _CollectionsTab used
//    to be). It reuses helpers already defined further up in that
//    file: KColors, card(), infoRow(), statusBadge(), sectionHeader(),
//    emptyState(), subTabStrip(), kSaCode, kFullName, StatTile.
//
// 3. Apply the endpoint + ApiService method additions in
//    "api_additions.dart" (separate file) to api_config.dart and
//    api_service.dart — Direct Collect and the Claim Batch Detail
//    screen call methods that don't exist in your ApiService yet
//    (getKaryakartaMemberPendingDues, payKaryakartaMemberDues,
//    getKaryakartaClaimBatchDetail). Everything else reuses methods
//    you already have (getKaryakartaCollectionsSummary,
//    getKaryakartaCollections).
//
// 4. Nothing outside the Collections tab is touched — My Members,
//    Enrollments, Claims (the "Claims Master" tab), Reports, Profile
//    are untouched.
// ============================================================

class _CollectionsTab extends StatefulWidget {
  const _CollectionsTab();
  @override
  State<_CollectionsTab> createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<_CollectionsTab> {
  int _tab = 0;
  String? _directCollectQuery;
  int _directCollectNonce = 0; // bumps the key so the panel re-loads on prefill

  static const _labels = [
    'Dashboard',
    'Master Register',
    'Direct Collect',
    'Current Active Claim',
    'Old Paid Claim',
  ];

  /// Called from the Claim Batch Detail screen's "Collect Dues" button —
  /// jumps to the Direct Collect tab with the member pre-searched.
  void _openDirectCollectFor(String memberIdOrMobile) {
    setState(() {
      _directCollectQuery = memberIdOrMobile;
      _directCollectNonce++;
      _tab = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        subTabStrip(_labels, _tab, (i) => setState(() => _tab = i)),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: [
              const _CollectionsDashboardPanel(),
              const _MasterRegisterPanel(),
              _DirectCollectPanel(
                key: ValueKey('direct-collect-$_directCollectNonce'),
                initialQuery: _directCollectQuery,
              ),
              _CurrentActiveClaimPanel(onCollectMember: _openDirectCollectFor),
              _OldPaidClaimPanel(onCollectMember: _openDirectCollectFor),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// Shared receipt row — used by both Dashboard ("Recent Collection
// Receipts") and Master Register ("all receipts + Gotra/Village").
// ------------------------------------------------------------
class _ReceiptRow extends StatelessWidget {
  final Map<String, dynamic> receipt;
  final bool showGotraVillage;
  const _ReceiptRow({required this.receipt, this.showGotraVillage = false});

  @override
  Widget build(BuildContext context) {
    final r = receipt;
    final receiptNo = (r['receipt_no'] ?? '-').toString();
    // NOTE(backend): receipts currently only return receipt_no/amount/
    // created_at (see getKaryakartaCollectionsSummary's my_receipts).
    // Add type, member_name, member_id, payment_mode, gotra/village to
    // match the web Master Register / Dashboard columns exactly.
    final type = (r['type'] ?? r['purpose'] ?? '-').toString();
    final memberName = (r['member_name'] ?? '-').toString();
    final memberId = (r['member_id'] ?? '-').toString();
    final amount = (r['amount'] ?? '0').toString();
    final mode = (r['payment_mode'] ?? r['mode'] ?? '-').toString();
    final dateTime = (r['created_at'] ?? r['date_time'] ?? '-').toString();
    final gotraVillage = (r['gotra'] ?? r['village'] ?? '-').toString();

    return card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
              child: Text(receiptNo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          statusBadge(type),
        ]),
        const SizedBox(height: 8),
        infoRow('Member', '$memberName ($memberId)'),
        if (showGotraVillage) infoRow('Gotra / Village', gotraVillage),
        infoRow('Amount', '₹$amount', bold: true),
        infoRow('Mode', mode),
        infoRow('Date & Time', dateTime),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => PaymentReceiptDialog(receipt: r),
            ),
            icon: const Icon(Icons.receipt_outlined, size: 16),
            label: const Text('Thermal Receipt'),
            style: OutlinedButton.styleFrom(foregroundColor: KColors.primary),
          ),
        ),
      ],
    ));
  }
}

// ------------------------------------------------------------
// 1) DASHBOARD panel — stat cards + last-10 receipts.
// ------------------------------------------------------------
class _CollectionsDashboardPanel extends StatefulWidget {
  const _CollectionsDashboardPanel();
  @override
  State<_CollectionsDashboardPanel> createState() =>
      _CollectionsDashboardPanelState();
}

class _CollectionsDashboardPanelState
    extends State<_CollectionsDashboardPanel> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getKaryakartaCollectionsSummary();
  }

  Future<void> _refresh() async {
    setState(() => _future = ApiService().getKaryakartaCollectionsSummary());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? {};

        final totalCollections = (data['total_collections'] ?? 0).toString();
        final todaysCollection = (data['todays_collection'] ?? 0).toString();
        final eventContributions =
        (data['event_contributions'] ?? 0).toString();
        final oldPendingRecovery =
        (data['old_pending_recovery'] ?? 0).toString();

        // Prefer a dedicated "recent_receipts" key if the backend adds one;
        // otherwise fall back to my_receipts (already returned today).
        final recentReceipts =
        ((data['recent_receipts'] ?? data['my_receipts']) as List? ?? [])
            .take(10)
            .toList();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatTile(
                        label: 'Total Collections',
                        value: '₹$totalCollections',
                        icon: Icons.receipt_long,
                        color: KColors.green),
                    StatTile(
                        label: "Today's Collection",
                        value: '₹$todaysCollection',
                        icon: Icons.currency_rupee,
                        color: KColors.primary),
                    StatTile(
                        label: 'Event Contributions',
                        value: '₹$eventContributions',
                        icon: Icons.volunteer_activism,
                        color: KColors.blue),
                    StatTile(
                        label: 'Old Pending Recovery',
                        value: '₹$oldPendingRecovery',
                        icon: Icons.history,
                        color: KColors.red),
                  ],
                ),
              sectionHeader(
                'Recent Collection Receipts (Last 10)',
                'Quick snapshot of recent collections. For all receipts, check Master Register.',
              ),
              if (!loading && recentReceipts.isEmpty)
                card(emptyState(Icons.receipt_long_outlined, 'No receipts yet.')),
              ...recentReceipts.map(
                    (raw) => _ReceiptRow(receipt: Map<String, dynamic>.from(raw)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------
// 2) MASTER REGISTER panel — full receipts list + search.
// ------------------------------------------------------------
class _MasterRegisterPanel extends StatefulWidget {
  const _MasterRegisterPanel();
  @override
  State<_MasterRegisterPanel> createState() => _MasterRegisterPanelState();
}

class _MasterRegisterPanelState extends State<_MasterRegisterPanel> {
  late Future<List<Map<String, dynamic>>> _future;
  List<Map<String, dynamic>> _all = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    // TODO(backend): a dedicated karyakarta-scoped master-register endpoint
    // (see ApiConfig.karyakartaMasterRegister in api_additions.dart) would
    // let you add pagination + server-side search. Until then this reuses
    // the existing full collections list.
    final data = await ApiService().getKaryakartaCollections();
    _all = data;
    return data;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((r) {
      final receiptNo = (r['receipt_no'] ?? '').toString().toLowerCase();
      final name = (r['member_name'] ?? '').toString().toLowerCase();
      return receiptNo.contains(q) || name.contains(q);
    }).toList();
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
                'Master Receipts Register',
                'All official collection receipts generated through your portal.',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search Receipt No, Member...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_filtered.isEmpty)
                card(emptyState(Icons.inbox_outlined, 'No receipts found.'))
              else
                ..._filtered.map(
                      (r) => _ReceiptRow(receipt: r, showGotraVillage: true),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------
// 3) DIRECT COLLECT panel — search → load pending dues → select
//    → pay → receipt. Replaces the old manual-entry form.
// ------------------------------------------------------------
class _DirectCollectPanel extends StatefulWidget {
  final String? initialQuery;
  const _DirectCollectPanel({super.key, this.initialQuery});
  @override
  State<_DirectCollectPanel> createState() => _DirectCollectPanelState();
}

class _DirectCollectPanelState extends State<_DirectCollectPanel> {
  final _searchCtrl = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _member;
  List<Map<String, dynamic>> _dues = [];
  final Set<String> _selected = {};
  String _paymentMode = 'cash';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if ((widget.initialQuery ?? '').trim().isNotEmpty) {
      _searchCtrl.text = widget.initialQuery!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPendingDues());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  num get _selectedTotal {
    num total = 0;
    for (final d in _dues) {
      final id = (d['id'] ?? '').toString();
      if (_selected.contains(id)) {
        total += num.tryParse('${d['contribution_amount'] ?? d['amount'] ?? 0}') ?? 0;
      }
    }
    return total;
  }

  Future<void> _loadPendingDues() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _member = null;
      _dues = [];
      _selected.clear();
    });

    // TODO(backend): GET /karyakarta/collections/member-dues?query=...
    // See ApiConfig.karyakartaMemberPendingDues in api_additions.dart.
    final result = await ApiService().getKaryakartaMemberPendingDues(query);

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result == null) {
        _member = null;
        _dues = [];
      } else {
        _member = Map<String, dynamic>.from(result['member'] ?? {});
        _dues = List<Map<String, dynamic>>.from(result['pending_dues'] ?? []);
        _selected.addAll(_dues.map((d) => (d['id'] ?? '').toString()));
      }
    });

    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member not found or has no pending dues.')),
      );
    }
  }

  Future<void> _payNow() async {
    if (_member == null || _selected.isEmpty) return;
    setState(() => _submitting = true);

    // TODO(backend): POST /karyakarta/collections/pay-dues
    // See ApiConfig.karyakartaPayMemberDues in api_additions.dart.
    final result = await ApiService().payKaryakartaMemberDues(
      memberId: (_member!['id'] ?? _member!['member_id'] ?? '').toString(),
      dueIds: _selected.toList(),
      paymentMode: _paymentMode,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['success'] == true) {
      final receipt = Map<String, dynamic>.from(result['data'] ?? result['receipt'] ?? {});
      await showDialog(
        context: context,
        builder: (_) => PaymentReceiptDialog(receipt: receipt),
      );
      if (!mounted) return;
      setState(() {
        _member = null;
        _dues = [];
        _selected.clear();
        _searchCtrl.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Payment failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        card(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Direct Member Collection Terminal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Text(
              'Search any member by ID or Mobile (separate multiple IDs with comma).',
              style: TextStyle(fontSize: 11.5, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Enter Member ID or Mobile (e.g. 8195201, 5731329)...',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onSubmitted: (_) => _loadPendingDues(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _loading ? null : _loadPendingDues,
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Load Pending Dues'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ]),
          ],
        )),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!_loading && _member != null) ...[
          card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Member Information & Verification',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Divider(height: 18),
              infoRow('Name & ID',
                  '${_member!['full_name'] ?? _member!['name'] ?? '-'} (${_member!['id'] ?? _member!['member_id'] ?? '-'})'),
              infoRow('Mobile', '${_member!['mobile'] ?? '-'}'),
              infoRow('SA Code & Karyakarta',
                  '${_member!['sa_code'] ?? kSaCode} — ${_member!['karyakarta_name'] ?? kFullName}'),
              infoRow('Scheme ID & Name',
                  '${_member!['scheme_id'] ?? '-'} — ${_member!['scheme_name'] ?? '-'}'),
            ],
          )),
          card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                  child: Text('Billable Pending Contributions (Select to Pay)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    if (_selected.length == _dues.length) {
                      _selected.clear();
                    } else {
                      _selected
                        ..clear()
                        ..addAll(_dues.map((d) => (d['id'] ?? '').toString()));
                    }
                  }),
                  child: Text(_selected.length == _dues.length ? 'Deselect All' : 'Select All'),
                ),
              ]),
              if (_dues.isEmpty)
                emptyState(Icons.check_circle_outline, 'No pending dues for this member.'),
              ..._dues.map((d) {
                final id = (d['id'] ?? '').toString();
                final claimScheme = '${d['claim_id'] ?? '-'} — ${d['scheme_name'] ?? '-'}';
                final beneficiary = '${d['beneficiary_name'] ?? '-'} (${d['beneficiary_id'] ?? '-'})';
                final eventInfo = '${d['event_type'] ?? '-'} • ${d['event_date'] ?? '-'}';
                final amount = '${d['contribution_amount'] ?? d['amount'] ?? '0'}';
                return CheckboxListTile(
                  value: _selected.contains(id),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selected.add(id);
                    } else {
                      _selected.remove(id);
                    }
                  }),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(claimScheme,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text('$beneficiary\n$eventInfo', style: const TextStyle(fontSize: 12)),
                  isThreeLine: true,
                  secondary: Text('₹$amount',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: KColors.green)),
                );
              }),
              const Divider(height: 20),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _paymentMode,
                    decoration: const InputDecoration(labelText: 'Payment Mode'),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash Handover')),
                      DropdownMenuItem(value: 'online', child: Text('Online')),
                    ],
                    onChanged: (v) => setState(() => _paymentMode = v ?? 'cash'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Collected By', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('$kSaCode — $kFullName',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KColors.bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL SELECTED AMOUNT', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text('₹$_selectedTotal',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: KColors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_selected.isEmpty || _submitting) ? null : _payNow,
                  icon: _submitting
                      ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    _submitting ? 'Processing...' : 'Pay Now & Generate Official Receipt',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          )),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------
// Shared row for BOTH claim-batch lists (Active & Old Paid).
// Matches: SN / Claim ID-Scheme / Beneficiary / Total Members /
// Collected-Expected / Action from the web screenshots.
// ------------------------------------------------------------
class _ClaimBatchRow extends StatelessWidget {
  final Map<String, dynamic> batch;
  final String actionLabel;
  final VoidCallback onTap;
  const _ClaimBatchRow({
    required this.batch,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final b = batch;
    final claimId = (b['claim_id'] ?? '-').toString();
    final schemeName = (b['scheme_name'] ?? '-').toString();
    final beneficiary = (b['beneficiary'] ?? b['beneficiary_name'] ?? '-').toString();
    final totalMembers = (b['total_members'] ?? '0').toString();
    final collected = (b['collected'] ?? b['collected_amount'] ?? '0').toString();
    final expected =
    (b['expected'] ?? b['expected_amount'] ?? b['total_collection'] ?? '0').toString();

    return card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(claimId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(schemeName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        infoRow('Beneficiary', beneficiary),
        infoRow('Total Members', totalMembers),
        infoRow('Collected / Expected', '₹$collected / ₹$expected', bold: true),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: KColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(actionLabel),
          ),
        ),
      ],
    ));
  }
}

// ------------------------------------------------------------
// 4) CURRENT ACTIVE CLAIM panel
// ------------------------------------------------------------
class _CurrentActiveClaimPanel extends StatefulWidget {
  final void Function(String memberIdOrMobile) onCollectMember;
  const _CurrentActiveClaimPanel({required this.onCollectMember});
  @override
  State<_CurrentActiveClaimPanel> createState() =>
      _CurrentActiveClaimPanelState();
}

class _CurrentActiveClaimPanelState extends State<_CurrentActiveClaimPanel> {
  late Future<List<Map<String, dynamic>>> _future;
  String _query = '';
  List<Map<String, dynamic>> _all = [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    // IMPORTANT(backend): this must return the SAME batch shape as
    // old_paid_claims (claim_id, scheme_name, beneficiary, total_members,
    // collected, expected) — NOT the claim_request_no/status shape the
    // old "Active Claims" tab used. See _ClaimBatchRow above.
    final summary = await ApiService().getKaryakartaCollectionsSummary();
    final list = (summary['active_claims'] as List?) ?? [];
    _all = List<Map<String, dynamic>>.from(list);
    return _all;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((c) {
      final id = (c['claim_id'] ?? c['claim_request_no'] ?? '').toString().toLowerCase();
      final ben = (c['beneficiary_name'] ?? c['beneficiary'] ?? '').toString().toLowerCase();
      return id.contains(q) || ben.contains(q);
    }).toList();
  }

  void _openBatch(Map<String, dynamic> c) {
    final claimId = (c['claim_id'] ?? c['id'] ?? '').toString();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClaimBatchDetailScreen(
          claimId: claimId,
          onCollectMember: widget.onCollectMember,
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
              sectionHeader('Current Active Claims Batches', ''),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search Active Claims...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_filtered.isEmpty)
                card(emptyState(Icons.inbox_outlined, 'No active claims currently ongoing.'))
              else
                ..._filtered.map((c) => _ClaimBatchRow(
                  batch: c,
                  actionLabel: 'View',
                  onTap: () => _openBatch(c),
                )),
            ],
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------
// 5) OLD PAID CLAIM panel
// ------------------------------------------------------------
class _OldPaidClaimPanel extends StatefulWidget {
  final void Function(String memberIdOrMobile) onCollectMember;
  const _OldPaidClaimPanel({required this.onCollectMember});
  @override
  State<_OldPaidClaimPanel> createState() => _OldPaidClaimPanelState();
}

class _OldPaidClaimPanelState extends State<_OldPaidClaimPanel> {
  late Future<List<Map<String, dynamic>>> _future;
  String _query = '';
  List<Map<String, dynamic>> _all = [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final summary = await ApiService().getKaryakartaCollectionsSummary();
    final list = (summary['old_paid_claims'] as List?) ?? [];
    _all = List<Map<String, dynamic>>.from(list);
    return _all;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((c) {
      final id = (c['claim_id'] ?? '').toString().toLowerCase();
      final ben = (c['beneficiary'] ?? c['beneficiary_name'] ?? '').toString().toLowerCase();
      return id.contains(q) || ben.contains(q);
    }).toList();
  }

  void _openBatch(Map<String, dynamic> c) {
    final claimId = (c['claim_id'] ?? c['id'] ?? '').toString();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClaimBatchDetailScreen(
          claimId: claimId,
          onCollectMember: widget.onCollectMember,
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
              sectionHeader('Old Paid Claims (Recovery Mode)', ''),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search Old Paid Claims...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_filtered.isEmpty)
                card(emptyState(Icons.inbox_outlined, 'No old paid claims yet.'))
              else
                ..._filtered.map((c) => _ClaimBatchRow(
                  batch: c,
                  actionLabel: 'Recover Dues',
                  onTap: () => _openBatch(c),
                )),
            ],
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------
// CLAIM BATCH DETAIL SCREEN — full-screen page opened when tapping
// a row in either Current Active Claim or Old Paid Claim.
// Matches "Claim Settlement Hub & Batch..." in your screenshot.
// ------------------------------------------------------------
class ClaimBatchDetailScreen extends StatefulWidget {
  final String claimId;
  final void Function(String memberIdOrMobile) onCollectMember;
  const ClaimBatchDetailScreen({
    super.key,
    required this.claimId,
    required this.onCollectMember,
  });

  @override
  State<ClaimBatchDetailScreen> createState() => _ClaimBatchDetailScreenState();
}

class _ClaimBatchDetailScreenState extends State<ClaimBatchDetailScreen> {
  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    // TODO(backend): GET /karyakarta/claim-batches/{claimId}
    // See ApiConfig.karyakartaClaimBatchDetail in api_additions.dart.
    _future = ApiService().getKaryakartaClaimBatchDetail(widget.claimId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService().getKaryakartaClaimBatchDetail(widget.claimId);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.navyDark,
        foregroundColor: Colors.white,
        title: Text('Claim ID: ${widget.claimId}'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: emptyState(Icons.error_outline, 'Could not load claim batch details.'),
            );
          }

          final batchId = (data['batch_id'] ?? '-').toString();
          final memberName = (data['member_name'] ?? '-').toString();
          final memberId = (data['member_id'] ?? '-').toString();
          final schemeId = (data['scheme_id'] ?? '-').toString();
          final schemeName = (data['scheme_name'] ?? '-').toString();
          final eventType = (data['event_type'] ?? '-').toString();
          final eventDate = (data['event_date'] ?? '-').toString();
          final karyakarta = (data['karyakarta_name'] ?? '-').toString();
          final claimStatus = (data['claim_status'] ?? '-').toString();
          final collectionStatus = (data['collection_status'] ?? '-').toString();
          final totalMembers = (data['total_members'] ?? '0').toString();
          final paidCount = (data['paid_count'] ?? '0').toString();
          final pendingCount = (data['pending_count'] ?? '0').toString();
          final collected = (data['collected'] ?? '0').toString();
          final total = (data['total'] ?? data['expected'] ?? '0').toString();
          final ageGroups = List<Map<String, dynamic>>.from(data['age_groups'] ?? []);
          final members = List<Map<String, dynamic>>.from(data['members'] ?? []);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration:
                  BoxDecoration(color: KColors.navyDark, borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    Expanded(
                      child: Text('BATCH: $batchId',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                    statusBadge(claimStatus),
                    const SizedBox(width: 8),
                    statusBadge(collectionStatus),
                  ]),
                ),
                card(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Claim Beneficiary Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Divider(height: 18),
                    infoRow('Member Name & ID', '$memberName ($memberId)'),
                    infoRow('Scheme ID & A/C', '$schemeId — $schemeName'),
                    infoRow('Event & Date', '$eventType — $eventDate'),
                    infoRow('Karyakarta', karyakarta),
                  ],
                )),
                card(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Batch Collection & Disbursal Details',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Divider(height: 18),
                    ...ageGroups.map((g) => infoRow(
                        '${g['age_group'] ?? '-'} (${g['members'] ?? 0} members)',
                        '₹${g['per_amount'] ?? 0} × ${g['members'] ?? 0} = ₹${g['total_amount'] ?? 0}')),
                    const Divider(height: 18),
                    infoRow('Total Members', totalMembers),
                    infoRow('Paid / Pending', '$paidCount Paid / $pendingCount Pending'),
                    infoRow('Collected / Total', '₹$collected / ₹$total', bold: true),
                  ],
                )),
                sectionHeader(
                  'Batch Breakdown View & Collections Status',
                  'Showing only your tagged members.',
                ),
                if (members.isEmpty)
                  card(emptyState(Icons.inbox_outlined, 'No members in this batch.'))
                else
                  ...members.map((m) {
                    final mId = (m['member_id'] ?? '-').toString();
                    final mName = (m['member_name'] ?? '-').toString();
                    final mMobile = (m['mobile'] ?? '').toString();
                    final ageGroup = (m['age_group'] ?? '-').toString();
                    final contribution = (m['contribution'] ?? '0').toString();
                    final status = (m['payment_status'] ?? '-').toString();
                    final isPaid = status.toUpperCase() == 'PAID';

                    return card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Text('$mName ($mId)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                          statusBadge(status),
                        ]),
                        const SizedBox(height: 6),
                        infoRow('Age Group', ageGroup),
                        infoRow('Contribution', '₹$contribution', bold: true),
                        const SizedBox(height: 8),
                        if (!isPaid)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onCollectMember(mMobile.isNotEmpty ? mMobile : mId);
                              },
                              icon: const Icon(Icons.download_outlined, size: 16),
                              label: const Text('Collect Dues'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                            ),
                          ),
                      ],
                    ));
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// PAYMENT RECEIPT DIALOG — "OFFICIAL PAYMENT RECEIPT" popup shown
// after a Direct Collect payment, or from the "Thermal Receipt" /
// "Receipt" buttons in Dashboard & Master Register.
// ------------------------------------------------------------
class PaymentReceiptDialog extends StatelessWidget {
  final Map<String, dynamic> receipt;
  const PaymentReceiptDialog({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final r = receipt;
    final receiptNo = (r['receipt_no'] ?? '-').toString();
    final purpose = (r['type'] ?? r['purpose'] ?? 'Receipt').toString();
    final memberName = (r['member_name'] ?? '-').toString();
    final memberId = (r['member_id'] ?? '-').toString();
    final gotra = (r['gotra'] ?? '-').toString();
    final proposalNo = (r['proposal_no'] ?? '-').toString();
    final schemeName = (r['scheme_name'] ?? '-').toString();
    final schemeId = (r['scheme_id'] ?? '-').toString();
    final taggedKaryakarta = (r['karyakarta_code'] ?? kSaCode).toString();
    final taggedKaryakartaName = (r['karyakarta_name'] ?? kFullName).toString();
    final paymentMode = (r['payment_mode'] ?? r['mode'] ?? '-').toString();
    final collectedBy = (r['collected_by'] ?? 'Admin Office').toString();
    final dateTime = (r['created_at'] ?? r['date_time'] ?? '-').toString();
    final amount = (r['amount'] ?? '0').toString();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('OFFICIAL PAYMENT RECEIPT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const Text('॥ श्री विश्वकर्मणाय नमः ॥',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: KColors.orange)),
              const SizedBox(height: 4),
              const Text('समरस सुथार समाज सेवा समिति',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: KColors.navyDark)),
              const Text('SD Charitable Trust (Reg. E/1786/BK) | Changda (Thesed)',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
                child: Text(purpose.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Text(receiptNo, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, letterSpacing: 1)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoRow('Member Name', memberName),
                    infoRow('Member ID / Gotra', '$memberId ($gotra)'),
                    infoRow('Purpose', purpose),
                    infoRow('Proposal No', proposalNo),
                    infoRow('Scheme Name & ID', '$schemeName ($schemeId)'),
                    infoRow('Tagged Karyakarta', '$taggedKaryakarta — $taggedKaryakartaName'),
                    infoRow('Payment Mode', paymentMode),
                    infoRow('Collected By', collectedBy),
                    infoRow('Date & Time', dateTime),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFDFF6EA), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    const Text('TOTAL AMOUNT PAID', style: TextStyle(fontSize: 11, color: KColors.green)),
                    Text('₹$amount',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: KColors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Digitally generated payment receipt verified by central server. Thank you for your community support.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _notImplemented(context, 'PDF export'),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                      label: const Text('PDF'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _notImplemented(context, 'JPEG export'),
                      icon: const Icon(Icons.image_outlined, size: 16),
                      label: const Text('JPEG'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _notImplemented(context, 'Share'),
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: KColors.green, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _notImplemented(BuildContext context, String feature) {
    // TODO: wire up real export. PDF/JPEG need the `printing` + `pdf`
    // (or `screenshot`) packages; Share needs `share_plus`. Add them to
    // pubspec.yaml, then replace this SnackBar with the real calls.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not wired up yet — see TODO in PaymentReceiptDialog.')),
    );
  }
}

// ============================================================
// 3) REPORTS  (bottom-nav index 2)
// FIX: only "My Commission" now — the "Notifications" sub-tab chip
// (marked with an X in your screenshot) has been removed. Since
// there's only one section left, the chip strip itself is dropped
// too and _CommissionTab is shown directly.
// ============================================================
class _ReportsSection extends StatelessWidget {
  const _ReportsSection();

  @override
  Widget build(BuildContext context) {
    return const _CommissionTab();
  }
}

// ---- My Commission ----
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
    _future = ApiService().getKaryakartaCommissions();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService().getKaryakartaCommissions();
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
              // ---- NEW: Page title (the blue line area) ----
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'Commissions',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: KColors.navyDark),
                ),
              ),

              // ---- NEW: 3 compact cards in ONE row ----
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Total Earned',
                        value: '₹$totalEarned',
                        icon: Icons.savings_outlined,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStat(
                        label: 'Settled',
                        value: '₹$settled',
                        icon: Icons.check_circle_outline,
                        color: KColors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStat(
                        label: 'Pending',
                        value: '₹$pending',
                        icon: Icons.hourglass_bottom,
                        color: KColors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              sectionHeader('Commissions',
                  ''),
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                card(emptyState(Icons.error_outline, 'Failed to load commissions. Pull down to retry.'))
              else if (list.isEmpty)
                  card(emptyState(Icons.inbox_outlined, 'No commission records yet.'))
                else
                  ...list.map((c) => card(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text('${c['proposal_no'] ?? '-'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
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
// Compact stat card (used only in Commission tab)
// ============================================================
class _MiniStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: color.withOpacity(.12),
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 4) PROFILE  (bottom-nav index 3)
// FIX: added a Logout card/button right below "Update Profile"
// (the space you circled in the screenshot).
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
  Map<String, dynamic>? _data;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ApiService().getKaryakartaSelfProfile();
    if (!mounted || data == null) return;
    setState(() {
      _data = data;
      KaryakartaSession.saCode = data['karyakarta_code']?.toString() ?? KaryakartaSession.saCode;
      KaryakartaSession.fullName = data['full_name']?.toString() ?? KaryakartaSession.fullName;
      KaryakartaSession.mobile = data['mobile']?.toString() ?? KaryakartaSession.mobile;
      KaryakartaSession.village = data['village']?.toString() ?? KaryakartaSession.village;
      final photoDoc = (data['photo_doc'] ?? '').toString();
      KaryakartaSession.photoUrl = photoDoc.isNotEmpty ? ApiConfig.bannerImageUrl(photoDoc) : '';
      _altMobile.text = data['alt_mobile']?.toString() ?? '';
      _address.text = (data['full_address'] ?? data['address'] ?? '').toString();
    });
  }

  @override
  void dispose() {
    _altMobile.dispose();
    _address.dispose();
    _password.dispose();
    super.dispose();
  }

  // first non-empty value among the given keys
  String _v(List<String> keys, [String fallback = '-']) {
    final d = _data;
    if (d == null) return fallback;
    for (final k in keys) {
      final val = d[k];
      if (val != null) {
        final s = val.toString().trim();
        if (s.isNotEmpty && s != 'null') return s;
      }
    }
    return fallback;
  }

  // ---------- UI helpers ----------
  Widget _section(IconData icon, Color color, String title, List<Widget> rows, {Widget? trailing}) {
    return card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          if (trailing != null) trailing,
        ]),
        const Divider(height: 18),
        ...rows,
      ],
    ));
  }

  Widget _actionBtn(String label, IconData icon, Color bg, Color fg, VoidCallback onTap, {Color? border}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 15),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, maxLines: 1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: border ?? bg),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Actions ----------
  void _openIdCard() {
    final d = _data;
    if (d == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile not loaded yet.')));
      return;
    }
    final m = Map<String, dynamic>.from(d);
    m['photo_doc'] = kPhotoUrl; // full URL
    m['member_id'] = m['member_id'] ?? kSaCode;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemberCardScreen(member: m, saCode: kSaCode)),
    );
  }

  void _showCertificate() {
    final name = _v(['full_name'], kFullName);
    final village = _v(['village', 'village_name'], kVillage);
    final taluka = _v(['taluka', 'taluka_name', 'tehsil']);
    final district = _v(['district', 'district_name']);
    final state = _v(['state', 'state_name']);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Karyakarta Certificate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text('॥ श्री विश्वकर्मणाय नमः ॥',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFC97C0F))),
                      const SizedBox(height: 4),
                      const Text('SUTHAR SAMAJ SEVA SAMITI\nGUJARAT & RAJASTHAN',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: KColors.navyDark)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(color: KColors.navyDark, borderRadius: BorderRadius.circular(20)),
                        child: const Text('अधिकृत कार्यकर्ता प्रमाण-पत्र',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'प्रमाणित किया जाता है कि $name, निवासी $village, तह. $taluka (जि. $district, $state) संस्था के अधिकृत कार्यकर्ता (SA) के रूप में पंजीकृत हैं।',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, height: 1.6),
                      ),
                      const SizedBox(height: 12),
                      Text('SA Code: $kSaCode',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: KColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditSheet() {
    bool busy = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
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
                    onPressed: busy
                        ? null
                        : () async {
                      setSheet(() => busy = true);
                      Map<String, dynamic> res;
                      try {
                        res = await ApiService().updateKaryakartaSelfProfile(
                          altMobile: _altMobile.text,
                          fullAddress: _address.text,
                          password: _password.text.isNotEmpty ? _password.text : null,
                        );
                      } catch (e) {
                        res = {'success': false, 'message': 'Update failed: $e'};
                      }
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res['message'] ?? 'Profile updated successfully')),
                      );
                      if (res['success'] == true) {
                        _password.clear();
                        Navigator.of(sheetCtx).pop();
                        _loadProfile();
                      } else {
                        setSheet(() => busy = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: busy
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Update Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout of the Karyakarta Portal?'),
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
    KaryakartaSession.clear();

    if (!mounted) return;
    setState(() => _loggingOut = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Logged out')),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final aadhaar = _v(['aadhaar_no'], '');
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        sectionHeader('Manage Karyakarta Profile', 'Your registered personal, area and system details.'),

        // 1. Personal Info
        _section(
          Icons.person_outline, KColors.primary, '1. Personal Info',
          [
            infoRow('Full Name', _v(['full_name'], kFullName), bold: true),
            infoRow('Father Name', _v(['father_name'])),
            infoRow('Gender & DOB', '${_v(['gender'])} (${_v(['dob'])})'),
            infoRow('Mobile (Login ID)', _v(['mobile'], kMobile)),
            infoRow('Alt Mobile', _v(['alt_mobile'])),
            infoRow('Aadhaar No', aadhaar.isEmpty ? 'Pending' : 'Linked & Verified'),
            infoRow('PAN Number', _v(['pan_no', 'pan_number', 'pan'])),
          ],
          trailing: karyakartaAvatar(radius: 22, fontSize: 18),
        ),

        // 2. Working Area & Address
        _section(
          Icons.location_on_outlined, KColors.orange, '2. Working Area & Address',
          [
            infoRow('State', _v(['state', 'state_name'])),
            infoRow('District / Taluka', '${_v(['district', 'district_name'])} / ${_v(['taluka', 'taluka_name', 'tehsil'])}'),
            infoRow('Village', _v(['village', 'village_name'], kVillage)),
            infoRow('PIN Code', _v(['pincode', 'pin_code'])),
            infoRow('Full Address', _v(['full_address', 'address'])),
          ],
        ),

        // 3. Samaj & System Data
        _section(
          Icons.account_tree_outlined, KColors.green, '3. Samaj & System Data',
          [
            infoRow('SA Code', _v(['karyakarta_code'], kSaCode), bold: true),
            infoRow('Gotra', _v(['gotra', 'gotra_name'])),
            infoRow('Occupation', _v(['occupation'])),
            infoRow('Education', _v(['education'])),
            infoRow('Date of Joining', _v(['joining_date', 'created_at'])),
            infoRow('Login Password', '••••••••'),
          ],
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(13, 0, 13, 12),
          child: Row(children: [
            _actionBtn('ID Card', Icons.badge_outlined, Colors.white, KColors.navyDark, _openIdCard,
                border: Colors.grey.shade300),
            _actionBtn('Certificate', Icons.workspace_premium_outlined, const Color(0xFFFFF4E0), KColors.orange,
                _showCertificate, border: const Color(0xFFF2D9A6)),
            _actionBtn('Edit Profile', Icons.edit_outlined, KColors.navyDark, Colors.white, _showEditSheet),
          ]),
        ),

        // Logout (unchanged)
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
