// import 'package:flutter/material.dart';
// import '../models/claim_model.dart';
// import '../services/api_service.dart';
//
// class ClaimManageScreen extends StatefulWidget {
//   const ClaimManageScreen({super.key});
//
//   @override
//   State<ClaimManageScreen> createState() => _ClaimManageScreenState();
// }
//
// class _ClaimManageScreenState extends State<ClaimManageScreen> {
//   final _api = ApiService();
//   final _searchCtrl = TextEditingController();
//
//   List<ClaimModel> _all = [];
//   List<ClaimModel> _filtered = [];
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
//       final claims = await _api.getClaims();
//       setState(() {
//         _all = claims;
//         _filtered = claims;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Could not load claims: $e';
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
//         _filtered = _all.where((c) {
//           return c.claimType.toLowerCase().contains(q) ||
//               c.hospitalName.toLowerCase().contains(q) ||
//               c.status.toLowerCase().contains(q) ||
//               c.enrollmentId.toLowerCase().contains(q) ||
//               c.id.toLowerCase().contains(q);
//         }).toList();
//       }
//     });
//   }
//
//   Color _statusColor(String status) {
//     switch (status) {
//       case 'approved':
//         return const Color(0xFF16A085);
//       case 'rejected':
//         return const Color(0xFFE0522F);
//       case 'paid':
//         return const Color(0xFF2F7DE1);
//       default:
//         return const Color(0xFFC97C0F);
//     }
//   }
//
//   void _openClaim(ClaimModel claim) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (ctx) => _ClaimDetailSheet(
//         claim: claim,
//         onChanged: _load,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F6FB),
//       appBar: AppBar(
//         title: const Text('Claim Manage'),
//         backgroundColor: const Color(0xFF6A5AE0),
//         foregroundColor: Colors.white,
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
//                   hintText: 'Search by type, hospital, status, enrollment id...',
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: _searchCtrl.text.isNotEmpty
//                       ? IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => _searchCtrl.clear(),
//                   )
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
//           Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
//           const SizedBox(height: 12),
//           Center(child: Text(_error!, textAlign: TextAlign.center)),
//           const SizedBox(height: 12),
//           Center(
//             child: OutlinedButton(onPressed: _load, child: const Text('Retry')),
//           ),
//         ],
//       );
//     }
//     if (_filtered.isEmpty) {
//       return ListView(
//         children: [
//           const SizedBox(height: 100),
//           Icon(Icons.description_outlined, color: Colors.grey.shade400, size: 48),
//           const SizedBox(height: 12),
//           Center(
//             child: Text(
//               _all.isEmpty ? 'No claims found' : 'No claims match your search',
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
//         final c = _filtered[i];
//         return InkWell(
//           borderRadius: BorderRadius.circular(14),
//           onTap: () => _openClaim(c),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: const Color(0xFFFBEBD4),
//                   child: const Icon(Icons.description_outlined, color: Color(0xFFC97C0F)),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(c.claimType.isEmpty ? 'Claim #${c.id}' : c.claimType,
//                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                       const SizedBox(height: 2),
//                       Text(c.hospitalName.isEmpty ? 'Enrollment #${c.enrollmentId}' : c.hospitalName,
//                           style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text('₹${c.claimAmount.toStringAsFixed(0)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 4),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: _statusColor(c.status).withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         c.status.toUpperCase(),
//                         style: TextStyle(
//                             color: _statusColor(c.status), fontSize: 11, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _ClaimDetailSheet extends StatefulWidget {
//   final ClaimModel claim;
//   final VoidCallback onChanged;
//   const _ClaimDetailSheet({required this.claim, required this.onChanged});
//
//   @override
//   State<_ClaimDetailSheet> createState() => _ClaimDetailSheetState();
// }
//
// class _ClaimDetailSheetState extends State<_ClaimDetailSheet> {
//   final _api = ApiService();
//   bool _busy = false;
//
//   Future<void> _approve() async {
//     final amountCtrl =
//     TextEditingController(text: widget.claim.claimAmount.toStringAsFixed(2));
//     final remarksCtrl = TextEditingController();
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Approve claim'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: amountCtrl,
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               decoration: const InputDecoration(labelText: 'Approved amount'),
//             ),
//             TextField(
//               controller: remarksCtrl,
//               decoration: const InputDecoration(labelText: 'Remarks (optional)'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
//           ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve')),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//
//     setState(() => _busy = true);
//     final result = await _api.approveClaim(
//       widget.claim.id,
//       approvedAmount: double.tryParse(amountCtrl.text) ?? widget.claim.claimAmount,
//       remarks: remarksCtrl.text.trim().isEmpty ? null : remarksCtrl.text.trim(),
//     );
//     setState(() => _busy = false);
//     _finish(result);
//   }
//
//   Future<void> _reject() async {
//     final reasonCtrl = TextEditingController();
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Reject claim'),
//         content: TextField(
//           controller: reasonCtrl,
//           decoration: const InputDecoration(labelText: 'Rejection reason'),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
//           ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reject')),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//     if (reasonCtrl.text.trim().isEmpty) return;
//
//     setState(() => _busy = true);
//     final result = await _api.rejectClaim(widget.claim.id, reasonCtrl.text.trim());
//     setState(() => _busy = false);
//     _finish(result);
//   }
//
//   void _finish(Map<String, dynamic> result) {
//     if (!mounted) return;
//     Navigator.pop(context); // close sheet
//     widget.onChanged();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(result['message']?.toString() ?? 'Done')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final c = widget.claim;
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.only(
//           left: 20,
//           right: 20,
//           top: 20,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(c.claimType.isEmpty ? 'Claim #${c.id}' : c.claimType,
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             const SizedBox(height: 12),
//             _row('Enrollment ID', c.enrollmentId),
//             _row('Hospital', c.hospitalName),
//             _row('Claim date', c.claimDate),
//             _row('Claim amount', '₹${c.claimAmount.toStringAsFixed(2)}'),
//             if (c.approvedAmount != null)
//               _row('Approved amount', '₹${c.approvedAmount!.toStringAsFixed(2)}'),
//             _row('Reason', c.reason),
//             _row('Status', c.status.toUpperCase()),
//             if (c.rejectionReason != null && c.rejectionReason!.isNotEmpty)
//               _row('Rejection reason', c.rejectionReason!),
//             const SizedBox(height: 16),
//             if (c.status == 'pending')
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: _busy ? null : _reject,
//                       icon: const Icon(Icons.close, color: Color(0xFFE0522F)),
//                       label: const Text('Reject', style: TextStyle(color: Color(0xFFE0522F))),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: _busy ? null : _approve,
//                       style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A085)),
//                       icon: const Icon(Icons.check, color: Colors.white),
//                       label: const Text('Approve', style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ],
//               ),
//             if (_busy) const Padding(
//               padding: EdgeInsets.only(top: 12),
//               child: Center(child: CircularProgressIndicator()),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _row(String label, String value) {
//     if (value.isEmpty) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 130,
//             child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//           ),
//           Expanded(
//             child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import '../models/claim_model.dart';
// import '../services/api_service.dart';
//
// class ClaimManageScreen extends StatefulWidget {
//   const ClaimManageScreen({super.key});
//
//   @override
//   State<ClaimManageScreen> createState() => _ClaimManageScreenState();
// }
//
// class _ClaimManageScreenState extends State<ClaimManageScreen> {
//   final _api = ApiService();
//   final _searchCtrl = TextEditingController();
//
//   List<ClaimModel> _all = [];
//   List<ClaimModel> _filtered = [];
//   bool _loading = true;
//   String? _error;
//   String _statusFilter = 'all'; // all / pending / approved / rejected / paid
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
//       final claims = await _api.getClaims();
//       setState(() {
//         _all = claims;
//         _loading = false;
//       });
//       _applyFilter();
//     } catch (e) {
//       setState(() {
//         _error = 'Could not load claims: $e';
//         _loading = false;
//       });
//     }
//   }
//
//   void _applyFilter() {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     setState(() {
//       var result = _all;
//       if (_statusFilter != 'all') {
//         result = result.where((c) => c.status == _statusFilter).toList();
//       }
//       if (q.isNotEmpty) {
//         result = result.where((c) {
//           return c.claimType.toLowerCase().contains(q) ||
//               c.hospitalName.toLowerCase().contains(q) ||
//               c.status.toLowerCase().contains(q) ||
//               c.enrollmentId.toLowerCase().contains(q) ||
//               c.id.toLowerCase().contains(q) ||
//               (c.memberName ?? '').toLowerCase().contains(q) ||
//               (c.requestNo ?? '').toLowerCase().contains(q) ||
//               (c.taggedKaryakarta ?? '').toLowerCase().contains(q);
//         }).toList();
//       }
//       _filtered = result;
//     });
//   }
//
//   Color _statusColor(String status) {
//     switch (status) {
//       case 'approved':
//         return const Color(0xFF16A085);
//       case 'rejected':
//         return const Color(0xFFE0522F);
//       case 'paid':
//         return const Color(0xFF2F7DE1);
//       default:
//         return const Color(0xFFC97C0F);
//     }
//   }
//
//   void _openClaim(ClaimModel claim) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (ctx) => _ClaimDetailSheet(
//         claim: claim,
//         onChanged: _load,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F6FB),
//       appBar: AppBar(
//         title: const Text('Claims & Settlement Manager'),
//         backgroundColor: const Color(0xFF6A5AE0),
//         foregroundColor: Colors.white,
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
//                   hintText: 'Search Claim ID, Member, Scheme, Karyakarta...',
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: _searchCtrl.text.isNotEmpty
//                       ? IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => _searchCtrl.clear(),
//                   )
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
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     _filterChip('All', 'all'),
//                     _filterChip('Pending', 'pending'),
//                     _filterChip('Approved', 'approved'),
//                     _filterChip('Rejected', 'rejected'),
//                     _filterChip('Paid', 'paid'),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 6),
//             Expanded(child: _buildBody()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _filterChip(String label, String value) {
//     final selected = _statusFilter == value;
//     return Padding(
//       padding: const EdgeInsets.only(right: 8, bottom: 6),
//       child: ChoiceChip(
//         label: Text(label),
//         selected: selected,
//         onSelected: (_) {
//           _statusFilter = value;
//           _applyFilter();
//         },
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
//           Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
//           const SizedBox(height: 12),
//           Center(child: Text(_error!, textAlign: TextAlign.center)),
//           const SizedBox(height: 12),
//           Center(
//             child: OutlinedButton(onPressed: _load, child: const Text('Retry')),
//           ),
//         ],
//       );
//     }
//     if (_filtered.isEmpty) {
//       return ListView(
//         children: [
//           const SizedBox(height: 100),
//           Icon(Icons.description_outlined, color: Colors.grey.shade400, size: 48),
//           const SizedBox(height: 12),
//           Center(
//             child: Text(
//               _all.isEmpty ? 'No claims registered yet' : 'No claims match your filter',
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
//         final c = _filtered[i];
//         return InkWell(
//           borderRadius: BorderRadius.circular(14),
//           onTap: () => _openClaim(c),
//           child: Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: const Color(0xFFFBEBD4),
//                   child: const Icon(Icons.description_outlined, color: Color(0xFFC97C0F)),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         c.requestNo ?? (c.claimType.isEmpty ? 'Claim #${c.id}' : c.claimType),
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         c.memberName ?? (c.hospitalName.isEmpty ? 'Enrollment #${c.enrollmentId}' : c.hospitalName),
//                         style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//                       ),
//                       if (c.taggedKaryakarta != null)
//                         Text('Karyakarta: ${c.taggedKaryakarta}',
//                             style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text('₹${(c.netPayable ?? c.claimAmount).toStringAsFixed(0)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 4),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: _statusColor(c.status).withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         c.status.toUpperCase(),
//                         style: TextStyle(
//                             color: _statusColor(c.status), fontSize: 11, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     if (c.collectionStatus != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 3),
//                         child: Text(c.collectionStatus!.toUpperCase(),
//                             style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _ClaimDetailSheet extends StatefulWidget {
//   final ClaimModel claim;
//   final VoidCallback onChanged;
//   const _ClaimDetailSheet({required this.claim, required this.onChanged});
//
//   @override
//   State<_ClaimDetailSheet> createState() => _ClaimDetailSheetState();
// }
//
// class _ClaimDetailSheetState extends State<_ClaimDetailSheet> {
//   final _api = ApiService();
//   bool _busy = false;
//
//   Future<void> _approve() async {
//     final amountCtrl =
//     TextEditingController(text: widget.claim.claimAmount.toStringAsFixed(2));
//     final remarksCtrl = TextEditingController();
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Approve claim'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: amountCtrl,
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               decoration: const InputDecoration(labelText: 'Approved amount'),
//             ),
//             TextField(
//               controller: remarksCtrl,
//               decoration: const InputDecoration(labelText: 'Remarks (optional)'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
//           ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve')),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//
//     setState(() => _busy = true);
//     final result = await _api.approveClaim(
//       widget.claim.id,
//       approvedAmount: double.tryParse(amountCtrl.text) ?? widget.claim.claimAmount,
//       remarks: remarksCtrl.text.trim().isEmpty ? null : remarksCtrl.text.trim(),
//     );
//     setState(() => _busy = false);
//     _finish(result);
//   }
//
//   Future<void> _reject() async {
//     final reasonCtrl = TextEditingController();
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Reject claim'),
//         content: TextField(
//           controller: reasonCtrl,
//           decoration: const InputDecoration(labelText: 'Rejection reason'),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
//           ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reject')),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
//     if (reasonCtrl.text.trim().isEmpty) return;
//
//     setState(() => _busy = true);
//     final result = await _api.rejectClaim(widget.claim.id, reasonCtrl.text.trim());
//     setState(() => _busy = false);
//     _finish(result);
//   }
//
//   void _finish(Map<String, dynamic> result) {
//     if (!mounted) return;
//     Navigator.pop(context); // close sheet
//     widget.onChanged();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(result['message']?.toString() ?? 'Done')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final c = widget.claim;
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.only(
//           left: 20,
//           right: 20,
//           top: 20,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(c.requestNo ?? (c.claimType.isEmpty ? 'Claim #${c.id}' : c.claimType),
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//               const SizedBox(height: 12),
//               if (c.memberName != null) _row('Member', c.memberName!),
//               _row('Enrollment ID', c.enrollmentId),
//               if (c.schemeName != null) _row('Scheme', c.schemeName!),
//               if (c.taggedKaryakarta != null) _row('Tagged Karyakarta', c.taggedKaryakarta!),
//               if (c.eventType != null) _row('Event Type', c.eventType!),
//               _row('Hospital', c.hospitalName),
//               _row('Claim date', c.claimDate),
//               _row('Claim amount', '₹${c.claimAmount.toStringAsFixed(2)}'),
//               if (c.approvedAmount != null)
//                 _row('Approved amount', '₹${c.approvedAmount!.toStringAsFixed(2)}'),
//               if (c.netPayable != null) _row('Net payable', '₹${c.netPayable!.toStringAsFixed(2)}'),
//               _row('Reason', c.reason),
//               _row('Status', c.status.toUpperCase()),
//               if (c.collectionStatus != null) _row('Collection status', c.collectionStatus!.toUpperCase()),
//               if (c.rejectionReason != null && c.rejectionReason!.isNotEmpty)
//                 _row('Rejection reason', c.rejectionReason!),
//               const SizedBox(height: 16),
//               if (c.status == 'pending')
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: _busy ? null : _reject,
//                         icon: const Icon(Icons.close, color: Color(0xFFE0522F)),
//                         label: const Text('Reject', style: TextStyle(color: Color(0xFFE0522F))),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: _busy ? null : _approve,
//                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A085)),
//                         icon: const Icon(Icons.check, color: Colors.white),
//                         label: const Text('Approve', style: TextStyle(color: Colors.white)),
//                       ),
//                     ),
//                   ],
//                 ),
//               if (_busy) const Padding(
//                 padding: EdgeInsets.only(top: 12),
//                 child: Center(child: CircularProgressIndicator()),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _row(String label, String value) {
//     if (value.isEmpty) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//           ),
//           Expanded(
//             child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ClaimManageScreen extends StatefulWidget {
  const ClaimManageScreen({super.key});

  @override
  State<ClaimManageScreen> createState() => _ClaimManageScreenState();
}

class _ClaimManageScreenState extends State<ClaimManageScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'all';

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
      final claims = await _api.getClaimsRaw(); // GET /api/claims (all)
      setState(() {
        _all = claims;
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
      var result = _all;
      if (_statusFilter != 'all') {
        result = result
            .where((c) => (c['status']?.toString().toLowerCase() ?? '') == _statusFilter)
            .toList();
      }
      if (q.isNotEmpty) {
        result = result.where((c) {
          return (c['claim_request_no']?.toString() ?? '').toLowerCase().contains(q) ||
              (c['member_name']?.toString() ?? '').toLowerCase().contains(q) ||
              (c['member_code']?.toString() ?? '').toLowerCase().contains(q) ||
              (c['scheme_name']?.toString() ?? '').toLowerCase().contains(q) ||
              (c['karyakarta_code']?.toString() ?? '').toLowerCase().contains(q) ||
              (c['status']?.toString() ?? '').toLowerCase().contains(q) ||
              (c['id']?.toString() ?? '').toLowerCase().contains(q);
        }).toList();
      }
      _filtered = result;
    });
  }

  double _num(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'approved':
      case 'settled':
        return const Color(0xFF16A085);
      case 'rejected':
        return const Color(0xFFE0522F);
      case 'submitted':
        return const Color(0xFF2F7DE1);
      default:
        return const Color(0xFFC97C0F); // pending / others
    }
  }

  void _openClaim(Map<String, dynamic> claim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _ClaimDetailSheet(claim: claim, onChanged: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(
        title: const Text('Claims & Settlement Manager'),
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search Claim ID, Member, Scheme, Karyakarta...',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('All', 'all'),
                    _filterChip('Submitted', 'submitted'),
                    _filterChip('Pending', 'pending'),
                    _filterChip('Paid', 'paid'),
                    _filterChip('Rejected', 'rejected'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          _statusFilter = value;
          _applyFilter();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
          const SizedBox(height: 12),
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
          Icon(Icons.description_outlined, color: Colors.grey.shade400, size: 48),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _all.isEmpty ? 'No claims registered yet' : 'No claims match your filter',
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
        final status = (c['status'] ?? '-').toString();
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openClaim(c),
          child: Container(
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
                  backgroundColor: Color(0xFFFBEBD4),
                  child: Icon(Icons.description_outlined, color: Color(0xFFC97C0F)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['claim_request_no']?.toString() ?? 'Claim #${c['id']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        '${c['member_name'] ?? '-'} • ${c['scheme_name'] ?? '-'}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      Text('Karyakarta: ${c['karyakarta_code'] ?? '-'}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${_num(c['net_payable_amount']).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (c['collection_status'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(c['collection_status'].toString().toUpperCase(),
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClaimDetailSheet extends StatefulWidget {
  final Map<String, dynamic> claim;
  final VoidCallback onChanged;
  const _ClaimDetailSheet({required this.claim, required this.onChanged});

  @override
  State<_ClaimDetailSheet> createState() => _ClaimDetailSheetState();
}

class _ClaimDetailSheetState extends State<_ClaimDetailSheet> {
  final _api = ApiService();
  bool _busy = false;

  double _num(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

  Future<void> _approve() async {
    final claimed = _num(widget.claim['calculated_amount']);
    final amountCtrl = TextEditingController(
      text: (claimed > 0 ? claimed : _num(widget.claim['net_payable_amount'])).toStringAsFixed(2),
    );
    final remarksCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Approved amount'),
            ),
            TextField(
              controller: remarksCtrl,
              decoration: const InputDecoration(labelText: 'Remarks (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    final result = await _api.approveClaim(
      widget.claim['id'].toString(),
      approvedAmount: double.tryParse(amountCtrl.text) ?? claimed,
      remarks: remarksCtrl.text.trim().isEmpty ? null : remarksCtrl.text.trim(),
    );
    setState(() => _busy = false);
    _finish(result);
  }

  Future<void> _reject() async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject claim'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Rejection reason'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reject')),
        ],
      ),
    );
    if (confirmed != true) return;
    if (reasonCtrl.text.trim().isEmpty) return;

    setState(() => _busy = true);
    final result = await _api.rejectClaim(widget.claim['id'].toString(), reasonCtrl.text.trim());
    setState(() => _busy = false);
    _finish(result);
  }

  void _finish(Map<String, dynamic> result) {
    if (!mounted) return;
    Navigator.pop(context);
    widget.onChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']?.toString() ?? 'Done')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.claim;
    final status = (c['status'] ?? '').toString().toLowerCase();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c['claim_request_no']?.toString() ?? 'Claim #${c['id']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              _row('Member', c['member_name']?.toString() ?? '-'),
              _row('Member ID', c['member_code']?.toString() ?? '-'),
              _row('Scheme', c['scheme_name']?.toString() ?? '-'),
              _row('Karyakarta', c['karyakarta_code']?.toString() ?? '-'),
              _row('Event type', c['event_type']?.toString() ?? '-'),
              _row('Event date', c['event_date']?.toString() ?? '-'),
              _row('Claim date', c['claim_date']?.toString() ?? '-'),
              _row('Calculated amount', '₹${_num(c['calculated_amount']).toStringAsFixed(2)}'),
              _row('Approved amount', '₹${_num(c['approved_amount']).toStringAsFixed(2)}'),
              _row('Net payable', '₹${_num(c['net_payable_amount']).toStringAsFixed(2)}'),
              _row('Disbursed amount', '₹${_num(c['disbursed_amount']).toStringAsFixed(2)}'),
              _row('Status', status.toUpperCase()),
              _row('Collection status', c['collection_status']?.toString().toUpperCase() ?? '-'),
              if ((c['rejection_reason']?.toString() ?? '').isNotEmpty)
                _row('Rejection reason', c['rejection_reason'].toString()),
              const SizedBox(height: 16),
              if (status == 'pending' || status == 'submitted')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _reject,
                        icon: const Icon(Icons.close, color: Color(0xFFE0522F)),
                        label: const Text('Reject', style: TextStyle(color: Color(0xFFE0522F))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _busy ? null : _approve,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A085)),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('Approve', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    if (value.isEmpty || value == '-') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}