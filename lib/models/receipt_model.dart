class ReceiptModel {
  final String id;
  final String receiptNo;
  final String memberId;
  final String karyakartaId;
  final String enrollmentId;
  final double amount;
  final String type; // joining_fee / contribution / other
  final String paymentMode; // Cash / Online / Cheque ...
  final String refBatchId;
  final String refClaimId;
  final String? createdAt;

  ReceiptModel({
    required this.id,
    required this.receiptNo,
    required this.memberId,
    required this.karyakartaId,
    required this.enrollmentId,
    required this.amount,
    required this.type,
    required this.paymentMode,
    required this.refBatchId,
    required this.refClaimId,
    this.createdAt,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    double _num(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return ReceiptModel(
      id: (json['id'] ?? '').toString(),
      receiptNo: (json['receipt_no'] ?? json['receiptNo'] ?? '').toString(),
      memberId: (json['member_id'] ?? '').toString(),
      karyakartaId: (json['karyakarta_id'] ?? '').toString(),
      enrollmentId: (json['enrollment_id'] ?? '').toString(),
      amount: _num(json['amount']),
      type: json['type']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '',
      refBatchId: (json['ref_batch_id'] ?? '0').toString(),
      refClaimId: (json['ref_claim_id'] ?? '0').toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "member_id": int.tryParse(memberId) ?? memberId,
    "karyakarta_id": int.tryParse(karyakartaId) ?? karyakartaId,
    "enrollment_id": int.tryParse(enrollmentId) ?? enrollmentId,
    "amount": amount,
    "type": type,
    "payment_mode": paymentMode,
    "ref_batch_id": int.tryParse(refBatchId) ?? 0,
    "ref_claim_id": int.tryParse(refClaimId) ?? 0,
  };
}