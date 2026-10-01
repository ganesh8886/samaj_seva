class AppConfig {
  // TODO: change if your domain/path differs
  static const String adminBaseUrl = "https://sugamdigital.in/sssERP/admin";

  static String idCardUrl(int id) =>
      "$adminBaseUrl/karyakarta_card.php?id=$id&type=id_card";

  static String certificateUrl(int id) =>
      "$adminBaseUrl/karyakarta_card.php?id=$id&type=certificate";

  static String editKaryakartaUrl(int id) =>
      "$adminBaseUrl/karyakarta_new.php?id=$id";
}