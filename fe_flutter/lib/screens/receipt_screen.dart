import 'package:flutter/material.dart';
import '../models/receipt.dart';
import '../services/receipt_service.dart';
import '../services/pdf_service.dart';

class ReceiptScreen extends StatelessWidget {
  final int transactionId;

  const ReceiptScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Struk"),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
      ),
      body: FutureBuilder<Receipt>(
        future: ReceiptService.getReceipt(transactionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final r = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("Total: Rp ${r.total}"),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("PDF"),
                      onPressed: () async {
                        final file = await PdfService.generateReceiptPdf(r);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("PDF tersimpan: ${file.path}")),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
