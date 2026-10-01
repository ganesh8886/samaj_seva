// import 'package:flutter/material.dart';
// import '../utils/constants.dart';
// import 'scheme_enrollment_screen.dart';
// import 'claim_request_screen.dart';
// import 'service_list_screen.dart';
// import 'collection_screen.dart';
// import 'collection_view_screen.dart';
// import 'profile_screen.dart';
// import 'reports_screen.dart';
//
// class ServicesScreen extends StatefulWidget {
//   const ServicesScreen({super.key});
//
//   @override
//   State<ServicesScreen> createState() => _ServicesScreenState();
// }
//
// class _ServicesScreenState extends State<ServicesScreen> {
//   int _tabIndex = 0; // 0 = Members, 1 = Claims, 2 = Collections
//
//   static const _tabs = ['Members', 'Claims', 'Collections'];
//
//   // label -> onTap callback per tab
//   final Map<String, List<String>> _buttons = const {
//     'Members': ['Add', 'View', 'Search'],
//     'Claims': ['Add', 'View'],
//     'Collections': ['Collection', 'View'],
//   };
//
//   void _handleButtonTap(String tab, String action) {
//     if (tab == 'Members' && action == 'Add') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const SchemeEnrollmentScreen()),
//       );
//       return;
//     }
//     if (tab == 'Claims' && action == 'Add') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const ClaimRequestScreen()),
//       );
//       return;
//     }
//     if (tab == 'Members' && action == 'View') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const ServiceListScreen(
//             appBarTitle: 'Services_members_view',
//             heading: 'View Members',
//             records: [
//               ServiceRecord(
//                   name: 'SUNITABEN RAJUBHAI SUTHAR',
//                   subtitle: 'Proposal No./ Member ID & Scheme ID',
//                   status: 'Submitted'),
//               ServiceRecord(
//                   name: 'SUTHAR1',
//                   subtitle: 'Proposal No./ Member ID & Scheme ID',
//                   status: 'Active'),
//               ServiceRecord(
//                   name: 'SUTHAR2',
//                   subtitle: 'Proposal No./ Member ID & Scheme ID',
//                   status: 'Rejected'),
//               ServiceRecord(
//                   name: 'SUTHAR3',
//                   subtitle: 'Proposal No./ Member ID & Scheme ID',
//                   status: 'Active'),
//               ServiceRecord(name: 'Matthew', subtitle: 'Content', status: 'Active'),
//               ServiceRecord(name: 'Brian', subtitle: 'Content', status: 'Active'),
//               ServiceRecord(name: 'Pedro', subtitle: 'Content', status: 'Active'),
//               ServiceRecord(
//                   name: 'SUTHAR4',
//                   subtitle: 'Proposal No./ Member ID & Scheme ID',
//                   status: 'Hold'),
//             ],
//           ),
//         ),
//       );
//       return;
//     }
//     if (tab == 'Claims' && action == 'View') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const ServiceListScreen(
//             appBarTitle: 'Services_claims_view',
//             heading: 'View Claims',
//             records: [
//               ServiceRecord(
//                   name: 'SUNITABEN RAJUBHAI SUTHAR',
//                   subtitle: 'Proposal No./ Member ID & Scheme ID',
//                   status: 'Submitted'),
//               ServiceRecord(
//                   name: 'SUTHAR1',
//                   subtitle: 'Proposal No./ Member ID & Scheme ID',
//                   status: 'Approved'),
//               ServiceRecord(
//                   name: 'SUTHAR2',
//                   subtitle: 'Proposal No./ Member ID & Scheme ID',
//                   status: 'Rejected'),
//               ServiceRecord(
//                   name: 'SUTHAR4',
//                   subtitle: 'Proposal No./ Member ID & Scheme ID',
//                   status: 'Hold'),
//             ],
//           ),
//         ),
//       );
//       return;
//     }
//     if (tab == 'Collections' && action == 'Collection') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const CollectionScreen()),
//       );
//       return;
//     }
//     if (tab == 'Collections' && action == 'View') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const CollectionViewScreen()),
//       );
//       return;
//     }
//     // TODO: wire up the remaining buttons (Search) the same way once you
//     // have their target screens.
//     debugPrint('Tapped $tab -> $action');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentTab = _tabs[_tabIndex];
//     final actions = _buttons[currentTab]!;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F3F6),
//       // appBar: AppBar(
//       //   title: Text('Services_${currentTab.toLowerCase()}'),
//       //   centerTitle: false,
//       //   backgroundColor: const Color(0xFFF3F3F6),
//       //   foregroundColor: Colors.black87,
//       //   elevation: 0,
//       // ),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
//           children: [
//             _buildWelcomeCard(),
//             const SizedBox(height: 16),
//             _buildTabSelector(),
//             const SizedBox(height: 16),
//             _buildActionGrid(currentTab, actions),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }
//
//   Widget _buildWelcomeCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Welcome!',
//                     style: TextStyle(
//                         // color: Colors.green[700],
//                         color: AppColors.primaryDark,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 2),
//                 Text('SA4281',
//                     style: TextStyle(
//                         // color: Colors.green[700],
//                         color: AppColors.primaryDark,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 2),
//                 Text('Govindbhai M. Suthar',
//                     style: TextStyle(
//                         // color: Colors.green[800],
//                         color: AppColors.primaryDark,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//            CircleAvatar(
//             radius: 28,
//             // backgroundColor: Color(0xFFFBDCE3),
//             // child: Icon(Icons.person, size: 32, color: Colors.black54),
//             backgroundColor: AppColors.primaryLight,
//             child: const Icon(Icons.person, size: 32, color: AppColors.primaryDark),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTabSelector() {
//     return Row(
//       children: List.generate(_tabs.length, (i) {
//         final selected = i == _tabIndex;
//         return Expanded(
//           child: Padding(
//             padding: EdgeInsets.only(right: i == _tabs.length - 1 ? 0 : 8),
//             child: GestureDetector(
//               onTap: () => setState(() => _tabIndex = i),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: selected ? Colors.grey[400] : Colors.white,
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Text(
//                   _tabs[i],
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     // color: Colors.indigo[800],
//                     color: AppColors.primaryDark,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
//   IconData _iconForAction(String label) {
//     switch (label) {
//       case 'Add':
//         return Icons.add_circle_outline;
//       case 'View':
//         return Icons.visibility_outlined;
//       case 'Search':
//         return Icons.search;
//       case 'Collection':
//         return Icons.account_balance_wallet_outlined;
//       default:
//         return Icons.touch_app_outlined;
//     }
//   }
//   Widget _buildActionGrid(String tab, List<String> actions) {
//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       mainAxisSpacing: 16,
//       crossAxisSpacing: 16,
//       childAspectRatio: 1.6,
//       children: actions.map((label) {
//         return GestureDetector(
//           onTap: () => _handleButtonTap(tab, label),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 6,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 52,
//                   height: 52,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: AppColors.primaryLight,
//                   ),
//                   child: Icon(
//                     _iconForAction(label),
//                     color: AppColors.primaryDark,
//                     size: 26,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                     color: AppColors.primaryDark,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildBottomNav() {
//     return BottomNavigationBar(
//       currentIndex: 1, // Services tab active
//       type: BottomNavigationBarType.fixed,
//       backgroundColor: Colors.white,
//       // selectedItemColor: Colors.indigo,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: Colors.black54,
//       // unselectedItemColor:AppColors.primaryDark,
//       showUnselectedLabels: true,
//       selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//       // onTap: (index) {
//       //   if (index == 1) return; // already here
//       //   Navigator.pop(context); // back to Dashboard, let it handle other tabs
//       // },
//       onTap: (index) {
//         switch (index) {
//           case 0:
//           // Home
//             Navigator.pop(context);
//             break;
//
//           case 1:
//           // Already on Services
//             break;
//
//           case 2:
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const ReportsScreen()),
//             );
//             break;
//
//           case 3:
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const ProfileScreen(),
//               ),
//             );
//             break;
//         }
//       },
//       items: const [
//         BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home'),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.people_alt_outlined),
//             activeIcon: Icon(Icons.people_alt),
//             label: 'Services'),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.description_outlined),
//             activeIcon: Icon(Icons.description),
//             label: 'Reports'),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle_outlined),
//             activeIcon: Icon(Icons.account_circle),
//             label: 'Profile'),
//       ],
//     );
//   }
// }