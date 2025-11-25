import 'package:flutter/material.dart';

class ReorderScreen extends StatelessWidget {
  const ReorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reorder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No past orders yet"),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: () {},
                child: const Text("Start Shopping")
            )
          ],
        ),
      ),
    );
  }
}