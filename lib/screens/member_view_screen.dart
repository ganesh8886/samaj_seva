import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // NOTE: uses url_launcher — tell me if you already have an in-app WebView screen for cards instead
import '../models/member_model.dart';
import '../models/karyakarta_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';
import 'add_member_screen.dart';

class MemberViewScreen extends StatefulWidget {
  final int memberId;
  const MemberViewScreen({super.key, required this.memberId});

  @override
  State<MemberViewScreen> createState() => _MemberViewScreenState();
}

class _MemberViewScreenState extends State<MemberViewScreen> {
  final _api = ApiService();
  late Future<MemberModel?> _future;
  List<KaryakartaModel> _karyakartas = [];
  bool _changed = false; // tracks if edit/hold/delete happened, to refresh the list on pop

  @override
  void initState() {
    super.initState();
    _future = _load();
    _api.getKaryakartas().then((list) {
      if (mounted) setState(() => _karyakartas = list);
    });
  }

  Future<MemberModel?> _load() => _api.getMemberById(widget.memberId.toString());

  Future<void> _refresh() async {
    setState(() => _future = _load());
  }

  String _karyakartaName(int id) {
    final match = _karyakartas.where((k) => k.id == id);
    return match.isEmpty ? '-' : match.first.fullName;
  }

  Future<void> _openCard(String type) async {
    final url = ApiConfig.karyakartaMemberPvcCardWebUrl(
      widget.memberId.toString(),
      _api.authToken ?? '',
      type: type,
    );
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open $type')));
    }
  }

  Future<void> _editMember() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddMemberScreen(editMemberId: widget.memberId)),
    );
    if (result == true) {
      _changed = true;
      _refresh();
    }
  }

  Future<void> _toggleHold(MemberModel m) async {
    final newStatus = m.status.toUpperCase() == 'ACTIVE' ? 'inactive' : 'active';
    final res = await _api.toggleMemberStatus(widget.memberId.toString(), newStatus);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message']?.toString() ?? 'Status updated')),
    );
    if (res['success'] == true) {
      _changed = true;
      _refresh();
    }
  }

  Future<void> _resetPassword() async {
    final ctrl = TextEditingController();
    final newPassword = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'New Portal Password', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Reset')),
        ],
      ),
    );
    if (newPassword == null || newPassword.isEmpty) return;
    final res = await _api.updateMember(widget.memberId.toString(), {'portal_password': newPassword});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message']?.toString() ?? (res['success'] == true ? 'Password reset' : 'Failed to reset password'))),
    );
  }

  Future<void> _deleteMember() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: const Text('This cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final res = await _api.deleteMember(widget.memberId.toString());
    if (!mounted) return;
    if (res['success'] == true) {
      Navigator.pop(context, true); // pop back to list, tell it to refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Failed to delete member')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Member 360° Profile & Activity Hub')),
        body: FutureBuilder<MemberModel?>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final m = snap.data;
            if (m == null) {
              return const Center(child: Text('Member not found'));
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(m),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(onPressed: () => _openCard('id_card'), icon: const Icon(Icons.badge_outlined, size: 16), label: const Text('ID Card')),
                      OutlinedButton.icon(onPressed: () => _openCard('certificate'), icon: const Icon(Icons.workspace_premium_outlined, size: 16), label: const Text('Certificate')),
                      OutlinedButton.icon(onPressed: () => _toggleHold(m), icon: const Icon(Icons.pause_circle_outline, size: 16), label: Text(m.status.toUpperCase() == 'ACTIVE' ? 'Hold' : 'Activate')),
                      OutlinedButton.icon(onPressed: _resetPassword, icon: const Icon(Icons.lock_reset, size: 16), label: const Text('Reset Password')),
                      ElevatedButton.icon(onPressed: _editMember, icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit Profile')),
                      IconButton(onPressed: _deleteMember, icon: const Icon(Icons.delete_outline, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _infoCard('1. Personal Information', {
                    'Full Name': m.fullName,
                    'Gotra': m.gotra,
                    'Gender & DOB': '${m.gender} (${m.dob})',
                    'Mobile No': m.mobile,
                    'Aadhaar No': m.aadhaarNo.isEmpty ? '-' : '••••••••${m.aadhaarNo.length >= 4 ? m.aadhaarNo.substring(m.aadhaarNo.length - 4) : m.aadhaarNo}',
                    'Member ID': m.memberId.isEmpty ? '${m.id}' : m.memberId,
                  }),
                  const SizedBox(height: 12),
                  _infoCard('2. Family & Nominee Details', {
                    'Father Name': m.fatherName,
                    'Mother Name': m.motherName,
                    'Husband / Guardian': m.husbandName.isNotEmpty ? m.husbandName : m.guardianName,
                    'Nominee Name': m.nomineeName,
                    'Nominee Relation': m.nomineeRelation,
                  }),
                  const SizedBox(height: 12),
                  _infoCard('3. Address & Tagged SA Code', {
                    'State & District': '${m.state} / ${m.district}',
                    'Taluka & Village': '${m.taluka} / ${m.village}',
                    'PIN Code': m.pincode,
                    'Tagged Karyakarta': '${m.karyakartaCode} (${_karyakartaName(m.karyakartaId)})',
                    'Joined Date': m.createdAt,
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(MemberModel m) {
    return Row(
      children: [
        Expanded(
          child: Text(m.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Chip(
          label: Text('ID: ${m.memberId.isEmpty ? m.id : m.memberId}'),
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(width: 8),
        Chip(
          label: Text(m.status, style: const TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: m.status.toUpperCase() == 'ACTIVE' ? Colors.green : Colors.orange,
        ),
      ],
    );
  }

  Widget _infoCard(String title, Map<String, String> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          ...rows.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(color: Colors.black54)),
                Flexible(child: Text(e.value.isEmpty ? '-' : e.value, textAlign: TextAlign.right)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}