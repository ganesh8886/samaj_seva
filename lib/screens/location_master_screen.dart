import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LocationMasterScreen extends StatefulWidget {
  const LocationMasterScreen({super.key});

  @override
  State<LocationMasterScreen> createState() => _LocationMasterScreenState();
}

class _LocationMasterScreenState extends State<LocationMasterScreen> {
  final _api = ApiService();

  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];

  Map<String, dynamic>? _selectedState;
  Map<String, dynamic>? _selectedDistrict;

  bool _loadingStates = true;
  bool _loadingDistricts = false;
  bool _loadingTalukas = false;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    setState(() => _loadingStates = true);
    final list = await _api.getStates();
    setState(() {
      _states = list;
      _loadingStates = false;
    });
  }

  Future<void> _selectState(Map<String, dynamic> state) async {
    setState(() {
      _selectedState = state;
      _selectedDistrict = null;
      _talukas = [];
      _loadingDistricts = true;
    });
    final list = await _api.getDistricts(state['id'].toString());
    setState(() {
      _districts = list;
      _loadingDistricts = false;
    });
  }

  Future<void> _selectDistrict(Map<String, dynamic> district) async {
    setState(() {
      _selectedDistrict = district;
      _loadingTalukas = true;
    });
    final list = await _api.getTalukas(district['id'].toString());
    setState(() {
      _talukas = list;
      _loadingTalukas = false;
    });
  }

  Future<void> _addState() async {
    final name = await _promptText('Add New State', 'e.g. Gujarat, Rajasthan');
    if (name == null || name.trim().isEmpty) return;
    final res = await _api.addState(name.trim());
    _snack(res);
    if (res['success'] == true) _loadStates();
  }

  Future<void> _addDistrict() async {
    if (_selectedState == null) return;
    final name = await _promptText('Add New District', 'e.g. Ahmedabad');
    if (name == null || name.trim().isEmpty) return;
    final res = await _api.addDistrict(_selectedState!['id'].toString(), name.trim());
    _snack(res);
    if (res['success'] == true) _selectState(_selectedState!);
  }

  Future<void> _addTaluka() async {
    if (_selectedDistrict == null) return;
    final name = await _promptText('Add New Taluka', 'e.g. Daskroi');
    if (name == null || name.trim().isEmpty) return;
    final res = await _api.addTaluka(_selectedDistrict!['id'].toString(), name.trim());
    _snack(res);
    if (res['success'] == true) _selectDistrict(_selectedDistrict!);
  }

  void _snack(Map<String, dynamic> res) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message']?.toString() ?? (res['success'] == true ? 'Saved' : 'Failed'))),
    );
  }

  Future<String?> _promptText(String title, String hint) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: ctrl, decoration: InputDecoration(hintText: hint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Master (State, District, Taluka)')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _column('States', _loadingStates, _states, _selectedState, _selectState, _addState,
                labelKey: 'name')),
            const SizedBox(width: 10),
            Expanded(child: _column('Districts', _loadingDistricts, _districts, _selectedDistrict, _selectDistrict,
                _selectedState == null ? null : _addDistrict, labelKey: 'name')),
            const SizedBox(width: 10),
            Expanded(child: _column('Talukas', _loadingTalukas, _talukas, null, (_) {},
                _selectedDistrict == null ? null : _addTaluka, labelKey: 'name')),
          ],
        ),
      ),
    );
  }

  Widget _column(
      String title,
      bool loading,
      List<Map<String, dynamic>> items,
      Map<String, dynamic>? selected,
      void Function(Map<String, dynamic>) onTap,
      VoidCallback? onAdd, {
        required String labelKey,
      }) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add, size: 18), onPressed: onAdd),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 400,
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? const Center(child: Text('No data', style: TextStyle(fontSize: 12)))
                : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final isSelected = selected != null && selected['id'] == item['id'];
                return ListTile(
                  dense: true,
                  tileColor: isSelected ? Colors.deepPurple.shade50 : null,
                  title: Text(item[labelKey]?.toString() ?? ''),
                  onTap: () => onTap(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}