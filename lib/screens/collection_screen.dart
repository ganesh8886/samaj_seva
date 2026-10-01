// import 'package:flutter/material.dart';
//
// /// ---------------------------------------------------------------------
// /// SCHEME FEE / CONTRIBUTION TABLES
// /// (Per your spec — can later be replaced by data fetched from the
// /// Admin Panel API instead of these hardcoded constants.)
// /// ---------------------------------------------------------------------
//
// class AgeBracket {
//   final String label;
//   final int minAge;
//   final int maxAge;
//   final double joiningFee; // 0 == Free
//   final double contribution;
//
//   const AgeBracket({
//     required this.label,
//     required this.minAge,
//     required this.maxAge,
//     required this.joiningFee,
//     required this.contribution,
//   });
//
//   bool matches(int age) => age >= minAge && age <= maxAge;
// }
//
// class SchemeFee {
//   final String id;
//   final String name;
//   final String eventLabel; // e.g. "per marriage" / "per Death"
//   final List<AgeBracket> brackets;
//
//   const SchemeFee({
//     required this.id,
//     required this.name,
//     required this.eventLabel,
//     required this.brackets,
//   });
//
//   /// Returns the matching age bracket, or null if the member's age
//   /// falls outside every bracket (i.e. not eligible).
//   AgeBracket? bracketFor(int age) {
//     for (final b in brackets) {
//       if (b.matches(age)) return b;
//     }
//     return null;
//   }
// }
//
// const List<SchemeFee> kSchemeFees = [
//   SchemeFee(
//     id: 'kanyadan',
//     name: 'Kanyadan / Putra Vivah Scheme',
//     eventLabel: 'per marriage',
//     brackets: [
//       AgeBracket(label: '0 to 5 Years', minAge: 0, maxAge: 5, joiningFee: 0, contribution: 50),
//       AgeBracket(label: '6 to 10 Years', minAge: 6, maxAge: 10, joiningFee: 2500, contribution: 100),
//       AgeBracket(label: '11 to 15 Years', minAge: 11, maxAge: 15, joiningFee: 3500, contribution: 200),
//       AgeBracket(label: '16 to 20 Years', minAge: 16, maxAge: 20, joiningFee: 6500, contribution: 300),
//       AgeBracket(label: '21 to 30 Years', minAge: 21, maxAge: 30, joiningFee: 8500, contribution: 400),
//     ],
//   ),
//   SchemeFee(
//     id: 'mayara',
//     name: 'Mayara Scheme',
//     eventLabel: 'per marriage',
//     brackets: [
//       AgeBracket(label: '0 to 5 Years', minAge: 0, maxAge: 5, joiningFee: 1100, contribution: 50),
//       AgeBracket(label: '6 to 10 Years', minAge: 6, maxAge: 10, joiningFee: 2100, contribution: 100),
//       AgeBracket(label: '11 to 15 Years', minAge: 11, maxAge: 15, joiningFee: 3100, contribution: 200),
//       AgeBracket(label: '16 to 20 Years', minAge: 16, maxAge: 20, joiningFee: 5100, contribution: 300),
//       AgeBracket(label: '21 to 30 Years', minAge: 21, maxAge: 30, joiningFee: 8500, contribution: 400),
//     ],
//   ),
//   SchemeFee(
//     id: 'parivar_kalyan',
//     name: 'Parivar Kalyan Scheme',
//     eventLabel: 'per Death',
//     brackets: [
//       AgeBracket(label: '0 to 10 Years', minAge: 0, maxAge: 10, joiningFee: 0, contribution: 200),
//       AgeBracket(label: '11 to 25 Years', minAge: 11, maxAge: 25, joiningFee: 1100, contribution: 200),
//       AgeBracket(label: '26 to 35 Years', minAge: 26, maxAge: 35, joiningFee: 2500, contribution: 200),
//       AgeBracket(label: '36 to 50 Years', minAge: 36, maxAge: 50, joiningFee: 3500, contribution: 200),
//       AgeBracket(label: '51 to 70 Years', minAge: 51, maxAge: 70, joiningFee: 5500, contribution: 200),
//       AgeBracket(label: '71 to 85 Years', minAge: 71, maxAge: 85, joiningFee: 7500, contribution: 200),
//     ],
//   ),
// ];
//
// SchemeFee? schemeById(String id) {
//   for (final s in kSchemeFees) {
//     if (s.id == id) return s;
//   }
//   return null;
// }
//
// /// ---------------------------------------------------------------------
// /// MOCK "ACTIVE CLAIM" DATA
// /// Replace this with a real API call (by MemberID/SchemeID/Aadhaar or
// /// by Mobile) once the backend endpoint is available.
// /// ---------------------------------------------------------------------
//
// class ActiveClaim {
//   final String id;
//   final String memberName;
//   final String memberId;
//   final String schemeId;
//   final int age;
//   final String mobile;
//   final String aadhaar;
//   final bool alreadyPaid;
//   final String? receiptNo;
//   final String? receiptDate;
//
//   const ActiveClaim({
//     required this.id,
//     required this.memberName,
//     required this.memberId,
//     required this.schemeId,
//     required this.age,
//     required this.mobile,
//     required this.aadhaar,
//     this.alreadyPaid = false,
//     this.receiptNo,
//     this.receiptDate,
//   });
//
//   SchemeFee? get scheme => schemeById(schemeId);
//   AgeBracket? get bracket => scheme?.bracketFor(age);
//   bool get isEligible => bracket != null;
// }
//
// const List<ActiveClaim> kMockActiveClaims = [
//   ActiveClaim(
//     id: 'CLM001',
//     memberName: 'SUNITABEN RAJUBHAI SUTHAR',
//     memberId: 'SA4281',
//     schemeId: 'kanyadan',
//     age: 24,
//     mobile: '9876543210',
//     aadhaar: '1234-5678-9012',
//   ),
//   ActiveClaim(
//     id: 'CLM002',
//     memberName: 'SUTHAR1',
//     memberId: 'SA4282',
//     schemeId: 'mayara',
//     age: 8,
//     mobile: '9876500001',
//     aadhaar: '2234-5678-9012',
//   ),
//   ActiveClaim(
//     id: 'CLM003',
//     memberName: 'SUTHAR2',
//     memberId: 'SA4283',
//     schemeId: 'parivar_kalyan',
//     age: 60,
//     mobile: '9876500002',
//     aadhaar: '3234-5678-9012',
//     alreadyPaid: true,
//     receiptNo: 'RCT-000452',
//     receiptDate: '12-Jun-2026',
//   ),
//   ActiveClaim(
//     id: 'CLM004',
//     memberName: 'SUTHAR4',
//     memberId: 'SA4284',
//     schemeId: 'kanyadan',
//     age: 45, // out of range on purpose -> "not eligible" demo
//     mobile: '9876500004',
//     aadhaar: '4234-5678-9012',
//   ),
// ];
//
// enum SearchBy { idBased, mobileBased }
//
// /// ---------------------------------------------------------------------
// /// COLLECTION SCREEN
// /// ---------------------------------------------------------------------
//
// class CollectionScreen extends StatefulWidget {
//   const CollectionScreen({super.key});
//
//   @override
//   State<CollectionScreen> createState() => _CollectionScreenState();
// }
//
// class _CollectionScreenState extends State<CollectionScreen> {
//   // 0 = search, 1 = active claims list, 2 = confirm payment & member
//   // details, 3 = payment mode, 4 = receipt
//   int _step = 0;
//
//   SearchBy _searchBy = SearchBy.idBased;
//   final TextEditingController _idController = TextEditingController();
//   final TextEditingController _mobileController = TextEditingController();
//
//   List<ActiveClaim> _searchResults = [];
//   final Set<String> _selectedClaimIds = {};
//
//   String _paymentMode = 'Cash';
//   String? _receiptNo;
//   String? _receiptDate;
//
//   @override
//   void dispose() {
//     _idController.dispose();
//     _mobileController.dispose();
//     super.dispose();
//   }
//
//   // --- search -----------------------------------------------------------
//
//   void _onSearch() {
//     final query = _searchBy == SearchBy.idBased
//         ? _idController.text.trim()
//         : _mobileController.text.trim();
//
//     if (query.isEmpty) {
//       _showNotEligibleDialog(
//         'Please enter ${_searchBy == SearchBy.idBased ? 'Member ID / Scheme ID / Aadhaar' : 'Mobile Number'} to search.',
//       );
//       return;
//     }
//
//     final matches = kMockActiveClaims.where((c) {
//       if (_searchBy == SearchBy.idBased) {
//         return c.memberId.toLowerCase() == query.toLowerCase() ||
//             c.schemeId.toLowerCase() == query.toLowerCase() ||
//             c.aadhaar.replaceAll('-', '') == query.replaceAll('-', '');
//       } else {
//         return c.mobile == query;
//       }
//     }).toList();
//
//     if (matches.isEmpty) {
//       _showNotEligibleDialog('No active claim found for the details entered.');
//       return;
//     }
//
//     // If a single already-paid claim matches, short-circuit to the
//     // "already paid" popup as per spec (#10).
//     final singleAlreadyPaid =
//         matches.length == 1 && matches.first.alreadyPaid;
//     if (singleAlreadyPaid) {
//       _showAlreadyPaidDialog(matches.first);
//       return;
//     }
//
//     // Filter out already-paid claims from the eligible list, and check
//     // whether anything eligible remains.
//     final payable = matches.where((c) => !c.alreadyPaid).toList();
//     if (payable.isEmpty) {
//       _showAlreadyPaidDialog(matches.first);
//       return;
//     }
//
//     final anyEligible = payable.any((c) => c.isEligible);
//     if (!anyEligible) {
//       _showNotEligibleDialog(
//         'Member is not eligible to pay any active claim (age is outside the eligible range for the scheme).',
//       );
//       return;
//     }
//
//     setState(() {
//       _searchResults = payable;
//       // Default: select all eligible claims (partial payment can be
//       // deselected by the karyakarta on the next screen).
//       _selectedClaimIds
//         ..clear()
//         ..addAll(payable.where((c) => c.isEligible).map((c) => c.id));
//       _step = 1;
//     });
//   }
//
//   // --- popups -------------------------------------------------------------
//
//   void _showNotEligibleDialog(String reason) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Not Eligible'),
//         content: Text(reason),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAlreadyPaidDialog(ActiveClaim claim) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Already Paid'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Member: ${claim.memberName}'),
//             Text('Member ID: ${claim.memberId}'),
//             const SizedBox(height: 8),
//             Text('Receipt No.: ${claim.receiptNo ?? '-'}'),
//             Text('Receipt Date: ${claim.receiptDate ?? '-'}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- payment ------------------------------------------------------------
//
//   double get _totalContribution {
//     double total = 0;
//     for (final c in _searchResults) {
//       if (_selectedClaimIds.contains(c.id) && c.isEligible) {
//         total += c.bracket!.contribution;
//       }
//     }
//     return total;
//   }
//
//   void _makePayment() {
//     // TODO: replace with real payment gateway / office API call.
//     final now = DateTime.now();
//     setState(() {
//       _receiptNo = 'RCT-${now.millisecondsSinceEpoch.toString().substring(7)}';
//       _receiptDate =
//       '${now.day.toString().padLeft(2, '0')}-${_monthName(now.month)}-${now.year}';
//       _step = 4;
//     });
//   }
//
//   String _monthName(int m) {
//     const months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
//     ];
//     return months[m - 1];
//   }
//
//   // --- UI -------------------------------------------------------------
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F3F6),
//       appBar: AppBar(
//         title: const Text('Services_collections_collect'),
//         centerTitle: false,
//         backgroundColor: const Color(0xFFF3F3F6),
//         foregroundColor: Colors.black87,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: _buildStep(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStep() {
//     switch (_step) {
//       case 0:
//         return _buildSearchStep();
//       case 1:
//         return _buildActiveClaimsStep();
//       case 2:
//         return _buildConfirmStep();
//       case 3:
//         return _buildPaymentModeStep();
//       case 4:
//         return _buildReceiptStep();
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   // Step 1: search
//   Widget _buildSearchStep() {
//     return ListView(
//       children: [
//         const Text('Search Member',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 16),
//         RadioListTile<SearchBy>(
//           contentPadding: EdgeInsets.zero,
//           title: const Text('Member ID / Scheme ID / Aadhaar'),
//           value: SearchBy.idBased,
//           groupValue: _searchBy,
//           onChanged: (v) => setState(() => _searchBy = v!),
//         ),
//         RadioListTile<SearchBy>(
//           contentPadding: EdgeInsets.zero,
//           title: const Text('Mobile (if eligible to pay any active claim)'),
//           value: SearchBy.mobileBased,
//           groupValue: _searchBy,
//           onChanged: (v) => setState(() => _searchBy = v!),
//         ),
//         const SizedBox(height: 12),
//         if (_searchBy == SearchBy.idBased)
//           TextField(
//             controller: _idController,
//             decoration: _fieldDecoration('Member ID / Scheme ID / Aadhaar'),
//           )
//         else
//           TextField(
//             controller: _mobileController,
//             keyboardType: TextInputType.phone,
//             decoration: _fieldDecoration('Mobile Number'),
//           ),
//         const SizedBox(height: 20),
//         _primaryButton('Search', _onSearch),
//       ],
//     );
//   }
//
//   // Step 2: active claims list (multi-select, default all selected)
//   Widget _buildActiveClaimsStep() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Active Claims',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         const Text('All eligible claims are selected by default. '
//             'Uncheck any for a partial payment.'),
//         const SizedBox(height: 12),
//         Expanded(
//           child: ListView.separated(
//             itemCount: _searchResults.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 8),
//             itemBuilder: (_, i) {
//               final c = _searchResults[i];
//               final scheme = c.scheme;
//               final bracket = c.bracket;
//               final selected = _selectedClaimIds.contains(c.id);
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: CheckboxListTile(
//                   value: selected,
//                   enabled: c.isEligible,
//                   onChanged: c.isEligible
//                       ? (v) {
//                     setState(() {
//                       if (v == true) {
//                         _selectedClaimIds.add(c.id);
//                       } else {
//                         _selectedClaimIds.remove(c.id);
//                       }
//                     });
//                   }
//                       : null,
//                   title: Text(c.memberName,
//                       style: const TextStyle(fontWeight: FontWeight.w600)),
//                   subtitle: Text(
//                     c.isEligible
//                         ? '${scheme?.name ?? c.schemeId} • ${bracket?.label} • '
//                         'Contribution: \u20B9${bracket?.contribution.toStringAsFixed(0)}'
//                         : '${scheme?.name ?? c.schemeId} • Not eligible (age ${c.age})',
//                     style: TextStyle(
//                       color: c.isEligible ? Colors.black54 : Colors.red,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(child: _secondaryButton('Back', () => setState(() => _step = 0))),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _primaryButton(
//                 'Next',
//                 _selectedClaimIds.isEmpty
//                     ? null
//                     : () => setState(() => _step = 2),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // Step 3: confirm payment & member details (auto-fetched)
//   Widget _buildConfirmStep() {
//     final selected =
//     _searchResults.where((c) => _selectedClaimIds.contains(c.id)).toList();
//     final member = selected.first;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Confirm Payment & Member Details',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 12),
//         _detailCard([
//           _detailRow('Member Name', member.memberName),
//           _detailRow('Member ID', member.memberId),
//           _detailRow('Aadhaar', member.aadhaar),
//           _detailRow('Mobile', member.mobile),
//         ]),
//         const SizedBox(height: 12),
//         const Text('Claims Selected',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         ...selected.map((c) => _detailCard([
//           _detailRow('Scheme', c.scheme?.name ?? c.schemeId),
//           _detailRow('Age Bracket', c.bracket?.label ?? '-'),
//           _detailRow('Contribution Amount',
//               '\u20B9${c.bracket?.contribution.toStringAsFixed(0)}'),
//         ])),
//         const SizedBox(height: 12),
//         _detailCard([
//           _detailRow('Total Contribution Amount',
//               '\u20B9${_totalContribution.toStringAsFixed(0)}',
//               bold: true),
//         ]),
//         const Spacer(),
//         Row(
//           children: [
//             Expanded(child: _secondaryButton('Back', () => setState(() => _step = 1))),
//             const SizedBox(width: 12),
//             Expanded(child: _primaryButton('Next', () => setState(() => _step = 3))),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // Step 4: payment mode
//   Widget _buildPaymentModeStep() {
//     const modes = ['Cash', 'UPI', 'Card', 'Cheque'];
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Payment Mode',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 12),
//         ...modes.map((m) => RadioListTile<String>(
//           contentPadding: EdgeInsets.zero,
//           title: Text(m),
//           value: m,
//           groupValue: _paymentMode,
//           onChanged: (v) => setState(() => _paymentMode = v!),
//         )),
//         const Spacer(),
//         Text('Amount to Pay: \u20B9${_totalContribution.toStringAsFixed(0)}',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(child: _secondaryButton('Back', () => setState(() => _step = 2))),
//             const SizedBox(width: 12),
//             Expanded(child: _primaryButton('Pay Now', _makePayment)),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // Step 5: office response / receipt
//   Widget _buildReceiptStep() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Icon(Icons.check_circle, color: Colors.green, size: 56),
//         const SizedBox(height: 12),
//         const Text('Payment Successful',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 16),
//         _detailCard([
//           _detailRow('Receipt No.', _receiptNo ?? '-'),
//           _detailRow('Receipt Date', _receiptDate ?? '-'),
//           _detailRow('Amount Paid', '\u20B9${_totalContribution.toStringAsFixed(0)}'),
//           _detailRow('Payment Mode', _paymentMode),
//         ]),
//         const Spacer(),
//         Row(
//           children: [
//             Expanded(
//               child: _secondaryButton('Download', () {
//                 // TODO: integrate a PDF/receipt generation package
//                 // (e.g. printing / pdf) to actually produce the file.
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Receipt download not yet wired up.')),
//                 );
//               }),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _secondaryButton('Share', () {
//                 // TODO: integrate share_plus to share the receipt.
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Receipt share not yet wired up.')),
//                 );
//               }),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         _primaryButton('Done', () => Navigator.pop(context)),
//       ],
//     );
//   }
//
//   // --- small reusable widgets ---------------------------------------------
//
//   InputDecoration _fieldDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//     );
//   }
//
//   Widget _primaryButton(String label, VoidCallback? onTap) {
//     return SizedBox(
//       height: 48,
//       child: ElevatedButton(
//         onPressed: onTap,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.grey[400],
//           foregroundColor: Colors.indigo[800],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(24),
//           ),
//           elevation: 0,
//         ),
//         child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//       ),
//     );
//   }
//
//   Widget _secondaryButton(String label, VoidCallback onTap) {
//     return SizedBox(
//       height: 48,
//       child: OutlinedButton(
//         onPressed: onTap,
//         style: OutlinedButton.styleFrom(
//           foregroundColor: Colors.indigo[800],
//           side: BorderSide(color: Colors.grey[400]!),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(24),
//           ),
//         ),
//         child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//       ),
//     );
//   }
//
//   Widget _detailCard(List<Widget> children) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
//     );
//   }
//
//   Widget _detailRow(String label, String value, {bool bold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.black54)),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: bold ? FontWeight.bold : FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// ---------------------------------------------------------------------
/// SCHEME FEE / CONTRIBUTION TABLES (unchanged — your data, already fixed)
/// ---------------------------------------------------------------------

class AgeBracket {
  final String label;
  final int minAge;
  final int maxAge;
  final double joiningFee;
  final double contribution;

  const AgeBracket({
    required this.label,
    required this.minAge,
    required this.maxAge,
    required this.joiningFee,
    required this.contribution,
  });

  bool matches(int age) => age >= minAge && age <= maxAge;
}

class SchemeFee {
  final String id;
  final String name;
  final String eventLabel;
  final List<AgeBracket> brackets;

  const SchemeFee({
    required this.id,
    required this.name,
    required this.eventLabel,
    required this.brackets,
  });

  AgeBracket? bracketFor(int age) {
    for (final b in brackets) {
      if (b.matches(age)) return b;
    }
    return null;
  }
}

const List<SchemeFee> kSchemeFees = [
  SchemeFee(
    id: 'kanyadan',
    name: 'Kanyadan / Putra Vivah Scheme',
    eventLabel: 'per marriage',
    brackets: [
      AgeBracket(label: '0 to 5 Years', minAge: 0, maxAge: 5, joiningFee: 0, contribution: 50),
      AgeBracket(label: '6 to 10 Years', minAge: 6, maxAge: 10, joiningFee: 2500, contribution: 100),
      AgeBracket(label: '11 to 15 Years', minAge: 11, maxAge: 15, joiningFee: 3500, contribution: 200),
      AgeBracket(label: '16 to 20 Years', minAge: 16, maxAge: 20, joiningFee: 6500, contribution: 300),
      AgeBracket(label: '21 to 30 Years', minAge: 21, maxAge: 30, joiningFee: 8500, contribution: 400),
    ],
  ),
  SchemeFee(
    id: 'mayara',
    name: 'Mayara Scheme',
    eventLabel: 'per marriage',
    brackets: [
      AgeBracket(label: '0 to 5 Years', minAge: 0, maxAge: 5, joiningFee: 1100, contribution: 50),
      AgeBracket(label: '6 to 10 Years', minAge: 6, maxAge: 10, joiningFee: 2100, contribution: 100),
      AgeBracket(label: '11 to 15 Years', minAge: 11, maxAge: 15, joiningFee: 3100, contribution: 200),
      AgeBracket(label: '16 to 20 Years', minAge: 16, maxAge: 20, joiningFee: 5100, contribution: 300),
      AgeBracket(label: '21 to 30 Years', minAge: 21, maxAge: 30, joiningFee: 8500, contribution: 400),
    ],
  ),
  SchemeFee(
    id: 'parivar_kalyan',
    name: 'Parivar Kalyan Scheme',
    eventLabel: 'per Death',
    brackets: [
      AgeBracket(label: '0 to 10 Years', minAge: 0, maxAge: 10, joiningFee: 0, contribution: 200),
      AgeBracket(label: '11 to 25 Years', minAge: 11, maxAge: 25, joiningFee: 1100, contribution: 200),
      AgeBracket(label: '26 to 35 Years', minAge: 26, maxAge: 35, joiningFee: 2500, contribution: 200),
      AgeBracket(label: '36 to 50 Years', minAge: 36, maxAge: 50, joiningFee: 3500, contribution: 200),
      AgeBracket(label: '51 to 70 Years', minAge: 51, maxAge: 70, joiningFee: 5500, contribution: 200),
      AgeBracket(label: '71 to 85 Years', minAge: 71, maxAge: 85, joiningFee: 7500, contribution: 200),
    ],
  ),
];

SchemeFee? schemeById(String id) {
  for (final s in kSchemeFees) {
    if (s.id == id) return s;
  }
  return null;
}

class ActiveClaim {
  final String id;
  final String memberName;
  final String memberId;
  final String schemeId;
  final int age;
  final String mobile;
  final String aadhaar;
  final bool alreadyPaid;
  final String? receiptNo;
  final String? receiptDate;

  const ActiveClaim({
    required this.id,
    required this.memberName,
    required this.memberId,
    required this.schemeId,
    required this.age,
    required this.mobile,
    required this.aadhaar,
    this.alreadyPaid = false,
    this.receiptNo,
    this.receiptDate,
  });

  SchemeFee? get scheme => schemeById(schemeId);
  AgeBracket? get bracket => scheme?.bracketFor(age);
  bool get isEligible => bracket != null;

  /// Display code like "KDS000001" (matches the mockup format).
  String get code =>
      'KDS${id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(6, '0')}';
}

const List<ActiveClaim> kMockActiveClaims = [
  ActiveClaim(
    id: 'CLM001',
    memberName: 'SUNITABEN RAJUBHAI SUTHAR',
    memberId: 'SA4281',
    schemeId: 'kanyadan',
    age: 24,
    mobile: '9876543210',
    aadhaar: '1234-5678-9012',
  ),
  ActiveClaim(
    id: 'CLM002',
    memberName: 'SUTHAR1',
    memberId: 'SA4282',
    schemeId: 'mayara',
    age: 8,
    mobile: '9876500001',
    aadhaar: '2234-5678-9012',
  ),
  ActiveClaim(
    id: 'CLM003',
    memberName: 'SUTHAR2',
    memberId: 'SA4283',
    schemeId: 'parivar_kalyan',
    age: 60,
    mobile: '9876500002',
    aadhaar: '3234-5678-9012',
    alreadyPaid: true,
    receiptNo: 'RCT-000452',
    receiptDate: '12-Jun-2026',
  ),
  ActiveClaim(
    id: 'CLM004',
    memberName: 'SUTHAR4',
    memberId: 'SA4284',
    schemeId: 'kanyadan',
    age: 45, // out of range on purpose -> "not eligible" demo
    mobile: '9876500004',
    aadhaar: '4234-5678-9012',
  ),
];

/// ---------------------------------------------------------------------
/// COLLECTION SCREEN — 4 step flow matching the reference screens
/// 1) Search by Scheme + Member ID   2) Active Claims List (multi-select)
/// 3) Confirm Details + Payment Mode 4) Receipt
/// ---------------------------------------------------------------------

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});
  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  int _step = 1; // 1..4

  String? _schemeId;

  String _searchBy = "member";

  final List<Map<String, String>> _searchOptions = [
    {"value": "member", "title": "By Member ID"},
    {"value": "scheme", "title": "By Scheme ID"},
    {"value": "aadhaar", "title": "By Aadhaar"},
    {"value": "mobile", "title": "By Mobile"},
  ];
  final _memberIdCtrl = TextEditingController();
  ActiveClaim? _preview;

  List<ActiveClaim> _claims = [];
  final Set<String> _selected = {};

  String _paymentMode = 'Cash';
  String? _receiptNo, _receiptDate;

  @override
  void dispose() {
    _memberIdCtrl.dispose();
    super.dispose();
  }

  // ---- actions ----------------------------------------------------------
  void _onSearch() {
    final value = _memberIdCtrl.text.trim();

    if (value.isEmpty) {
      _alert(
        "Search",
        "Please enter the search value.",
      );
      return;
    }
    ActiveClaim? found;

    switch (_searchBy) {
    // Search By Member ID
      case "member":
        for (final c in kMockActiveClaims) {
          if (c.memberId.toLowerCase() == value.toLowerCase()) {
            found = c;
            break;
          }
        }
        break;

    // Search By Scheme ID
      case "scheme":
        for (final c in kMockActiveClaims) {
          if (c.schemeId.toLowerCase() == value.toLowerCase()) {
            found = c;
            break;
          }
        }
        break;

    // Search By Aadhaar
      case "aadhaar":
        for (final c in kMockActiveClaims) {
          if (c.aadhaar.toLowerCase() == value.toLowerCase()) {
            found = c;
            break;
          }
        }
        break;

    // Search By Mobile
      case "mobile":
        for (final c in kMockActiveClaims) {
          if (c.mobile.toLowerCase() == value.toLowerCase()) {
            found = c;
            break;
          }
        }
        break;
    }

    if (found == null) {
      _alert(
        "Not Found",
        "No member found.",
      );
      return;
    }

    setState(() {
      _preview = found;
    });
  }

  void _goToClaimsList() {
    setState(() {
      _claims = kMockActiveClaims;
      _selected
        ..clear()
        ..addAll(_claims.where((c) => c.isEligible && !c.alreadyPaid).map((c) => c.id));
      _step = 2;
    });
  }

  double get _total {
    double t = 0;
    for (final c in _claims) {
      if (_selected.contains(c.id) && c.isEligible) t += c.bracket!.contribution;
    }
    return t;
  }

  void _pay() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    setState(() {
      _receiptNo = 'SDCT${now.millisecondsSinceEpoch.toString().substring(5)}';
      _receiptDate = '${now.day.toString().padLeft(2, '0')}-${months[now.month - 1]}-${now.year}';
      _step = 4;
    });
  }

  void _alert(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  // ---- UI -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF3F3F6),
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   title: const Text('Services_collections_collect'),
      //   backgroundColor: const Color(0xFFF3F3F6),
      //   foregroundColor: Colors.black87,
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Padding(
          // padding: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text('Collect', style: TextStyle(fontSize: 22, color: Colors.indigo, fontWeight: FontWeight.bold)),
              const Text('Collect', style: TextStyle(fontSize: 22, color: AppColors.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _stepper(),
              const Divider(height: 24),
              Expanded(child: _buildStep()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepper() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // CircleAvatar(radius: 12, backgroundColor: Colors.indigo, child: Text('$_step', style: const TextStyle(color: Colors.white, fontSize: 13))),
          CircleAvatar(radius: 12, backgroundColor: AppColors.primary, child: Text('$_step', style: const TextStyle(color: Colors.white, fontSize: 13))),
          const SizedBox(width: 8),
          const Text('of  4'),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return _searchStep();
      case 2:
        return _claimsStep();
      case 3:
        return _confirmStep();
      default:
        return _receiptStep();
    }
  }

  // Step 1: Search by Scheme + Member ID
  Widget _searchStep() {
    String label = "";

    switch (_searchBy) {
      case "member":
        label = "Member ID";
        break;

      case "scheme":
        label = "Scheme ID";
        break;

      case "aadhaar":
        label = "Aadhaar Number";
        break;

      case "mobile":
        label = "Mobile Number";
        break;
    }

    return ListView(
      children: [

        const Text(
          "Search By:",
          style: TextStyle(
            // color: Colors.black54,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          value: _searchBy,
          decoration: _fieldDecoration("Click to Select"),

          items: _searchOptions.map((item) {
            return DropdownMenuItem(
              value: item["value"],
              child: Text(item["title"]!),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              _searchBy = value!;
              _memberIdCtrl.clear();
              _preview = null;
            });
          },
        ),

        const SizedBox(height: 18),

        Text(
          "Enter $label:",
          style: const TextStyle(
            // color: Colors.black54,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: _memberIdCtrl,
          keyboardType: _searchBy == "mobile"
              ? TextInputType.phone
              : TextInputType.text,
          decoration: _fieldDecoration("Enter $label"),
        ),

        const SizedBox(height: 20),

        _primaryButton(
          "Search",
          _onSearch,
        ),

        if (_preview != null) ...[
          const SizedBox(height: 20),

          _detailCard([
            _detailRow("Member ID", _preview!.memberId),
            _detailRow("Scheme ID", _preview!.code),
            _detailRow("Member Name", _preview!.memberName),
            _detailRow(
              "Age Group",
              _preview!.bracket?.label ?? "Not Eligible",
            ),
            _detailRow(
              "Contribution Amount",
              "₹${_preview!.bracket?.contribution.toStringAsFixed(0) ?? "-"}",
            ),
          ]),

          const SizedBox(height: 20),

          _primaryButton(
            "Next",
            _goToClaimsList,
          ),
        ],
      ],
    );
  }

  // Step 2: Active Claims List (multi-select)
  Widget _claimsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active Claims List:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _claims.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final c = _claims[i];
              final canPick = c.isEligible && !c.alreadyPaid;
              final checked = _selected.contains(c.id);
              final status = c.alreadyPaid ? 'Paid' : (c.isEligible ? 'Pending' : 'Not Eligible');
              final statusColor = c.alreadyPaid
                  // ? Colors.green
                  // : (c.isEligible ? Colors.indigo : Colors.red);
                  ? AppColors.success
                  : (c.isEligible ? AppColors.primary : AppColors.rejected);
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: CheckboxListTile(
                  value: checked,
                  onChanged: canPick
                      ? (v) => setState(() {
                    if (v == true) {
                      _selected.add(c.id);
                    } else {
                      _selected.remove(c.id);
                    }
                  })
                      : null,
                  title: Text(c.memberName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${c.code} • ${c.scheme?.name ?? c.schemeId} • ₹${c.bracket?.contribution.toStringAsFixed(0) ?? '-'}'),
                  secondary: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _secondaryButton('Back', () => setState(() => _step = 1))),
          const SizedBox(width: 12),
          Expanded(child: _primaryButton('Next', _selected.isEmpty ? null : () => setState(() => _step = 3))),
        ]),
      ],
    );
  }

  // Step 3: Confirm Details + Payment Mode
  Widget _confirmStep() {
    final selected = _claims.where((c) => _selected.contains(c.id)).toList();
    final member = selected.first;
    return ListView(
      children: [
        const Text('Confirm Details:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Member Details:', style: TextStyle(fontWeight: FontWeight.bold)),
        _detailCard([
          _detailRow('Member ID', member.memberId),
          _detailRow('Member Name', member.memberName),
          _detailRow('Scheme ID', member.code),
          _detailRow('Scheme Name', member.scheme?.name ?? member.schemeId),
          _detailRow('Age Group', member.bracket?.label ?? '-'),
          _detailRow('Contribution Amount', '₹${member.bracket?.contribution.toStringAsFixed(0) ?? '-'}'),
        ]),
        const SizedBox(height: 12),
        const Text('Payment Details:', style: TextStyle(fontWeight: FontWeight.bold)),
        _detailCard([
          // const Text('Selected Claim ID:', style: TextStyle(color: Colors.black54)),
          const Text('Selected Claim ID:', style: TextStyle(color: AppColors.textLight)),
          ...selected.map((c) => Text('${c.code} * ${c.bracket?.contribution.toStringAsFixed(0) ?? '-'}')),
          const Divider(),
          _detailRow('Total Contribution Amount', '₹${_total.toStringAsFixed(0)}', bold: true),
        ]),
        const SizedBox(height: 12),
        const Text('Payment Mode:', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [
          Expanded(
            child: RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cash'),
              value: 'Cash',
              groupValue: _paymentMode,
              onChanged: (v) => setState(() => _paymentMode = v!),
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Online'),
              value: 'Online',
              groupValue: _paymentMode,
              onChanged: (v) => setState(() => _paymentMode = v!),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _secondaryButton('Back', () => setState(() => _step = 2))),
          const SizedBox(width: 12),
          Expanded(child: _primaryButton('Pay Now', _pay)),
        ]),
      ],
    );
  }

  // Step 4: Receipt
  Widget _receiptStep() {
    final selected = _claims.where((c) => _selected.contains(c.id)).toList();
    final member = selected.first;
    return ListView(
      children: [
        const Text(
          'Payment Successful',
          // style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success),
        ),
        const SizedBox(height: 12),
        const Text('Member Details:', style: TextStyle(fontWeight: FontWeight.bold)),
        _detailCard([
          _detailRow('Member ID', member.memberId),
          _detailRow('Member Name', member.memberName),
          _detailRow('Scheme ID', member.code),
          _detailRow('Scheme Name', member.scheme?.name ?? member.schemeId),
          _detailRow('Age Group', member.bracket?.label ?? '-'),
          _detailRow('Contribution Amount', '₹${member.bracket?.contribution.toStringAsFixed(0) ?? '-'}'),
        ]),
        const SizedBox(height: 12),
        const Text('Payment Details:', style: TextStyle(fontWeight: FontWeight.bold)),
        _detailCard([
          // const Text('Selected Claim ID:', style: TextStyle(color: Colors.black54)),
          const Text('Selected Claim ID:', style: TextStyle(color: AppColors.textLight)),
          ...selected.map((c) => Text('${c.code} * ${c.bracket?.contribution.toStringAsFixed(0) ?? '-'}')),
          const Divider(),
          _detailRow('Total Contribution Amount', '₹${_total.toStringAsFixed(0)}', bold: true),
        ]),
        const SizedBox(height: 12),
        const Text('Receipt Details:', style: TextStyle(fontWeight: FontWeight.bold)),
        _detailCard([
          _detailRow('Receipt No.', _receiptNo ?? '-'),
          _detailRow('Receipt Date', _receiptDate ?? '-'),
          _detailRow('Pay Mode', _paymentMode.toUpperCase()),
          _detailRow('Amount', '₹${_total.toStringAsFixed(0)}'),
        ]),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _secondaryButton('Share', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt share not yet wired up.')),
                );
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _secondaryButton('Download', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt download not yet wired up.')),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _primaryButton('Done', () => Navigator.pop(context)),
      ],
    );
  }

  // ---- small reusable widgets ---------------------------------------------

  InputDecoration _fieldDecoration(String label) => InputDecoration(
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  Widget _primaryButton(String label, VoidCallback? onTap) => SizedBox(
    height: 48,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        // backgroundColor: Colors.grey[300],
        // foregroundColor: Colors.indigo[800],
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );

  Widget _secondaryButton(String label, VoidCallback onTap) => SizedBox(
    height: 48,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        // foregroundColor: Colors.indigo[800],
        // side: BorderSide(color: Colors.grey[400]!),
        foregroundColor: AppColors.primaryDark,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );

  Widget _detailCard(List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  // Widget _detailRow(String label, String value, {bool bold = false}) => Padding(
  //   padding: const EdgeInsets.symmetric(vertical: 3),
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(label, style: const TextStyle(color: Colors.black54)),
  //       Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
  //     ],
  //   ),
  // );
  Widget _detailRow(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textLight)),
        Text(value, style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          color: AppColors.textDark,
        )),
      ],
    ),
  );
}