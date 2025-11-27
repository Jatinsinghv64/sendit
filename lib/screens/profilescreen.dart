import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../themes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      (user?.email ?? "U")[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email?.split('@')[0] ?? "Guest User", // Simple name extraction
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? "No email linked",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  // Edit Button
                  TextButton(
                    onPressed: () {},
                    child: const Text("EDIT", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

            // 2. My Information Section
            _buildSectionTitle(context, "YOUR INFORMATION"),
            _buildListTile(
              context,
              icon: Icons.receipt_long_outlined,
              title: "Your Orders",
              subtitle: "View past orders and invoices",
              onTap: () {}, // Navigate to Orders
            ),
            _buildListTile(
              context,
              icon: Icons.location_on_outlined,
              title: "Address Book",
              subtitle: "Manage delivery addresses",
              onTap: () {},
            ),
            _buildListTile(
              context,
              icon: Icons.favorite_outline,
              title: "Favorites",
              subtitle: "View your liked products",
              onTap: () {}, // Optionally navigate to Favorites tab
            ),

            const SizedBox(height: 12),

            // 3. General Section
            _buildSectionTitle(context, "OTHER"),
            _buildListTile(
              context,
              icon: Icons.share_outlined,
              title: "Share the App",
              onTap: () {},
            ),
            _buildListTile(
              context,
              icon: Icons.info_outline,
              title: "About Us",
              onTap: () {},
            ),
            _buildListTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // 4. Logout Button
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.qcDiscountRed),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Log Out", style: TextStyle(color: AppTheme.qcDiscountRed, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 40),

            const Center(
              child: Text(
                "App Version 1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.textPrimary, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }
}