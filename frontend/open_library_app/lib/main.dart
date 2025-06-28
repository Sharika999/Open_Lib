// lib/main.dart
import 'package:flutter/material.dart';
import 'package:open_library_app/screens/home_screen.dart';
import 'package:open_library_app/screens/login_screen.dart'; // New import for LoginScreen
import 'package:open_library_app/services/api_service.dart'; // New import for ApiService

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiService _apiService = ApiService();
  bool _isLoggedIn = false;
  bool _isLoading = true; // Added loading state for initial check

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status when the app starts
  }

  Future<void> _checkLoginStatus() async {
    final token = await _apiService.getAuthToken();
    setState(() {
      _isLoggedIn = token != null; // User is logged in if a token exists
      _isLoading = false; // Finished loading
    });
  }

  @override
  Widget build(BuildContext context) {
    // Theme settings are kept from previous main.dart
    return MaterialApp(
      title: 'OpenLibrary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
      ),
      // Decide which screen to show based on login status and loading state
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator())) // Show loading while checking status
          : _isLoggedIn
              ? const HomeScreen() // If logged in, go to home
              : const LoginScreen(), // Otherwise, go to login
    );
  }
}