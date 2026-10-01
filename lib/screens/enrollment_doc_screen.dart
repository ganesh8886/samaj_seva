import 'package:flutter/material.dart';

class EnrollmentDocScreen extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  final bool isPolicy;
  final String saCode;
  final String? saName;
  final Map<String, dynamic> member;
  final VoidCallback? onPdf;

  const EnrollmentDocScreen({
    super.key,
    required this.enrollment,
    required this.isPolicy,
    required this.saCode,
    this.saName,
    required this.member,
    this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isPolicy ? 'Policy Document' : 'Proposal Form'),
        backgroundColor: const Color(0xFF6A5AE0),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 80, color: Color(0xFF6A5AE0)),
            const SizedBox(height: 20),
            Text(
              'Proposal: ${enrollment['proposal_no'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('SA Code: $saCode'),
            const SizedBox(height: 20),
            const Text('Enrollment Document Screen - Coming Soon'),
            if (onPdf != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onPdf,
                child: const Text('View PDF'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
