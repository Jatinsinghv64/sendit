import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sendit/screens/CartScreen.dart';
import 'auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

import 'screens/login_screen.dart'; // Added import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Connects to your google-services.json

  runApp(const SendItApp());
}

class SendItApp extends StatelessWidget {
  const SendItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Send_It',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            primary: const Color(0xFF2E7D32),
            secondary: const Color(0xFF81C784),
            surface: const Color(0xFFF5F5F5),
          ),
          scaffoldBackgroundColor: const Color(0xFFF9F9F9),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1A1A1A),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        // Simple auth check: if user is logged in, go Home, else Welcome
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) => auth.isAuthenticated ? const HomeScreen() : const WelcomeScreen(),
        ),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}