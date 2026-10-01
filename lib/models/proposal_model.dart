class ProposalModel {
  final String proposalNo;
  final String name;
  final String scheme;
  final String karyakarta;
  final String date;
  final String status; // New, Pending, Approved, Rejected

  ProposalModel({
    required this.proposalNo,
    required this.name,
    required this.scheme,
    required this.karyakarta,
    required this.date,
    required this.status,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(
      proposalNo: json['proposal_no']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      scheme: json['scheme']?.toString() ?? '',
      karyakarta: json['karyakarta']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'New',
    );
  }

  Map<String, dynamic> toJson() => {
    'proposal_no': proposalNo,
    'name': name,
    'scheme': scheme,
    'karyakarta': karyakarta,
    'date': date,
    'status': status,
  };
}
