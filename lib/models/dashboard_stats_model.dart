// class DashboardStatsModel {
//   final int newProposals;
//   final int pendingApprovals;
//   final int totalMembers;
//   final double totalCollection;
//   final int pendingClaims;
//
//   DashboardStatsModel({
//     required this.newProposals,
//     required this.pendingApprovals,
//     required this.totalMembers,
//     required this.totalCollection,
//     required this.pendingClaims,
//   });
//
//   factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
//     return DashboardStatsModel(
//       newProposals: json['new_proposals'] ?? 0,
//       pendingApprovals: json['pending_approvals'] ?? 0,
//       totalMembers: json['total_members'] ?? 0,
//       totalCollection: (json['total_collection'] ?? 0).toDouble(),
//       pendingClaims: json['pending_claims'] ?? 0,
//     );
//   }
//
//   /// Fallback demo data so the UI has something to show
//   /// before the real API is wired up.
//   factory DashboardStatsModel.demo() => DashboardStatsModel(
//     newProposals: 15,
//     pendingApprovals: 8,
//     totalMembers: 12548,
//     totalCollection: 1245680,
//     pendingClaims: 6,
//   );
// }

/// Stats shown on the Admin dashboard.
/// Field names below match what dashboardStats should eventually return;
/// until that endpoint is confirmed, DashboardScreen falls back to demo().
class DashboardStatsModel {
  final int activeMembers;
  final int socialActivists;
  final int pendingProposals;
  final double todaysCollection;

  DashboardStatsModel({
    required this.activeMembers,
    required this.socialActivists,
    required this.pendingProposals,
    required this.todaysCollection,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      activeMembers: (json['total_members'] ?? 0) as int,
      socialActivists: (json['total_karyakartas'] ?? 0) as int,
      pendingProposals: (json['pending_proposals'] ?? 0) as int,
      todaysCollection:
      double.tryParse('${json['total_collections'] ?? 0}') ?? 0.0,
    );
  }

  factory DashboardStatsModel.demo() {
    return DashboardStatsModel(
      activeMembers: 35,
      socialActivists: 1,
      pendingProposals: 0,
      todaysCollection: 0.0,
    );
  }
}