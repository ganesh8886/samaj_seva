import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show ClientException;
import 'package:samaj_seva_suthar/screens/pin_screen.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/wave_clipper.dart';
import '../utils/dialogs.dart';
import 'otp_screen.dart';
import 'admin_dashboard_screen.dart';
import 'karyakarta_dashboard_screen.dart' hide KaryakartaSession;
import '../models/karyakarta_session.dart';
import 'member_dashboard_screen.dart' show MemberDashboardScreen;
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? logoutMessage;

  const LoginScreen({super.key, this.logoutMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
const _networkErrorMessage =
    'Cannot reach the server. Check that your phone is on the same Wi-Fi network as the server, and that the server is running.';

bool _isNetworkError(Map<String, dynamic> data) {
  final msg = (data['message'] ?? '').toString().toLowerCase();
  return msg.contains('no route to host') ||
      msg.contains('socketexception') ||
      msg.contains('connection refused') ||
      msg.contains('network is unreachable') ||
      msg.contains('failed host lookup');
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.logoutMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.logoutMessage!)),
        );
      });
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _userController.text.trim();
    final password = _passController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = "Please enter username and password");
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> data = {"success": false};
      final upperUser = username.toUpperCase();

      // 1. Direct Karyakarta routing if username begins with SA
      if (upperUser.startsWith('SA')) {
        data = await _api.karyakartaLogin(username, password);
      }
      // 2. Direct Member routing if username begins with MEM
      else if (upperUser.startsWith('MEM')) {
        data = await _api.memberLogin(username, password);
      }
      // 3. General login (mobile number or username)
      else {
        // Try Karyakarta first
        data = await _api.karyakartaLogin(username, password);

        // If the failure was a network problem, stop immediately — trying
        // admin/member logins will just fail the same way and the final
        // error message would misleadingly say "Invalid credentials".
        if (_isNetworkError(data)) {
          if (mounted) setState(() => _error = _networkErrorMessage);
          return;
        }

        // Stop if the server is rate-limiting us
        if ((data['message'] ?? '').toString().toLowerCase().contains('too many')) {
          if (mounted) setState(() => _error = data['message'].toString());
          return;
        }

        // If not a Karyakarta, try Admin
        if (data['success'] != true) {
          try {
            data = await _api.login(username, password);
          } on SocketException {
            if (mounted) setState(() => _error = _networkErrorMessage);
            return;
          } catch (e) {
            data = {"success": false, "message": "Login failed: $e"};
          }
        }

        // If neither, try Member
        if (data['success'] != true) {
          try {
            data = await _api.memberLogin(username, password);
          } on SocketException {
            if (mounted) setState(() => _error = _networkErrorMessage);
            return;
          } catch (e) {
            data = {"success": false, "message": data['message'] ?? "Invalid credentials"};
          }
        }
      }

      if (!mounted) return;
      if (data['success'] != true) {
        setState(() => _error = data['message'] ?? "Invalid username or password");
        return;
      }

      // Navigate based on logged-in role
      final role = _api.roleName;
      if (role == AppRoles.karyakarta || upperUser.startsWith('SA')) {
        final user = _api.currentUser ?? {};
        KaryakartaSession.saCode = (user['karyakarta_code'] ?? user['sa_code'] ?? username).toString();
        KaryakartaSession.fullName = (user['full_name'] ?? user['name'] ?? 'Karyakarta').toString();
        KaryakartaSession.mobile = (user['mobile'] ?? user['phone'] ?? '').toString();
        KaryakartaSession.village = (user['village'] ?? user['working_area'] ?? '').toString();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KaryakartaDashboardScreen()),
        );
      } else if (role == AppRoles.member || upperUser.startsWith('MEM')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MemberDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      setState(() => _error = "Login failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      height: 230,
                      width: double.infinity,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              const Center(
                child: Text(
                  "SUTHAR SAMAJ SEVA",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    fontSize: 16,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  "Digital Platform",
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Username",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF2A2E3B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _userController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primary),
                        hintText: "Enter Usercode or Mobile",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF2A2E3B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _passController,
                            obscureText: _obscurePassword,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                              hintText: "Enter Password",
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  "NEXT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: AppColors.rejected),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: AppColors.rejected, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Need help? Contact support",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}