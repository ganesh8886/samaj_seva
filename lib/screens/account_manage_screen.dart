// import 'package:flutter/material.dart';
//
// class AccountManageScreen extends StatefulWidget {
//   const AccountManageScreen({super.key});
//
//   @override
//   State<AccountManageScreen> createState() => _AccountManageScreenState();
// }
//
// class _AccountManageScreenState extends State<AccountManageScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Account manage'),
//       ),
//       body: const Center(
//         child: Text('Account management screen — coming soon'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AccountManageScreen extends StatefulWidget {
  const AccountManageScreen({super.key});

  @override
  State<AccountManageScreen> createState() => _AccountManageScreenState();
}

enum _Period { all, thisFy, thisMonth, custom }

class _AccountManageScreenState extends State<AccountManageScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();

  _Period _period = _Period.all;
  String? _entryType; // null = all, 'credit', 'debit'
  DateTime? _from;
  DateTime? _to;

  bool _loading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _transactions = [];

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

  String? _fmt(DateTime? d) => d == null ? null : DateFormat('yyyy-MM-dd').format(d);

  void _applyPeriod(_Period p) {
    final now = DateTime.now();
    setState(() {
      _period = p;
      switch (p) {
        case _Period.all:
          _from = null;
          _to = null;
          break;
        case _Period.thisFy:
        // Indian FY: Apr 1 – Mar 31
          final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
          _from = DateTime(fyStartYear, 4, 1);
          _to = DateTime(fyStartYear + 1, 3, 31);
          break;
        case _Period.thisMonth:
          _from = DateTime(now.year, now.month, 1);
          _to = DateTime(now.year, now.month + 1, 0);
          break;
        case _Period.custom:
          break;
      }
    });
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _api.getLedger(
      entryType: _entryType,
      dateFrom: _fmt(_from),
      dateTo: _fmt(_to),
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
    );
    setState(() {
      _stats = Map<String, dynamic>.from(data['stats'] ?? {});
      _transactions = List<Map<String, dynamic>>.from(data['transactions'] ?? []);
      _loading = false;
    });
  }

  num _num(dynamic v) => v == null ? 0 : (v is num ? v : num.tryParse(v.toString()) ?? 0);

  String _rupee(dynamic v) => '₹${NumberFormat('#,##,##0.##').format(_num(v))}';

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: (_from != null && _to != null) ? DateTimeRange(start: _from!, end: _to!) : null,
    );
    if (range != null) {
      setState(() {
        _period = _Period.custom;
        _from = range.start;
        _to = range.end;
      });
      _load();
    }
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _period = _Period.all;
      _entryType = null;
      _from = null;
      _to = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final netBalance = _stats['net_balance'];
    final netCash = _stats['net_cash'];
    final netBank = _stats['net_bank'];
    final totalCredit = _stats['total_credit'];
    final creditCash = _stats['credit_cash'];
    final creditBank = _stats['credit_bank'];
    final totalDebit = _stats['total_debit'];
    final debitCash = _stats['debit_cash'];
    final debitBank = _stats['debit_bank'];

    return Scaffold(
      backgroundColor: const Color(0xFFC97C0F),
      appBar: AppBar(title: const Text('Account Manage & Master Credit / Debit Ledger')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Period pills ----
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _periodChip('All Time', _Period.all),
                _periodChip('This FY', _Period.thisFy),
                _periodChip('This Month', _Period.thisMonth),
                ActionChip(
                  label: Text(_period == _Period.custom && _from != null
                      ? '${DateFormat('dd-MM-yyyy').format(_from!)} → ${DateFormat('dd-MM-yyyy').format(_to!)}'
                      : 'Custom Range'),
                  onPressed: _pickCustomRange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---- Stat cards ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E1B4B), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NET AVAILABLE BALANCE', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(_rupee(netBalance), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bank: ${_rupee(netBank)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('Cash: ${_rupee(netCash)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _smallStatCard('TOTAL RECEIPTS (CREDIT)', totalCredit, creditCash, creditBank, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _smallStatCard('TOTAL PAYMENTS (DEBIT)', totalDebit, debitCash, debitBank, Colors.red)),
              ],
            ),
            const SizedBox(height: 16),

            // ---- Search + filter row ----
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search Txn No, Party, Head...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onSubmitted: (_) => _load(),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All Entries'),
                  selected: _entryType == null,
                  onSelected: (_) {
                    setState(() => _entryType = null);
                    _load();
                  },
                ),
                ChoiceChip(
                  label: const Text('Credit'),
                  selected: _entryType == 'credit',
                  selectedColor: Colors.green.shade100,
                  onSelected: (_) {
                    setState(() => _entryType = 'credit');
                    _load();
                  },
                ),
                ChoiceChip(
                  label: const Text('Debit'),
                  selected: _entryType == 'debit',
                  selectedColor: Colors.red.shade100,
                  onSelected: (_) {
                    setState(() => _entryType = 'debit');
                    _load();
                  },
                ),
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear Filter'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---- Transactions list ----
            if (_loading)
              const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: CircularProgressIndicator()))
            else if (_transactions.isEmpty)
              const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text('No transactions found')))
            else
              ..._transactions.map(_transactionTile),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(String label, _Period p) {
    return ChoiceChip(
      label: Text(label),
      selected: _period == p,
      onSelected: (_) => _applyPeriod(p),
    );
  }

  Widget _smallStatCard(String label, dynamic total, dynamic cash, dynamic bank, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(_rupee(total), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text('Bank: ${_rupee(bank)}  •  Cash: ${_rupee(cash)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _transactionTile(Map<String, dynamic> t) {
    final isCredit = (t['entry_type'] ?? '').toString().toUpperCase() == 'CREDIT';
    final amount = isCredit ? t['credit_amount'] : t['debit_amount'];
    final party = (t['party_name'] ?? '').toString().isNotEmpty
        ? t['party_name']
        : (t['transaction_against'] ?? t['sa_name'] ?? '-');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isCredit ? 'CREDIT' : 'DEBIT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['txn_ref_no']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '${(t['category_head'] ?? '').toString().replaceAll('_', ' ').toUpperCase()} • $party',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(t['created_at']?.toString() ?? '', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(
            (isCredit ? '+ ' : '- ') + _rupee(amount),
            style: TextStyle(fontWeight: FontWeight.bold, color: isCredit ? Colors.green.shade700 : Colors.red.shade700),
          ),
        ],
      ),
    );
  }
}