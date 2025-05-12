import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_x/pages/stocks_add.dart';

class StockEntry extends StatelessWidget {
  const StockEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Entry'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('medicines')
            .orderBy('purchasedate',
                descending: false) // Oldest first, latest at bottom
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No stock entries found',
                    style: TextStyle(fontSize: 18)));
          }

          final medicines = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          final groupedMedicines = _groupMedicines(medicines);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: groupedMedicines.entries.length,
            itemBuilder: (context, index) {
              final group = groupedMedicines.entries.elementAt(index);
              return _buildStockTable(context, group);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddStockScreen(),
              ));
        }, // Leave for your navigation
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupMedicines(
      List<Map<String, dynamic>> medicines) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var med in medicines) {
      final purchaseDate = (med['purchasedate'] as Timestamp).toDate();
      final dateKey = DateFormat('yyyy-MM-dd').format(purchaseDate);
      final key = '${med['distributorname']}_$dateKey';
      grouped.putIfAbsent(key, () => []).add(med);
    }
    return grouped;
  }

  Widget _buildStockTable(BuildContext context,
      MapEntry<String, List<Map<String, dynamic>>> group) {
    final medicines = group.value;
    final distributor = medicines.first['distributorname'];
    final purchaseDate = DateFormat('yyyy-MM-dd')
        .format((medicines.first['purchasedate'] as Timestamp).toDate());
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final canEdit = purchaseDate == today;

    // Calculate totals for the group
    final totalPurchasePrice = medicines.fold<double>(
      0.0,
      (sum, med) =>
          sum + (double.tryParse(med['purchaseprice'].toString()) ?? 0.0),
    );
    final totalMRP = medicines.fold<double>(
      0.0,
      (sum, med) => sum + (double.tryParse(med['mrp'].toString()) ?? 0.0),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Distributor: $distributor',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                Text(
                  'Date: $purchaseDate',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Google Sheets-like Table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header Row
                  Container(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const [
                        Expanded(
                            flex: 2,
                            child: Text('Name',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('Batch',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('Expiry',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('Qty',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('P. Price',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('MRP',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('Total P. In',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('Total MRP',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  // Data Rows
                  ...medicines.map((med) {
                    final purchasePrice =
                        double.tryParse(med['purchaseprice'].toString()) ?? 0.0;
                    final mrp = double.tryParse(med['mrp'].toString()) ?? 0.0;
                    final newquantity = med['Quentity'] ?? 0;
                    int quantity = int.parse(newquantity.toString());
                    final totalPurchaseIn = purchasePrice * quantity;
                    final totalRowMRP = mrp * quantity;

                    return GestureDetector(
                      onLongPress: () {
                        if (canEdit) {
                          // Placeholder for edit action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Edit mode not implemented yet')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Sorry, you can\'t edit past entries')),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(med['name'] ?? '')),
                            Expanded(child: Text(med['batchno'] ?? '')),
                            Expanded(
                              child: Text(
                                med['expirydate'] != null
                                    ? DateFormat('yyyy-MM-dd').format(
                                        (med['expirydate'] as Timestamp)
                                            .toDate())
                                    : '',
                              ),
                            ),
                            Expanded(child: Text(quantity.toString())),
                            Expanded(
                                child: Text(purchasePrice.toStringAsFixed(2))),
                            Expanded(child: Text(mrp.toStringAsFixed(2))),
                            Expanded(
                                child:
                                    Text(totalPurchaseIn.toStringAsFixed(2))),
                            Expanded(
                                child: Text(totalRowMRP.toStringAsFixed(2))),
                          ],
                        ),
                      ),
                    );
                  }),
                  // Totals Row
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 6,
                            child: Text('Totals',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                          child: Text(
                            totalPurchasePrice.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3)),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            totalMRP.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
