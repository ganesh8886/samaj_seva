// // class MemberModel {
// //   final String memberId; // 7-digit auto ID
// //   final String fullName;
// //   final String fatherName;
// //   final String dob;
// //   final String gender;
// //   final String aadhaarNumber;
// //   final String? panNumber;
// //   final String mobileNumber;
// //   final String? alternateMobile;
// //   final String? email;
// //
// //   // Address
// //   final String state;
// //   final String district;
// //   final String taluka;
// //   final String village;
// //   final String pinCode;
// //   final String fullAddress;
// //
// //   // Samaj info
// //   final String gotra;
// //   final String occupation;
// //   final String education;
// //
// //   MemberModel({
// //     required this.memberId,
// //     required this.fullName,
// //     required this.fatherName,
// //     required this.dob,
// //     required this.gender,
// //     required this.aadhaarNumber,
// //     this.panNumber,
// //     required this.mobileNumber,
// //     this.alternateMobile,
// //     this.email,
// //     required this.state,
// //     required this.district,
// //     required this.taluka,
// //     required this.village,
// //     required this.pinCode,
// //     required this.fullAddress,
// //     required this.gotra,
// //     required this.occupation,
// //     required this.education,
// //   });
// //   factory MemberModel.fromJson(Map<String, dynamic> json) {
// //     return MemberModel(
// //       memberId: json['member_id']?.toString() ?? '',
// //       fullName: json['full_name']?.toString() ?? '',
// //       fatherName: json['father_name']?.toString() ?? '',
// //       dob: json['dob']?.toString() ?? '',
// //       gender: json['gender']?.toString() ?? '',
// //       aadhaarNumber: json['aadhaar_number']?.toString() ?? '',
// //       panNumber: json['pan_number']?.toString(),
// //       mobileNumber: json['mobile_number']?.toString() ?? '',
// //       alternateMobile: json['alternate_mobile']?.toString(),
// //       email: json['email']?.toString(),
// //       state: json['state']?.toString() ?? '',
// //       district: json['district']?.toString() ?? '',
// //       taluka: json['taluka']?.toString() ?? '',
// //       village: json['village']?.toString() ?? '',
// //       pinCode: json['pin_code']?.toString() ?? '',
// //       fullAddress: json['full_address']?.toString() ?? '',
// //       gotra: json['gotra']?.toString() ?? '',
// //       occupation: json['occupation']?.toString() ?? '',
// //       education: json['education']?.toString() ?? '',
// //     );
// //   }
// //   Map<String, dynamic> toJson() => {
// //     'member_id': memberId,
// //     'full_name': fullName,
// //     'father_name': fatherName,
// //     'dob': dob,
// //     'gender': gender,
// //     'aadhaar_number': aadhaarNumber,
// //     'pan_number': panNumber,
// //     'mobile_number': mobileNumber,
// //     'alternate_mobile': alternateMobile,
// //     'email': email,
// //     'state': state,
// //     'district': district,
// //     'taluka': taluka,
// //     'village': village,
// //     'pin_code': pinCode,
// //     'full_address': fullAddress,
// //     'gotra': gotra,
// //     'occupation': occupation,
// //     'education': education,
// //   };
// // }
//
// class MemberModel {
//   final int id;
//   final int karyakartaId;
//   final String fullName;
//   final String gotra;
//   final String dob;
//   final String gender;
//   final String mobile;
//   final String aadhaarNo;
//   final String fatherName;
//   final String motherName;
//   final String nomineeName;
//   final String nomineeRelation;
//   final String state;
//   final String district;
//   final String taluka;
//   final String village;
//   final String address;
//   final String pincode;
//   final String status;
//   final String createdAt;
//
//   MemberModel({
//     required this.id,
//     required this.karyakartaId,
//     required this.fullName,
//     required this.gotra,
//     required this.dob,
//     required this.gender,
//     required this.mobile,
//     required this.aadhaarNo,
//     required this.fatherName,
//     required this.motherName,
//     required this.nomineeName,
//     required this.nomineeRelation,
//     required this.state,
//     required this.district,
//     required this.taluka,
//     required this.village,
//     required this.address,
//     required this.pincode,
//     required this.status,
//     required this.createdAt,
//   });
//
//   factory MemberModel.fromJson(Map<String, dynamic> json) {
//     String s(dynamic v) => v?.toString() ?? '';
//     return MemberModel(
//       id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
//       karyakartaId: int.tryParse(json['karyakarta_id']?.toString() ?? '') ?? 0,
//       fullName: s(json['full_name']),
//       gotra: s(json['gotra']),
//       dob: s(json['dob']),
//       gender: s(json['gender']),
//       mobile: s(json['mobile']),
//       aadhaarNo: s(json['aadhaar_no']),
//       fatherName: s(json['father_name']),
//       motherName: s(json['mother_name']),
//       nomineeName: s(json['nominee_name']),
//       nomineeRelation: s(json['nominee_relation']),
//       state: s(json['state']),
//       district: s(json['district']),
//       taluka: s(json['taluka']),
//       village: s(json['village']),
//       address: s(json['address']),
//       pincode: s(json['pincode']),
//       status: s(json['status']),
//       createdAt: s(json['created_at']),
//     );
//   }
// }

// class MemberModel {
//   final int id;
//   final int karyakartaId;
//   final String memberId;          // NEW — display ID, e.g. "6825955" or "MEM202682337"
//   final String karyakartaCode;    // NEW — e.g. "SA4281"
//   final String fullName;
//   final String gotra;
//   final String dob;
//   final String gender;
//   final String mobile;
//   final String aadhaarNo;
//   final String fatherName;
//   final String motherName;
//   final String husbandName;       // NEW
//   final String guardianName;      // NEW
//   final String nomineeName;
//   final String nomineeRelation;
//   final String state;
//   final String district;
//   final String taluka;
//   final String village;
//   final String address;
//   final String pincode;
//   final String status;
//   final String createdAt;
//   final String? email;            // NEW
//   final String? aadhaarDoc;       // NEW — file path from server
//   final String? photoDoc;         // NEW
//   final String? authDoc;          // NEW
//   final String submittedByType;   // NEW — "admin" etc.
//   final Map<String, dynamic> raw; // NEW — full original JSON, for anything not modeled above
//
//   MemberModel({
//     required this.id,
//     required this.karyakartaId,
//     required this.memberId,
//     required this.karyakartaCode,
//     required this.fullName,
//     required this.gotra,
//     required this.dob,
//     required this.gender,
//     required this.mobile,
//     required this.aadhaarNo,
//     required this.fatherName,
//     required this.motherName,
//     required this.husbandName,
//     required this.guardianName,
//     required this.nomineeName,
//     required this.nomineeRelation,
//     required this.state,
//     required this.district,
//     required this.taluka,
//     required this.village,
//     required this.address,
//     required this.pincode,
//     required this.status,
//     required this.createdAt,
//     this.email,
//     this.aadhaarDoc,
//     this.photoDoc,
//     this.authDoc,
//     required this.submittedByType,
//     required this.raw,
//   });
//
//   factory MemberModel.fromJson(Map<String, dynamic> json) {
//     String s(dynamic v) => v?.toString() ?? '';
//     String? sn(dynamic v) => v == null ? null : v.toString();
//     return MemberModel(
//       id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
//       karyakartaId: int.tryParse(json['karyakarta_id']?.toString() ?? '') ?? 0,
//       memberId: s(json['member_id']),
//       karyakartaCode: s(json['karyakarta_code']),
//       fullName: s(json['full_name']),
//       gotra: s(json['gotra']),
//       dob: s(json['dob']),
//       gender: s(json['gender']),
//       mobile: s(json['mobile']),
//       aadhaarNo: s(json['aadhaar_no']),
//       fatherName: s(json['father_name']),
//       motherName: s(json['mother_name']),
//       husbandName: s(json['husband_name']),
//       guardianName: s(json['guardian_name']),
//       nomineeName: s(json['nominee_name']),
//       nomineeRelation: s(json['nominee_relation']),
//       state: s(json['state']),
//       district: s(json['district']),
//       taluka: s(json['taluka']),
//       village: s(json['village']),
//       address: s(json['address']),
//       pincode: s(json['pincode']),
//       status: s(json['status']),
//       createdAt: s(json['created_at']),
//       email: sn(json['email']),
//       aadhaarDoc: sn(json['aadhaar_doc']),
//       photoDoc: sn(json['photo_doc']),
//       authDoc: sn(json['auth_doc']),
//       submittedByType: s(json['submitted_by_type']),
//       raw: json,
//     );
//   }
//
//   /// Handy for the edit form: builds a PUT payload straight from current
//   /// field values, so you don't retype every key by hand in the screen.
//   Map<String, dynamic> toUpdatePayload() => {
//     "full_name": fullName,
//     "gotra": gotra,
//     "dob": dob,
//     "gender": gender,
//     "mobile": mobile,
//     "aadhaar_no": aadhaarNo,
//     "father_name": fatherName,
//     "mother_name": motherName,
//     "husband_name": husbandName,
//     "guardian_name": guardianName,
//     "nominee_name": nomineeName,
//     "nominee_relation": nomineeRelation,
//     "state": state,
//     "district": district,
//     "taluka": taluka,
//     "village": village,
//     "address": address,
//     "pincode": pincode,
//   };
// }

class MemberModel {
  final int id;
  final int karyakartaId;
  final String memberId;
  final String karyakartaCode;
  final String fullName;
  final String gotra;
  final String dob;
  final String gender;
  final String mobile;
  final String aadhaarNo;
  final String fatherName;
  final String motherName;
  final String husbandName;
  final String guardianName;
  final String nomineeName;
  final String nomineeRelation;
  final String state;
  final String district;
  final String taluka;
  final String village;
  final String address;
  final String pincode;
  final String status;
  final String createdAt;
  final String? email;
  final String? aadhaarDoc;
  final String? photoDoc;
  final String? authDoc;
  final String submittedByType;
  final Map<String, dynamic> raw;

  MemberModel({
    required this.id,
    required this.karyakartaId,
    required this.memberId,
    required this.karyakartaCode,
    required this.fullName,
    required this.gotra,
    required this.dob,
    required this.gender,
    required this.mobile,
    required this.aadhaarNo,
    required this.fatherName,
    required this.motherName,
    required this.husbandName,
    required this.guardianName,
    required this.nomineeName,
    required this.nomineeRelation,
    required this.state,
    required this.district,
    required this.taluka,
    required this.village,
    required this.address,
    required this.pincode,
    required this.status,
    required this.createdAt,
    this.email,
    this.aadhaarDoc,
    this.photoDoc,
    this.authDoc,
    required this.submittedByType,
    required this.raw,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString() ?? '';
    String? sn(dynamic v) => v == null ? null : v.toString();
    return MemberModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      karyakartaId: int.tryParse(json['karyakarta_id']?.toString() ?? '') ?? 0,
      memberId: s(json['member_id']),
      karyakartaCode: s(json['karyakarta_code']),
      fullName: s(json['full_name']),
      gotra: s(json['gotra']),
      dob: s(json['dob']),
      gender: s(json['gender']),
      mobile: s(json['mobile']),
      aadhaarNo: s(json['aadhaar_no']),
      fatherName: s(json['father_name']),
      motherName: s(json['mother_name']),
      husbandName: s(json['husband_name']),
      guardianName: s(json['guardian_name']),
      nomineeName: s(json['nominee_name']),
      nomineeRelation: s(json['nominee_relation']),
      state: s(json['state']),
      district: s(json['district']),
      taluka: s(json['taluka']),
      village: s(json['village']),
      address: s(json['address']),
      pincode: s(json['pincode']),
      status: s(json['status']),
      createdAt: s(json['created_at']),
      email: sn(json['email']),
      aadhaarDoc: sn(json['aadhaar_doc']),
      photoDoc: sn(json['photo_doc']),
      authDoc: sn(json['auth_doc']),
      submittedByType: s(json['submitted_by_type']),
      raw: json,
    );
  }

  Map<String, dynamic> toUpdatePayload() => {
    "full_name": fullName,
    "gotra": gotra,
    "dob": dob,
    "gender": gender,
    "mobile": mobile,
    "aadhaar_no": aadhaarNo,
    "father_name": fatherName,
    "mother_name": motherName,
    "husband_name": husbandName,
    "guardian_name": guardianName,
    "nominee_name": nomineeName,
    "nominee_relation": nomineeRelation,
    "state": state,
    "district": district,
    "taluka": taluka,
    "village": village,
    "address": address,
    "pincode": pincode,
  };
}