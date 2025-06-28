// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:open_library_app/screens/book_action_screen.dart';
import 'package:open_library_app/screens/register_user_screen.dart';
import 'package:open_library_app/screens/login_screen.dart'; // New import for LoginScreen
import 'package:open_library_app/services/api_service.dart'; // New import for ApiService

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenLibrary App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService().logoutUser(); // Call logout method
              // Navigate back to login screen and clear navigation stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false, // Clear all previous routes
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully!')),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterUserScreen()),
                );
              },
              child: const Text('Register New User'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookActionScreen()),
                );
              },
              child: const Text('Loan/Return Book'),
            ),
            // You might add other buttons here for future features like:
            // const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     // Navigator.push(... to a screen showing user's current loans
            //   },
            //   child: const Text('My Current Loans'),
            // ),
          ],
        ),
      ),
    );
  }
}