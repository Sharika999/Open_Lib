import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    fetchBorrowedBooks(); // Load once when screen is opened
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
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 1.15, // 🔠 Slightly bigger font everywhere
        ),
      ),
      child: Scaffold(
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search from your read books...",
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🏙️ Metro Heading
            const Center(
              child: Text(
                "Hyderabad Metro",
                style: TextStyle(fontWeight: FontWeight.w500,
                fontSize: 18),
              ),

            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : borrowedBooks.isEmpty
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "📚 No books taken yet",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                      const Text(
                        "📘 Books currently loaned",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...borrowedBooks.map((book) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "📖 ${book['book_title'] ?? 'Untitled'}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("📚 Book ID: ${book['book_id']}"),
                                Text("🚉 Metro: ${book['metro_name']}"),
                                Text("⏰ Loaned at: ${book['loan_time']}"),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📝 Encouraging Content Below
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      Text(
                        "",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "📌 Don't forget!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Please return books within the due time to help fellow passengers enjoy the reading experience.",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "📚 Maintaining your OpenLibrary account is important.",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "🌟 Read more. Travel more. Grow more. Discover new genres while you commute!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "🚇 Your metro ride just got better. Make it a habit to grab a book!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // 🔘 Bottom Buttons
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
                    fetchBorrowedBooks(); // Refresh on return
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
                    fetchBorrowedBooks(); // Refresh on loan
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
      ),
    );
  }
}
