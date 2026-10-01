import 'package:flutter/material.dart';

import '../utils/constants.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class MemberPaymentRecord {
  final String name;
  final String subtitle;
  final String status; // 'Pending' or 'Paid'
  final double amount;
  final double penalty;
  final String? paidOn;
  final String? receiptNo;

  const MemberPaymentRecord({
    required this.name,
    required this.subtitle,
    required this.status,
    required this.amount,
    this.penalty = 0,
    this.paidOn,
    this.receiptNo,
  });
}

class ClaimRecord {
  final String id;
  final String title;
  final String subtitle;
  final List<MemberPaymentRecord> members;

  const ClaimRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.members,
  });

  int get pendingCount => members.where((m) => m.status == 'Pending').length;
  int get paidCount => members.where((m) => m.status == 'Paid').length;
  int get totalCount => members.length;
}

// ---------------------------------------------------------------------------
// Sample data — replace with real API data later
// ---------------------------------------------------------------------------

const List<ClaimRecord> _activeClaims = [
  ClaimRecord(
    id: 'CLM-1001',
    title: 'Claim CLM-1001',
    subtitle: 'Scheme: Group Health / 3 Members',
    members: [
      MemberPaymentRecord(
        name: 'SUNITABEN RAJUBHAI SUTHAR',
        subtitle: 'Member ID: MB-201',
        status: 'Pending',
        amount: 500,
      ),
      MemberPaymentRecord(
        name: 'SUTHAR1',
        subtitle: 'Member ID: MB-202',
        status: 'Paid',
        amount: 500,
        paidOn: '02-Jul-2026',
        receiptNo: 'RC-9001',
      ),
      MemberPaymentRecord(
        name: 'SUTHAR2',
        subtitle: 'Member ID: MB-203',
        status: 'Pending',
        amount: 500,
      ),
    ],
  ),
  ClaimRecord(
    id: 'CLM-1002',
    title: 'Claim CLM-1002',
    subtitle: 'Scheme: Accident Cover / 2 Members',
    members: [
      MemberPaymentRecord(
        name: 'Matthew',
        subtitle: 'Member ID: MB-301',
        status: 'Paid',
        amount: 300,
        paidOn: '28-Jun-2026',
        receiptNo: 'RC-9010',
      ),
      MemberPaymentRecord(
        name: 'Brian',
        subtitle: 'Member ID: MB-302',
        status: 'Pending',
        amount: 300,
      ),
    ],
  ),
];

const List<ClaimRecord> _oldPendingClaims = [
  ClaimRecord(
    id: 'CLM-0876',
    title: 'Claim CLM-0876',
    subtitle: 'Closed: 15-Mar-2026 / 2 Members Pending',
    members: [
      MemberPaymentRecord(
        name: 'SUTHAR3',
        subtitle: 'Member ID: MB-115',
        status: 'Pending',
        amount: 500,
        penalty: 50,
      ),
      MemberPaymentRecord(
        name: 'SUTHAR4',
        subtitle: 'Member ID: MB-116',
        status: 'Pending',
        amount: 500,
        penalty: 50,
      ),
    ],
  ),
];

const List<ClaimRecord> _oldPaidClaims = [
  ClaimRecord(
    id: 'CLM-0755',
    title: 'Claim CLM-0755',
    subtitle: 'Closed: 10-Jan-2026 / All Members Paid',
    members: [
      MemberPaymentRecord(
        name: 'Pedro',
        subtitle: 'Member ID: MB-050',
        status: 'Paid',
        amount: 500,
        paidOn: '12-Jan-2026',
        receiptNo: 'RC-8000',
      ),
      MemberPaymentRecord(
        name: 'SUTHAR1',
        subtitle: 'Member ID: MB-051',
        status: 'Paid',
        amount: 500,
        paidOn: '13-Jan-2026',
        receiptNo: 'RC-8001',
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Top level: View screen -> Active / Old Paid tabs
// ---------------------------------------------------------------------------

class CollectionViewScreen extends StatelessWidget {
  const CollectionViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // backgroundColor: const Color(0xFFF3F3F6),
        backgroundColor: AppColors.background,
        appBar: AppBar(
          // title: const Text('Collections_view'),
          automaticallyImplyLeading: false, // 👈 removes the back arrow
          centerTitle: false,
          // backgroundColor: const Color(0xFFF3F3F6),
          // foregroundColor: Colors.black87,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          bottom: const TabBar(
            // labelColor: Colors.indigo,
            // unselectedLabelColor: Colors.black54,
            // indicatorColor: Colors.indigo,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Paid'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ActiveClaimsTab(),
            _OldPaidSectionTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active tab
// ---------------------------------------------------------------------------

class _ActiveClaimsTab extends StatelessWidget {
  const _ActiveClaimsTab();

  @override
  Widget build(BuildContext context) {
    return _ClaimListView(
      claims: _activeClaims,
      emptyText: 'No active claims found.',
      onTapClaim: (claim) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClaimMembersScreen(
              claim: claim,
              allowCollect: true,
              applyPenalty: false,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Old Paid section tab -> nested Old Pending / Old Paid tabs
// ---------------------------------------------------------------------------

class _OldPaidSectionTab extends StatelessWidget {
  const _OldPaidSectionTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              // labelColor: Colors.indigo,
              // unselectedLabelColor: Colors.black54,
              // indicatorColor: Colors.indigo,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Paid'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ClaimListView(
                  claims: _oldPendingClaims,
                  emptyText: 'No pending old claims found.',
                  onTapClaim: (claim) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClaimMembersScreen(
                          claim: claim,
                          allowCollect: true,
                          applyPenalty: true,
                        ),
                      ),
                    );
                  },
                ),
                _ClaimListView(
                  claims: _oldPaidClaims,
                  emptyText: 'No old paid claims found.',
                  onTapClaim: (claim) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClaimReceiptScreen(claim: claim),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared claim list widget
// ---------------------------------------------------------------------------

class _ClaimListView extends StatelessWidget {
  final List<ClaimRecord> claims;
  final String emptyText;
  final void Function(ClaimRecord claim) onTapClaim;

  const _ClaimListView({
    required this.claims,
    required this.emptyText,
    required this.onTapClaim,
  });

  @override
  Widget build(BuildContext context) {
    if (claims.isEmpty) {
      return Center(
        // child: Text(emptyText, style: const TextStyle(color: Colors.black54)),
        child: Text(emptyText, style: const TextStyle(color: AppColors.textLight)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: claims.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final claim = claims[index];
        return GestureDetector(
          onTap: () => onTapClaim(claim),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claim.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        claim.subtitle,
                        style: const TextStyle(
                            // color: Colors.black54, fontSize: 12),
                            color: AppColors.textLight, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // _statusChip(
                          //     '${claim.totalCount} Members', Colors.blue),
                          // if (claim.pendingCount > 0)
                          //   _statusChip(
                          //       '${claim.pendingCount} Pending', Colors.orange),
                          // if (claim.paidCount > 0)
                          //   _statusChip('${claim.paidCount} Paid', Colors.green),
                          _statusChip(
                              '${claim.totalCount} Members', AppColors.primary),
                          if (claim.pendingCount > 0)
                            _statusChip(
                                '${claim.pendingCount} Pending', AppColors.pending),
                          if (claim.paidCount > 0)
                            _statusChip('${claim.paidCount} Paid', AppColors.success),
                        ],
                      ),
                    ],
                  ),
                ),
                // const Icon(Icons.chevron_right, color: Colors.black38),
                const Icon(Icons.chevron_right, color: AppColors.textLight),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Member list for a single claim (pending/paid) with Collect action
// ---------------------------------------------------------------------------

class ClaimMembersScreen extends StatefulWidget {
  final ClaimRecord claim;
  final bool allowCollect;
  final bool applyPenalty;

  const ClaimMembersScreen({
    super.key,
    required this.claim,
    this.allowCollect = false,
    this.applyPenalty = false,
  });

  @override
  State<ClaimMembersScreen> createState() => _ClaimMembersScreenState();
}

class _ClaimMembersScreenState extends State<ClaimMembersScreen> {
  late List<MemberPaymentRecord> _members;

  @override
  void initState() {
    super.initState();
    _members = List.of(widget.claim.members);
  }

  Future<void> _collect(int index) async {
    final member = _members[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Collection'),
        content: Text(
          widget.applyPenalty
              ? 'Collect ₹${member.amount.toStringAsFixed(0)} + '
              'penalty ₹${member.penalty.toStringAsFixed(0)} from '
              '${member.name}?'
              : 'Collect ₹${member.amount.toStringAsFixed(0)} from '
              '${member.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _members[index] = MemberPaymentRecord(
          name: member.name,
          subtitle: member.subtitle,
          status: 'Paid',
          amount: member.amount,
          penalty: member.penalty,
          paidOn: 'Today',
          receiptNo: 'RC-${DateTime.now().millisecondsSinceEpoch % 100000}',
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment collected from ${member.name}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F6),
      // appBar: AppBar(
      //   title: Text(widget.claim.title),
      //   centerTitle: false,
      //   backgroundColor: const Color(0xFFF3F3F6),
      //   foregroundColor: Colors.black87,
      //   elevation: 0,
      // ),
      // body: ListView.separated(
      //   padding: const EdgeInsets.all(16),
      //   itemCount: _members.length,
      //   separatorBuilder: (_, __) => const SizedBox(height: 12),
      //   itemBuilder: (context, index) {
        body: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            itemCount: _members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
          final member = _members[index];
          final isPending = member.status == 'Pending';
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.subtitle,
                        style: const TextStyle(
                            // color: Colors.black54, fontSize: 12),
                            color: AppColors.textLight, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isPending
                            ? 'Pending: ₹${member.amount.toStringAsFixed(0)}'
                            '${widget.applyPenalty ? ' + ₹${member.penalty.toStringAsFixed(0)} penalty' : ''}'
                            : 'Paid on ${member.paidOn} · ${member.receiptNo}',
                        style: TextStyle(
                          color:
                          // isPending ? Colors.orange[800] : Colors.green[700],
                          isPending ? AppColors.pending : AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPending && widget.allowCollect)
                  ElevatedButton(
                    onPressed: () => _collect(index),
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.indigo,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Collect'),
                  )
                else if (!isPending)
                  // const Icon(Icons.check_circle, color: Colors.green),
                  const Icon(Icons.check_circle, color: AppColors.success),
              ],
            ),
          );
            },
          ),
        ),
    );
  }
}

// ---------------------------------------------------------------------------
// Receipt / details view for fully paid old claims
// ---------------------------------------------------------------------------

class ClaimReceiptScreen extends StatelessWidget {
  final ClaimRecord claim;

  const ClaimReceiptScreen({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF3F3F6),
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   title: Text(claim.title),
      //   centerTitle: false,
      //   backgroundColor: const Color(0xFFF3F3F6),
      //   foregroundColor: Colors.black87,
      //   elevation: 0,
      // ),
        body: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            itemCount: claim.members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
          final member = claim.members[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    // const Icon(Icons.receipt_long, color: Colors.indigo),
                    const Icon(Icons.receipt_long, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.subtitle,
                  // style: const TextStyle(color: Colors.black54, fontSize: 12),
                  style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                ),
                const Divider(height: 20),
                _detailRow('Amount', '₹${member.amount.toStringAsFixed(0)}'),
                _detailRow('Paid On', member.paidOn ?? '-'),
                _detailRow('Receipt No.', member.receiptNo ?? '-'),
                _detailRow('Status', member.status),
              ],
            ),
          );
            },
          ),
        ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              // style: const TextStyle(color: Colors.black54, fontSize: 12)),
              style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
          Text(
            value,
            style:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}