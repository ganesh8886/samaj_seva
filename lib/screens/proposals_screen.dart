import 'package:flutter/material.dart';
import '../models/proposal_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/proposal_tile.dart';

class ProposalsScreen extends StatefulWidget {
  const ProposalsScreen({super.key});

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: AppConstants.proposalStatuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Demo fallback data, shown if the API call fails (e.g. no backend yet)
  List<ProposalModel> _demoData(String status) => [
    ProposalModel(
      proposalNo: "PRP000125",
      name: "Mahesh Kumar",
      scheme: "Kanyadan",
      karyakarta: "Ramesh Patel",
      date: "20-02-2026",
      status: status,
    ),
    ProposalModel(
      proposalNo: "PRP000126",
      name: "Pooja Kumari",
      scheme: "Mayara",
      karyakarta: "Suresh Joshi",
      date: "20-02-2026",
      status: status,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Membership Proposals"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: AppConstants.proposalStatuses
              .map((s) => Tab(text: s))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: AppConstants.proposalStatuses.map((status) {
          return FutureBuilder<List<ProposalModel>>(
            future: _api.getProposals(status: status),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final proposals = (snapshot.hasError || snapshot.data == null)
                  ? _demoData(status)
                  : snapshot.data!;
              if (proposals.isEmpty) {
                return const Center(child: Text("No proposals found"));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: proposals.length,
                itemBuilder: (context, index) {
                  final p = proposals[index];
                  return ProposalTile(
                    proposal: p,
                    onTap: () => _showActions(p),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }

  void _showActions(ProposalModel proposal) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline,
                  color: AppColors.success),
              title: const Text("Approve"),
              onTap: () async {
                Navigator.pop(context);
                await _api.approveProposal(proposal.proposalNo);
                setState(() {});
              },
            ),
            ListTile(
              leading:
              const Icon(Icons.cancel_outlined, color: AppColors.rejected),
              title: const Text("Reject"),
              onTap: () async {
                Navigator.pop(context);
                await _api.rejectProposal(proposal.proposalNo);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
