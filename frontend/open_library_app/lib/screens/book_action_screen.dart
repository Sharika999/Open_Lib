// lib/screens/book_action_screen.dart
import 'package:flutter/material.dart';
import 'package:open_library_app/services/api_service.dart';

class BookActionScreen extends StatefulWidget {
  const BookActionScreen({super.key});

  @override
  State<BookActionScreen> createState() => _BookActionScreenState();
}

class _BookActionScreenState extends State<BookActionScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _bookIdController = TextEditingController();
  final TextEditingController _metroIdController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _message = '';
  bool _isLoading = false;

  Future<void> _performAction(String actionType) async {
    setState(() {
      _isLoading = true;
      _message = '${actionType}ing book...';
    });

    final userId = int.tryParse(_userIdController.text);
    final bookId = int.tryParse(_bookIdController.text);
    final metroId = int.tryParse(_metroIdController.text);

    if (userId == null || bookId == null || metroId == null) {
      setState(() {
        _message = 'Error: Please enter valid numbers for User ID, Book ID, and Metro ID.';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields with valid numbers!'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final response = await _apiService.performBookAction(
        userId,
        bookId,
        metroId,
        actionType,
      );
      setState(() {
        _message = 'Success: ${response['message']}';
        _userIdController.clear();
        _bookIdController.clear();
        _metroIdController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book ${actionType}ed successfully!')),
      );
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action Failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan / Return Book'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bookIdController,
              decoration: const InputDecoration(
                labelText: 'Book ID (from QR scan)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.menu_book),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _metroIdController,
              decoration: const InputDecoration(
                labelText: 'Metro Station ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.train),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _performAction('loan'),
                          icon: const Icon(Icons.outbox),
                          label: const Text('Take Book', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _performAction('return'),
                          icon: const Icon(Icons.inbox),
                          label: const Text('Deposit Book', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.green, // Differentiate return button
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _message.startsWith('Error') ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}