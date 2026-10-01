// import 'package:flutter/material.dart';
// import '../models/member_model.dart';
// import '../services/api_service.dart';
// import 'add_member_screen.dart';
//
// class MemberListScreen extends StatefulWidget {
//   const MemberListScreen({super.key});
//   @override
//   State<MemberListScreen> createState() => _MemberListScreenState();
// }
//
// class _MemberListScreenState extends State<MemberListScreen> {
//   final _api = ApiService();
//   late Future<List<MemberModel>> _future;
//
//   @override
//   void initState() {
//     super.initState();
//     _future = _api.getMembers();
//   }
//
//   Future<void> _refresh() async {
//     setState(() => _future = _api.getMembers());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Member List")),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final created = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddMemberScreen()),
//           );
//           if (created == true) _refresh();
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: FutureBuilder<List<MemberModel>>(
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
//                   Center(child: Text("No members found")),
//                 ],
//               );
//             }
//             return ListView.separated(
//               padding: const EdgeInsets.all(12),
//               itemCount: list.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (context, i) {
//                 final m = list[i];
//                 return Card(
//                   child: ListTile(
//                     leading: CircleAvatar(child: Text(m.fullName.isNotEmpty ? m.fullName[0] : '?')),
//                     title: Text(m.fullName),
//                     subtitle: Text("${m.mobile}\n${m.village}, ${m.district}"),
//                     isThreeLine: true,
//                     trailing: Text(m.status, style: const TextStyle(fontSize: 12, color: Colors.green)),
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
// import '../models/member_model.dart';
// import '../services/api_service.dart';
// import 'add_member_screen.dart';
//
// class MemberListScreen extends StatefulWidget {
//   const MemberListScreen({super.key});
//   @override
//   State<MemberListScreen> createState() => _MemberListScreenState();
// }
//
// class _MemberListScreenState extends State<MemberListScreen> {
//   final _api = ApiService();
//   final _searchCtrl = TextEditingController();
//   late Future<List<MemberModel>> _future;
//   List<MemberModel> _all = [];
//   List<MemberModel> _filtered = [];
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
//   Future<List<MemberModel>> _load() async {
//     final list = await _api.getMembers();
//     _all = list;
//     _filtered = list;
//     return list;
//   }
//
//   // Future<void> _refresh() async {
//   //   setState(() => _future = _load());
//   // }
//   Future<void> _refresh() async {
//     setState(() {
//       _future = _load();
//     });
//   }
//
//   void _applyFilter() {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     setState(() {
//       _filtered = q.isEmpty
//           ? _all
//           : _all.where((m) =>
//       m.fullName.toLowerCase().contains(q) ||
//           m.mobile.toLowerCase().contains(q) ||
//           m.village.toLowerCase().contains(q) ||
//           m.district.toLowerCase().contains(q)).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Member List")),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final created = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddMemberScreen()),
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
//                 hintText: "Search by name, mobile, village...",
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
//               child: FutureBuilder<List<MemberModel>>(
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
//                               ? "No members found"
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
//                       final m = list[i];
//                       return Card(
//                         child: ListTile(
//                           leading: CircleAvatar(child: Text(m.fullName.isNotEmpty ? m.fullName[0] : '?')),
//                           title: Text(m.fullName),
//                           subtitle: Text("${m.mobile}\n${m.village}, ${m.district}"),
//                           isThreeLine: true,
//                           trailing: Text(m.status, style: const TextStyle(fontSize: 12, color: Colors.green)),
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
import '../models/member_model.dart';
import '../models/karyakarta_model.dart';
import '../services/api_service.dart';
import 'add_member_screen.dart';
import 'member_view_screen.dart';

/// NOTE: This assumes KaryakartaModel has `id` (int) and `fullName` (String)

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});
  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();

  late Future<List<MemberModel>> _future;
  List<MemberModel> _all = [];
  List<MemberModel> _filtered = [];

  List<KaryakartaModel> _karyakartas = [];
  String _statusFilter = 'All Status';
  String? _karyakartaFilter; // null = all

  final List<String> _statusOptions = const [
    'All Status',
    'ACTIVE',
    'INACTIVE',
    'PENDING',
  ];

  @override
  void initState() {
    super.initState();
    _future = _load();
    _loadKaryakartas();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<MemberModel>> _load() async {
    final list = await _api.getMembers();
    _all = list;
    _applyFilter();
    return list;
  }

  Future<void> _loadKaryakartas() async {
    final list = await _api.getKaryakartas();
    if (mounted) setState(() => _karyakartas = list);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = _all.where((m) {
        final matchesSearch = q.isEmpty ||
            m.fullName.toLowerCase().contains(q) ||
            m.mobile.toLowerCase().contains(q) ||
            m.village.toLowerCase().contains(q) ||
            m.district.toLowerCase().contains(q) ||
            m.id.toString().contains(q);
        final matchesStatus =
            _statusFilter == 'All Status' || m.status.toUpperCase() == _statusFilter;
        final matchesKaryakarta =
            _karyakartaFilter == null || m.karyakartaId.toString() == _karyakartaFilter;
        return matchesSearch && matchesStatus && matchesKaryakarta;
      }).toList();
    });
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _statusFilter = 'All Status';
      _karyakartaFilter = null;
    });
    _applyFilter();
  }

  Future<void> _goToAddMember() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMemberScreen()),
    );
    if (created == true) _refresh();
  }

  // NEW — now correctly inside _MemberListScreenState
  Future<void> _viewMember(MemberModel m) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MemberViewScreen(memberId: m.id)),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Management (360°)')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<MemberModel>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                _buildToolbar(),
                Expanded(child: _buildTable()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search 7-Digit ID, Name, Gotra, Village...',
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
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _statusFilter,
                  items: _statusOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _statusFilter = v ?? 'All Status');
                    _applyFilter();
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: _karyakartaFilter,
                  hint: const Text('Filter By Karyakarta'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All Karyakarta')),
                    ..._karyakartas.map(
                          (k) => DropdownMenuItem<String?>(
                        value: k.id.toString(),
                        child: Text(k.fullName),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _karyakartaFilter = v);
                    _applyFilter();
                  },
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Clear Filter'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: wire this up once the backend has an export endpoint
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export Excel not wired up yet')),
                    );
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Export Excel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _goToAddMember,
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text('Add New Member'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final list = _filtered;
    if (list.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              _searchCtrl.text.isEmpty ? 'No members found' : 'No results for "${_searchCtrl.text}"',
            ),
          ),
        ],
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        // child: DataTable(
        //   columns: const [
        //     DataColumn(label: Text('SN')),
        //     DataColumn(label: Text('Tagged Karyakarta')),
        //     DataColumn(label: Text('Member ID')),
        //     DataColumn(label: Text('Full Name & Parent/Husband')),
        //     DataColumn(label: Text('Gotra')),
        //     DataColumn(label: Text('Gender / DOB')),
        //     DataColumn(label: Text('Mobile')),
        //     DataColumn(label: Text('Village / Area')),
        //     DataColumn(label: Text('Date of Joining')),
        //     DataColumn(label: Text('Status')),
        //   ],
        //   rows: List<DataRow>.generate(list.length, (i) {
        //     final m = list[i];
        //     return DataRow(cells: [
        //       DataCell(Text('${i + 1}')),
        //       DataCell(Text(_karyakartaName(m.karyakartaId))),
        //       DataCell(Text('${m.id}')),
        //       DataCell(Text('${m.fullName}\nS/O ${m.fatherName}')),
        //       DataCell(Text(m.gotra)),
        //       DataCell(Text('${m.gender}\n${m.dob}')),
        //       DataCell(Text(m.mobile)),
        //       DataCell(Text('${m.village}, ${m.district}')),
        //       DataCell(Text(m.createdAt)),
        //       DataCell(Chip(
        //         label: Text(m.status, style: const TextStyle(fontSize: 11)),
        //         backgroundColor:
        //         m.status.toUpperCase() == 'ACTIVE' ? Colors.green.shade100 : Colors.grey.shade200,
        //       )),
        //     ]);
        //   }),
        // ),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('SN')),
            DataColumn(label: Text('Tagged Karyakarta')),
            DataColumn(label: Text('Member ID')),
            DataColumn(label: Text('Full Name & Parent/Husband')),
            DataColumn(label: Text('Gotra')),
            DataColumn(label: Text('Gender / DOB')),
            DataColumn(label: Text('Mobile')),
            DataColumn(label: Text('Village / Area')),
            DataColumn(label: Text('Date of Joining')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Action')), // NEW
          ],
          rows: List<DataRow>.generate(list.length, (i) {
            final m = list[i];
            return DataRow(cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(_karyakartaName(m.karyakartaId))),
              DataCell(Text(m.memberId.isNotEmpty ? m.memberId : '${m.id}')), // NEW — shows "member_id" like 6825955, falls back to internal id
              DataCell(Text('${m.fullName}\nS/O ${m.fatherName}')),
              DataCell(Text(m.gotra)),
              DataCell(Text('${m.gender}\n${m.dob}')),
              DataCell(Text(m.mobile)),
              DataCell(Text('${m.village}, ${m.district}')),
              DataCell(Text(m.createdAt)),
              DataCell(Chip(
                label: Text(m.status, style: const TextStyle(fontSize: 11)),
                backgroundColor:
                m.status.toUpperCase() == 'ACTIVE' ? Colors.green.shade100 : Colors.grey.shade200,
              )),
              DataCell(ElevatedButton.icon( // NEW
                onPressed: () => _viewMember(m),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('View'),
              )),
            ]);
          }),
        ),
      ),
    );
  }

  String _karyakartaName(int id) {
    final match = _karyakartas.where((k) => k.id == id);
    if (match.isEmpty) return '-';
    return match.first.fullName;
  }
}