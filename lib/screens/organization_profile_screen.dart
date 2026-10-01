import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrganizationProfileScreen extends StatefulWidget {
  const OrganizationProfileScreen({super.key});

  @override
  State<OrganizationProfileScreen> createState() => _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState extends State<OrganizationProfileScreen> {
  final _api = ApiService();
  bool _loading = true;
  bool _saving = false;

  final _orgName = TextEditingController();
  final _trustReg = TextEditingController();
  final _headOffice = TextEditingController();
  final _founder = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _jurisdiction = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _api.getOrganizationProfile();
    if (data != null) {
      _orgName.text = data['organization_name']?.toString() ?? '';
      _trustReg.text = data['trust_reg_no']?.toString() ?? '';
      _headOffice.text = data['head_office_location']?.toString() ?? '';
      _founder.text = data['founder_details']?.toString() ?? '';
      _mobile.text = data['official_mobile']?.toString() ?? '';
      _email.text = data['official_email']?.toString() ?? '';
      _jurisdiction.text = data['jurisdiction']?.toString() ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final res = await _api.updateOrganizationProfile({
      "organization_name": _orgName.text.trim(),
      "trust_reg_no": _trustReg.text.trim(),
      "head_office_location": _headOffice.text.trim(),
      "founder_details": _founder.text.trim(),
      "official_mobile": _mobile.text.trim(),
      "official_email": _email.text.trim(),
      "jurisdiction": _jurisdiction.text.trim(),
    });
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? (res['success'] == true ? 'Saved' : 'Failed'))),
    );
  }

  @override
  void dispose() {
    for (final c in [_orgName, _trustReg, _headOffice, _founder, _mobile, _email, _jurisdiction]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Profile Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Trust Profile & Legal Identity',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('These details reflect on all membership certificates & receipts.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
          const SizedBox(height: 20),
          _field('Organization / Trust Name', _orgName),
          _field('Operating Trust Name & Reg. No', _trustReg),
          _field('Head Office Location', _headOffice),
          _field('Founder / President Details', _founder),
          _field('Official Mobile Numbers', _mobile),
          _field('Official Email Address', _email),
          _field('Jurisdiction / Coverage Area', _jurisdiction),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Profile Changes'),
            ),
          ),
        ],
      ),
    );
  }
}