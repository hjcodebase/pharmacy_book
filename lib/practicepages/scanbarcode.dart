import 'package:barcode_scan2/barcode_scan2.dart'; // Import barcode scanner
import 'package:flutter/material.dart';

// Scan Code Screen
class ScanCodeScreen extends StatelessWidget {
  const ScanCodeScreen({super.key});

  Future<void> _scanBarcode(BuildContext context) async {
    try {
      final result = await BarcodeScanner.scan();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BarcodeResultScreen(barcode: result.rawContent),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning barcode: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Scan Barcode'),
          backgroundColor: Color(0xFF4CAF50),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 100, color: Color(0xFF2196F3)),
              SizedBox(height: 20),
              Text(
                'Scan a Barcode',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _scanBarcode(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Start Scanning'),
              ),
            ],
          ),
        ),
      );
}

// Barcode Result Screen
class BarcodeResultScreen extends StatelessWidget {
  final String barcode;

  const BarcodeResultScreen({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Barcode Details'),
          backgroundColor: Color(0xFF4CAF50),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Scanned Barcode',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Code: $barcode',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

// Placeholder for other classes (UdharCustomer, UdharKhataScreen, etc.)


// Add your existing UdharKhataScreen, StockListScreen, etc., below...