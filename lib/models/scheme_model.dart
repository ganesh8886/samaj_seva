class SchemeModel {
  final int id;
  final String schemeName;
  final String shortCode;
  final String schemeType;
  final String? description;
  final double managementChargePercent;
  final int minMembers;
  final int maxMembers;

  SchemeModel({
    required this.id,
    required this.schemeName,
    required this.shortCode,
    required this.schemeType,
    this.description,
    required this.managementChargePercent,
    required this.minMembers,
    required this.maxMembers,
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      schemeName: json['scheme_name']?.toString() ?? '',
      shortCode: json['short_code']?.toString() ?? '',
      schemeType: json['scheme_type']?.toString() ?? '',
      description: json['description']?.toString(),
      managementChargePercent: json['management_charge_percent'] is num
          ? (json['management_charge_percent'] as num).toDouble()
          : double.tryParse('${json['management_charge_percent']}') ?? 0,
      minMembers: json['min_members'] is int
          ? json['min_members']
          : int.tryParse('${json['min_members']}') ?? 0,
      maxMembers: json['max_members'] is int
          ? json['max_members']
          : int.tryParse('${json['max_members']}') ?? 0,
    );
  }
}