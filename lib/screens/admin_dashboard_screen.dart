import 'package:flutter/material.dart';
import 'package:samaj_seva_suthar/screens/scheme_master_screen.dart';
import '../models/dashboard_stats_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'add_karyakarta_screen.dart';
import 'config_masters_hub_screen.dart';
import 'karyakarta_list_screen.dart';
import 'add_member_screen.dart';
import 'member_list_screen.dart';
import 'placeholder_screen.dart';
import 'services_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'enrollment_list_screen.dart';
import 'claim_manage_screen.dart';
import 'collection_manage_screen.dart';
import 'account_manage_screen.dart';
import 'payment_manage_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = ApiService();
  late Future<DashboardStatsModel> _statsFuture;
  String? _errorMessage;
  int _selectedIndex = 0; // FIXED: Added this back

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _statsFuture = _api.getDashboardStats();
      _errorMessage = null;
    });

    try {
      await _statsFuture;
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load dashboard: $e";
      });
    }
  }

  Future<void> _refresh() async {
    await _loadDashboardStats();
  }

  void _goTo(String title) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => PlaceholderScreen(title: title)));

  void _openProfile() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const ProfileScreen()));

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    Widget? page;
    switch (index) {
      case 1: page = const ReportsScreen(); break;
      case 2: page = const ProfileScreen(); break;
    }
    if (page == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => page!)).then((_) {
      if (mounted) setState(() => _selectedIndex = 0); // back on Home
    });
  }

  void _showMemberOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF2A9D8F)),
            title: const Text('Add Member'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMemberScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.visibility_outlined, color: Color(0xFF6A5AE0)),
            title: const Text('View Members'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberListScreen()));
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showKaryakartaOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Karyakarta manage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF2A9D8F)),
            title: const Text('Add Karyakarta'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddKaryakartaScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.visibility_outlined, color: Color(0xFF6A5AE0)),
            title: const Text('View Karyakarta'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const KaryakartaListScreen()));
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _api.currentUser?['name'] ?? _api.currentUser?['full_name'] ?? 'Admin';
    return Scaffold(
      backgroundColor: AppColors.orange,
      drawer: _buildAdminDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<DashboardStatsModel>(
            future: _statsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading dashboard',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(_errorMessage ?? snap.error.toString(),
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final stats = snap.data;
              if (stats == null) {
                return const Center(child: Text('No dashboard data available'));
              }
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(displayName),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(stats),
                        const SizedBox(height: 24),
                        const Text('Active contribution batches',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Live snapshot of approved claims',
                            style: TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 12),
                        _buildEmptyBatchesCard(),
                        const Divider(height: 40),
                        const Center(
                          child: Text('Quick access',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickAccessGrid(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---- Drawer (full admin menu, unchanged — open via edge swipe) ----
  Widget _buildAdminDrawer() {
    Widget tile(String title, [VoidCallback? onTap]) =>
        ListTile(title: Text(title), onTap: onTap ?? () { Navigator.pop(context); _goTo(title); });

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text('Admin Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          ExpansionTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Karyakarta Management'),
            children: [
              ListTile(
                title: const Text('Add Karyakarta'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddKaryakartaScreen()));
                },
              ),
              ListTile(
                title: const Text('View Karyakarta'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const KaryakartaListScreen()));
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.people_alt_outlined),
            title: const Text('Member Management'),
            children: [
              ListTile(
                title: const Text('Add Member'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMemberScreen()));
                },
              ),
              ListTile(
                title: const Text('View Members'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberListScreen()));
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.card_giftcard_outlined),
            title: const Text('Scheme Management'),
            children: [
              ListTile(
                title: const Text('Scheme Master'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemeMasterScreen()));
                },
              ),
              tile('Proposal Management'),
              ListTile(
                title: const Text('Enrollment Management'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EnrollmentListScreen()));
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Claim Management'),
            children: [
              ListTile(
                title: const Text('Claim Manage'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimManageScreen()));
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.attach_money_outlined),
            title: const Text('Collection Management'),
            children: [
              ListTile(
                title: const Text('Collection Manage'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionManageScreen()));
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Reports'),
            children: [
              tile('Collection Reports'), tile('Claim Reports'),
              tile('Member Reports'), tile('Karyakarta Reports'),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Account Manage'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountManageScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: const Text('Payment Manage'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentManageScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications & Logs'),
            onTap: () { Navigator.pop(context); _goTo('Notifications & Logs'); },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Admin Settings'),
            onTap: () { Navigator.pop(context); _goTo('Admin Settings'); },
          ),
        ],
      ),
    );
  }

  // ---- Header: no left menu icon, profile avatar on the right ----
  Widget _buildHeader(String displayName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 36), // balances the avatar so title stays centered
              const Expanded(
                child: Text('ADMIN PORTAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, letterSpacing: 1.2, fontSize: 13)),
              ),
              GestureDetector(
                onTap: _openProfile,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Suthar Samaj ERP',
              style: TextStyle(color: AppColors.headerTitle, fontWeight: FontWeight.bold, fontSize: 30)),
          const SizedBox(height: 6),
          Text(displayName, style: TextStyle(color: AppColors.headerSubtitle, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DashboardStatsModel stats) {
    final cards = [
      ('A', AppColors.green, AppColors.greenTint, '${stats.activeMembers}', 'Active members', 'Active Members'),
      ('S', AppColors.primary, AppColors.headerBg, '${stats.socialActivists}', 'Social activists', 'Social Activists'),
      ('P', AppColors.orange, AppColors.orangeTint, '${stats.pendingProposals}', 'Pending proposals', 'Pending Proposals'),
      ('₹', AppColors.red, AppColors.redTint, '₹${stats.todaysCollection.toStringAsFixed(2)}', "Today's collection", "Today's Collection"),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: cards.map((c) => _StatCard(
        icon: c.$1, iconBg: c.$2, cardBg: c.$3, value: c.$4, label: c.$5,
        onTap: () => _goTo(c.$6),
      )).toList(),
    );
  }

  Widget _buildEmptyBatchesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2)),
          ),
          const SizedBox(height: 16),
          Text('No active contribution batches currently.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final items = [
      (icon: Icons.people_alt_outlined, color: AppColors.primary, label: 'Manage members', dest: 'Manage Members'),
      (icon: Icons.card_giftcard_outlined, color: AppColors.green, label: 'Config masters', dest: 'Config Masters'),
      (icon: Icons.description_outlined, color: AppColors.orange, label: 'Claim manage', dest: 'Claim Manage'),
      (icon: Icons.attach_money_outlined, color: AppColors.red, label: 'Collection manage', dest: 'Collection Manage'),
      (icon: Icons.groups_outlined, color: AppColors.teal, label: 'Karyakarta manage', dest: 'Karyakarta manage'),
      (icon: Icons.how_to_reg_outlined, color: AppColors.blue, label: 'Scheme Enrollments', dest: 'Scheme Enrollments'),
      (icon: Icons.account_circle_outlined, color: AppColors.brown, label: 'Account manage', dest: 'Account Manage'),
      (icon: Icons.payments_outlined, color: AppColors.tealDark, label: 'Payment manage', dest: 'Payment Manage'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items.map((item) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (item.dest == 'Karyakarta manage') {
            _showKaryakartaOptions();
          } else if (item.dest == 'Manage Members') {
            _showMemberOptions();
          } else if (item.dest == 'Config Masters') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigMastersHubScreen()));
          } else if (item.dest == 'Scheme Enrollments') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EnrollmentListScreen()));
          } else if (item.dest == 'Claim Manage') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimManageScreen()));
          } else if (item.dest == 'Collection Manage') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionManageScreen()));
          } else if (item.dest == 'Account Manage') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountManageScreen()));
          } else if (item.dest == 'Payment Manage') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentManageScreen()));
          } else {
            _goTo(item.dest);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: item.color, width: 2)),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  // ---- Bottom nav: Home / Services / Reports / Profile ----
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.black54,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        // BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), activeIcon: Icon(Icons.people_alt), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), activeIcon: Icon(Icons.account_circle), label: 'Profile'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final Color iconBg, cardBg;
  final String value, label;
  final VoidCallback onTap;
  const _StatCard({required this.icon, required this.iconBg, required this.cardBg,
    required this.value, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            CircleAvatar(radius: 18, backgroundColor: iconBg,
                child: Text(icon, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}