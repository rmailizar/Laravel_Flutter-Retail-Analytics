import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _found = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_found) return;
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;
          final code = barcodes.first.rawValue ?? barcodes.first.displayValue;
          if (code == null) return;
          _found = true;
          Navigator.of(context).pop(code);
        },
      ),
    );
  }
}
