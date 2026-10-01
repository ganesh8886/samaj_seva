import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CommissionMasterScreen extends StatefulWidget {
  const CommissionMasterScreen({super.key});

  @override
  State<CommissionMasterScreen> createState() => _CommissionMasterScreenState();
}

class _CommissionMasterScreenState extends State<CommissionMasterScreen> {
  final _api = ApiService();
  bool _loading = true;
  List<Map<String, dynamic>> _rules = [];

  final _rateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _category = 'regular';
  String _calcType = 'fixed';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rules = await _api.getCommissionRules();
    setState(() {
      _rules = rules;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_rateCtrl.text.trim().isEmpty) return;
    final res = await _api.addCommissionRule({
      "category": _category,
      "calculation_type": _calcType,
      "rate": _rateCtrl.text.trim(),
      "notes": _notesCtrl.text.trim(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Saved')));
    if (res['success'] == true) {
      _rateCtrl.clear();
      _notesCtrl.clear();
      _load();
    }
  }

  Future<void> _delete(Map<String, dynamic> rule) async {
    final res = await _api.deleteCommissionRule(rule['id'].toString());
    if (res['success'] == true) _load();
  }

  @override
  void dispose() {
    _rateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commission Master & Incentive Rules')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Define Commission Rule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Commission Category', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'regular', child: Text('Regular (Standard Rule per policy)')),
              DropdownMenuItem(value: 'offer', child: Text('Promotional Offer')),
              DropdownMenuItem(value: 'special', child: Text('Karyakarta-specific Special')),
            ],
            onChanged: (v) => setState(() => _category = v ?? 'regular'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _calcType,
            decoration: const InputDecoration(labelText: 'Calculation Type', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'fixed', child: Text('Fixed (₹ / Policy)')),
              DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
            ],
            onChanged: (v) => setState(() => _calcType = v ?? 'fixed'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rateCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Commission Rate (e.g. 100 or 15)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Rule Description / Notes', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _save, child: const Text('+ Save Commission Rule')),
          ),
          const Divider(height: 40),
          Text('Commission Rules Ledger (${_rules.length} Configured)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          if (_rules.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 20), child: Center(child: Text('No rules configured yet')))
          else
            ..._rules.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text('${r['category'] ?? ''} • ${r['rate'] ?? ''}'),
                subtitle: Text(r['notes']?.toString() ?? ''),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(r)),
              ),
            )),
        ],
      ),
    );
  }
}