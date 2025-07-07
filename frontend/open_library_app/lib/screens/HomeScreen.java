import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_library_app/models/user.dart';
import 'package:open_library_app/screens/book_action_screen.dart';
import 'package:open_library_app/screens/login_screen.dart';
import 'package:open_library_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> borrowedBooks = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchBorrowedBooks();
  }

  Future<void> fetchBorrowedBooks() async {
    try {
      final loans = await ApiService().fetchUserLoans(widget.user.mobileNo);
      setState(() {
        borrowedBooks = loans;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        borrowedBooks = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching loans: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = borrowedBooks.where((book) {
      final title = (book['book_title'] ?? '').toString().toLowerCase();
      return title.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Open Library"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService().logoutUser();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: "Search from your read books...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Hyderabad Metro",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: 20),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: filteredBooks.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("📚 No books taken yet", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text(
                                "Hyderabad Metro invites you to explore OpenLibrary — grab a book from our station library and enjoy your ride!",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("📘 Books currently loaned", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              ...filteredBooks.map((book) {
                                final time = DateTime.tryParse(book['loan_time'] ?? '');
                                final formattedTime = time != null
                                    ? DateFormat('dd MMM yyyy, hh:mm a').format(time)
                                    : 'Unknown';
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade50, Colors.white],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "📖 ${book['book_title'] ?? 'Untitled'}",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("📚 Book ID: ${book['book_id']}"),
                                      Text("🚉 Metro: ${book['metro_name']}"),
                                      Text("⏰ Loaned at: $formattedTime"),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                  ),
                ),
          const SizedBox(height: 30),
          const Text(
            "📌 Don't forget!",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please return books within the due time to help fellow passengers enjoy the reading experience.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "🌟 Read more. Travel more. Grow more.",
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookActionScreen(initialTab: 1)),
                  );
                  fetchBorrowedBooks();
                },
                icon: const Icon(Icons.assignment_return),
                label: const Text("Return"),
              ),
              TextButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookActionScreen(initialTab: 0)),
                  );
                  fetchBorrowedBooks();
                },
                icon: const Icon(Icons.add),
                label: const Text("Loan"),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile coming soon...')),
                  );
                },
                icon: const Icon(Icons.person),
                label: const Text("Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
