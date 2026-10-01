// import 'package:flutter/material.dart';
// import '../services/api_service.dart'; // adjust path if different
//
// enum _PayCategory { claims, commission, expenses }
//
// class MakePaymentScreen extends StatefulWidget {
//   const MakePaymentScreen({super.key});
//
//   @override
//   State<MakePaymentScreen> createState() => _MakePaymentScreenState();
// }
//
// class _MakePaymentScreenState extends State<MakePaymentScreen> {
//   final _api = ApiService();
//
//   _PayCategory _category = _PayCategory.claims;
//   bool _loadingOptions = true;
//   bool _submitting = false;
//
//   // shared fields
//   final _disbursedByCtrl = TextEditingController(text: 'Admin Head Office');
//   String _paymentMode = 'cash';
//   final _refNoCtrl = TextEditingController();
//   final _remarksCtrl = TextEditingController();
//
//   // claims
//   List claims = [];
//   dynamic _selectedClaim;
//
//   // commission
//   List karyakartas = [];
//   Map<String, dynamic>? _selectedKaryakarta;
//   List<Map<String, dynamic>> _bankAccounts = [];
//   int? _selectedBankAccountId;
//
//   // expenses
//   final _vendorCtrl = TextEditingController();
//   final _purposeCtrl = TextEditingController();
//   final _amountCtrl = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadOptions();
//   }
//
//   Future<void> _loadOptions() async {
//     setState(() => _loadingOptions = true);
//     final results = await Future.wait([
//       _api.getClaims(), // existing method — filter approved below
//       _api.getKaryakartasRaw(),
//       _api.getBankAccounts(status: 'active'),
//     ]);
//     claims = (results[0] as List)
//         .where((c) => (c as dynamic).status?.toString().toLowerCase() == 'approved')
//         .toList();
//     karyakartas = results[1] as List;
//     _bankAccounts = results[2] as List<Map<String, dynamic>>;
//     if (mounted) setState(() => _loadingOptions = false);
//   }
//
//   double get _finalAmount {
//     switch (_category) {
//       case _PayCategory.claims:
//         try {
//           return double.tryParse(
//               (_selectedClaim as dynamic)?.approvedAmount?.toString() ?? '') ??
//               0;
//         } catch (_) {
//           return 0;
//         }
//       case _PayCategory.commission:
//         final v = _selectedKaryakarta?['pending_commission'];
//         return double.tryParse(v?.toString() ?? '') ?? 0;
//       case _PayCategory.expenses:
//         return double.tryParse(_amountCtrl.text) ?? 0;
//     }
//   }
//
//   Future<void> _submit() async {
//     if (_finalAmount <= 0) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Enter/select a valid amount')));
//       return;
//     }
//     setState(() => _submitting = true);
//     Map<String, dynamic> result;
//
//     if (_category == _PayCategory.claims) {
//       final claim = _selectedClaim as dynamic;
//       result = await _api.createTransaction({
//         "transaction_type": "expense",
//         "category": "claim_payment",
//         "amount": _finalAmount,
//         "transaction_date": DateTime.now().toIso8601String().split('T').first,
//         "payment_mode": _paymentMode,
//         "bank_account_id": _selectedBankAccountId ?? 0,
//         "reference_no": _refNoCtrl.text,
//         "description": "Claim payout — ${claim?.claimNo ?? claim?.id ?? ''}",
//         "related_member_id": claim?.memberId ?? 0,
//         "related_karyakarta_id": claim?.karyakartaId ?? 0,
//         "ref_claim_id": claim?.id ?? 0,
//       });
//     } else if (_category == _PayCategory.commission) {
//       result = await _api.createCommissionPayout({
//         "karyakarta_id": _selectedKaryakarta?['id'],
//         "commission_ids": _selectedKaryakarta?['commission_ids'] ?? [],
//         "total_amount": _finalAmount,
//         "payout_date": DateTime.now().toIso8601String().split('T').first,
//         "payment_mode": _paymentMode,
//         "bank_account_id": _selectedBankAccountId ?? 0,
//         "reference_no": _refNoCtrl.text,
//         "notes": _remarksCtrl.text,
//       });
//     } else {
//       result = await _api.createTransaction({
//         "transaction_type": "expense",
//         "category": "office_expenses",
//         "amount": _finalAmount,
//         "transaction_date": DateTime.now().toIso8601String().split('T').first,
//         "payment_mode": _paymentMode,
//         "bank_account_id": _selectedBankAccountId ?? 0,
//         "reference_no": _refNoCtrl.text,
//         "description": "${_purposeCtrl.text} — ${_vendorCtrl.text}",
//         "related_member_id": 0,
//         "related_karyakarta_id": 0,
//       });
//     }
//
//     setState(() => _submitting = false);
//
//     if (result['success'] == true) {
//       if (mounted) Navigator.pop(context, true);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(result['message']?.toString() ?? 'Payment failed')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Execute Treasury Payment')),
//       body: _loadingOptions
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//         padding: const EdgeInsets.all(12),
//         children: [
//           const Text('STEP 1: SELECT PAYMENT CATEGORY',
//               style: TextStyle(fontSize: 12, color: Colors.grey)),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               _categoryChip('Claims Payout', _PayCategory.claims, Colors.indigo),
//               const SizedBox(width: 8),
//               _categoryChip('Commissions', _PayCategory.commission, Colors.purple),
//               const SizedBox(width: 8),
//               _categoryChip('Expenses', _PayCategory.expenses, Colors.red),
//             ],
//           ),
//           const SizedBox(height: 20),
//           if (_category == _PayCategory.claims) _buildClaimsSection(),
//           if (_category == _PayCategory.commission) _buildCommissionSection(),
//           if (_category == _PayCategory.expenses) _buildExpenseSection(),
//           const SizedBox(height: 20),
//           const Text('STEP 2: PAYMENT EXECUTION & MODES',
//               style: TextStyle(fontSize: 12, color: Colors.grey)),
//           const SizedBox(height: 8),
//           TextField(
//             controller: _disbursedByCtrl,
//             decoration: const InputDecoration(labelText: 'Disbursed By', border: OutlineInputBorder()),
//           ),
//           const SizedBox(height: 10),
//           DropdownButtonFormField<String>(
//             value: _paymentMode,
//             decoration: const InputDecoration(labelText: 'Payment Mode', border: OutlineInputBorder()),
//             items: const [
//               DropdownMenuItem(value: 'cash', child: Text('Cash Handover')),
//               DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
//               DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
//               DropdownMenuItem(value: 'upi', child: Text('UPI')),
//             ],
//             onChanged: (v) => setState(() => _paymentMode = v ?? 'cash'),
//           ),
//           if (_paymentMode == 'bank_transfer') ...[
//             const SizedBox(height: 10),
//             DropdownButtonFormField<int>(
//               value: _selectedBankAccountId,
//               decoration: const InputDecoration(labelText: 'Bank Account', border: OutlineInputBorder()),
//               items: _bankAccounts
//                   .map((b) => DropdownMenuItem<int>(
//                 value: b['id'] as int?,
//                 child: Text(b['account_name']?.toString() ?? ''),
//               ))
//                   .toList(),
//               onChanged: (v) => setState(() => _selectedBankAccountId = v),
//             ),
//           ],
//           const SizedBox(height: 10),
//           TextField(
//             controller: _refNoCtrl,
//             decoration: const InputDecoration(
//                 labelText: 'Payment Ref. No / UTR / Cheque No', border: OutlineInputBorder()),
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             controller: _remarksCtrl,
//             decoration: const InputDecoration(labelText: 'Remarks / Internal Notes', border: OutlineInputBorder()),
//           ),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey.shade900,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('FINAL PAYABLE DISBURSEMENT AMOUNT',
//                         style: TextStyle(color: Colors.orange, fontSize: 11)),
//                     Text('₹${_finalAmount.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                             color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _submitting ? null : _submit,
//                   icon: _submitting
//                       ? const SizedBox(
//                       width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
//                       : const Icon(Icons.check),
//                   label: const Text('Pay Now (Generate Voucher)'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _categoryChip(String label, _PayCategory value, Color color) {
//     final selected = _category == value;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _category = value),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           decoration: BoxDecoration(
//             color: selected ? color : Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           alignment: Alignment.center,
//           child: Text(label,
//               textAlign: TextAlign.center,
//               style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 12)),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildClaimsSection() {
//     return DropdownButtonFormField<dynamic>(
//       value: _selectedClaim,
//       decoration: const InputDecoration(
//           labelText: 'Select Active / Approved Welfare Claim', border: OutlineInputBorder()),
//       items: claims
//           .map<DropdownMenuItem<dynamic>>((c) => DropdownMenuItem(
//         value: c,
//         child: Text('Claim #${(c as dynamic).id} — ₹${(c as dynamic).approvedAmount ?? ''}'),
//       ))
//           .toList(),
//       onChanged: (v) => setState(() => _selectedClaim = v),
//     );
//   }
//
//   Widget _buildCommissionSection() {
//     return DropdownButtonFormField<Map<String, dynamic>>(
//       value: _selectedKaryakarta,
//       decoration: const InputDecoration(
//           labelText: 'Search & Select Karyakarta (SA Code / Name / Mobile)',
//           border: OutlineInputBorder()),
//       items: karyakartas
//           .map<DropdownMenuItem<Map<String, dynamic>>>((k) => DropdownMenuItem(
//         value: Map<String, dynamic>.from(k as Map),
//         child: Text('${k['sa_code'] ?? ''} — ${k['full_name'] ?? k['name'] ?? ''}'),
//       ))
//           .toList(),
//       onChanged: (v) => setState(() => _selectedKaryakarta = v),
//     );
//   }
//
//   Widget _buildExpenseSection() {
//     return Column(
//       children: [
//         TextField(
//           controller: _vendorCtrl,
//           decoration: const InputDecoration(
//               labelText: 'Recipient / Vendor Name', hintText: 'e.g. Ramesh Stationery / Office Landlord',
//               border: OutlineInputBorder()),
//         ),
//         const SizedBox(height: 10),
//         TextField(
//           controller: _purposeCtrl,
//           decoration: const InputDecoration(
//               labelText: 'Expense Purpose / Head', hintText: 'e.g. Office Rent / Printing / Event Food',
//               border: OutlineInputBorder()),
//         ),
//         const SizedBox(height: 10),
//         TextField(
//           controller: _amountCtrl,
//           keyboardType: TextInputType.number,
//           onChanged: (_) => setState(() {}),
//           decoration: const InputDecoration(labelText: 'Expense Amount (₹)', border: OutlineInputBorder()),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../services/api_service.dart'; // adjust path if different

enum _PayCategory { claims, commission, expenses }

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final _api = ApiService();

  _PayCategory _category = _PayCategory.claims;
  bool _loadingOptions = true;
  bool _submitting = false;

  // shared fields
  final _paidByCtrl = TextEditingController(text: 'Admin Head Office'); // -> "paid_by"
  final _disbursedByCtrl = TextEditingController(text: 'Admin Office'); // -> "disbursed_by"
  String _paymentMode = 'Cash'; // FIXED — Title Case to match backend ("Cash","UPI",...)
  final _refNoCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(); // NEW — used by all 3 categories now

  // claims
  List claims = [];
  dynamic _selectedClaim;

  // commission
  List<Map<String, dynamic>> karyakartas = [];
  Map<String, dynamic>? _selectedKaryakarta;
  final _payAgainstCtrl = TextEditingController(); // NEW — e.g. "10 Proposals (KDS)"

  // expenses
  final _vendorCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() => _loadingOptions = true);
    try {
      final results = await Future.wait([
        _api.getClaims(), // filter approved below
        _api.getKaryakartasRaw(),
      ]);
      claims = (results[0] as List)
          .where((c) => (c as dynamic).status?.toString().toLowerCase() == 'approved')
          .toList();
      karyakartas = results[1] as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint("🔴 MakePaymentScreen._loadOptions error: $e");
    } finally {
      if (mounted) setState(() => _loadingOptions = false);
    }
  }

  // FIXED — amount is now a plain editable field for every category.
  // Claims still auto-fill it from the approved claim (best effort),
  // but the user can always override before submitting.
  double get _finalAmount => double.tryParse(_amountCtrl.text) ?? 0;

  void _onClaimSelected(dynamic claim) {
    setState(() {
      _selectedClaim = claim;
      final approved = (claim as dynamic)?.approvedAmount;
      if (approved != null) {
        _amountCtrl.text = approved.toString();
      }
    });
  }

  // FIXED — backend expects Title Case ("Cash","UPI","Bank Transfer","Cheque")
  String get _paymentModeForApi => _paymentMode;

  Future<void> _submit() async {
    if (_finalAmount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter/select a valid amount')));
      return;
    }
    if (_category == _PayCategory.commission && _selectedKaryakarta == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select a karyakarta')));
      return;
    }
    if (_category == _PayCategory.claims && _selectedClaim == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select a claim')));
      return;
    }

    setState(() => _submitting = true);

    Map<String, dynamic> payload;

    switch (_category) {
      case _PayCategory.claims:
        final claim = _selectedClaim as dynamic;
        payload = {
          "payout_type": "claim",
          "pay_against": "",
          "recipient_name": "",
          "beneficiary_type": "Member",
          "member_id": claim?.memberId ?? 0,
          "karyakarta_id": claim?.karyakartaId ?? 0,
          "claim_id": claim?.id ?? 0,
          "amount": _finalAmount,
          "payment_mode": _paymentModeForApi,
          "ref_no": _refNoCtrl.text,
          "disbursed_by": _disbursedByCtrl.text,
          "paid_by": _paidByCtrl.text,
          "notes": _remarksCtrl.text.isNotEmpty
              ? _remarksCtrl.text
              : "Claim Settlement Payout: ${claim?.claimNo ?? claim?.id ?? ''}",
        };
        break;

      case _PayCategory.commission:
        final k = _selectedKaryakarta!;
        final name = k['full_name'] ?? k['name'] ?? '';
        final saCode = k['sa_code'] ?? '';
        payload = {
          "payout_type": "commission",
          "pay_against": _payAgainstCtrl.text,
          "recipient_name": saCode.toString().isNotEmpty ? '$name ($saCode)' : name,
          "beneficiary_type": "Member",
          "member_id": null,
          "karyakarta_id": k['id'],
          "claim_id": null,
          "amount": _finalAmount,
          "payment_mode": _paymentModeForApi,
          "ref_no": _refNoCtrl.text,
          "disbursed_by": _disbursedByCtrl.text,
          "paid_by": _paidByCtrl.text,
          "notes": _remarksCtrl.text,
        };
        break;

      case _PayCategory.expenses:
        payload = {
          "payout_type": "expense",
          "pay_against": _purposeCtrl.text,
          "recipient_name": _vendorCtrl.text,
          "beneficiary_type": "Vendor",
          "member_id": null,
          "karyakarta_id": null,
          "claim_id": null,
          "amount": _finalAmount,
          "payment_mode": _paymentModeForApi,
          "ref_no": _refNoCtrl.text,
          "disbursed_by": _disbursedByCtrl.text,
          "paid_by": _paidByCtrl.text,
          "notes": _remarksCtrl.text,
        };
        break;
    }

    final result = await _api.createPayment(payload);

    setState(() => _submitting = false);

    if (result['success'] == true) {
      if (mounted) Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Payment failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Execute Treasury Payment')),
      body: _loadingOptions
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('STEP 1: SELECT PAYMENT CATEGORY',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              _categoryChip('Claims Payout', _PayCategory.claims, Colors.indigo),
              const SizedBox(width: 8),
              _categoryChip('Commissions', _PayCategory.commission, Colors.purple),
              const SizedBox(width: 8),
              _categoryChip('Expenses', _PayCategory.expenses, Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          if (_category == _PayCategory.claims) _buildClaimsSection(),
          if (_category == _PayCategory.commission) _buildCommissionSection(),
          if (_category == _PayCategory.expenses) _buildExpenseSection(),
          const SizedBox(height: 16),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          const Text('STEP 2: PAYMENT EXECUTION & MODES',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _paidByCtrl,
            decoration: const InputDecoration(labelText: 'Paid By', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _disbursedByCtrl,
            decoration: const InputDecoration(labelText: 'Disbursed By (Office)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _paymentMode,
            decoration: const InputDecoration(labelText: 'Payment Mode', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'Cash', child: Text('Cash Handover')),
              DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
              DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
              DropdownMenuItem(value: 'UPI', child: Text('UPI')),
            ],
            onChanged: (v) => setState(() => _paymentMode = v ?? 'Cash'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _refNoCtrl,
            decoration: const InputDecoration(
                labelText: 'Payment Ref. No / UTR / Cheque No', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _remarksCtrl,
            decoration: const InputDecoration(labelText: 'Remarks / Internal Notes', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FINAL PAYABLE DISBURSEMENT AMOUNT',
                    style: TextStyle(color: Colors.orange, fontSize: 11)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('₹${_finalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: const Text('Pay Now (Generate Voucher)'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, _PayCategory value, Color color) {
    final selected = _category == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _category = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildClaimsSection() {
    return DropdownButtonFormField<dynamic>(
      value: _selectedClaim,
      decoration: const InputDecoration(
          labelText: 'Select Active / Approved Welfare Claim', border: OutlineInputBorder()),
      items: claims
          .map<DropdownMenuItem<dynamic>>((c) => DropdownMenuItem(
        value: c,
        child: Text('Claim #${(c as dynamic).id} — ₹${(c as dynamic).approvedAmount ?? ''}'),
      ))
          .toList(),
      onChanged: _onClaimSelected, // FIXED — now auto-fills amount too
    );
  }

  Widget _buildCommissionSection() {
    return Column(
      children: [
        DropdownButtonFormField<Map<String, dynamic>>(
          value: _selectedKaryakarta,
          decoration: const InputDecoration(
              labelText: 'Search & Select Karyakarta (SA Code / Name / Mobile)',
              border: OutlineInputBorder()),
          items: karyakartas
              .map<DropdownMenuItem<Map<String, dynamic>>>((k) => DropdownMenuItem(
            value: k,
            child: Text('${k['sa_code'] ?? ''} — ${k['full_name'] ?? k['name'] ?? ''}'),
          ))
              .toList(),
          onChanged: (v) => setState(() => _selectedKaryakarta = v),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _payAgainstCtrl,
          decoration: const InputDecoration(
              labelText: 'Pay Against', hintText: 'e.g. 10 Proposals (KDS)',
              border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildExpenseSection() {
    return Column(
      children: [
        TextField(
          controller: _vendorCtrl,
          decoration: const InputDecoration(
              labelText: 'Recipient / Vendor Name', hintText: 'e.g. Ramesh Stationery / Office Landlord',
              border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _purposeCtrl,
          decoration: const InputDecoration(
              labelText: 'Expense Purpose / Head', hintText: 'e.g. Office Rent / Printing / Event Food',
              border: OutlineInputBorder()),
        ),
      ],
    );
  }
}