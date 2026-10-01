class ContributionBatchModel {
  final String id;
  final String claimId;
  final int totalEnrolledSnapshot;
  final double expectedCollection;
  final double managementCharge;
  final double netSettlement;
  final String status; // open / settled
  final String? createdAt;

  ContributionBatchModel({
    required this.id,
    required this.claimId,
    required this.totalEnrolledSnapshot,
    required this.expectedCollection,
    required this.managementCharge,
    required this.netSettlement,
    required this.status,
    this.createdAt,
  });

  factory ContributionBatchModel.fromJson(Map<String, dynamic> json) {
    double _num(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return ContributionBatchModel(
      id: (json['id'] ?? '').toString(),
      claimId: (json['claim_id'] ?? '').toString(),
      totalEnrolledSnapshot:
      int.tryParse(json['total_enrolled_snapshot']?.toString() ?? '') ?? 0,
      expectedCollection: _num(json['expected_collection']),
      managementCharge: _num(json['management_charge']),
      netSettlement: _num(json['net_settlement']),
      status: (json['status']?.toString() ?? 'open').toLowerCase(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "claim_id": int.tryParse(claimId) ?? claimId,
    "total_enrolled_snapshot": totalEnrolledSnapshot,
    "expected_collection": expectedCollection,
    "management_charge": managementCharge,
    "net_settlement": netSettlement,
  };
}