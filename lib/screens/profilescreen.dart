import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person, size: 50, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 16),
            const Text("User Name", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("user@example.com", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            // Add more profile details here
          ],
        ),
      ),
    );
  }
}