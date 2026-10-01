import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/wave_clipper.dart';
import '../utils/dialogs.dart';
import 'pin_screen.dart';

class OtpScreen extends StatefulWidget {
  final String usercode;
  final OtpMode mode;
  const OtpScreen({super.key, required this.usercode, required this.mode});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}
enum OtpMode { firstTimeSetup, forgotPin }
class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _api = ApiService();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  static const Color kNavy = AppColors.primary;
  static const Color kBlueStart = AppColors.primary;
  static const Color kBlueEnd = AppColors.primary;
  static const Color kOrange = Color(0xFFC97C0F);

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _error = "Please enter OTP");
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = widget.mode == OtpMode.firstTimeSetup
          ? await _api.verifyLoginOtp(widget.usercode, otp)
          : await _api.verifyForgotPinOtp(widget.usercode, otp);

      if (!mounted) return;
      if (data['success'] == true) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PinScreen(
            usercode: widget.usercode,
            isSetup: true,
            forgotPin: widget.mode == OtpMode.forgotPin,
          ),
        ));
      } else {
        showErrorDialog(context, data['message'] ?? "OTP verification failed");
      }
    } catch (e) {
      if (mounted) showErrorDialog(context, "Entered OTP is wrong");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      prefixIcon: const Icon(Icons.lock_outline, color: kBlueStart),
      hintText: "Enter OTP",
      hintStyle: const TextStyle(color: Colors.grey),
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
      filled: true,
      fillColor: const Color(0xFFF4F6FA),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kBlueStart, width: 1.4),
      ),
    );
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
              // Wave header + overlapping logo, same as reference design
              Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      height: 210,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [kBlueStart, kBlueEnd],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 130,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 82,
                            height: 82,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 56),
              // Branding
              const Center(
                child: Text(
                  "SUTHAR SAMAJ SEVA",
                  style: TextStyle(
                    // color: Colors.orange,
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
                  // style: TextStyle(color: Colors.orange, fontSize: 12),
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Body content sits directly on white, like the reference
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Verify OTP",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: kNavy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        "Sent to ${widget.usercode}",
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      "OTP",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF2A2E3B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Field + button in one row, like the reference "Sign In" screen
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _otpController,
                            obscureText: _obscure,
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _verify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kOrange,
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                                : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_forward,
                                    size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  "NEXT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Text(
                      "OTP has been sent by SMS/WhatsApp to your registered mobile.",
                      style: TextStyle(color: AppColors.success, fontSize: 12),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 16, color: AppColors.rejected),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                  color: AppColors.rejected, fontSize: 13),
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