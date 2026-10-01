// class ClaimModel {
//   final String id;
//   final String enrollmentId;
//   final String claimType;
//   final double claimAmount;
//   final double? approvedAmount;
//   final String claimDate;
//   final String reason;
//   final String hospitalName;
//   final String status; // pending / approved / rejected / paid
//   final String? rejectionReason;
//   final String? remarks;
//
//   ClaimModel({
//     required this.id,
//     required this.enrollmentId,
//     required this.claimType,
//     required this.claimAmount,
//     this.approvedAmount,
//     required this.claimDate,
//     required this.reason,
//     required this.hospitalName,
//     required this.status,
//     this.rejectionReason,
//     this.remarks,
//   });
//
//   factory ClaimModel.fromJson(Map<String, dynamic> json) {
//     double? _num(dynamic v) {
//       if (v == null) return null;
//       if (v is num) return v.toDouble();
//       return double.tryParse(v.toString());
//     }
//
//     return ClaimModel(
//       id: (json['id'] ?? json['claim_id'] ?? '').toString(),
//       enrollmentId: (json['enrollment_id'] ?? '').toString(),
//       claimType: json['claim_type']?.toString() ?? '',
//       claimAmount: _num(json['claim_amount']) ?? 0,
//       approvedAmount: _num(json['approved_amount']),
//       claimDate: json['claim_date']?.toString() ?? '',
//       reason: json['reason']?.toString() ?? '',
//       hospitalName: json['hospital_name']?.toString() ?? '',
//       status: (json['status']?.toString() ?? 'pending').toLowerCase(),
//       rejectionReason: json['rejection_reason']?.toString(),
//       remarks: json['remarks']?.toString(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "enrollment_id": enrollmentId,
//     "claim_type": claimType,
//     "claim_amount": claimAmount,
//     "claim_date": claimDate,
//     "reason": reason,
//     "hospital_name": hospitalName,
//   };
// }

class ClaimModel {
  final String id;
  final String enrollmentId;
  final String claimType;
  final double claimAmount;
  final double? approvedAmount;
  final String claimDate;
  final String reason;
  final String hospitalName;
  final String status; // pending / approved / rejected / paid
  final String? rejectionReason;
  final String? remarks;

  // ---- NEW (optional) fields to match the web "Claims & Settlement Manager".
  final String? requestNo;         // e.g. CLM-REQ0001
  final String? memberName;
  final String? memberIdDisplay;   // scheme account id shown next to member
  final String? schemeName;
  final String? schemeAccountId;
  final String? taggedKaryakarta;
  final String? eventType;
  final double? netPayable;
  final String? submittedBy;
  final String? collectionStatus;  // pending / collected / settled

  ClaimModel({
    required this.id,
    required this.enrollmentId,
    required this.claimType,
    required this.claimAmount,
    this.approvedAmount,
    required this.claimDate,
    required this.reason,
    required this.hospitalName,
    required this.status,
    this.rejectionReason,
    this.remarks,
    this.requestNo,
    this.memberName,
    this.memberIdDisplay,
    this.schemeName,
    this.schemeAccountId,
    this.taggedKaryakarta,
    this.eventType,
    this.netPayable,
    this.submittedBy,
    this.collectionStatus,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    double? _num(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return ClaimModel(
      id: (json['id'] ?? json['claim_id'] ?? '').toString(),
      enrollmentId: (json['enrollment_id'] ?? '').toString(),
      claimType: json['claim_type']?.toString() ?? '',
      claimAmount: _num(json['claim_amount']) ?? 0,
      approvedAmount: _num(json['approved_amount']),
      claimDate: json['claim_date']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      hospitalName: json['hospital_name']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
      rejectionReason: json['rejection_reason']?.toString(),
      remarks: json['remarks']?.toString(),
      requestNo: json['request_no']?.toString(),
      memberName: json['member_name']?.toString(),
      memberIdDisplay: json['member_display_id']?.toString(),
      schemeName: json['scheme_name']?.toString(),
      schemeAccountId: json['scheme_account_id']?.toString(),
      taggedKaryakarta: json['tagged_karyakarta']?.toString(),
      eventType: json['event_type']?.toString(),
      netPayable: _num(json['net_payable']),
      submittedBy: json['submitted_by']?.toString(),
      collectionStatus: json['collection_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "enrollment_id": enrollmentId,
    "claim_type": claimType,
    "claim_amount": claimAmount,
    "claim_date": claimDate,
    "reason": reason,
    "hospital_name": hospitalName,
  };
}