import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _identifierController.text.trim();
    if (value.isEmpty) {
      setState(() => _message = "Please enter your username or mobile number");
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });

    // TODO: wire this up to your actual reset-password API call.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _loading = false;
      _message = "If an account exists, reset instructions have been sent.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your username or mobile number and we'll help you reset your password.",
              style: TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _identifierController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                hintText: "Usercode or Mobile",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text("Submit"),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                style: const TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}