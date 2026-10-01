import 'package:flutter/material.dart';

/// App-wide static text, colors and format rules.
/// Edit these values freely — nothing else in the app needs to change.
class AppConstants {
  static const String appName = "Suthar Samaj Seva";

  // ---- ID / Number formats (for display & validation only) ----
  static const int memberIdLength = 7; // e.g. 7856891
  static const String kanyadanPrefix = "KDS";
  static const String putraVivahPrefix = "PVS";
  static const String mayaraPrefix = "MYS";
  static const String parivarKalyanPrefix = "PKS";
  static const String karyakartaPrefix = "SA";

  static const List<String> schemeNames = [
    "Kanyadan Yojana",
    "Putra Vivah Yojana",
    "Mayara Yojana",
    "Parivar Kalyan Yojana",
  ];

  static const List<String> proposalStatuses = [
    "New",
    "Pending",
    "Approved",
    "Rejected",
  ];
}

/// Single source of truth for backend role strings. Every screen that
/// checks `ApiService().roleName` (login routing, dashboards, guards)
/// should compare against these constants instead of retyping the raw
/// string, so a future backend rename only needs to change one place.
class AppRoles {
  static const String admin = 'admin';
  static const String karyakarta = 'karyakarta';
  static const String member = 'member';
}

class AppColors {
  // ---- Brand ----
  // static const Color primary = Color(0xFF6A5AE0);
  // static const Color primaryDark = Color(0xFF4B3FB0);
  static const Color primary = Color(0xFFE8631C);      // saffron-orange (outer ring of logo)
  static const Color primaryDark = Color(0xFFB8410E);  // deep red-orange (logo border)
  static const Color accent = Color(0xFFF2A93B);
  static const Color navy = Color(0xFF241C4F);
  static const Color navyDark = Color(0xFF1B1442);

  // ---- Base palette ----
  static const Color green = Color(0xFF16A085);
  static const Color orange = Color(0xFFC97C0F);
  static const Color red = Color(0xFFE0522F);
  static const Color blue = Color(0xFF2F7DE1);

  // ---- Surfaces ----
  static const Color background = Color(0xFFF7F6FB);
  // static const Color background = Color(0xFFC97C0F);
  static const Color cardBg = Colors.white;

  // ---- Bottom nav ----
  static const Color navActive = Color(0xFFF2A93B);
  static const Color navInactive = Color(0xFF8B8B8B);

  // ---- Semantic status colors ----
  static const Color success = green;
  static const Color pending = Color(0xFFF9A825);       // ✅ fixed — distinct amber, not same as red
  static const Color rejected = red;                    // ✅ added — used across login/otp/proposals/collection screens

  // ---- Text ----
  static const Color textDark = Color(0xFF1A1A1A);      // ✅ added — used in claim_request/collection screens
  static const Color textLight = Color(0xFF6B6B6B);     // ✅ added — used in claim_request/collection screens
// NEW
  static const Color purple = Color(0xFF9B59B6); // Earned Commission / Pending Payout tiles

  // ---- Dashboard-specific (added for dashboard_screen.dart parity) ----
  static const Color headerBg = Color(0xFFE9E7FB);
  static const Color headerTitle = Color(0xFF2A1E6E);
  static const Color headerSubtitle = Color(0xFF4A3FBE);
  static const Color teal = Color(0xFF2A9D8F);      // Karyakarta manage icon
  static const Color tealDark = Color(0xFF3D8B7D);   // Payment manage icon
// NEW
  static const Color brown = Color(0xFF7A5C61);      // Account manage icon
  // ---- Stat card tint backgrounds (dashboard) ----
  static const Color greenTint = Color(0xFFDFF6EA);
  static const Color orangeTint = Color(0xFFFBEBD4);
  static const Color redTint = Color(0xFFFBE3DD);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
