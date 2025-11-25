import 'package:flutter/material.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Placeholder for App Logo
              Icon(Icons.shopping_basket_rounded, size: 100, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              const Text(
                "send_it",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              Text(
                "Fresh groceries delivered\nto your doorstep in minutes.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Text("Get Started"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {}, // Navigate to Signup
                child: const Text("Create an Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}