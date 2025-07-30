import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book_loan.dart';

class BookCard extends StatelessWidget {
  final BookLoan book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final formattedTime = book.loanedAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(book.loanedAt!)
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
          Text("📖 ${book.title}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("📚 Book ID: ${book.isbn}"),
          Text("🚉 Metro: ${book.metro}"),
          Text("⏰ Loaned at: $formattedTime"),
        ],
      ),
    );
  }
}
