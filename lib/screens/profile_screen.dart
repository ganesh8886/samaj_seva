import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _profile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _api.getProfile();
    if (!mounted) return;
    setState(() {
      _profile = data;
      _loadingProfile = false;
    });
  }

  Future<void> _logout() async {
    final result = await _api.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          logoutMessage: (result['message'] ?? 'Logged out successfully').toString(),
        ),
      ),
          (route) => false,
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFCE9DE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout of the Portal?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.brown),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F6),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            children: [

          // Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [

                const CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 15),

                _loadingProfile
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(
                  (_profile?['name'] ?? _api.currentUser?['name'] ?? 'User')
                      .toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  (_profile?['role'] ?? _api.roleName ?? '').toString().isNotEmpty
                      ? "Role : ${(_profile?['role'] ?? _api.roleName)}"
                      : "",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _menuTile(
            Icons.lock_outline,
            "Change PIN",
                () {},
          ),

          _menuTile(
            Icons.language,
            "Change Language",
                () {},
          ),

              _menuTile(
                Icons.phone_android,
                "Mobile Number",
                    () {},
                trailing: Text(
                  (_profile?['mobile'] ?? _api.currentUser?['mobile'] ?? '').toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      // Icon(Icons.volunteer_activism, color: Colors.indigo),
                      Icon(Icons.volunteer_activism, color: AppColors.primary),
                      SizedBox(width: 16),

                      // Left side - Title only
                      Expanded(
                        child: Text(
                          "Sanstha Contact Details", // <-- charity / Sanstha name
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      SizedBox(width: 8),

                      // Right side - phone, district, pincode
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "9979776816", // contact number
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Changda, Gujarat - 385565", // district, state - pincode
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

          const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _confirmLogout,
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
            ],
          ),
        ),
    );
  }

  static Widget _menuTile(
      IconData icon,
      String title,
      VoidCallback onTap, {
        Widget? trailing,
      }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          // color: Colors.indigo,
          color: AppColors.primary,
        ),
        title: Text(title),
        trailing: trailing ??
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
        onTap: onTap,
      ),
    );
  }
}