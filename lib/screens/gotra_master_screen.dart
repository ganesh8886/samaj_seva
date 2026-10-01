import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GotraMasterScreen extends StatefulWidget {
  const GotraMasterScreen({super.key});

  @override
  State<GotraMasterScreen> createState() => _GotraMasterScreenState();
}

class _GotraMasterScreenState extends State<GotraMasterScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  List<Map<String, dynamic>> _gotras = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _api.getGotras();
    setState(() {
      _gotras = list;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _gotras;
    return _gotras.where((g) =>
    (g['name_en']?.toString().toLowerCase().contains(q) ?? false) ||
        (g['name_hi']?.toString().toLowerCase().contains(q) ?? false)).toList();
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final enCtrl = TextEditingController(text: existing?['name_en']?.toString() ?? '');
    final hiCtrl = TextEditingController(text: existing?['name_hi']?.toString() ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add New Gotra' : 'Edit Gotra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: enCtrl, decoration: const InputDecoration(labelText: 'Gotra Name (English)')),
            const SizedBox(height: 10),
            TextField(controller: hiCtrl, decoration: const InputDecoration(labelText: 'Gotra Name (Hindi/Gujarati)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final res = existing == null
                  ? await _api.addGotra(enCtrl.text.trim(), hiCtrl.text.trim())
                  : await _api.updateGotra(existing['id'].toString(), enCtrl.text.trim(), hiCtrl.text.trim());
              if (!ctx.mounted) return;
              Navigator.pop(ctx, res['success'] == true);
            },
            child: const Text('Save Gotra'),
          ),
        ],
      ),
    );

    if (saved == true) _load();
  }

  Future<void> _delete(Map<String, dynamic> gotra) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Gotra?'),
        content: Text('Remove "${gotra['name_en']}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    final res = await _api.deleteGotra(gotra['id'].toString());
    if (res['success'] == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gotra Master (${_gotras.length} Total)'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _openForm()),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by English or Hindi name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final g = _filtered[i];
                return ListTile(
                  title: Text(g['name_en']?.toString() ?? ''),
                  subtitle: Text(g['name_hi']?.toString() ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _openForm(existing: g)),
                      IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _delete(g)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}