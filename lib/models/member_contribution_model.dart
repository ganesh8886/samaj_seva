class MemberContributionModel {
  final String id;
  final String batchId;
  final String memberId;
  final String karyakartaId;
  final double amount;
  final String paymentMode;
  final String receiptNo;
  final String status; // pending / paid

  MemberContributionModel({
    required this.id,
    required this.batchId,
    required this.memberId,
    required this.karyakartaId,
    required this.amount,
    required this.paymentMode,
    required this.receiptNo,
    required this.status,
  });

  factory MemberContributionModel.fromJson(Map<String, dynamic> json) {
    double _num(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return MemberContributionModel(
      id: (json['id'] ?? '').toString(),
      batchId: (json['batch_id'] ?? '').toString(),
      memberId: (json['member_id'] ?? '').toString(),
      karyakartaId: (json['karyakarta_id'] ?? '').toString(),
      amount: _num(json['amount']),
      paymentMode: json['payment_mode']?.toString() ?? '',
      receiptNo: json['receipt_no']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() => {
    "batch_id": int.tryParse(batchId) ?? batchId,
    "member_id": int.tryParse(memberId) ?? memberId,
    "karyakarta_id": int.tryParse(karyakartaId) ?? karyakartaId,
    "amount": amount,
    "payment_mode": paymentMode,
    "receipt_no": receiptNo,
  };
}