import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  final void Function(String) onScanned;

  const QRScannerPage({super.key, required this.onScanned});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Book QR Code")),
      body: MobileScanner(
        onDetect: (capture) {
          if (_scanned) return; // Prevent multiple triggers
          _scanned = true;

          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;
          if (code != null) {
            widget.onScanned(code); // Send result back
            Navigator.of(context).pop(); // Only close scanner
          }
        },
      ),
    );
  }
}

