import 'package:flutter/material.dart';
import 'scheme_master_screen.dart';
import 'placeholder_screen.dart';
import 'organization_profile_screen.dart';
import 'location_master_screen.dart';
import 'gotra_master_screen.dart';
import 'commission_master_screen.dart';

class ConfigMastersHubScreen extends StatelessWidget {
  const ConfigMastersHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
      icon: Icons.account_balance_outlined,
      iconColor: const Color(0xFF6A5AE0),
      iconBg: const Color(0xFFE9E7FB),
      title: 'Organization Profile',
      subtitle: 'Trust registration details, head office location, contact numbers & signatory settings.',
      linkText: 'Manage Profile',
      dest: 'Organization Profile',
      ),
      (
      icon: Icons.map_outlined,
      iconColor: const Color(0xFF2F7DE1),
      iconBg: const Color(0xFFE3EEFD),
      title: 'Location Master',
      subtitle: 'State wise District and Tehsil/Taluka hierarchy. Add, edit, remove districts and tehsils dynamically.',
      linkText: 'Configure State / Dist / Taluka',
      dest: 'Location Master',
      ),
      (
      icon: Icons.fingerprint,
      iconColor: const Color(0xFFC97C0F),
      iconBg: const Color(0xFFFBEBD4),
      title: 'Gotra Master',
      subtitle: 'Add, edit, delete community gotras with A-Z alphabetical toolbar and dual language search.',
      linkText: 'Manage Gotras',
      dest: 'Gotra Master',
      ),
      (
      icon: Icons.layers_outlined,
      iconColor: const Color(0xFF16A085),
      iconBg: const Color(0xFFDFF6EA),
      title: 'Scheme Master & Slabs',
      subtitle: 'Welfare schemes (Kanyadan, Mayara, Parivar Kalyan) and age group contribution slabs.',
      linkText: 'Manage Schemes',
      dest: 'Scheme Master & Slabs',
      ),
      (
      icon: Icons.percent_outlined,
      iconColor: const Color(0xFF8B5CF6),
      iconBg: const Color(0xFFF0EBFD),
      title: 'Commission Master',
      subtitle: 'Configure Regular, Promotional Offer, and Karyakarta-specific special commission rules.',
      linkText: 'Configure Commission Rules',
      dest: 'Commission Master',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Config Masters')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B4B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CONFIG MASTERS & TRUST CONTROLS',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 6),
                Text(
                  'Manage your organization profile, commission slabs, location hierarchy, and dynamic welfare rules.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...cards.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              // onTap: () {
              //   if (c.dest == 'Scheme Master & Slabs') {
              //     Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemeMasterScreen()));
              //   } else {
              //     Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceholderScreen(title: c.dest)));
              //   }
              // },
              onTap: () {
                switch (c.dest) {
                  case 'Organization Profile':
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizationProfileScreen()));
                    break;
                  case 'Location Master':
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationMasterScreen()));
                    break;
                  case 'Gotra Master':
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GotraMasterScreen()));
                    break;
                  case 'Scheme Master & Slabs':
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemeMasterScreen()));
                    break;
                  case 'Commission Master':
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CommissionMasterScreen()));
                    break;
                  default:
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceholderScreen(title: c.dest)));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(12)),
                      child: Icon(c.icon, color: c.iconColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(c.subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                          const SizedBox(height: 10),
                          Text(c.linkText,
                              style: const TextStyle(color: Color(0xFF6A5AE0), fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}