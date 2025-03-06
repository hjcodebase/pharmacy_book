import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class AddStockScreen extends StatefulWidget {
  const AddStockScreen({super.key});

  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String name = '', category = 'Tablet', batchNo = '', distributorName = '';
  DateTime purchaseDate = DateTime.now(), expiryDate = DateTime.now();
  String purchasePriceText = '', mrpText = '';
  String quantity = '';
  bool hasError = false;

  final categories = ['Tablet', 'Syrup', 'Capsule', 'Cream', 'Other'];

  Future<void> _selectDate(bool isPurchase) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isPurchase ? purchaseDate : expiryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => isPurchase ? purchaseDate = picked : expiryDate = picked);
    }
  }

  bool _validateForm() {
    final purchasePrice = double.tryParse(purchasePriceText);
    final mrp = double.tryParse(mrpText);
    return _formKey.currentState!.validate() &&
        purchasePrice != null &&
        mrp != null &&
        purchasePrice >= 0 &&
        mrp >= 0;
  }

  String barcode = ''; // Add this new field for barcode

  // Existing code...

  // Add this function to scan barcode
  Future<void> _scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan(); // Open camera to scan
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100); // Vibrate for 200ms when detected
      }
      setState(() => barcode = result.rawContent); // Set scanned barcode
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning barcode: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text('Add New Stock'), backgroundColor: Color(0xFF4CAF50)),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) => setState(() => name = value),
                  validator: (value) =>
                      value!.isEmpty ? 'Name is required' : null,
                ),
                DropdownButtonFormField(
                  value: category,
                  items: categories
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => category = value as String),
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Batch No'),
                  onChanged: (value) => setState(() => batchNo = value),
                  validator: (value) =>
                      value!.isEmpty ? 'Batch No is required' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Bar code No',
                    suffixIcon: IconButton(
                      onPressed: _scanBarcode,
                      icon: Icon(
                        Icons.camera_alt,
                      ),
                    ),
                  ),
                  controller: TextEditingController(text: barcode),
                  readOnly: true,
                  // onChanged: (value) => setState(() => batchNo = value),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Quentity'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly // Allows only digits (0-9)
                  ],
                  onChanged: (value) => setState(() => quantity = value),
                  validator: (value) => value!.isEmpty
                      ? 'Quentity is required'
                      : int.tryParse(value) == null || int.parse(value) < 0
                          ? 'Enter a valid number'
                          : null,
                ),
                ListTile(
                  title: Text(
                      'Purchase Date: ${purchaseDate.toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(true),
                ),
                ListTile(
                  title: Text(
                      'Expiry Date: ${expiryDate.toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(false),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Purchase Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      setState(() => purchasePriceText = value),
                  validator: (value) => value!.isEmpty
                      ? 'Price is required'
                      : double.tryParse(value) == null ||
                              double.parse(value) < 0
                          ? 'Enter a valid number'
                          : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'MRP'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() => mrpText = value),
                  validator: (value) => value!.isEmpty
                      ? 'MRP is required'
                      : double.tryParse(value) == null ||
                              double.parse(value) < 0
                          ? 'Enter a valid number'
                          : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Distributor Name'),
                  onChanged: (value) => setState(() => distributorName = value),
                  validator: (value) =>
                      value!.isEmpty ? 'Distributor is required' : null,
                ),
                if (hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('Please correct the errors before adding.',
                        style: TextStyle(color: Colors.red)),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_validateForm()) {
                      if (_auth.currentUser!.uid.isNotEmpty) {
                        if (barcode.isNotEmpty) {
                          await _firebaseFirestore
                              .collection("users")
                              .doc(_auth.currentUser!.uid)
                              .collection("medicines")
                              .add(
                            {
                              "name": name,
                              "category": category,
                              "batchno": batchNo,
                              "barcode": barcode,
                              "Quentity": quantity,
                              "purchasedate": Timestamp.fromDate(purchaseDate),
                              "expirydate": Timestamp.fromDate(expiryDate),
                              "purchaseprice": purchasePriceText,
                              "mrp": mrpText,
                              "distributorname": distributorName
                            },
                          );
                        } else {
                          await _firebaseFirestore
                              .collection("users")
                              .doc(_auth.currentUser!.uid)
                              .collection("medicines")
                              .add({
                            "name": name,
                            "category": category,
                            "batchno": batchNo,
                            "Quentity": quantity,
                            "purchasedate": Timestamp.fromDate(purchaseDate),
                            "expirydate": Timestamp.fromDate(expiryDate),
                            "purchaseprice": purchasePriceText,
                            "mrp": mrpText,
                            "distributorname": distributorName
                          });
                        }
                      }

                      Navigator.pop(
                        context,
                      );
                    } else {
                      setState(() => hasError = true);
                    }
                  },
                  child: Text('Add Stock'),
                ),
              ],
            ),
          ),
        ),
      );
}
