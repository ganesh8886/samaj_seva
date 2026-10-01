// import 'package:flutter/material.dart';
// import '../models/receipt_model.dart';
// import '../models/contribution_batch_model.dart';
// import '../services/api_service.dart';
//
// class CollectionManageScreen extends StatefulWidget {
//   const CollectionManageScreen({super.key});
//
//   @override
//   State<CollectionManageScreen> createState() => _CollectionManageScreenState();
// }
//
// class _CollectionManageScreenState extends State<CollectionManageScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F6FB),
//       appBar: AppBar(
//         title: const Text('Collection Manage'),
//         backgroundColor: const Color(0xFFE0522F),
//         foregroundColor: Colors.white,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           tabs: const [
//             Tab(text: 'Receipts'),
//             Tab(text: 'Batches'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: const [
//           _ReceiptsTab(),
//           _BatchesTab(),
//         ],
//       ),
//     );
//   }
// }
//
// // ---------------- RECEIPTS TAB ----------------
//
// class _ReceiptsTab extends StatefulWidget {
//   const _ReceiptsTab();
//
//   @override
//   State<_ReceiptsTab> createState() => _ReceiptsTabState();
// }
//
// class _ReceiptsTabState extends State<_ReceiptsTab> {
//   final _api = ApiService();
//   final _searchCtrl = TextEditingController();
//   List<ReceiptModel> _all = [];
//   List<ReceiptModel> _filtered = [];
//   bool _loading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//     _searchCtrl.addListener(_applyFilter);
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final receipts = await _api.getReceipts();
//       setState(() {
//         _all = receipts;
//         _filtered = receipts;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Could not load receipts: $e';
//         _loading = false;
//       });
//     }
//   }
//
//   void _applyFilter() {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     setState(() {
//       if (q.isEmpty) {
//         _filtered = _all;
//       } else {
//         _filtered = _all.where((r) {
//           return r.receiptNo.toLowerCase().contains(q) ||
//               r.type.toLowerCase().contains(q) ||
//               r.paymentMode.toLowerCase().contains(q) ||
//               r.memberId.toLowerCase().contains(q) ||
//               r.id.toLowerCase().contains(q);
//         }).toList();
//       }
//     });
//   }
//
//   Future<void> _openAddReceipt() async {
//     final memberCtrl = TextEditingController();
//     final karyakartaCtrl = TextEditingController();
//     final enrollmentCtrl = TextEditingController();
//     final amountCtrl = TextEditingController();
//     String type = 'joining_fee';
//     String paymentMode = 'Cash';
//
//     final created = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setSheetState) => Padding(
//           padding: EdgeInsets.only(
//             left: 20,
//             right: 20,
//             top: 20,
//             bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Create Receipt',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: memberCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Member ID'),
//                 ),
//                 TextField(
//                   controller: karyakartaCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Karyakarta ID'),
//                 ),
//                 TextField(
//                   controller: enrollmentCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Enrollment ID'),
//                 ),
//                 TextField(
//                   controller: amountCtrl,
//                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                   decoration: const InputDecoration(labelText: 'Amount'),
//                 ),
//                 const SizedBox(height: 8),
//                 DropdownButtonFormField<String>(
//                   value: type,
//                   decoration: const InputDecoration(labelText: 'Type'),
//                   items: const [
//                     DropdownMenuItem(value: 'joining_fee', child: Text('Joining fee')),
//                     DropdownMenuItem(value: 'contribution', child: Text('Contribution')),
//                     DropdownMenuItem(value: 'other', child: Text('Other')),
//                   ],
//                   onChanged: (v) => setSheetState(() => type = v ?? type),
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: paymentMode,
//                   decoration: const InputDecoration(labelText: 'Payment mode'),
//                   items: const [
//                     DropdownMenuItem(value: 'Cash', child: Text('Cash')),
//                     DropdownMenuItem(value: 'Online', child: Text('Online')),
//                     DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
//                   ],
//                   onChanged: (v) => setSheetState(() => paymentMode = v ?? paymentMode),
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE0522F)),
//                     onPressed: () async {
//                       final payload = {
//                         "member_id": int.tryParse(memberCtrl.text) ?? 0,
//                         "karyakarta_id": int.tryParse(karyakartaCtrl.text) ?? 0,
//                         "enrollment_id": int.tryParse(enrollmentCtrl.text) ?? 0,
//                         "amount": double.tryParse(amountCtrl.text) ?? 0,
//                         "type": type,
//                         "payment_mode": paymentMode,
//                         "ref_batch_id": 0,
//                         "ref_claim_id": 0,
//                       };
//                       final result = await _api.createReceipt(payload);
//                       if (ctx.mounted) {
//                         Navigator.pop(ctx, result['success'] == true);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text(result['message']?.toString() ?? 'Done')),
//                         );
//                       }
//                     },
//                     child: const Text('Create Receipt', style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//
//     if (created == true) _load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _openAddReceipt,
//         backgroundColor: const Color(0xFFE0522F),
//         icon: const Icon(Icons.add),
//         label: const Text('Add Receipt'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _load,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//               child: TextField(
//                 controller: _searchCtrl,
//                 decoration: InputDecoration(
//                   hintText: 'Search by receipt no, type, payment mode...',
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: _searchCtrl.text.isNotEmpty
//                       ? IconButton(icon: const Icon(Icons.close), onPressed: () => _searchCtrl.clear())
//                       : null,
//                   filled: true,
//                   fillColor: Colors.white,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(child: _buildBody()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_loading) return const Center(child: CircularProgressIndicator());
//     if (_error != null) {
//       return ListView(
//         children: [
//           const SizedBox(height: 80),
//           Center(child: Text(_error!, textAlign: TextAlign.center)),
//           const SizedBox(height: 12),
//           Center(child: OutlinedButton(onPressed: _load, child: const Text('Retry'))),
//         ],
//       );
//     }
//     if (_filtered.isEmpty) {
//       return ListView(
//         children: [
//           const SizedBox(height: 100),
//           Icon(Icons.receipt_long_outlined, color: Colors.grey.shade400, size: 48),
//           const SizedBox(height: 12),
//           Center(
//             child: Text(
//               _all.isEmpty ? 'No receipts found' : 'No receipts match your search',
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//           ),
//         ],
//       );
//     }
//     return ListView.separated(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
//       itemCount: _filtered.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 10),
//       itemBuilder: (context, i) {
//         final r = _filtered[i];
//         return Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Row(
//             children: [
//               const CircleAvatar(
//                 radius: 20,
//                 backgroundColor: Color(0xFFFBE3DD),
//                 child: Icon(Icons.receipt_long_outlined, color: Color(0xFFE0522F)),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(r.receiptNo.isEmpty ? 'Receipt #${r.id}' : r.receiptNo,
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                     const SizedBox(height: 2),
//                     Text('${r.type} • ${r.paymentMode}',
//                         style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//                   ],
//                 ),
//               ),
//               Text('₹${r.amount.toStringAsFixed(2)}',
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ---------------- BATCHES TAB ----------------
//
// class _BatchesTab extends StatefulWidget {
//   const _BatchesTab();
//
//   @override
//   State<_BatchesTab> createState() => _BatchesTabState();
// }
//
// class _BatchesTabState extends State<_BatchesTab> {
//   final _api = ApiService();
//   final _searchCtrl = TextEditingController();
//   List<ContributionBatchModel> _all = [];
//   List<ContributionBatchModel> _filtered = [];
//   bool _loading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//     _searchCtrl.addListener(_applyFilter);
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final batches = await _api.getContributionBatches();
//       setState(() {
//         _all = batches;
//         _filtered = batches;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Could not load batches: $e';
//         _loading = false;
//       });
//     }
//   }
//
//   void _applyFilter() {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     setState(() {
//       if (q.isEmpty) {
//         _filtered = _all;
//       } else {
//         _filtered = _all.where((b) {
//           return b.status.toLowerCase().contains(q) ||
//               b.claimId.toLowerCase().contains(q) ||
//               b.id.toLowerCase().contains(q);
//         }).toList();
//       }
//     });
//   }
//
//   Future<void> _settle(ContributionBatchModel batch) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Settle batch'),
//         content: Text('Settle batch #${batch.id}? This cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
//           ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Settle')),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//     final result = await _api.settleContributionBatch(batch.id);
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(result['message']?.toString() ?? 'Done')),
//     );
//     _load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: _load,
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: TextField(
//               controller: _searchCtrl,
//               decoration: InputDecoration(
//                 hintText: 'Search by status or claim id...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchCtrl.text.isNotEmpty
//                     ? IconButton(icon: const Icon(Icons.close), onPressed: () => _searchCtrl.clear())
//                     : null,
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(child: _buildBody()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_loading) return const Center(child: CircularProgressIndicator());
//     if (_error != null) {
//       return ListView(
//         children: [
//           const SizedBox(height: 80),
//           Center(child: Text(_error!, textAlign: TextAlign.center)),
//           const SizedBox(height: 12),
//           Center(child: OutlinedButton(onPressed: _load, child: const Text('Retry'))),
//         ],
//       );
//     }
//     if (_filtered.isEmpty) {
//       return ListView(
//         children: [
//           const SizedBox(height: 100),
//           Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400, size: 48),
//           const SizedBox(height: 12),
//           Center(
//             child: Text(
//               _all.isEmpty ? 'No contribution batches found' : 'No batches match your search',
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//           ),
//         ],
//       );
//     }
//     return ListView.separated(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//       itemCount: _filtered.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 10),
//       itemBuilder: (context, i) {
//         final b = _filtered[i];
//         final settled = b.status == 'settled';
//         return Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text('Batch #${b.id} — Claim #${b.claimId}',
//                         style: const TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: (settled ? const Color(0xFF16A085) : const Color(0xFFC97C0F))
//                           .withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       b.status.toUpperCase(),
//                       style: TextStyle(
//                         color: settled ? const Color(0xFF16A085) : const Color(0xFFC97C0F),
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text('Enrolled: ${b.totalEnrolledSnapshot}',
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//               Text('Expected: ₹${b.expectedCollection.toStringAsFixed(2)}',
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//               Text('Management charge: ₹${b.managementCharge.toStringAsFixed(2)}',
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//               Text('Net settlement: ₹${b.netSettlement.toStringAsFixed(2)}',
//                   style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//               if (!settled) ...[
//                 const SizedBox(height: 10),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: OutlinedButton(
//                     onPressed: () => _settle(b),
//                     child: const Text('Settle batch'),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import '../models/receipt_model.dart';
// import '../models/contribution_batch_model.dart';
// import '../services/api_service.dart';
//
// class CollectionManageScreen extends StatefulWidget {
//   const CollectionManageScreen({super.key});
//
//   @override
//   State<CollectionManageScreen> createState() => _CollectionManageScreenState();
// }
//
// class _CollectionManageScreenState extends State<CollectionManageScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F6FB),
//       appBar: AppBar(
//         title: const Text('Collections & Contribution Master'),
//         backgroundColor: const Color(0xFFE0522F),
//         foregroundColor: Colors.white,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           tabs: const [
//             Tab(text: 'Receipts'),
//             Tab(text: 'Batches'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: const [
//           _ReceiptsTab(),
//           _BatchesTab(),
//         ],
//       ),
//     );
//   }
// }
//
// // ---------------- SHARED: DASHBOARD STAT CARDS ----------------
// // Computed client-side from the receipts list (Total / Joining Fee /
// // Contribution / Old Pending) so it mirrors the 4 cards on the web
// // "Collections & Contribution Master" screen without needing a new API.
//
// class _StatsRow extends StatelessWidget {
//   final List<ReceiptModel> receipts;
//   const _StatsRow({required this.receipts});
//
//   @override
//   Widget build(BuildContext context) {
//     final total = receipts.fold<double>(0, (sum, r) => sum + r.amount);
//     final joining = receipts
//         .where((r) => r.type.toLowerCase() == 'joining_fee')
//         .fold<double>(0, (sum, r) => sum + r.amount);
//     final contribution = receipts
//         .where((r) => r.type.toLowerCase() == 'contribution')
//         .fold<double>(0, (sum, r) => sum + r.amount);
//     final other = total - joining - contribution;
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//       child: Row(
//         children: [
//           Expanded(child: _statCard('Total Collections', total, const Color(0xFF16A085), Icons.savings_outlined)),
//           const SizedBox(width: 10),
//           Expanded(child: _statCard('Joining Fees', joining, const Color(0xFF2F7DE1), Icons.badge_outlined)),
//           const SizedBox(width: 10),
//           Expanded(child: _statCard('Contributions', contribution, const Color(0xFF6A5AE0), Icons.volunteer_activism_outlined)),
//           const SizedBox(width: 10),
//           Expanded(child: _statCard('Other', other < 0 ? 0 : other, const Color(0xFFC97C0F), Icons.restore_outlined)),
//         ],
//       ),
//     );
//   }
//
//   Widget _statCard(String label, double value, Color color, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 18),
//           const SizedBox(height: 6),
//           Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
//           const SizedBox(height: 2),
//           FittedBox(
//             child: Text('₹${value.toStringAsFixed(0)}',
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ---------------- RECEIPTS TAB ----------------
//
// class _ReceiptsTab extends StatefulWidget {
//   const _ReceiptsTab();
//
//   @override
//   State<_ReceiptsTab> createState() => _ReceiptsTabState();
// }
//
// class _ReceiptsTabState extends State<_ReceiptsTab> {
//   final _api = ApiService();
//   final _searchCtrl = TextEditingController();
//   List<ReceiptModel> _all = [];
//   List<ReceiptModel> _filtered = [];
//   bool _loading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//     _searchCtrl.addListener(_applyFilter);
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final receipts = await _api.getReceipts();
//       setState(() {
//         _all = receipts;
//         _filtered = receipts;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Could not load receipts: $e';
//         _loading = false;
//       });
//     }
//   }
//
//   void _applyFilter() {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     setState(() {
//       if (q.isEmpty) {
//         _filtered = _all;
//       } else {
//         _filtered = _all.where((r) {
//           return r.receiptNo.toLowerCase().contains(q) ||
//               r.type.toLowerCase().contains(q) ||
//               r.paymentMode.toLowerCase().contains(q) ||
//               r.memberId.toLowerCase().contains(q) ||
//               r.id.toLowerCase().contains(q);
//         }).toList();
//       }
//     });
//   }
//
//   Future<void> _openAddReceipt() async {
//     final memberCtrl = TextEditingController();
//     final karyakartaCtrl = TextEditingController();
//     final enrollmentCtrl = TextEditingController();
//     final amountCtrl = TextEditingController();
//     String type = 'joining_fee';
//     String paymentMode = 'Cash';
//
//     final created = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setSheetState) => Padding(
//           padding: EdgeInsets.only(
//             left: 20,
//             right: 20,
//             top: 20,
//             bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Collect Scheme Contribution',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: memberCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Member ID'),
//                 ),
//                 TextField(
//                   controller: karyakartaCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Karyakarta ID'),
//                 ),
//                 TextField(
//                   controller: enrollmentCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Enrollment ID'),
//                 ),
//                 TextField(
//                   controller: amountCtrl,
//                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                   decoration: const InputDecoration(labelText: 'Amount'),
//                 ),
//                 const SizedBox(height: 8),
//                 DropdownButtonFormField<String>(
//                   value: type,
//                   decoration: const InputDecoration(labelText: 'Type'),
//                   items: const [
//                     DropdownMenuItem(value: 'joining_fee', child: Text('Joining fee')),
//                     DropdownMenuItem(value: 'contribution', child: Text('Contribution')),
//                     DropdownMenuItem(value: 'other', child: Text('Other')),
//                   ],
//                   onChanged: (v) => setSheetState(() => type = v ?? type),
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: paymentMode,
//                   decoration: const InputDecoration(labelText: 'Payment mode'),
//                   items: const [
//                     DropdownMenuItem(value: 'Cash', child: Text('Cash')),
//                     DropdownMenuItem(value: 'Online', child: Text('Online')),
//                     DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
//                   ],
//                   onChanged: (v) => setSheetState(() => paymentMode = v ?? paymentMode),
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE0522F)),
//                     onPressed: () async {
//                       final payload = {
//                         "member_id": int.tryParse(memberCtrl.text) ?? 0,
//                         "karyakarta_id": int.tryParse(karyakartaCtrl.text) ?? 0,
//                         "enrollment_id": int.tryParse(enrollmentCtrl.text) ?? 0,
//                         "amount": double.tryParse(amountCtrl.text) ?? 0,
//                         "type": type,
//                         "payment_mode": paymentMode,
//                         "ref_batch_id": 0,
//                         "ref_claim_id": 0,
//                       };
//                       final result = await _api.createReceipt(payload);
//                       if (ctx.mounted) {
//                         Navigator.pop(ctx, result['success'] == true);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text(result['message']?.toString() ?? 'Done')),
//                         );
//                       }
//                     },
//                     child: const Text('Create Receipt', style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//
//     if (created == true) _load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _openAddReceipt,
//         backgroundColor: const Color(0xFFE0522F),
//         icon: const Icon(Icons.add),
//         label: const Text('Collect Payment'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _load,
//         child: Column(
//           children: [
//             if (!_loading && _error == null) _StatsRow(receipts: _all),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//               child: TextField(
//                 controller: _searchCtrl,
//                 decoration: InputDecoration(
//                   hintText: 'Search by receipt no, type, payment mode...',
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: _searchCtrl.text.isNotEmpty
//                       ? IconButton(icon: const Icon(Icons.close), onPressed: () => _searchCtrl.clear())
//                       : null,
//                   filled: true,
//                   fillColor: Colors.white,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(child: _buildBody()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_loading) return const Center(child: CircularProgressIndicator());
//     if (_error != null) {
//       return ListView(
//         children: [
//           const SizedBox(height: 80),
//           Center(child: Text(_error!, textAlign: TextAlign.center)),
//           const SizedBox(height: 12),
//           Center(child: OutlinedButton(onPressed: _load, child: const Text('Retry'))),
//         ],
//       );
//     }
//     if (_filtered.isEmpty) {
//       return ListView(
//         children: [
//           const SizedBox(height: 100),
//           Icon(Icons.receipt_long_outlined, color: Colors.grey.shade400, size: 48),
//           const SizedBox(height: 12),
//           Center(
//             child: Text(
//               _all.isEmpty ? 'No receipts found' : 'No receipts match your search',
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//           ),
//         ],
//       );
//     }
//     return ListView.separated(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
//       itemCount: _filtered.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 10),
//       itemBuilder: (context, i) {
//         final r = _filtered[i];
//         return Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Row(
//             children: [
//               const CircleAvatar(
//                 radius: 20,
//                 backgroundColor: Color(0xFFFBE3DD),
//                 child: Icon(Icons.receipt_long_outlined, color: Color(0xFFE0522F)),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(r.receiptNo.isEmpty ? 'Receipt #${r.id}' : r.receiptNo,
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                     const SizedBox(height: 2),
//                     Text('${r.type} • ${r.paymentMode}',
//                         style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//                   ],
//                 ),
//               ),
//               Text('₹${r.amount.toStringAsFixed(2)}',
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ---------------- BATCHES TAB ----------------
//
// class _BatchesTab extends StatefulWidget {
//   const _BatchesTab();
//
//   @override
//   State<_BatchesTab> createState() => _BatchesTabState();
// }
//
// class _BatchesTabState extends State<_BatchesTab> {
//   final _api = ApiService();
//   final _searchCtrl = TextEditingController();
//   List<ContributionBatchModel> _all = [];
//   List<ContributionBatchModel> _filtered = [];
//   bool _loading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//     _searchCtrl.addListener(_applyFilter);
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final batches = await _api.getContributionBatches();
//       setState(() {
//         _all = batches;
//         _filtered = batches;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Could not load batches: $e';
//         _loading = false;
//       });
//     }
//   }
//
//   void _applyFilter() {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     setState(() {
//       if (q.isEmpty) {
//         _filtered = _all;
//       } else {
//         _filtered = _all.where((b) {
//           return b.status.toLowerCase().contains(q) ||
//               b.claimId.toLowerCase().contains(q) ||
//               b.id.toLowerCase().contains(q);
//         }).toList();
//       }
//     });
//   }
//
//   Future<void> _settle(ContributionBatchModel batch) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Settle batch'),
//         content: Text('Settle batch #${batch.id}? This cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
//           ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Settle')),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//     final result = await _api.settleContributionBatch(batch.id);
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(result['message']?.toString() ?? 'Done')),
//     );
//     _load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: _load,
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: TextField(
//               controller: _searchCtrl,
//               decoration: InputDecoration(
//                 hintText: 'Search by status or claim id...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchCtrl.text.isNotEmpty
//                     ? IconButton(icon: const Icon(Icons.close), onPressed: () => _searchCtrl.clear())
//                     : null,
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(child: _buildBody()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_loading) return const Center(child: CircularProgressIndicator());
//     if (_error != null) {
//       return ListView(
//         children: [
//           const SizedBox(height: 80),
//           Center(child: Text(_error!, textAlign: TextAlign.center)),
//           const SizedBox(height: 12),
//           Center(child: OutlinedButton(onPressed: _load, child: const Text('Retry'))),
//         ],
//       );
//     }
//     if (_filtered.isEmpty) {
//       return ListView(
//         children: [
//           const SizedBox(height: 100),
//           Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400, size: 48),
//           const SizedBox(height: 12),
//           Center(
//             child: Text(
//               _all.isEmpty ? 'No contribution batches found' : 'No batches match your search',
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//           ),
//         ],
//       );
//     }
//     return ListView.separated(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//       itemCount: _filtered.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 10),
//       itemBuilder: (context, i) {
//         final b = _filtered[i];
//         final settled = b.status == 'settled';
//         return Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text('Batch #${b.id} — Claim #${b.claimId}',
//                         style: const TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: (settled ? const Color(0xFF16A085) : const Color(0xFFC97C0F))
//                           .withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       b.status.toUpperCase(),
//                       style: TextStyle(
//                         color: settled ? const Color(0xFF16A085) : const Color(0xFFC97C0F),
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text('Enrolled: ${b.totalEnrolledSnapshot}',
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//               Text('Expected: ₹${b.expectedCollection.toStringAsFixed(2)}',
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//               Text('Management charge: ₹${b.managementCharge.toStringAsFixed(2)}',
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//               Text('Net settlement: ₹${b.netSettlement.toStringAsFixed(2)}',
//                   style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//               if (!settled) ...[
//                 const SizedBox(height: 10),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: OutlinedButton(
//                     onPressed: () => _settle(b),
//                     child: const Text('Settle batch'),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CollectionManageScreen extends StatefulWidget {
  const CollectionManageScreen({super.key});

  @override
  State<CollectionManageScreen> createState() => _CollectionManageScreenState();
}

class _CollectionManageScreenState extends State<CollectionManageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(
        title: const Text('Collections & Contribution Master'),
        backgroundColor: const Color(0xFFE0522F),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Master Register'),
            Tab(text: 'Joining Fee'),
            Tab(text: 'Contribution Received'),
            Tab(text: 'Current Active Claims'),
            Tab(text: 'Old Paid Claims'),
            Tab(text: 'Closed Claims'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DashboardTab(),
          _MasterRegisterTab(category: null, title: 'Master Register'),
          _MasterRegisterTab(category: 'joining_fee', title: 'Joining Fee'),
          _MasterRegisterTab(category: 'contribution', title: 'Contribution Received'),
          _ClaimsStatusTab(status: 'pending', emptyLabel: 'No active claims'),
          _ClaimsStatusTab(status: 'settled', emptyLabel: 'No old paid claims'),
          _ClaimsStatusTab(status: 'rejected', emptyLabel: 'No closed claims'),
        ],
      ),
    );
  }
}

// ==================== DASHBOARD TAB ====================
// GET /api/collections/dashboard

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final _api = ApiService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getCollectionsDashboard();
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load dashboard: $e';
        _loading = false;
      });
    }
  }

  double _num(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            Center(child: Text(_error!, textAlign: TextAlign.center)),
            const SizedBox(height: 12),
            Center(child: OutlinedButton(onPressed: _load, child: const Text('Retry'))),
          ],
        ),
      );
    }

    final stats = Map<String, dynamic>.from(_data?['stats'] ?? {});
    final latest = List<Map<String, dynamic>>.from(
        (_data?['latest_collections'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? []);
    final topKaryakartas = List<Map<String, dynamic>>.from(
        (_data?['top_karyakartas'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? []);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: [
              _statCard('Total Collections', _num(stats['total_collections']), const Color(0xFF16A085), Icons.savings_outlined),
              _statCard('Joining Fees', _num(stats['total_joining_fees']), const Color(0xFF2F7DE1), Icons.badge_outlined),
              _statCard('Event Contributions', _num(stats['total_event_contributions']), const Color(0xFF6A5AE0), Icons.volunteer_activism_outlined),
              _statCard('Old Pending Recovery', _num(stats['old_pending_recovery']), const Color(0xFFC97C0F), Icons.restore_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(child: _miniStat('Today Total', _num(stats['today_total_collection']))),
                Expanded(child: _miniStat('Today Joining', _num(stats['today_joining_fees']))),
                Expanded(child: _miniStat('Today Contrib.', _num(stats['today_contribution']))),
                Expanded(child: _miniStat('This Month', _num(stats['this_month_total']))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Latest Collections', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          if (latest.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No recent collections', style: TextStyle(color: Colors.grey.shade600))),
            )
          else
            ...latest.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['receipt_no']?.toString() ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          '${r['type'] ?? ''} • ${r['member_name'] ?? 'Member #${r['member_code'] ?? '-'}'} • ${r['karyakarta_code'] ?? '-'}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text('₹${_num(r['amount']).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          const SizedBox(height: 20),
          const Text('Top Collected by Karyakarta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          if (topKaryakartas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No data yet', style: TextStyle(color: Colors.grey.shade600))),
            )
          else
            ...topKaryakartas.map((k) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFFBEBD4),
                    child: Text(
                      (k['karyakarta_code']?.toString().isNotEmpty == true)
                          ? k['karyakarta_code'].toString().substring(0, 1)
                          : '?',
                      style: const TextStyle(color: Color(0xFFC97C0F), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(k['full_name']?.toString() ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(
                          '${k['karyakarta_code'] ?? '-'} • ${k['district'] ?? '-'} • ${k['receipt_count'] ?? 0} receipts',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text('₹${_num(k['total_collected']).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _statCard(String label, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          const SizedBox(height: 2),
          FittedBox(
            child: Text('₹${value.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, double value) {
    return Column(
      children: [
        Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }
}

// ==================== MASTER REGISTER / JOINING FEE / CONTRIBUTION TAB ====================
// GET /api/payment/master-register?type=collection[&category=joining_fee|contribution]

class _MasterRegisterTab extends StatefulWidget {
  final String? category; // null = all (Master Register), 'joining_fee', 'contribution'
  final String title;
  const _MasterRegisterTab({required this.category, required this.title});

  @override
  State<_MasterRegisterTab> createState() => _MasterRegisterTabState();
}

class _MasterRegisterTabState extends State<_MasterRegisterTab> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilter);
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
      final list = await _api.getMasterRegister(type: 'collection', category: widget.category);
      setState(() {
        _all = list;
        _loading = false;
      });
      _applyFilter();
    } catch (e) {
      setState(() {
        _error = 'Could not load ${widget.title}: $e';
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((r) {
          return (r['receipt_no']?.toString() ?? '').toLowerCase().contains(q) ||
              (r['type']?.toString() ?? '').toLowerCase().contains(q) ||
              (r['payment_mode']?.toString() ?? '').toLowerCase().contains(q) ||
              (r['collected_by']?.toString() ?? '').toLowerCase().contains(q) ||
              (r['member_id']?.toString() ?? '').toLowerCase().contains(q) ||
              (r['karyakarta_id']?.toString() ?? '').toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  double _num(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

  @override
  Widget build(BuildContext context) {
    final total = _all.fold<double>(0, (sum, r) => sum + _num(r['amount']));
    return RefreshIndicator(
      onRefresh: _load,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by receipt no, payment mode, collected by...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close), onPressed: () => _searchCtrl.clear())
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${_filtered.length} records • Total ₹${total.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ),
            ),
          const SizedBox(height: 6),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(child: Text(_error!, textAlign: TextAlign.center)),
          const SizedBox(height: 12),
          Center(child: OutlinedButton(onPressed: _load, child: const Text('Retry'))),
        ],
      );
    }
    if (_filtered.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.receipt_long_outlined, color: Colors.grey.shade400, size: 48),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _all.isEmpty ? 'No records found' : 'No records match your search',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final r = _filtered[i];
        final type = (r['type']?.toString() ?? '').replaceAll('_', ' ');
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFFBE3DD),
                child: Icon(Icons.receipt_long_outlined, color: Color(0xFFE0522F)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['receipt_no']?.toString() ?? 'Receipt #${r['id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      '${type.isEmpty ? '-' : type} • ${r['payment_mode'] ?? '-'} • by ${r['collected_by'] ?? '-'}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    if (r['created_at'] != null)
                      Text(r['created_at'].toString(), style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                  ],
                ),
              ),
              Text('₹${_num(r['amount']).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}

// ==================== CLAIMS STATUS TAB (Current Active / Old Paid / Closed) ====================
// GET /api/claims?status=pending|settled|rejected

class _ClaimsStatusTab extends StatefulWidget {
  final String status;
  final String emptyLabel;
  const _ClaimsStatusTab({required this.status, required this.emptyLabel});

  @override
  State<_ClaimsStatusTab> createState() => _ClaimsStatusTabState();
}

class _ClaimsStatusTabState extends State<_ClaimsStatusTab> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilter);
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
      final list = await _api.getClaimsRaw(status: widget.status);
      setState(() {
        _all = list;
        _loading = false;
      });
      _applyFilter();
    } catch (e) {
      setState(() {
        _error = 'Could not load claims: $e';
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((c) {
          return (c['member_name']?.toString() ?? '').toLowerCase().contains(q) ||
              (c['claim_request_no']?.toString() ?? '').toLowerCase().contains(q) ||
              (c['scheme_name']?.toString() ?? '').toLowerCase().contains(q) ||
              (c['karyakarta_code']?.toString() ?? '').toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  double _num(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by member, request no, scheme...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close), onPressed: () => _searchCtrl.clear())
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(child: Text(_error!, textAlign: TextAlign.center)),
          const SizedBox(height: 12),
          Center(child: OutlinedButton(onPressed: _load, child: const Text('Retry'))),
        ],
      );
    }
    if (_filtered.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400, size: 48),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _all.isEmpty ? widget.emptyLabel : 'No claims match your search',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final c = _filtered[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(c['claim_request_no']?.toString() ?? 'Claim #${c['id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Text('₹${_num(c['net_payable_amount']).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Text('${c['member_name'] ?? '-'} • ${c['scheme_name'] ?? '-'}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              Text('Karyakarta: ${c['karyakarta_code'] ?? '-'} • Event: ${c['event_type'] ?? '-'}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _statusBadge((c['status'] ?? '-').toString()),
                  const SizedBox(width: 6),
                  if (c['collection_status'] != null) _statusBadge(c['collection_status'].toString(), outline: true),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status, {bool outline = false}) {
    final color = _colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : color.withOpacity(0.12),
        border: outline ? Border.all(color: color) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _colorFor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'settled':
      case 'approved':
      case 'received':
        return const Color(0xFF16A085);
      case 'rejected':
        return const Color(0xFFE0522F);
      default:
        return const Color(0xFFC97C0F);
    }
  }
}