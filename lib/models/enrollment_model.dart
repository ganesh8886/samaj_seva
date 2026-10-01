// class EnrollmentModel {
//   final String id;
//   final String memberId;
//   final String memberName;
//   final String schemeId;
//   final String schemeName;
//   final String status; // pending / approved / rejected
//   final String? rejectionReason;
//   final String? createdAt;
//
//   EnrollmentModel({
//     required this.id,
//     required this.memberId,
//     required this.memberName,
//     required this.schemeId,
//     required this.schemeName,
//     required this.status,
//     this.rejectionReason,
//     this.createdAt,
//   });
//
//   factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
//     return EnrollmentModel(
//       id: '${json['id'] ?? json['enrollment_id'] ?? ''}',
//       memberId: '${json['member_id'] ?? ''}',
//       memberName: json['member_name'] ?? json['member']?['name'] ?? '',
//       schemeId: '${json['scheme_id'] ?? ''}',
//       schemeName: json['scheme_name'] ?? json['scheme']?['name'] ?? '',
//       status: json['status'] ?? 'pending',
//       rejectionReason: json['rejection_reason'],
//       createdAt: json['created_at'],
//     );
//   }
// }

class EnrollmentModel {
  final String id;
  final String memberId;
  final String memberName;
  final String schemeId;
  final String schemeName;
  final String status; // pending / approved / rejected
  final String? rejectionReason;
  final String? createdAt;

  // ---- NEW (optional) fields to match the web admin "Scheme Enrollments" screen.
  // These are all nullable / default-safe, so the app keeps working even if
  // your current backend does NOT send them yet.
  final String? proposalNo;        // e.g. KDS-PN0000011
  final String? schemeAccountId;   // e.g. KDS00011
  final String? taggedKaryakarta;  // e.g. SA4281 - Govindbhai M. Suthar
  final double? joiningFee;        // e.g. 8500
  final double? perEventFee;       // e.g. 400
  final String? submittedBy;       // e.g. Admin / Head Office
  final String? proposalDocUrl;
  final String? dastavejDocUrl;

  EnrollmentModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.schemeId,
    required this.schemeName,
    required this.status,
    this.rejectionReason,
    this.createdAt,
    this.proposalNo,
    this.schemeAccountId,
    this.taggedKaryakarta,
    this.joiningFee,
    this.perEventFee,
    this.submittedBy,
    this.proposalDocUrl,
    this.dastavejDocUrl,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    double? _num(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return EnrollmentModel(
      id: '${json['id'] ?? json['enrollment_id'] ?? ''}',
      memberId: '${json['member_id'] ?? ''}',
      memberName: json['member_name'] ?? json['member']?['name'] ?? '',
      schemeId: '${json['scheme_id'] ?? ''}',
      schemeName: json['scheme_name'] ?? json['scheme']?['name'] ?? '',
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'],
      proposalNo: json['proposal_no']?.toString(),
      schemeAccountId: json['scheme_account_id']?.toString(),
      taggedKaryakarta: json['tagged_karyakarta']?.toString() ??
          json['karyakarta_name']?.toString(),
      joiningFee: _num(json['joining_fee']),
      perEventFee: _num(json['per_event_fee']),
      submittedBy: json['submitted_by']?.toString(),
      proposalDocUrl: json['proposal_doc_url']?.toString(),
      dastavejDocUrl: json['dastavej_doc_url']?.toString(),
    );
  }
}