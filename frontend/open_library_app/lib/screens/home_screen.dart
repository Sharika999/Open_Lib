// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:open_library_app/screens/book_action_screen.dart';
import 'package:open_library_app/screens/register_user_screen.dart';
import 'package:open_library_app/screens/login_screen.dart';
import 'package:open_library_app/services/api_service.dart';
import 'package:open_library_app/models/user.dart'; // ✅ Needed to use User type

class HomeScreen extends StatelessWidget {
  final User user; // ✅ Accept the user

  const HomeScreen({super.key, required this.user}); // ✅ Make it required

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenLibrary App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService().logoutUser();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully!')),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),   //             Text('Welcome, ${user.mobileNo}!', style: const TextStyle(fontSize: 20)),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
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
          ],
        ),
      ),
    );
  }
}
