// lib/screens/book_action_screen.dart
import 'package:flutter/material.dart';
import 'package:open_library_app/services/api_service.dart';

class BookActionScreen extends StatefulWidget {
  final int initialTab;

  const BookActionScreen({super.key, this.initialTab = 0});

  @override
  State<BookActionScreen> createState() => _BookActionScreenState();
}

class _BookActionScreenState extends State<BookActionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _bookIdController = TextEditingController();
  final TextEditingController _metroIdController = TextEditingController();
  final ApiService _apiService = ApiService();

  String _message = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mobileNoController.dispose();
    _bookIdController.dispose();
    _metroIdController.dispose();
    super.dispose();
  }

  Future<void> _performAction(String actionType) async {
    setState(() {
      _isLoading = true;
      _message = '${actionType}ing book...';
    });

    final mobileNo = _mobileNoController.text.trim();
    final bookId = int.tryParse(_bookIdController.text.trim());
    final metroId = int.tryParse(_metroIdController.text.trim());

    if (mobileNo.isEmpty || bookId == null || metroId == null) {
      setState(() {
        _message = 'Please enter valid Mobile No, Book ID, and Metro ID.';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields with valid data!'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final response = await _apiService.performBookAction(
        mobileNo,
        bookId,
        metroId,
        actionType,
      );
      setState(() {
        _message = 'Success: ${response['message']}';
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
        SnackBar(content: Text('Action Failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildActionTab(String actionType) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _mobileNoController,
            decoration: const InputDecoration(
              labelText: 'Mobile No',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bookIdController,
            decoration: const InputDecoration(
              labelText: 'Book ID',
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
              : ElevatedButton.icon(
            onPressed: () => _performAction(actionType),
            icon: Icon(actionType == 'loan' ? Icons.outbox : Icons.inbox),
            label: Text(
              actionType == 'loan' ? 'Take Book' : 'Deposit Book',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionType == 'loan' ? null : Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan / Return Book'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.outbox), text: 'Loan'),
            Tab(icon: Icon(Icons.inbox), text: 'Return'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActionTab('loan'),
          _buildActionTab('return'),
        ],
      ),
    );
  }
}
