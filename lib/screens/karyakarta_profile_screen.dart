import 'package:flutter/material.dart';
import 'package:samaj_seva_suthar/screens/web_view_screen.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

/// NEW SCREEN — matches "Karyakarta Profile & 360° Activity Hub" web page.
/// Opened from the list screen's "View Profile" button, passing the karyakarta id.
class KaryakartaProfileScreen extends StatefulWidget {
  final int id;
  const KaryakartaProfileScreen({super.key, required this.id});

  @override
  State<KaryakartaProfileScreen> createState() => _KaryakartaProfileScreenState();
}

class _KaryakartaProfileScreenState extends State<KaryakartaProfileScreen> {
  final _api = ApiService();
  late Future<Map<String, dynamic>> _future;
  int _tabIndex = 0;

  final _tabs = const [
    "Assigned Members",
    "Policies Enrolled",
    "Claims List",
    "Commission Ledger",
    "Collections Feed",
  ];
  /// Mints a real share-token for the PHP admin page (id card, certificate,
  /// or edit-profile form) and opens it in the WebView. Never passes
  /// `_api.authToken` (the login API token) into these URLs — those pages
  /// validate against a one-time `sss_shared_tokens` row, not the login token.
  Future<void> _openSecureWebView({
    required String docType, // 'karyakarta_id_card' | 'karyakarta_certificate' | 'karyakarta_edit'
    required String title,
    required String Function(String token) buildUrl,
    VoidCallback? onReturn,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final shareToken = await _api.getDocumentShareToken(
      docType: docType,
      recordId: widget.id.toString(),
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // close loader

    if (shareToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not generate a secure link. Please try again.')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewScreen(url: buildUrl(shareToken), title: title),
      ),
    );
    if (onReturn != null) onReturn();
    return result;
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }
  Future<Map<String, dynamic>> _load() => _api.getKaryakartaProfile(widget.id);

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  String _s(Map data, String key) => data[key]?.toString() ?? '-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(title: const Text("Karyakarta Profile & 360° Activity Hub")),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(children: [
                const SizedBox(height: 100),
                Center(child: Text("Failed to load profile: ${snap.error}")),
              ]);
            }
            final data = snap.data ?? {};
            final personal = Map<String, dynamic>.from(data['personal'] ?? {});
            final workingArea = Map<String, dynamic>.from(data['working_area'] ?? {});
            final samaj = Map<String, dynamic>.from(data['samaj'] ?? {});

            return ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _buildHeaderCard(data, personal, workingArea),
                const SizedBox(height: 14),
                _infoCard("1. Personal Info", Icons.person_outline, [
                  _kv("Full Name", _s(personal, 'full_name')),
                  _kv("Father Name", _s(personal, 'father_name')),
                  _kv("Gender & DOB", "${_s(personal, 'gender')} (${_s(personal, 'dob')})"),
                  _kv("Mobile (Login ID)", _s(personal, 'mobile')),
                  _kv("Aadhaar No", "[Aadhaar Redacted]"),
                  _kv("PAN Number", _s(personal, 'pan_no')),
                ]),
                const SizedBox(height: 12),
                _infoCard("2. Working Area & Address", Icons.location_on_outlined, [
                  _kv("State", _s(workingArea, 'state')),
                  _kv("District / Taluka", "${_s(workingArea, 'district')} / ${_s(workingArea, 'taluka')}"),
                  _kv("Village", _s(workingArea, 'village')),
                  _kv("PIN Code", _s(workingArea, 'pincode')),
                  _kv("Full Address", _s(workingArea, 'full_address')),
                ]),
                const SizedBox(height: 12),
                _infoCard("3. Samaj & System Data", Icons.account_balance_outlined, [
                  _kv("Gotra", _s(samaj, 'gotra')),
                  _kv("Occupation", _s(samaj, 'occupation')),
                  _kv("Education", _s(samaj, 'education')),
                  _kv("Date of Joining", _s(samaj, 'date_of_joining')),
                  _kv("Login Password", "••••••••"),
                ]),
                const SizedBox(height: 20),
                _buildTabSelector(),
                const SizedBox(height: 10),
                _buildTabContent(data),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- Header: name, SA code, status pill, action buttons ----
  Widget _buildHeaderCard(Map data, Map personal, Map workingArea) {
    final status = data['status']?.toString() ?? 'ACTIVE';
    final isActive = status.toUpperCase() == 'ACTIVE';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(_s(personal, 'full_name'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E7FB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(data['karyakarta_code']?.toString() ?? '-',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF6A5AE0), fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFDFF6EA) : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(status.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isActive ? const Color(0xFF16A085) : Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Text(
                      "Mobile: ${_s(personal, 'mobile')} | Area: ${_s(workingArea, 'village')} (${_s(workingArea, 'taluka')})",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _toggleStatus(isActive),
                icon: Icon(isActive ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
                    color: const Color(0xFF16A085)),
                label: Text(isActive ? "Disable" : "Enable"),
              ),
              OutlinedButton.icon(
                onPressed: () => _openSecureWebView(
                  docType: 'karyakarta_id_card',
                  title: "Identity Card",
                  buildUrl: (token) => ApiConfig.idCardUrl(widget.id, token: token),
                ),
                icon: const Icon(Icons.badge_outlined, color: Color(0xFF6A5AE0)),
                label: const Text("ID Card"),
              ),
              OutlinedButton.icon(
                onPressed: () => _openSecureWebView(
                  docType: 'karyakarta_certificate',
                  title: "Appointment Certificate",
                  buildUrl: (token) => ApiConfig.certificateUrl(widget.id, token: token),
                ),
                icon: const Icon(Icons.workspace_premium_outlined, color: Color(0xFFC97C0F)),
                label: const Text("Certificate"),
              ),
              FilledButton.icon(
                onPressed: () => _openSecureWebView(
                  docType: 'karyakarta_edit',
                  title: "Edit Karyakarta Profile",
                  buildUrl: (token) => ApiConfig.editKaryakartaUrl(widget.id, token: token),
                  onReturn: _refresh,
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text("Edit Profile"),
                style: FilledButton.styleFrom(backgroundColor: Colors.black87),
              ),
              IconButton(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Future<void> _toggleStatus(bool isActive) async {
    final newStatus = isActive ? 'inactive' : 'active';

    // Matches the web's "Confirm Action" dialog before changing status.
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Action"),
        content: Text(
            "Change Karyakarta status to ${newStatus.toUpperCase()}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6A5AE0)),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final res = await _api.updateKaryakartaStatus(widget.id.toString(), newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Status updated')),
      );
      if (res['success'] == true) _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Action"),
        content: const Text(
            "Are you sure you want to permanently delete this Karyakarta?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final res = await _api.deleteKaryakarta(widget.id.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Karyakarta deleted')),
      );
      if (res['success'] == true) Navigator.pop(context, true); // tell list screen to refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _infoCard(String title, IconData icon, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: const Color(0xFF6A5AE0)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          const Divider(height: 20),
          ...rows,
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // ---- 5-tab activity hub selector (Assigned Members / Policies / Claims / Commission / Collections) ----
  Widget _buildTabSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _tabIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_tabs[i]),
              selected: selected,
              selectedColor: const Color(0xFF6A5AE0),
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 12),
              onSelected: (_) => setState(() => _tabIndex = i),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> data) {
    final keys = ['assigned_members', 'policies', 'claims', 'commission_ledger', 'collections'];
    final list = (data[keys[_tabIndex]] as List?) ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_tabIndex + 1}. ${_tabs[_tabIndex]}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              OutlinedButton.icon(
                onPressed: () {}, // TODO: export current tab to Excel via API
                icon: const Icon(Icons.grid_on, size: 16, color: Color(0xFF16A085)),
                label: const Text("Excel"),
              ),
            ],
          ),
          const Divider(height: 20),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text("No ${_tabs[_tabIndex].toLowerCase()} yet.",
                    style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else
            Column(
              children: list.map<Widget>((item) {
                final m = Map<String, dynamic>.from(item as Map);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(m['name']?.toString() ?? m['title']?.toString() ?? '-'),
                  subtitle: Text(m['date']?.toString() ?? ''),
                  trailing: Text(m['amount']?.toString() ?? m['status']?.toString() ?? ''),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}