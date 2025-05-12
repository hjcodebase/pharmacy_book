// import 'package:barcode_scan2/barcode_scan2.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:vibration/vibration.dart';

// class BarcodeScannerPage extends StatefulWidget {
//   const BarcodeScannerPage({super.key});

//   @override
//   _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
// }

// class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;
//   String resultMessage = '';
//   bool isLoading = false;

//   Future<void> _scanAndCheckBarcode() async {
//     setState(() => isLoading = true); // Start loading
//     try {
//       final scanResult = await BarcodeScanner.scan(); // Scan barcode
//       if (await Vibration.hasVibrator() ?? false) {
//         Vibration.vibrate(duration: 200); // Vibrate for 200ms
//       }
//       final barcode = scanResult.rawContent;
//       final user = _auth.currentUser;

//       if (user != null) {
//         // Check Firestore for matching barcode
//         final querySnapshot = await _firestore
//             .collection("users")
//             .doc(user.uid)
//             .collection("medicines")
//             .where("barcode", isEqualTo: barcode)
//             .limit(1)
//             .get();

//         if (querySnapshot.docs.isNotEmpty) {
//           // Match found, show all details
//           final medicine = querySnapshot.docs.first.data();
//           setState(() {
//             resultMessage = '''
//               Name: ${medicine['name']}
//               Category: ${medicine['category']}
//               Batch No: ${medicine['batchno']}
//               Barcode: ${medicine['barcode']}
//               Purchase Date: ${(medicine['purchasedate'] as Timestamp).toDate()}
//               Expiry Date: ${(medicine['expirydate'] as Timestamp).toDate()}
//               Purchase Price: ${medicine['purchaseprice']}
//               MRP: ${medicine['mrp']}
//               Distributor: ${medicine['distributorname']}
//             ''';
//           });
//         } else {
//           // No match
//           setState(() => resultMessage =
//               'Not Found: No medicine matches barcode $barcode');
//         }
//       } else {
//         setState(() => resultMessage = 'Please log in first');
//       }
//     } catch (e) {
//       setState(() => resultMessage = 'Error: $e');
//     } finally {
//       setState(() => isLoading = false); // Stop loading
//     }
//   }

// ignore_for_file: use_build_context_synchronously

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           title: const Text('Scan Medicine'),
//           backgroundColor: const Color(0xFF4CAF50),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.camera_alt,
//                     size: 50, color: Color(0xFF2196F3)),
//                 onPressed: _scanAndCheckBarcode,
//               ),
//               const SizedBox(height: 20),
//               const Text('Tap to Scan Barcode', style: TextStyle(fontSize: 20)),
//               const SizedBox(height: 20),
//               if (isLoading)
//                 const CircularProgressIndicator() // Show loading circle
//               else
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     resultMessage,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       );
// }
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:med_x/pages/generate_bill.dart';
import 'package:vibration/vibration.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;

  Future<void> _scanAndCheckBarcode() async {
    setState(() => isLoading = true);
    try {
      final scanResult = await BarcodeScanner.scan();
      if (await Vibration.hasVibrator()) {
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
          // Ask for patient name
          final patientName = await _showPatientNameDialog();
          if (patientName != null) {
            // Move to bill page with the first medicine
            Navigator.push(
              // ignore: duplicate_ignore
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (_) => BillGenerationPage(
                  initialMedicine: medicine,
                  patientName: patientName,
                ),
              ),
            );
          }
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
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<String?> _showPatientNameDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Patient Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Patient Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scan Medicine'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt,
                    size: 50, color: Color(0xFF2196F3)),
                onPressed: _scanAndCheckBarcode,
              ),
              const SizedBox(height: 20),
              const Text('Tap to Scan Barcode', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      );
}
