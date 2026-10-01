import 'package:flutter/material.dart';

class MemberCardScreen extends StatelessWidget {
  final Map<String, dynamic> member;
  final String saCode;

  const MemberCardScreen({
    super.key,
    required this.member,
    required this.saCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Card'),
        backgroundColor: const Color(0xFF6A5AE0),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card, size: 80, color: Color(0xFF6A5AE0)),
            const SizedBox(height: 20),
            Text(
              'Member: ${member['full_name'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('SA Code: $saCode'),
            const SizedBox(height: 20),
            const Text('Member Card Screen - Coming Soon'),
          ],
        ),
      ),
    );
  }
}
