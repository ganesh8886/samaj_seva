// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
//
// class KaryakartaListScreen extends StatefulWidget {
//   const KaryakartaListScreen({super.key});
//
//   @override
//   State<KaryakartaListScreen> createState() => _KaryakartaListScreenState();
// }
//
// class _KaryakartaListScreenState extends State<KaryakartaListScreen> {
//   final _api = ApiService();
//   late Future<List<Map<String, dynamic>>> _future;
//
//   @override
//   void initState() {
//     super.initState();
//     _future = _api.getKaryakartas();
//   }
//
//   Future<void> _refresh() async {
//     setState(() => _future = _api.getKaryakartas());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F6FB),
//       appBar: AppBar(
//         title: const Text('Karyakarta List'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: FutureBuilder<List<Map<String, dynamic>>>(
//           future: _future,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             final list = snapshot.data ?? [];
//
//             if (list.isEmpty) {
//               return ListView(
//                 children: const [
//                   SizedBox(height: 120),
//                   Icon(Icons.groups_outlined, size: 48, color: Colors.grey),
//                   SizedBox(height: 12),
//                   Center(
//                     child: Text(
//                       'No karyakarta found',
//                       style: TextStyle(color: Colors.black54),
//                     ),
//                   ),
//                 ],
//               );
//             }
//
//             return ListView.separated(
//               padding: const EdgeInsets.all(16),
//               itemCount: list.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 12),
//               itemBuilder: (context, index) {
//                 final k = list[index];
//                 final status = (k['status'] ?? '').toString();
//                 final isActive = status.toLowerCase() == 'active';
//
//                 return Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CircleAvatar(
//                         radius: 22,
//                         backgroundColor: const Color(0xFFE9E7FB),
//                         child: Text(
//                           (k['full_name'] ?? '?').toString().isNotEmpty
//                               ? (k['full_name'] as String)[0].toUpperCase()
//                               : '?',
//                           style: const TextStyle(
//                             color: Color(0xFF6A5AE0),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     (k['full_name'] ?? '').toString(),
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: isActive
//                                         ? const Color(0xFFDFF6EA)
//                                         : const Color(0xFFFBE3DD),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     status.isEmpty ? '-' : status,
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w600,
//                                       color: isActive
//                                           ? const Color(0xFF16A085)
//                                           : const Color(0xFFE0522F),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Code: ${k['karyakarta_code'] ?? '-'}',
//                               style: const TextStyle(
//                                   fontSize: 12, color: Colors.black54),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               '${k['mobile'] ?? '-'}',
//                               style: const TextStyle(
//                                   fontSize: 13, color: Colors.black87),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               '${k['village'] ?? ''}, ${k['taluka'] ?? ''}, ${k['district'] ?? ''}',
//                               style: const TextStyle(
//                                   fontSize: 12, color: Colors.black54),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import '../models/karyakarta_model.dart';
// import '../services/api_service.dart';
// import 'add_karyakarta_screen.dart';
//
// class KaryakartaListScreen extends StatefulWidget {
//   const KaryakartaListScreen({super.key});
//   @override
//   State<KaryakartaListScreen> createState() => _KaryakartaListScreenState();
// }
//
// class _KaryakartaListScreenState extends State<KaryakartaListScreen> {
//   final _api = ApiService();
//   late Future<List<KaryakartaModel>> _future;
//
//   @override
//   void initState() {
//     super.initState();
//     _future = _api.getKaryakartas();
//   }
//
//   Future<void> _refresh() async {
//     setState(() => _future = _api.getKaryakartas());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Karyakarta List")),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final created = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddKaryakartaScreen()),
//           );
//           if (created == true) _refresh();
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: FutureBuilder<List<KaryakartaModel>>(
//           future: _future,
//           builder: (context, snap) {
//             if (snap.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final list = snap.data ?? [];
//             if (list.isEmpty) {
//               return ListView(
//                 children: const [
//                   SizedBox(height: 120),
//                   Center(child: Text("No karyakarta found")),
//                 ],
//               );
//             }
//             return ListView.separated(
//               padding: const EdgeInsets.all(12),
//               itemCount: list.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (context, i) {
//                 final k = list[i];
//                 return Card(
//                   child: ListTile(
//                     leading: CircleAvatar(child: Text(k.fullName.isNotEmpty ? k.fullName[0] : '?')),
//                     title: Text(k.fullName),
//                     subtitle: Text("${k.karyakartaCode} • ${k.mobile}\n${k.village}, ${k.district}"),
//                     isThreeLine: true,
//                     trailing: Text(k.status, style: const TextStyle(fontSize: 12, color: Colors.green)),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import '../models/karyakarta_model.dart';
// import '../services/api_service.dart';
// import 'add_karyakarta_screen.dart';
//
// class KaryakartaListScreen extends StatefulWidget {
//   const KaryakartaListScreen({super.key});
//   @override
//   State<KaryakartaListScreen> createState() => _KaryakartaListScreenState();
// }
//
// class _KaryakartaListScreenState extends State<KaryakartaListScreen> {
//   final _api = ApiService();
//   final _searchCtrl = TextEditingController();
//   late Future<List<KaryakartaModel>> _future;
//   List<KaryakartaModel> _all = [];
//   List<KaryakartaModel> _filtered = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _future = _load();
//     _searchCtrl.addListener(_applyFilter);
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<List<KaryakartaModel>> _load() async {
//     final list = await _api.getKaryakartas();
//     _all = list;
//     _filtered = list;
//     return list;
//   }
//
//   Future<void> _refresh() async {
//     setState(() => _future = _load());
//   }
//
//   void _applyFilter() {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     setState(() {
//       _filtered = q.isEmpty
//           ? _all
//           : _all.where((k) =>
//       k.fullName.toLowerCase().contains(q) ||
//           k.mobile.toLowerCase().contains(q) ||
//           k.karyakartaCode.toLowerCase().contains(q) ||
//           k.village.toLowerCase().contains(q) ||
//           k.district.toLowerCase().contains(q)).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Karyakarta List")),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final created = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddKaryakartaScreen()),
//           );
//           if (created == true) _refresh();
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
//             child: TextField(
//               controller: _searchCtrl,
//               decoration: InputDecoration(
//                 hintText: "Search by name, mobile, code, village...",
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchCtrl.text.isEmpty
//                     ? null
//                     : IconButton(
//                   icon: const Icon(Icons.clear),
//                   onPressed: () => _searchCtrl.clear(),
//                 ),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 isDense: true,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//               ),
//             ),
//           ),
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: _refresh,
//               child: FutureBuilder<List<KaryakartaModel>>(
//                 future: _future,
//                 builder: (context, snap) {
//                   if (snap.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   final list = _filtered;
//                   if (list.isEmpty) {
//                     return ListView(
//                       children: [
//                         const SizedBox(height: 120),
//                         Center(
//                           child: Text(_searchCtrl.text.isEmpty
//                               ? "No karyakarta found"
//                               : "No results for \"${_searchCtrl.text}\""),
//                         ),
//                       ],
//                     );
//                   }
//                   return ListView.separated(
//                     padding: const EdgeInsets.all(12),
//                     itemCount: list.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 10),
//                     itemBuilder: (context, i) {
//                       final k = list[i];
//                       return Card(
//                         child: ListTile(
//                           leading: CircleAvatar(child: Text(k.fullName.isNotEmpty ? k.fullName[0] : '?')),
//                           title: Text(k.fullName),
//                           subtitle: Text("${k.karyakartaCode} • ${k.mobile}\n${k.village}, ${k.district}"),
//                           isThreeLine: true,
//                           trailing: Text(k.status, style: const TextStyle(fontSize: 12, color: Colors.green)),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/karyakarta_model.dart';
import '../services/api_service.dart';
import 'add_karyakarta_screen.dart';
import 'karyakarta_profile_screen.dart'; // NEW: profile / 360 view screen

class KaryakartaListScreen extends StatefulWidget {
  const KaryakartaListScreen({super.key});
  @override
  State<KaryakartaListScreen> createState() => _KaryakartaListScreenState();
}

class _KaryakartaListScreenState extends State<KaryakartaListScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  late Future<List<KaryakartaModel>> _future;
  List<KaryakartaModel> _all = [];
  List<KaryakartaModel> _filtered = [];

  // NEW: status filter, mirrors the "All Status" dropdown in the web screen
  String _statusFilter = 'All Status';
  final List<String> _statusOptions = const ['All Status', 'Active', 'Inactive', 'Pending'];

  @override
  void initState() {
    super.initState();
    _future = _load();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<KaryakartaModel>> _load() async {
    final list = await _api.getKaryakartas();
    _all = list;
    _filtered = list;
    return list;
  }

  // Future<void> _refresh() async {
  //   setState(() => _future = _load());
  // }
  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = _all.where((k) {
        final matchesQuery = q.isEmpty ||
            k.fullName.toLowerCase().contains(q) ||
            k.mobile.toLowerCase().contains(q) ||
            k.karyakartaCode.toLowerCase().contains(q) ||
            k.village.toLowerCase().contains(q) ||
            k.district.toLowerCase().contains(q);
        final matchesStatus = _statusFilter == 'All Status' ||
            k.status.toLowerCase() == _statusFilter.toLowerCase();
        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() => _statusFilter = 'All Status');
    _applyFilter();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF16A085);
      case 'inactive':
        return Colors.red;
      default:
        return const Color(0xFFC97C0F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(
        title: const Text("Karyakarta Management"),
        actions: [
          // Mirrors "+ Add New Karyakarta" button from the web header
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddKaryakartaScreen()),
                );
                if (created == true) _refresh();
              },
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text("Add"),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6A5AE0)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Search + Status filter + Clear filter row ----
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: "Search SA Code, Name, Mobile, Village...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchCtrl.clear(),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _statusFilter,
                        isExpanded: true,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _statusOptions
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _statusFilter = v ?? 'All Status');
                          _applyFilter();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                      label: const Text("Clear"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<KaryakartaModel>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = _filtered;
                  if (list.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(_searchCtrl.text.isEmpty
                              ? "No karyakarta found"
                              : "No results for \"${_searchCtrl.text}\""),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final k = list[i];
                      // NEW: table-style card matching the web row layout
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            final changed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KaryakartaProfileScreen(id: k.id),
                              ),
                            );
                            if (changed == true) _refresh();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFF6A5AE0),
                                      child: Text(
                                        k.fullName.isNotEmpty ? k.fullName[0].toUpperCase() : '?',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(k.fullName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                          Text("S/O ${k.fatherName}",
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(k.status).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        k.status.isEmpty ? '-' : k.status.toUpperCase(),
                                        style: TextStyle(
                                          color: _statusColor(k.status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                _rowInfo("SA Code", k.karyakartaCode),
                                _rowInfo("Mobile", k.mobile),
                                _rowInfo("Village & Address", "${k.village}, ${k.district}"),
                                _rowInfo("Members", "${k.memberCount}"),
                                _rowInfo("DOJ", k.createdAt),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton.icon(
                                    onPressed: () async {
                                      final changed = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => KaryakartaProfileScreen(id: k.id),
                                        ),
                                      );
                                      if (changed == true) _refresh();
                                    },
                                    icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                                    label: const Text("View Profile"),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF6A5AE0),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}