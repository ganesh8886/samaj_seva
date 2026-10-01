import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/wave_clipper.dart';
import '../utils/dialogs.dart';
import 'admin_dashboard_screen.dart';
import 'otp_screen.dart';

/// isSetup = true  -> asks for PIN + Confirm PIN (first time)
/// isSetup = false -> asks for PIN only (returning user, "Enter PIN" screen)
class PinScreen extends StatefulWidget {
  final String usercode;
  final String? name;
  final bool isSetup;
  final bool forgotPin; // true only when isSetup came from the Forgot-PIN flow
  const PinScreen({
    super.key,
    required this.usercode,
    this.name,
    this.isSetup = false,
    this.forgotPin = false,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  final _api = ApiService();
  bool _obscurePin = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  // static const Color kNavy = Color(0xFF0D3B66);
  // static const Color kOrange = Color(0xFFEE8B24);
  static const Color kNavy = AppColors.primary;
  static const Color kOrange = AppColors.orange;

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.length != 6) {
      showErrorDialog(context, "Enter a 6 digit PIN");
      return;
    }
    if (widget.isSetup && pin != _confirmController.text.trim()) {
      showErrorDialog(context, "PIN and Confirm PIN do not match");
      return;
    }
    setState(() => _loading = true);
    try {
      Map<String, dynamic> data;
      if (widget.isSetup) {
        data = widget.forgotPin
            ? await _api.resetPin(widget.usercode, pin)   // Forgot-PIN flow
            : await _api.setPin(widget.usercode, pin);    // First-time setup
      } else {
        data = await _api.pinLogin(widget.usercode, pin); // Normal returning-user login
      }

      if (!mounted) return;
      if (data['success'] != true) {
        showErrorDialog(context, data['message'] ??
            (widget.isSetup ? "Could not save PIN. Please try again." : "Entered PIN is wrong"));
        return;
      }

      if (widget.isSetup) {
        showSuccessDialog(
          context,
          widget.forgotPin ? "PIN Reset Success!" : "PIN Set Success!",
          onClose: () {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => PinScreen(usercode: widget.usercode, name: widget.name, isSetup: false)));
          },
        );
      } else {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, widget.isSetup
            ? "Could not save PIN. Please try again." : "Entered PIN is wrong");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _pinDecoration({
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      prefixIcon: const Icon(Icons.lock_outline, color: kNavy),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      counterText: "",
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: onToggle,
      ),
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
        borderSide: const BorderSide(color: kNavy, width: 1.4),
      ),
    );
  }

  // void _onResetPin() {
  //   // TODO: wire this up to your real reset-pin API.

// NEW — actually triggers the forgot-pin OTP send first
Future<void> _onResetPin() async {
  try {
    await _api.sendForgotPinOtp(widget.usercode);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => OtpScreen(usercode: widget.usercode, mode: OtpMode.forgotPin)));
  } catch (e) {
    if (mounted) showErrorDialog(context, "Could not send OTP. Try again.");
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
              // Wave header with logo overlapping the edge — same as Sign In
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      height: 230,
                      width: double.infinity,
                      color: kNavy,
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
              const SizedBox(height: 70), // clears the overlapping logo

              // Branding
              const Center(
                child: Text(
                  "SUTHAR SAMAJ SEVA",
                  style: TextStyle(
                    color: kOrange,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    fontSize: 16,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  "Digital Platform",
                  style: TextStyle(color: kOrange, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.isSetup) ...[
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Welcome!",
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.usercode,
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.name != null && widget.name!.isNotEmpty)
                              Text(
                                widget.name!,
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    const Text(
                      "Enter PIN",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF2A2E3B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pinController,
                      obscureText: _obscurePin,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: _pinDecoration(
                        hint: "6 Digit PIN",
                        obscure: _obscurePin,
                        onToggle: () =>
                            setState(() => _obscurePin = !_obscurePin),
                      ),
                    ),

                    if (widget.isSetup) ...[
                      const SizedBox(height: 4),
                      const Text(
                        "Confirm PIN",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF2A2E3B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: _pinDecoration(
                          hint: "Confirm 6 digit PIN",
                          obscure: _obscureConfirm,
                          onToggle: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: widget.isSetup ? double.infinity : 160,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            widget.isSetup ? "NEXT" : "LOGIN",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (!widget.isSetup) ...[
                      const SizedBox(height: 14),
                      Center(
                        child: TextButton(
                          onPressed: _onResetPin,
                          child: const Text(
                            "Reset PIN?",
                            style: TextStyle(
                              color: Color(0xFF1E5FCC),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
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