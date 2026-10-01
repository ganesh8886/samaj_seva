 /// Central place for every API endpoint used in the app.
    /// Replace `baseUrl` with your real backend, and adjust paths
    /// if your backend uses different routes.
    class ApiConfig {
      static const String baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://sugamdigital.in/sssERP/api',
      );
      static const String adminBaseUrl = String.fromEnvironment(
        'ADMIN_BASE_URL',
        defaultValue: 'https://sugamdigital.in/sssERP/admin',
      );
 // class ApiConfig {
 //   // Use dynamic base URL that can be changed at runtime if needed
 //   static String baseUrl = String.fromEnvironment(
 //     'API_BASE_URL',
 //     defaultValue: 'http://192.168.100.48:3000/api',
 //   );
 //   static String adminBaseUrl = String.fromEnvironment(
 //     'ADMIN_BASE_URL',
 //     defaultValue: 'http://192.168.100.48:3000/admin',
 //   );
 //
 //   Add method to update base URL dynamically (useful for testing)
 //   static void updateBaseUrl(String newBaseUrl) {
 //     baseUrl = newBaseUrl;
 //   }

      static String idCardUrl(int id, {String? token}) =>
          "$adminBaseUrl/karyakarta_card.php?id=$id&type=id_card${token != null && token.isNotEmpty ? '&token=$token' : ''}";

      static String certificateUrl(int id, {String? token}) =>
          "$adminBaseUrl/karyakarta_card.php?id=$id&type=certificate${token != null && token.isNotEmpty ? '&token=$token' : ''}";

      static String editKaryakartaUrl(int id, {String? token}) =>
          "$adminBaseUrl/karyakarta_new.php?id=$id${token != null && token.isNotEmpty ? '&token=$token' : ''}";
      // ---- Document Share Tokens (NEW) ----
      static const String documentShareToken = "$adminBaseUrl/share_token.php"; // POST {doc_type, record_id}
      // ============ NEW ============
      // static String karyakartaEnrollmentProposalWebUrl(String enrollmentId, String token) =>
      //     "$adminBaseUrl/proposal_doc.php?id=$enrollmentId&token=$token";
      static String karyakartaEnrollmentProposalWebUrl(String enrollmentId, String token) =>
          "$adminBaseUrl/proposal_doc.php?id=$enrollmentId&token=$token&mobile=1";
      // ---- Payment Master Register (Collection Manage tabs) ----
      static const String paymentMasterRegister = "$baseUrl/payment/master-register"; // GET ?type=collection&category=joining_fee|contribution

// ---- Collections Dashboard (Collection Manage -> Dashboard tab) ----
      static const String collectionsDashboard = "$baseUrl/collections/dashboard"; // GET

// ---- Admin Notifications (Notifications & Logs) ----
      static const String adminNotifications = "$baseUrl/notifications"; // GET

      // // ---- Auth ----
      // static const String login = "$baseUrl/auth/login"; // POST {username, password}
      // // NEW
      // static const String karyakartaLogin = "$baseUrl/auth/karyakarta-login"; // POST {username, password}
      // static const String memberLogin = "$baseUrl/auth/member-login"; // POST {username, password}
      // ---- Auth ----
      static const String login = "$baseUrl/auth/login"; // POST {username, password}
      static const String karyakartaLogin = "$baseUrl/auth/karyakarta-login"; // POST {username, password}
      static const String memberLogin = "$baseUrl/auth/member-login"; // POST {username, password}
      // NEW — add this line inside class ApiConfig
      static const String karyakartaEnrollments = "$baseUrl/karyakarta/enrollments"; // GET list / POST create
      static String karyakartaEnrollmentById(String id) =>
          "$baseUrl/karyakarta/enrollments/$id"; // GET single enrollment

      // ---- Enrollment Create Screen (NEW) ----
      static const String karyakartaWelfareSchemes = "$baseUrl/karyakarta/schemes"; // GET — dropdown list
      static const String karyakartaMemberLookup = "$baseUrl/karyakarta/members/lookup"; // GET ?q=memberId|mobile|aadhaar
      static String karyakartaSchemeRates(String schemeId) =>
          "$baseUrl/karyakarta/schemes/$schemeId/rates"; // GET ?age_group=...

      // NEW — Karyakarta dashboard summary (stats + recent members/enrollments)
      static const String karyakartaDashboard = "$baseUrl/karyakarta/dashboard"; // GET

      // NEW — Karyakarta's own profile (logged-in karyakarta) + their members list
      static const String karyakartaSelfProfile = "$baseUrl/karyakarta/profile"; // GET
      static const String karyakartaMembers = "$baseUrl/karyakarta/members"; // GET list / POST create

// NEW — Karyakarta Member PVC Card
      static String karyakartaMemberPvcCard(String memberId) =>
          "$baseUrl/karyakarta/members/$memberId/pvc-card"; // GET
//       // ============ NEW ============
      // PVC / ID Card & Certificate (with mobile layout & hide_back parameters)
      static String karyakartaMemberPvcCardWebUrl(
          String memberId, String token, {String type = 'id_card'}) {
        final id = Uri.encodeComponent(memberId.trim());
        final tok = Uri.encodeComponent(token.trim());
        return "$adminBaseUrl/member_card.php?id=$id&type=$type&token=$tok&mobile=1&hide_back=1";
      }

// // Dastavej (policy document)
//       static String karyakartaEnrollmentDastavejWebUrl(String enrollmentId, String token) =>
//           "$adminBaseUrl/policy_dastavej.php?id=$enrollmentId&token=$token";
      static String karyakartaEnrollmentDastavejWebUrl(String enrollmentId, String token) =>
          "$adminBaseUrl/policy_dastavej.php?id=$enrollmentId&token=$token&mobile=1";
      // NEW — Claim Application Form (matches admin/claim_doc.php?id=..&token=..)
      static String karyakartaClaimDocWebUrl(String claimId, String token) =>
          "$adminBaseUrl/claim_doc.php?id=$claimId&type=claim&token=$token&mobile=1";

// Dastavej (policy document) — share/download link using active API token
//       static String karyakartaEnrollmentDastavejShareUrl(String enrollmentId, String token) {
//         final tok = Uri.encodeComponent(token.trim());
//         if (enrollmentId.trim().isNotEmpty) {
//           final id = Uri.encodeComponent(enrollmentId.trim());
//           return "$adminBaseUrl/policy_dastavej.php?id=$id&token=$tok&auto_download=1";
//         }
//         return "$adminBaseUrl/policy_dastavej.php?token=$tok&auto_download=1";
//       }
      static String karyakartaEnrollmentDastavejShareUrl(String enrollmentId, String token) {
        final tok = Uri.encodeComponent(token.trim());
        if (enrollmentId.trim().isNotEmpty) {
          final id = Uri.encodeComponent(enrollmentId.trim());
          return "$adminBaseUrl/policy_dastavej.php?id=$id&token=$tok&mobile=1&auto_download=1";
        }
        return "$adminBaseUrl/policy_dastavej.php?token=$tok&mobile=1&auto_download=1";
      }
      // ---- Organization Profile (NEW) ----
      static const String organizationProfile = "$baseUrl/config/organization"; // GET / PUT
      // NEW — add near the other web-url builders
      static String get karyakartaWebBaseUrl =>
          adminBaseUrl.replaceFirst('/admin', '/karyakarta');

      static String karyakartaEnrollmentDetailsWebUrl(String enrollmentId, String token) =>
          "$karyakartaWebBaseUrl/enrollment_details.php?id=$enrollmentId&token=$token";

      // NEW — Karyakarta Claims (submit + view)
      static const String karyakartaClaims = "$baseUrl/karyakarta/claims"; // GET list / POST create
      static String karyakartaClaimById(String id) =>
          "$baseUrl/karyakarta/claims/$id"; // GET single claim

      // NEW — Karyakarta Collections (record + view)
      static const String karyakartaCollections = "$baseUrl/karyakarta/collections"; // GET list / POST create

      // NEW — Direct Collect + Claim Batch Detail
      static const String karyakartaMemberPendingDues =
          "$baseUrl/karyakarta/collections/member-dues"; // GET ?query=memberId|mobile
      static const String karyakartaPayMemberDues =
          "$baseUrl/karyakarta/collections/pay-dues"; // POST {member_id, due_ids, payment_mode}
      static String karyakartaClaimBatchDetail(String claimId) =>
          "$baseUrl/karyakarta/claim-batches/$claimId"; // GET

      // NEW — Karyakarta Commission report
      static const String karyakartaCommissions = "$baseUrl/karyakarta/commissions"; // GET

      // NEW — Karyakarta Notifications
      static const String karyakartaNotifications = "$baseUrl/karyakarta/notifications"; // GET
      // // ---- Transactions / Ledger (NEW) ----
      // static const String transactions = "$baseUrl/transactions"; // GET / POST
      // static String transactionById(String id) => "$baseUrl/transactions/$id"; // GET / DELETE
      // static const String transactionsSummary = "$baseUrl/transactions/summary"; // GET
      // ---- Accounting Ledger (Account Manage screen) ----
      static const String accountingLedger = "$baseUrl/accounting/ledger"; // GET (entry_type, date_from, date_to, limit, search)
      static const String transactions = "$baseUrl/transactions"; // POST create only (leave if you still create txns here)
      static String transactionById(String id) => "$baseUrl/transactions/$id"; // GET / DELETE

      // ---- Bank Accounts (NEW) ----
      static const String bankAccounts = "$baseUrl/bank-accounts"; // GET / POST
      static String bankAccountById(String id) => "$baseUrl/bank-accounts/$id"; // GET / PUT / DELETE
      static String bankAccountStatus(String id) => "$baseUrl/bank-accounts/$id/status"; // PATCH

      // ---- Commission Payouts (NEW) ----
      static const String commissionPayouts = "$baseUrl/commission-payouts"; // GET / POST
      static String commissionPayoutById(String id) => "$baseUrl/commission-payouts/$id"; // GET
      // ---- Claim Payouts (NEW — Payment Manage screen) ----
      static const String claimPayouts = "$baseUrl/claim-payouts"; // GET / POST

      // ---- Generic Payments (NEW — Payment Manage "Make Payment" button) ----
      static const String payments = "$baseUrl/payments"; // POST

      // ---- Commission Report (NEW — Payment Manage "Commission Report" tab) ----
      static const String commissionReport = "$baseUrl/commission-report"; // GET
      // ---- Ledger (Account Manage screen) ----
      // static const String ledger = "$baseUrl/accounting/ledger"; // GET only
      // static const String organizationProfile = "$baseUrl/config/organization"; // GET / PUT

      // ---- Karyakarta summaries (NEW) ----
      static const String karyakartaCommissionsSummary = "$baseUrl/karyakarta/commissions-summary"; // GET — karyakarta role only
      static const String adminCommissionsSummary = "$baseUrl/admin/commissions-summary"; // GET — admin role (confirm path with backend)
      static const String karyakartaCollectionsSummary = "$baseUrl/karyakarta/collections-summary"; // GET
      // ---- Banners ----
      // static const String banners = "$baseUrl/banners"; // GET
      static const String banners = "$baseUrl/banners"; // GET / POST
      static String bannerById(String id) => "$baseUrl/banners/$id"; // DELETE

  // Your images are served from the domain root, not under /api,
  // so strip "/api" off baseUrl to build the full image URL.
      static String get mediaBaseUrl => baseUrl.replaceFirst('/api', '');

      static String bannerImageUrl(String path) {
        if (path.startsWith('http')) return path;
        final clean = path.startsWith('/') ? path.substring(1) : path;
        return "$mediaBaseUrl/$clean";
      }
      // ---- Member (self-service) ----
      static const String memberDashboard = "$baseUrl/member/dashboard";           // GET
      static const String memberProfile = "$baseUrl/member/profile";               // GET
      // static const String memberSchemes = "$baseUrl/member/schemes";               // GET
      static const String memberSchemes = "$baseUrl/member/schemes";               // GET list / POST create (confirm with backend)
      static const String memberPayments = "$baseUrl/member/payments";             // GET
      static const String memberClaims = "$baseUrl/member/claims";                 // GET / POST
      static const String memberNotifications = "$baseUrl/member/notifications";   // GET
      static const String memberPendingDues = "$baseUrl/member/pending-dues";      // GET
      static const String memberPayDues = "$baseUrl/member/pay-dues";              // POST {due_ids, payment_mode}


      // --- First-time login: mobile OTP verification (CONFIRM with backend) ---
      static const String sendLoginOtp = "$baseUrl/auth/send-otp";     // POST {username}
      static const String verifyLoginOtp = "$baseUrl/auth/verify-otp"; // POST {username, otp}
      static const String setPin = "$baseUrl/auth/set-pin";             // POST {username, pin}

      // --- Returning user: PIN login ---
      static const String pinLogin = "$baseUrl/auth/pin-login";        // POST {username, pin}

      // --- Forgot PIN flow ---
      static const String forgotPinSendOtp = "$baseUrl/auth/forgot-pin/send-otp";     // POST {username}
      static const String forgotPinVerifyOtp = "$baseUrl/auth/forgot-pin/verify-otp"; // POST {username, otp}
      static const String resetPin = "$baseUrl/auth/reset-pin";                        // POST {username, pin}

      static const String logout = "$baseUrl/auth/logout";

// NEW — logged-in user's own profile (works for admin/karyakarta role,
// same endpoint just returns different fields based on token's role)
      static const String profile = "$baseUrl/auth/profile"; // GET

      // ---- Dashboard ----
      static const String dashboardStats = "$baseUrl/dashboard/stats";       // GET
      static const String collectionOverview = "$baseUrl/dashboard/collection"; // GET
      static const String recentActivities = "$baseUrl/dashboard/activities";   // GET

      // ---- Membership ----
      static const String members = "$baseUrl/members";                 // GET / POST
      static String memberById(String id) => "$baseUrl/members/$id";    // GET / PUT / DELETE
      static String memberSearch(String query) =>
          "$baseUrl/members/search?query=${Uri.encodeQueryComponent(query)}"; // GET
      static String memberStatus(String id) => "$baseUrl/members/$id/status"; // PATCH
      static const String membershipProposals = "$baseUrl/proposals";   // GET / POST
      static String proposalById(String id) => "$baseUrl/proposals/$id"; // GET
      static String approveProposal(String id) => "$baseUrl/proposals/$id/approve"; // POST
      static String rejectProposal(String id) => "$baseUrl/proposals/$id/reject";   // POST
      static const String duplicateCheck = "$baseUrl/proposals/duplicate-check";   // POST

      // ---- Schemes ----
      static const String schemes = "$baseUrl/schemes";                     // GET / POST
      static String schemeById(String schemeId) =>
          "$baseUrl/schemes/$schemeId";                                     // PUT
      // static String schemeSlabs(String schemeId) =>
      //     "$baseUrl/schemes/$schemeId/slabs";                               // GET
      static String schemeSlabs(String schemeId) =>
          "$baseUrl/schemes/$schemeId/slabs";                               // GET / POST
      static String schemeSlabById(String slabId) =>
          "$baseUrl/schemes/slabs/$slabId";                                 // DELETE
      static const String calculateSlab = "$baseUrl/schemes/calculate-slab"; // POST
      static String schemeMembers(String schemeId) =>
          "$baseUrl/schemes/$schemeId/members";                             // GET
      static String schemeClaims(String schemeId) =>
          "$baseUrl/schemes/$schemeId/claims";                              // GET
      // ---- Commission Master (NEW) ----
      static const String commissionRules = "$baseUrl/commission-rules"; // GET / POST
      static String commissionRuleById(String id) => "$baseUrl/commission-rules/$id"; // DELETE

      // ---- Claims ----
      static const String claims = "$baseUrl/claims";                       // GET / POST
      static String claimById(String id) => "$baseUrl/claims/$id";          // GET / DELETE
      static String approveClaim(String id) => "$baseUrl/claims/$id/approve"; // PUT
      static String rejectClaim(String id) => "$baseUrl/claims/$id/reject";   // PUT

      // ---- Receipts ----
      static const String receipts = "$baseUrl/receipts";                   // GET / POST
      static String receiptById(String id) => "$baseUrl/receipts/$id";      // GET / DELETE

      // ---- Contribution Batches ----
      static const String contributionBatches = "$baseUrl/contribution-batches"; // GET / POST
      static String contributionBatchById(String id) =>
          "$baseUrl/contribution-batches/$id";                                   // GET
      static String settleContributionBatch(String id) =>
          "$baseUrl/contribution-batches/$id/settle";                            // PUT

      // ---- Member Contributions ----
      static const String memberContributions = "$baseUrl/member-contributions"; // GET / POST
      static String memberContributionById(String id) =>
          "$baseUrl/member-contributions/$id";                                   // GET / DELETE
      static String memberContributionStatus(String id) =>
          "$baseUrl/member-contributions/$id/status";                            // PUT

      // ---- Collection / Finance (legacy — kept in case still referenced) ----
      static const String premiumCollection = "$baseUrl/finance/premium";   // GET
      static const String joiningFees = "$baseUrl/finance/joining-fees";    // GET
      static const String installments = "$baseUrl/finance/installments";  // GET
      static const String paymentDisbursement = "$baseUrl/finance/disbursement"; // GET

      // ---- Karyakarta (Social Activist) ----
      static const String createKaryakarta = "$baseUrl/karyakartas"; // POST
      static const String karyakartas = "$baseUrl/karyakartas";      // GET
      // static String karyakartaById(String id) => "$baseUrl?action=get_karyakarta&id=$id"; // GET
      // static String karyakartaProfile(String id) => "$baseUrl/karyakartas/$id"; // GET full profile (personal, working_area, samaj, tabs)
      // static const String karyakartaSearch = "$baseUrl?action=search_karyakarta"; // POST
      static String karyakartaProfile(String id) => "$baseUrl/karyakartas/$id"; // GET / PUT / DELETE
      static String karyakartaStatus(String id) => "$baseUrl/karyakartas/$id/status"; // PATCH
      // static const String karyakartaSearch = "$baseUrl?action=search_karyakarta"; // POST
      static String karyakartaSearch(String query) =>
          "$baseUrl/karyakartas/search?query=${Uri.encodeQueryComponent(query)}"; // GET — mirrors memberSearch()

      // Legacy (kept in case something else still references these)
      static const String karyakartaList = "$baseUrl/karyakarta";
      static const String karyakartaRegister = "$baseUrl/karyakarta/register";
      static String karyakartaPerformance(String id) =>
          "$baseUrl/karyakarta/$id/performance";                          // GET

      // ---- Masters ----
      static const String states = "$baseUrl/locations/states";             // GET / POST
      static String districtsByState(String stateId) =>
          "$baseUrl/locations/states/$stateId/districts";                   // GET
      static const String addDistrict = "$baseUrl/locations/districts";     // POST
      static String talukasByDistrict(String districtId) =>
          "$baseUrl/locations/districts/$districtId/talukas";               // GET
      // static const String addDistrict = "$baseUrl/locations/districts"; // POST
      static const String addTaluka = "$baseUrl/locations/talukas";     // POST
      // static const String addTaluka = "$baseUrl/locations/talukas";         // POST
      static const String villages = "$baseUrl/masters/villages";           // GET
      // static const String gotra = "$baseUrl/gotras";                        // GET
      static const String gotra = "$baseUrl/gotras"; // GET / POST
      static String gotraById(String id) => "$baseUrl/gotras/$id"; // PUT / DELETE
      static const String occupation = "$baseUrl/masters/occupation";       // GET
      static const String education = "$baseUrl/masters/education";        // GET
      // static String gotraById(String id) => "$baseUrl/gotras/$id"; // PUT / DELETE
      static String slabById(String id) => "$baseUrl/schemes/slabs/$id"; // DELETE
      // static const String commissionRules = "$baseUrl/commission-rules"; // GET / POST
      // static String commissionRuleById(String id) => "$baseUrl/commission-rules/$id"; // DELETE

      // ---- Enrollments ----
      static const String enrollments = "$baseUrl/enrollments";               // GET / POST
      static String enrollmentById(String id) => "$baseUrl/enrollments/$id";  // GET / DELETE
      static String approveEnrollment(String id) =>
          "$baseUrl/enrollments/$id/approve";                                  // PUT
      static String rejectEnrollment(String id) =>
          "$baseUrl/enrollments/$id/reject";                                   // PUT

      // ---- Reports ----
      static const String memberReports = "$baseUrl/reports/members";       // GET
      static const String financialReports = "$baseUrl/reports/financial";  // GET
      static const String claimReports = "$baseUrl/reports/claims";         // GET
      // ---- Member self-service: PDF tokens & Karyakarta search (NEW) ----
      static const String memberSearchKaryakarta = "$baseUrl/member/search-karyakarta"; // GET ?code=SA1234
      static String memberClaimPdfToken(String claimId) =>
          "$baseUrl/member/claims/$claimId/pdf-token"; // GET
      static String memberReceiptPdfToken(String receiptId) =>
          "$baseUrl/member/receipts/$receiptId/pdf-token"; // GET
   static Map<String, String> headers({String? token}) => {
     "Content-Type": "application/json",
     "Accept": "application/json",
     if (token != null && token.isNotEmpty) ...{
       "X-API-Token": token,  // Primary token header
       // "Authorization": "Bearer $token",  // Optional backup
     },
   };
    }


