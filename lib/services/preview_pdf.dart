import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String patientName;

  const PdfPreviewPage(
      {super.key, required this.pdfBytes, required this.patientName});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Bill Preview'),
          backgroundColor: const Color(0xFF4CAF50),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                await Printing.sharePdf(
                  bytes: pdfBytes,
                  filename:
                      'Bill_${patientName}_${DateTime.now().toString().split(' ')[0]}.pdf',
                );
              },
            ),
          ],
        ),
        body: PdfPreview(
          build: (_) => pdfBytes,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          actions: [
            PdfPreviewAction(
              icon: const Icon(Icons.print),
              onPressed: (_, __, ___) => Printing.layoutPdf(
                onLayout: (format) => pdfBytes,
              ),
            ),
            PdfPreviewAction(
              icon: const Icon(Icons.download),
              onPressed: (_, __, ___) => Printing.sharePdf(
                  bytes: pdfBytes, filename: 'Bill_$patientName.pdf'),
            ),
          ],
        ),
      );
}
