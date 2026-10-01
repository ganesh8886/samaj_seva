import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';
import 'new_proposal_screen.dart';

/// Scheme Proposals & Enrollments screen.
/// Uses ONLY the fields your backend actually returns from
/// GET /api/enrollments (see: id, proposal_no, member_name, member_code,
/// scheme_name, karyakarta_code, joining_fee, per_event_installment,
/// payment_mode, status, created_at).
///
/// Actions map 1:1 to the APIs you gave:
///  - Create      -> POST /api/enrollments            {member_id, scheme_id}
///  - View        -> GET  /admin/proposal_doc.php?id=&token=
///  - Dastavej    -> GET  /admin/policy_dastavej.php?id=&token=
///  - Share       -> /admin/policy_dastavej.php?id=&token=&auto_download=1
///  - Reject      -> PUT  /api/enrollments/{id}/reject
///  - Delete      -> DELETE /api/enrollments/{id}
class EnrollmentListScreen extends StatefulWidget {
  const EnrollmentListScreen({super.key});

  @override
  State<EnrollmentListScreen> createState() => _EnrollmentListScreenState();
}

class _EnrollmentListScreenState extends State<EnrollmentListScreen> {
  final _api = ApiService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _all = [];

  String _statusFilter = 'All';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _all = await _api.getEnrollmentsRaw();
    } catch (e) {
      _error = 'Failed to load enrollments: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _all.where((e) {
      final matchesStatus = _statusFilter == 'All' ||
          (e['status']?.toString().toLowerCase() == _statusFilter.toLowerCase());
      if (!matchesStatus) return false;
      if (q.isEmpty) return true;
      final haystack = [
        e['proposal_no'],
        e['member_name'],
        e['member_code'],
        e['scheme_name'],
        e['karyakarta_code'],
      ].map((x) => (x ?? '').toString().toLowerCase()).join(' ');
      return haystack.contains(q);
    }).toList();
  }

  // ---------------- helpers ----------------

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'submitted':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  String get _token => _api.authToken ?? '';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      // Skip canLaunchUrl() — it unreliably returns false on Android 11+
      // when the <queries> manifest entry is missing/misconfigured.
      // Try launching directly and only show the error on real failure.
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open link: $e')));
      }
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- actions ----------------

  void _viewProposal(int id) {
    final token = _token;
    if (token.isEmpty) {
      _snack('Not logged in');
      return;
    }
    _openUrl(ApiConfig.karyakartaEnrollmentProposalWebUrl(id.toString(), token));
  }

  void _viewDastavej(int id) {
    final token = _token;
    if (token.isEmpty) {
      _snack('Not logged in');
      return;
    }
    _openUrl(ApiConfig.karyakartaEnrollmentDastavejWebUrl(id.toString(), token));
  }

  Future<void> _shareDastavej(int id) async {
    final token = _token;
    if (token.isEmpty) {
      _snack('Not logged in');
      return;
    }
    final url = ApiConfig.karyakartaEnrollmentDastavejShareUrl(id.toString(), token);
    await Clipboard.setData(ClipboardData(text: url));
    _snack('Share link copied to clipboard');
  }

  Future<void> _confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete enrollment?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final res = await _api.deleteEnrollment(id.toString());
    _snack(res['message']?.toString() ?? (res['success'] == true ? 'Deleted' : 'Delete failed'));
    if (res['success'] == true) _load();
  }

  Future<void> _rejectDialog(int id) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject enrollment'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, reasonCtrl.text.trim()),
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    final res = await _api.rejectEnrollment(id.toString(), reason);
    _snack(res['message']?.toString() ?? (res['success'] == true ? 'Rejected' : 'Reject failed'));
    if (res['success'] == true) _load();
  }

  Future<void> _openCreateProposalSheet() async {
    List<Map<String, dynamic>> members = [];
    List<Map<String, dynamic>> schemes = [];
    bool loadingOptions = true;
    int? selectedMemberId;
    int? selectedSchemeId;
    bool submitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          if (loadingOptions) {
            Future.wait([_api.getMembersRaw(), _api.getSchemesRaw()]).then((results) {
              members = results[0];
              schemes = results[1];
              loadingOptions = false;
              if (ctx.mounted) setSheetState(() {});
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: loadingOptions
                ? const SizedBox(
                height: 160, child: Center(child: CircularProgressIndicator()))
                : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Proposal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Member',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedMemberId,
                  items: members.map((m) {
                    final id = int.tryParse(m['id'].toString()) ?? 0;
                    final name = m['full_name'] ?? m['name'] ?? 'Member';
                    final code = m['member_code'] ?? '';
                    return DropdownMenuItem(
                      value: id,
                      child: Text('$name ${code.toString().isNotEmpty ? "($code)" : ""}'),
                    );
                  }).toList(),
                  onChanged: (v) => setSheetState(() => selectedMemberId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Scheme',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedSchemeId,
                  items: schemes.map((s) {
                    final id = int.tryParse(s['id'].toString()) ?? 0;
                    final name = s['scheme_name'] ?? s['name'] ?? 'Scheme';
                    return DropdownMenuItem(value: id, child: Text(name.toString()));
                  }).toList(),
                  onChanged: (v) => setSheetState(() => selectedSchemeId = v),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (selectedMemberId == null ||
                        selectedSchemeId == null ||
                        submitting)
                        ? null
                        : () async {
                      setSheetState(() => submitting = true);
                      final res = await _api.createEnrollment({
                        'member_id': selectedMemberId,
                        'scheme_id': selectedSchemeId,
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      _snack(res['message']?.toString() ??
                          (res['success'] == true
                              ? 'Proposal submitted successfully'
                              : 'Failed to submit proposal'));
                      if (res['success'] == true) _load();
                    },
                    child: submitting
                        ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Submit Proposal'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheme Proposals & Enrollments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const NewProposalScreen()),
          );
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Proposal'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search proposal, member, scheme...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _statusFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'submitted', child: Text('Submitted')),
                      DropdownMenuItem(value: 'approved', child: Text('Approved')),
                      DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                      DropdownMenuItem(value: 'closed', child: Text('Closed')),
                    ],
                    onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Container(
                width: double.infinity,
                color: Colors.red.shade50,
                padding: const EdgeInsets.all(8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('No enrollments found'))
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                itemCount: _filtered.length,
                itemBuilder: (_, i) => _buildCard(_filtered[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> e) {
    final id = int.tryParse(e['id'].toString()) ?? 0;
    final status = e['status']?.toString() ?? '-';
    final proposalNo = e['proposal_no']?.toString() ?? '-';
    final memberName = e['member_name']?.toString() ?? '-';
    final memberCode = e['member_code']?.toString();
    final schemeName = e['scheme_name']?.toString() ?? '-';
    final karyakartaCode = e['karyakarta_code']?.toString();
    final joiningFee = _num(e['joining_fee']);
    final perEvent = _num(e['per_event_installment']);
    final createdAt = e['created_at']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(proposalNo,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                        color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'reject') _rejectDialog(id);
                    if (v == 'delete') _confirmDelete(id);
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(value: 'reject', child: Text('Reject')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('$memberName${memberCode != null ? " ($memberCode)" : ""}',
                style: const TextStyle(fontSize: 13)),
            Text(schemeName, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Karyakarta: ${karyakartaCode ?? '-'}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const Spacer(),
                Text(createdAt, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Joining Fee: ₹${joiningFee.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                Text('Per-Event: ₹${perEvent.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _viewProposal(id),
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('Proposal'),
                ),
                TextButton.icon(
                  onPressed: () => _viewDastavej(id),
                  icon: const Icon(Icons.file_present_outlined, size: 16),
                  label: const Text('Dastavej'),
                ),
                TextButton.icon(
                  onPressed: () => _shareDastavej(id),
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}