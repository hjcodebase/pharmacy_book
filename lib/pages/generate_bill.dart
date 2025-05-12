import 'dart:typed_data';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:med_x/services/preview_pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
      final newQty = (currentQty + delta).clamp(1, 999);
      billItems[index]['billQuantity'] = newQty;
      _updateTotalMRP();
    });
  }

  Future<Uint8List> _generatePdfBill() async {
    final pdf = pw.Document();
    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Lakshmi Medical',
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Text('DL No: 1222781572896, 123286285282'),
                    //this is new comment added for new solution by me...
                    pw.Text('Address: Kalka Ji, New Delhi'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Invoice',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: ${now.toString().split(' ')[0]}'),
                    pw.Text('Customer: ${widget.patientName}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Table with proper alignment
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(2), // Medicine Name
                1: const pw.FlexColumnWidth(1), // Batch No
                2: const pw.FlexColumnWidth(1), // Expiry
                3: const pw.FlexColumnWidth(1), // Quantity
                4: const pw.FlexColumnWidth(1), // MRP
                5: const pw.FlexColumnWidth(1), // Amount
              },
              headers: [
                'Medicine Name',
                'Batch No',
                'Expiry',
                'Quantity',
                'MRP',
                'Amount'
              ],
              data: billItems
                  .map((item) => [
                        item['name'],
                        item['batchno'],
                        (item['expirydate'] as Timestamp)
                            .toDate()
                            .toString()
                            .split(' ')[0],
                        item['billQuantity'].toString(),
                        item['mrp'].toString(),
                        (double.parse(item['mrp'].toString()) *
                                item['billQuantity'])
                            .toStringAsFixed(2),
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 20),

            // Total
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Total Amount:${totalMRP.toStringAsFixed(2)} Rs',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );

    return await pdf.save();
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add More'),
                        onPressed: _addMoreMedicine,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Generate PDF Bill'),
                        onPressed: () async {
                          final pdfBytes = await _generatePdfBill();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfPreviewPage(
                                  pdfBytes: pdfBytes,
                                  patientName: widget.patientName),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// class BillGenerationPage extends StatefulWidget {
//   final Map<String, dynamic> initialMedicine;
//   final String patientName;

//   const BillGenerationPage(
//       {super.key, required this.initialMedicine, required this.patientName});

//   @override
//   _BillGenerationPageState createState() => _BillGenerationPageState();
// }

// class _BillGenerationPageState extends State<BillGenerationPage> {
//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;
//   List<Map<String, dynamic>> billItems = [];
//   double totalMRP = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     // Add the initial scanned medicine with quantity 1
//     billItems.add({...widget.initialMedicine, 'billQuantity': 1});
//     _updateTotalMRP();
//   }

//   Future<void> _addMoreMedicine() async {
//     try {
//       final scanResult = await BarcodeScanner.scan();
//       if (await Vibration.hasVibrator() ?? false) {
//         Vibration.vibrate(duration: 200);
//       }
//       final scannedBarcode = scanResult.rawContent;
//       final user = _auth.currentUser;

//       if (user != null) {
//         final querySnapshot = await _firestore
//             .collection("users")
//             .doc(user.uid)
//             .collection("medicines")
//             .where("barcode", isEqualTo: scannedBarcode)
//             .limit(1)
//             .get();

//         if (querySnapshot.docs.isNotEmpty) {
//           final medicine = querySnapshot.docs.first.data();
//           setState(() {
//             // Add new medicine with quantity 1 if not already in bill
//             final existingIndex = billItems
//                 .indexWhere((item) => item['barcode'] == scannedBarcode);
//             if (existingIndex == -1) {
//               billItems.add({...medicine, 'billQuantity': 1});
//             }
//             _updateTotalMRP();
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content:
//                     Text('No medicine found for barcode: $scannedBarcode')),
//           );
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error scanning: $e')),
//       );
//     }
//   }

//   void _updateTotalMRP() {
//     totalMRP = billItems.fold(0.0, (sum, item) {
//       final mrp = double.tryParse(item['mrp'].toString()) ?? 0.0;
//       final quantity = item['billQuantity'] as int? ?? 1;
//       return sum + (mrp * quantity);
//     });
//   }

//   void _changeQuantity(int index, int delta) {
//     setState(() {
//       final currentQty = billItems[index]['billQuantity'] as int;
//       final newQty = (currentQty + delta).clamp(1, 999); // Min 1, max 999
//       billItems[index]['billQuantity'] = newQty;
//       _updateTotalMRP();
//     });
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           title: Text('Bill for ${widget.patientName}'),
//           backgroundColor: const Color(0xFF4CAF50),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: billItems.length,
//                 itemBuilder: (context, index) {
//                   final item = billItems[index];
//                   return ListTile(
//                     title: Text(item['name']),
//                     subtitle: Text(
//                       'Batch: ${item['batchno']} - Expires: ${(item['expirydate'] as Timestamp).toDate().toString().split(' ')[0]} - MRP: ${item['mrp']}',
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.remove),
//                           onPressed: () => _changeQuantity(index, -1),
//                         ),
//                         Text('${item['billQuantity']}'),
//                         IconButton(
//                           icon: const Icon(Icons.add),
//                           onPressed: () => _changeQuantity(index, 1),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Text('Total MRP: \$${totalMRP.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                           fontSize: 20, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 10),
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add More Medicine'),
//                     onPressed: _addMoreMedicine,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
// }
