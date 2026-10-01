import 'package:flutter/material.dart';
import '../models/proposal_model.dart';
import '../utils/constants.dart';

class ProposalTile extends StatelessWidget {
  final ProposalModel proposal;
  final VoidCallback? onTap;

  const ProposalTile({super.key, required this.proposal, this.onTap});

  Color _statusColor() {
    switch (proposal.status) {
      case 'Approved':
        return AppColors.success;
      case 'Rejected':
        return AppColors.rejected;
      case 'Pending':
        return AppColors.pending;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        title: Text(proposal.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            "${proposal.proposalNo} • ${proposal.scheme}\nBy ${proposal.karyakarta} on ${proposal.date}"),
        isThreeLine: true,
        trailing: Chip(
          label: Text(proposal.status,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: _statusColor(),
        ),
      ),
    );
  }
}
