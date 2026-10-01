// import 'package:flutter/material.dart';
// import '../utils/constants.dart';
//
// /// A single row of data shown in the list (a member or a claim).
// class ServiceRecord {
//   final String name;
//   final String subtitle; // e.g. "Proposal No./Member ID & Scheme ID" or "Content"
//   final String status; // e.g. Submitted, Active, Rejected, Hold, Approved
//
//   const ServiceRecord({
//     required this.name,
//     required this.subtitle,
//     required this.status,
//   });
// }
//
// /// Reusable screen for "View Members" and "View Claims".
// /// Pass in a heading + list of records and it renders the same UI
// /// shown in your screenshots.
// class ServiceListScreen extends StatefulWidget {
//   final String appBarTitle; // e.g. "Services_members_view"
//   final String heading; // e.g. "View Members" / "View Claims"
//   final List<ServiceRecord> records;
//
//   const ServiceListScreen({
//     super.key,
//     required this.appBarTitle,
//     required this.heading,
//     required this.records,
//   });
//
//   @override
//   State<ServiceListScreen> createState() => _ServiceListScreenState();
// }
//
// class _ServiceListScreenState extends State<ServiceListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _query = '';
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   List<ServiceRecord> get _filteredRecords {
//     if (_query.trim().isEmpty) return widget.records;
//     final q = _query.toLowerCase();
//     return widget.records
//         .where((r) => r.name.toLowerCase().contains(q))
//         .toList();
//   }
//
//   Color _statusBgColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'submitted':
//         return const Color(0xFFE6E0FA); // light purple
//       case 'active':
//       case 'approved':
//         return const Color(0xFFD9F5E3); // light green
//       case 'rejected':
//         return const Color(0xFFFBDCE0); // light red
//       case 'hold':
//         return const Color(0xFFFBDCE0); // light red/pink
//       default:
//         return const Color(0xFFE0E0E0);
//     }
//   }
//
//   Color _statusTextColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'submitted':
//         return const Color(0xFF6A4FC7);
//       case 'active':
//       case 'approved':
//         return const Color(0xFF1E8A5B);
//       case 'rejected':
//         return const Color(0xFFD03050);
//       case 'hold':
//         return const Color(0xFFD03050);
//       default:
//         return Colors.black87;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final records = _filteredRecords;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F3F6),
//       // appBar: AppBar(
//       //   title: Text(widget.appBarTitle),
//       //   centerTitle: false,
//       //   backgroundColor: const Color(0xFFF3F3F6),
//       //   foregroundColor: Colors.black87,
//       //   elevation: 0,
//       // ),
//         body: SafeArea(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//                 child: Text(
//                   widget.heading,
//                   style: const TextStyle(
//                     // color: Colors.blue,
//                     color: AppColors.primary,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: (v) => setState(() => _query = v),
//                     decoration: InputDecoration(
//                       hintText: 'Search by ID or Name',
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: const Icon(Icons.filter_list),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             color: const Color(0xFFEDEDF2),
//             child: const Row(
//               children: [
//                 Expanded(
//                   child: Text('NAME',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, color: Colors.black54)),
//                 ),
//                 Text('STATUS',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold, color: Colors.black54)),
//               ],
//             ),
//           ),
//           Expanded(
//             child: records.isEmpty
//                 ? const Center(child: Text('No records found'))
//                 : ListView.separated(
//               padding: EdgeInsets.zero,
//               itemCount: records.length,
//               separatorBuilder: (_, __) =>
//                   Divider(height: 1, color: Colors.grey[300]),
//               itemBuilder: (context, index) {
//                 final r = records[index];
//                 return Container(
//                   color: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 14),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               r.name,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               r.subtitle,
//                               style: TextStyle(
//                                   fontSize: 12, color: Colors.grey[600]),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: _statusBgColor(r.status),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Text(
//                           r.status,
//                           style: TextStyle(
//                             color: _statusTextColor(r.status),
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//             ],
//           ),
//         ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 1,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         // selectedItemColor: Colors.indigo,
//         selectedItemColor: AppColors.primary,
//         unselectedItemColor: Colors.black54,
//         showUnselectedLabels: true,
//         selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//         onTap: (index) {
//           if (index == 1) return;
//           Navigator.pop(context);
//         },
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               activeIcon: Icon(Icons.home),
//               label: 'Home'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.people_alt_outlined),
//               activeIcon: Icon(Icons.people_alt),
//               label: 'Services'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.description_outlined),
//               activeIcon: Icon(Icons.description),
//               label: 'Reports'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.account_circle_outlined),
//               activeIcon: Icon(Icons.account_circle),
//               label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }