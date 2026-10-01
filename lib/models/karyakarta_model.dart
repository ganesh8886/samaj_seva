// class KaryakartaModel {
//   final int id;
//   final String karyakartaCode;
//   final String fullName;
//   final String fatherName;
//   final String dob;
//   final String gender;
//   final String aadhaarNo;
//   final String panNo;
//   final String mobile;
//   final String altMobile;
//   final String email;
//   final String state;
//   final String district;
//   final String taluka;
//   final String village;
//   final String pincode;
//   final String fullAddress;
//   final String gotra;
//   final String occupation;
//   final String education;
//   final String status;
//   final String createdAt;
//
//   KaryakartaModel({
//     required this.id,
//     required this.karyakartaCode,
//     required this.fullName,
//     required this.fatherName,
//     required this.dob,
//     required this.gender,
//     required this.aadhaarNo,
//     required this.panNo,
//     required this.mobile,
//     required this.altMobile,
//     required this.email,
//     required this.state,
//     required this.district,
//     required this.taluka,
//     required this.village,
//     required this.pincode,
//     required this.fullAddress,
//     required this.gotra,
//     required this.occupation,
//     required this.education,
//     required this.status,
//     required this.createdAt,
//   });
//
//   factory KaryakartaModel.fromJson(Map<String, dynamic> json) {
//     String s(dynamic v) => v?.toString() ?? '';
//     return KaryakartaModel(
//       id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
//       karyakartaCode: s(json['karyakarta_code']),
//       fullName: s(json['full_name']),
//       fatherName: s(json['father_name']),
//       dob: s(json['dob']),
//       gender: s(json['gender']),
//       aadhaarNo: s(json['aadhaar_no']),
//       panNo: s(json['pan_no']),
//       mobile: s(json['mobile']),
//       altMobile: s(json['alt_mobile']),
//       email: s(json['email']),
//       state: s(json['state']),
//       district: s(json['district']),
//       taluka: s(json['taluka']),
//       village: s(json['village']),
//       pincode: s(json['pincode']),
//       fullAddress: s(json['full_address']),
//       gotra: s(json['gotra']),
//       occupation: s(json['occupation']),
//       education: s(json['education']),
//       status: s(json['status']),
//       createdAt: s(json['created_at']),
//     );
//   }
// }

class KaryakartaModel {
  final int id;
  final String karyakartaCode;
  final String fullName;
  final String fatherName;
  final String dob;
  final String gender;
  final String aadhaarNo;
  final String panNo;
  final String mobile;
  final String altMobile;
  final String email;
  final String state;
  final String district;
  final String taluka;
  final String village;
  final String pincode;
  final String fullAddress;
  final String gotra;
  final String occupation;
  final String education;
  final String status;
  final String createdAt; // used as Date of Joining (DOJ)
  final int memberCount;  // NEW: used for the "MEMBERS" column in the list

  KaryakartaModel({
    required this.id,
    required this.karyakartaCode,
    required this.fullName,
    required this.fatherName,
    required this.dob,
    required this.gender,
    required this.aadhaarNo,
    required this.panNo,
    required this.mobile,
    required this.altMobile,
    required this.email,
    required this.state,
    required this.district,
    required this.taluka,
    required this.village,
    required this.pincode,
    required this.fullAddress,
    required this.gotra,
    required this.occupation,
    required this.education,
    required this.status,
    required this.createdAt,
    this.memberCount = 0, // NEW
  });

  factory KaryakartaModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString() ?? '';
    return KaryakartaModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      karyakartaCode: s(json['karyakarta_code']),
      fullName: s(json['full_name']),
      fatherName: s(json['father_name']),
      dob: s(json['dob']),
      gender: s(json['gender']),
      aadhaarNo: s(json['aadhaar_no']),
      panNo: s(json['pan_no']),
      mobile: s(json['mobile']),
      altMobile: s(json['alt_mobile']),
      email: s(json['email']),
      state: s(json['state']),
      district: s(json['district']),
      taluka: s(json['taluka']),
      village: s(json['village']),
      pincode: s(json['pincode']),
      fullAddress: s(json['full_address']),
      gotra: s(json['gotra']),
      occupation: s(json['occupation']),
      education: s(json['education']),
      status: s(json['status']),
      createdAt: s(json['created_at']),
      // NEW: backend can send member_count as an int or as members_assigned; fall back to 0
      memberCount: int.tryParse(
          (json['member_count'] ?? json['members_assigned'] ?? '0')
              .toString()) ??
          0,
    );
  }
}