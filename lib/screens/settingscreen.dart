import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Account Info"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text("Saved Addresses"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text("Notifications"),
            trailing: const Switch(value: true, onChanged: null),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              // App will auto-redirect via main.dart stream listener
            },
          ),
        ],
      ),
    );
  }
}