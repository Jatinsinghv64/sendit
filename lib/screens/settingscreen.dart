import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../themes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hides back button if on tab bar
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 16),

          // 1. App Settings
          _buildSectionHeader("GENERAL"),
          _buildSwitchTile(
              "Push Notifications",
              "Receive updates about your orders",
              _notificationsEnabled,
                  (val) => setState(() => _notificationsEnabled = val)
          ),
          _buildSwitchTile(
              "Dark Mode",
              "Switch to dark theme (Coming Soon)",
              _darkModeEnabled,
                  (val) => setState(() => _darkModeEnabled = val) // Just a UI toggle for now
          ),

          const SizedBox(height: 16),

          // 2. Support
          _buildSectionHeader("SUPPORT & LEGAL"),
          _buildActionTile(Icons.help_outline, "Help & Support", () {}),
          _buildActionTile(Icons.policy_outlined, "Privacy Policy", () {}),
          _buildActionTile(Icons.description_outlined, "Terms & Conditions", () {}),

          const SizedBox(height: 16),

          // 3. Developer Zone (For your Dummy Data)
          _buildSectionHeader("DEVELOPER ZONE"),
          Container(
            color: Colors.white,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_upload_rounded, color: Colors.blue),
              ),
              title: const Text("Load Dummy Data", style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text("Populate Firestore with sample products"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => {},
            ),
          ),

          const SizedBox(height: 32),

          // 4. Logout (Redundant here if in Profile, but good for completeness)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false).logout();
              },
              child: const Text("Log Out", style: TextStyle(color: AppTheme.qcDiscountRed, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textTertiary),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.qcGreen,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textSecondary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        onTap: onTap,
      ),
    );
  }

}