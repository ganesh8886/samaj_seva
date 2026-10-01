import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'make_payment_screen.dart';

class PaymentManageScreen extends StatefulWidget {
  const PaymentManageScreen({super.key});

  @override
  State<PaymentManageScreen> createState() => _PaymentManageScreenState();
}

class _PaymentManageScreenState extends State<PaymentManageScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  late TabController _tabController;

  bool _loading = true;
  String? _loadError;

  List<Map<String, dynamic>> _claimPayouts = [];
  List<Map<String, dynamic>> _commissionPayouts = [];
  List<Map<String, dynamic>> _commissionReport = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAll();
  }

  // ---- current month range, matches your API examples (date_from/date_to) ----
  String get _monthStartStr {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1).toIso8601String().split('T').first;
  }

  String get _todayFullStr => DateTime.now().toIso8601String().split('T').first;

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        _api.getClaimPayouts(dateFrom: _monthStartStr, dateTo: _todayFullStr),
        _api.getCommissionPayouts(dateFrom: _monthStartStr, dateTo: _todayFullStr),
        _api.getCommissionReport(dateFrom: _monthStartStr, dateTo: _todayFullStr),
      ]);
      _claimPayouts = results[0];
      _commissionPayouts = results[1];
      _commissionReport = results[2];
    } catch (e) {
      _loadError = 'Failed to load payment data: $e';
      debugPrint("🔴 PaymentManageScreen._loadAll error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---- helpers ----
  double? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  double _sumAmount(List<Map<String, dynamic>> list, {String field = 'amount'}) =>
      list.fold(0.0, (s, e) => s + (_num(e[field]) ?? 0));

  bool _isToday(dynamic createdAt) =>
      createdAt != null && createdAt.toString().startsWith(_todayFullStr);

  // ---- Master Register = claim-payouts + commission-payouts merged ----
  List<Map<String, dynamic>> get _masterRegister {
    final merged = [..._claimPayouts, ..._commissionPayouts];
    merged.sort((a, b) =>
        (b['created_at'] ?? '').toString().compareTo((a['created_at'] ?? '').toString()));
    return merged;
  }

  // ---- stat cards ----
  double get _claimsSettled => _sumAmount(_claimPayouts);
  double get _commissionDisbursed => _sumAmount(_commissionPayouts);
  double get _otherExpenses => 0; // no backend endpoint provided for this yet
  double get _totalDisbursements => _claimsSettled + _commissionDisbursed + _otherExpenses;

  // ---- today ----
  double get _todayClaimsSettled =>
      _sumAmount(_claimPayouts.where((c) => _isToday(c['created_at'])).toList());
  double get _todayCommissionPaid =>
      _sumAmount(_commissionPayouts.where((c) => _isToday(c['created_at'])).toList());
  double get _todayTotalPayout => _todayClaimsSettled + _todayCommissionPaid;

  // ---- this month (already scoped by the date_from/date_to we queried with) ----
  double get _thisMonthTotalPayout => _totalDisbursements;

  // ---- top karyakartas from commission report ----
  List<Map<String, dynamic>> get _topKaryakartas {
    final list = List<Map<String, dynamic>>.from(_commissionReport);
    list.sort((a, b) => (_num(b['paid_amount']) ?? 0).compareTo(_num(a['paid_amount']) ?? 0));
    return list.where((r) => (_num(r['paid_amount']) ?? 0) > 0).take(5).toList();
  }

  // ---- payment mode distribution across both payout types ----
  Map<String, double> get _paymentModeDistribution {
    final map = <String, double>{};
    for (final v in _masterRegister) {
      final mode = (v['payment_mode'] ?? 'Unknown').toString();
      map[mode] = (map[mode] ?? 0) + (_num(v['amount']) ?? 0);
    }
    return map;
  }

  String _displayRecipient(Map<String, dynamic> v) {
    final name = (v['recipient_name'] ?? '').toString().trim();
    if (name.isNotEmpty) return name;
    final type = (v['beneficiary_type'] ?? 'Beneficiary').toString();
    final id = v['member_id'] ?? v['karyakarta_id'] ?? '';
    return '$type #$id';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Manage')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MakePaymentScreen()),
          );
          if (result == true) _loadAll();
        },
        icon: const Icon(Icons.payment),
        label: const Text('Make Payment'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAll,
        child: Column(
          children: [
            _buildStatCards(),
            if (_loadError != null)
              Container(
                width: double.infinity,
                color: Colors.red.shade50,
                padding: const EdgeInsets.all(8),
                child: Text(_loadError!, style: const TextStyle(color: Colors.red)),
              ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Master Register'),
                Tab(text: 'Claims Payout'),
                Tab(text: 'Commission'),
                Tab(text: 'Other Expenses'),
                Tab(text: 'Commission Report'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildRegisterList(_masterRegister, emptyText: 'No records found'),
                  _buildRegisterList(_claimPayouts, emptyText: 'No claims disbursements recorded.'),
                  _buildRegisterList(_commissionPayouts, emptyText: 'No commission payouts recorded.'),
                  _buildRegisterList(const [], emptyText: 'No expense disbursements recorded.'),
                  _buildCommissionReportTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    Widget card(String label, double value, Color color) {
      final screenWidth = MediaQuery.of(context).size.width;
      final cardWidth = (screenWidth * 0.42).clamp(150.0, 190.0);

      return SizedBox(
        width: cardWidth,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('₹${value.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          card('TOTAL DISBURSEMENTS', _totalDisbursements, Colors.red),
          card('CLAIMS SETTLED', _claimsSettled, Colors.blue),
          card('COMMISSION DISBURSED', _commissionDisbursed, Colors.purple),
          card('OTHER EXPENSES', _otherExpenses, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    final feed = _masterRegister.take(8).toList();
    final topK = _topKaryakartas;
    final modeDist = _paymentModeDistribution;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        IntrinsicHeight(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _darkStatBox('TODAY TOTAL PAYOUT',
                    '₹${_todayTotalPayout.toStringAsFixed(0)}', 'Disbursed today'),
                _lightStatBox('TODAY CLAIMS SETTLED',
                    '₹${_todayClaimsSettled.toStringAsFixed(0)}', 'Welfare assistance paid'),
                _lightStatBox('TODAY COMMISSION PAID',
                    '₹${_todayCommissionPaid.toStringAsFixed(0)}', 'Karyakarta incentives cleared'),
                _lightStatBox('THIS MONTH TOTAL PAYOUT',
                    '₹${_thisMonthTotalPayout.toStringAsFixed(0)}', 'Current month'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Latest Disbursements Feed', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('Real-time expenditure and assistance disbursements',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 8),
        if (feed.isEmpty) const Text('No disbursements yet'),
        ...feed.map((v) => _voucherCard(v)),
        const Divider(height: 32),
        const Text('Top Disbursed to Karyakartas', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (topK.isEmpty)
          const Text('No data yet', style: TextStyle(color: Colors.grey))
        else
          ...topK.asMap().entries.map((e) {
            final i = e.key;
            final r = e.value;
            final paid = _num(r['paid_amount']) ?? 0;
            return Card(
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: i == 0 ? Colors.amber : Colors.grey.shade300,
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                ),
                title: Text(r['karyakarta_name']?.toString() ?? 'Karyakarta',
                    style: const TextStyle(fontSize: 13)),
                trailing: Text('₹${paid.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            );
          }),
        const Divider(height: 32),
        const Text('Payout Payment Mode Distribution', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (modeDist.isEmpty)
          const Text('No data yet', style: TextStyle(color: Colors.grey))
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: modeDist.entries
                    .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key.toString().toUpperCase(), style: const TextStyle(fontSize: 12)),
                      Text('₹${e.value.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _darkStatBox(String label, String value, String sub) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = (screenWidth * 0.42).clamp(150.0, 190.0);

    return Container(
      width: boxWidth,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF241E4E), borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text(sub,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _lightStatBox(String label, String value, String sub) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = (screenWidth * 0.42).clamp(150.0, 190.0);

    return Container(
      width: boxWidth,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildRegisterList(List<Map<String, dynamic>> items, {required String emptyText}) {
    if (items.isEmpty) {
      return Center(child: Text(emptyText, style: const TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (_, i) => _voucherCard(items[i]),
    );
  }

  Widget _voucherCard(Map<String, dynamic> v) {
    final amount = _num(v['amount']) ?? 0;
    final type = (v['payout_type'] ?? '').toString().toUpperCase();
    return Card(
      child: ListTile(
        title: Text(v['voucher_no']?.toString() ?? '-'),
        subtitle: Text(
          '$type • ${v['pay_against'] ?? ''} • ${_displayRecipient(v)}\n'
              '${v['payment_mode'] ?? ''} • Paid by ${v['paid_by'] ?? '-'} • ${v['created_at'] ?? ''}',
        ),
        isThreeLine: true,
        trailing: Text('₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
  Widget _buildCommissionReportTab() {
    if (_commissionReport.isEmpty) {
      return const Center(child: Text('No commission data.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _commissionReport.length,
      itemBuilder: (_, i) {
        final r = _commissionReport[i];
        final total = _num(r['total_commission']) ?? 0;
        final paid = _num(r['paid_amount']) ?? 0;
        final pending = total - paid;
        return Card(
          child: ListTile(
            title: Text(r['karyakarta_name']?.toString() ?? 'Karyakarta'),
            subtitle: Text('Total Members: ${r['total_members'] ?? 0} • Status: ${r['status'] ?? '-'}'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Paid ₹${paid.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.green, fontSize: 12)),
                Text('Pending ₹${pending.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}