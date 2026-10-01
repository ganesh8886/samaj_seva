// // NEW
// class KaryakartaSession {
//   static String saCode = '';
//   static String fullName = 'Karyakarta';
//   static String mobile = '';
//   static String village = '';
//   static String photoUrl = '';
//   static int karyakartaId = 0;   // NEW — from login "karyakarta_id"
//   static int userId = 0;         // NEW — from login "user_id"
// }

class KaryakartaSession {
  static String saCode = '';
  static String fullName = 'Karyakarta';
  static String mobile = '';
  static String village = '';
  static String photoUrl = '';
  static int karyakartaId = 0;
  static int userId = 0;

  /// Call this on logout so the next login starts clean.
  static void clear() {
    saCode = '';
    fullName = 'Karyakarta';
    mobile = '';
    village = '';
    photoUrl = '';
    karyakartaId = 0;
    userId = 0;
  }
}