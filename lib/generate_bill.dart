import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class BillGenerationPage extends StatefulWidget {
  final Map<String, dynamic> initialMedicine;
  final String patientName;

  const BillGenerationPage(
      {super.key, required this.initialMedicine, required this.patientName});

  @override
  _BillGenerationPageState createState() => _BillGenerationPageState();
}

class _BillGenerationPageState extends State<BillGenerationPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> billItems = [];
  double totalMRP = 0.0;

  @override
  void initState() {
    super.initState();
    // Add the initial scanned medicine with quantity 1
    billItems.add({...widget.initialMedicine, 'billQuantity': 1});
    _updateTotalMRP();
  }

  Future<void> _addMoreMedicine() async {
    try {
      final scanResult = await BarcodeScanner.scan();
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 200);
      }
      final scannedBarcode = scanResult.rawContent;
      final user = _auth.currentUser;

      if (user != null) {
        final querySnapshot = await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("medicines")
            .where("barcode", isEqualTo: scannedBarcode)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final medicine = querySnapshot.docs.first.data();
          setState(() {
            // Add new medicine with quantity 1 if not already in bill
            final existingIndex = billItems
                .indexWhere((item) => item['barcode'] == scannedBarcode);
            if (existingIndex == -1) {
              billItems.add({...medicine, 'billQuantity': 1});
            }
            _updateTotalMRP();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('No medicine found for barcode: $scannedBarcode')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning: $e')),
      );
    }
  }

  void _updateTotalMRP() {
    totalMRP = billItems.fold(0.0, (sum, item) {
      final mrp = double.tryParse(item['mrp'].toString()) ?? 0.0;
      final quantity = item['billQuantity'] as int? ?? 1;
      return sum + (mrp * quantity);
    });
  }

  void _changeQuantity(int index, int delta) {
    setState(() {
      final currentQty = billItems[index]['billQuantity'] as int;
      final newQty = (currentQty + delta).clamp(1, 999); // Min 1, max 999
      billItems[index]['billQuantity'] = newQty;
      _updateTotalMRP();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Bill for ${widget.patientName}'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: billItems.length,
                itemBuilder: (context, index) {
                  final item = billItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(
                      'Batch: ${item['batchno']} - Expires: ${(item['expirydate'] as Timestamp).toDate().toString().split(' ')[0]} - MRP: ${item['mrp']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _changeQuantity(index, -1),
                        ),
                        Text('${item['billQuantity']}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _changeQuantity(index, 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Total MRP: \$${totalMRP.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add More Medicine'),
                    onPressed: _addMoreMedicine,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
