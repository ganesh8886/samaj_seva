import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import '../services/api_service.dart';

class SchemeMasterScreen extends StatefulWidget {
  const SchemeMasterScreen({super.key});
  @override
  State<SchemeMasterScreen> createState() => _SchemeMasterScreenState();
}
class _SchemeMasterScreenState extends State<SchemeMasterScreen> {
  final _api = ApiService();
  late Future<List<SchemeModel>> _schemesFuture;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _schemesFuture = _api.getSchemes();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async =>
      setState(() => _schemesFuture = _api.getSchemes());

  Future<void> _showAddSchemeSheet() async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final chargeCtrl = TextEditingController(text: "5.0");
    final minCtrl = TextEditingController(text: "100");
    final maxCtrl = TextEditingController(text: "10000");
    String schemeType = "Individual";

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('New Scheme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Scheme name')),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Short code')),
              TextField(controller: chargeCtrl, decoration: const InputDecoration(labelText: 'Management charge %'), keyboardType: TextInputType.number),
              TextField(controller: minCtrl, decoration: const InputDecoration(labelText: 'Min members'), keyboardType: TextInputType.number),
              TextField(controller: maxCtrl, decoration: const InputDecoration(labelText: 'Max members'), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await _api.createScheme({
                      "scheme_name": nameCtrl.text.trim(),
                      "short_code": codeCtrl.text.trim(),
                      "scheme_type": schemeType,
                      "description": "",
                      "management_charge_percent": double.tryParse(chargeCtrl.text) ?? 0,
                      "min_members": int.tryParse(minCtrl.text) ?? 0,
                      "max_members": int.tryParse(maxCtrl.text) ?? 0,
                    });
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message']?.toString() ?? (result['success'] == true ? 'Scheme created' : 'Failed to create scheme'))),
                    );
                    if (result['success'] == true) _refresh();
                  },
                  child: const Text('Create Scheme'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _showEditSchemeSheet(SchemeModel s) async {
    final nameCtrl = TextEditingController(text: s.schemeName);
    final codeCtrl = TextEditingController(text: s.shortCode);
    final chargeCtrl = TextEditingController(text: s.managementChargePercent.toString());
    String schemeType = s.schemeType;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Scheme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Scheme name')),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Short code')),
              TextField(controller: chargeCtrl, decoration: const InputDecoration(labelText: 'Management charge %'), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await _api.updateScheme(s.id as String, {
                      "scheme_name": nameCtrl.text.trim(),
                      "short_code": codeCtrl.text.trim(),
                      "scheme_type": schemeType,
                      "management_charge_percent": double.tryParse(chargeCtrl.text) ?? 0,
                    });
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message']?.toString() ?? (result['success'] == true ? 'Scheme updated' : 'Failed to update scheme'))),
                    );
                    if (result['success'] == true) _refresh();
                  },
                  child: const Text('Update Scheme'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheme Master')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSchemeSheet,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search schemes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchCtrl.clear(),
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<SchemeModel>>(
                future: _schemesFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data ?? [];
                  final schemes = _searchQuery.isEmpty
                      ? all
                      : all.where((s) =>
                  s.schemeName.toLowerCase().contains(_searchQuery) ||
                      s.shortCode.toLowerCase().contains(_searchQuery)).toList();

                  if (schemes.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(child: Text(_searchQuery.isEmpty ? 'No schemes found' : 'No matching schemes')),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: schemes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final s = schemes[i];
                      return Card(
                        child: ListTile(
                          title: Text(s.schemeName),
                          subtitle: Text('${s.shortCode} • ${s.schemeType} • ${s.managementChargePercent}%'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${s.minMembers}-${s.maxMembers}'),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditSchemeSheet(s),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}