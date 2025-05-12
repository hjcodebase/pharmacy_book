import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UdharKhataPage extends StatefulWidget {
  const UdharKhataPage({super.key});

  @override
  _UdharKhataPageState createState() => _UdharKhataPageState();
}

class _UdharKhataPageState extends State<UdharKhataPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _searchController = TextEditingController();
  DateTime? _filterMonth;
  DateTime? _filterDate;
  List<Map<String, dynamic>> khataEntries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Udhar Khata'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF2196F3)),
                      onPressed: () => setState(() {}),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => _filterMonth =
                              DateTime(picked.year, picked.month));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3)),
                      child: Text(
                        _filterMonth == null
                            ? 'Filter by Month'
                            : DateFormat('MMM yyyy').format(_filterMonth!),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => _filterDate = picked);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3)),
                      child: Text(
                        _filterDate == null
                            ? 'Filter by Date'
                            : DateFormat('yyyy-MM-dd').format(_filterDate!),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Khata List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser!.uid)
                  .collection('udhar_khata')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final entries = snapshot.data!.docs
                    .map((doc) =>
                        {'id': doc.id, ...doc.data() as Map<String, dynamic>})
                    .where((entry) {
                  final name = entry['name'].toString().toLowerCase();
                  final search = _searchController.text.toLowerCase();
                  final entryDate = (entry['date'] as Timestamp).toDate();
                  bool matchesSearch = search.isEmpty || name.contains(search);
                  bool matchesMonth = _filterMonth == null ||
                      (entryDate.year == _filterMonth!.year &&
                          entryDate.month == _filterMonth!.month);
                  bool matchesDate = _filterDate == null ||
                      entryDate.isAtSameMomentAs(_filterDate!);
                  return matchesSearch && matchesMonth && matchesDate;
                }).toList();

                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _buildKhataCard(entry);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Khata Card UI
  Widget _buildKhataCard(Map<String, dynamic> entry) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        title: Text(entry['name'],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mobile: ${entry['mobile']}'),
            Text('Amount: \$${entry['amount']}'),
            Text(
                'Date: ${DateFormat('yyyy-MM-dd').format((entry['date'] as Timestamp).toDate())}'),
            if (entry['note'] != null && entry['note'].isNotEmpty)
              Text('Note: ${entry['note']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
              onPressed: () => _showAddEditDialog(entry: entry),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEntry(entry),
            ),
          ],
        ),
      ),
    );
  }

  // Add/Edit Dialog
  Future<void> _showAddEditDialog({Map<String, dynamic>? entry}) async {
    final isEdit = entry != null;
    final nameController = TextEditingController(text: entry?['name']);
    final addressController = TextEditingController(text: entry?['address']);
    final mobileController = TextEditingController(text: entry?['mobile']);
    final amountController =
        TextEditingController(text: entry?['amount']?.toString());
    final noteController = TextEditingController(text: entry?['note']);
    DateTime date =
        entry != null ? (entry['date'] as Timestamp).toDate() : DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Entry' : 'Add Entry'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address')),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) date = picked;
                },
                child: Text('Date: ${DateFormat('yyyy-MM-dd').format(date)}'),
              ),
              TextField(
                  controller: noteController,
                  decoration:
                      const InputDecoration(labelText: 'Note (Optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Name and Amount are required')));
                return;
              }
              final data = {
                'name': nameController.text.trim(),
                'address': addressController.text.trim(),
                'mobile': mobileController.text.trim(),
                'amount': double.parse(amountController.text.trim()),
                'date': Timestamp.fromDate(date),
                'note': noteController.text.trim(),
              };
              final user = _auth.currentUser!;
              if (isEdit) {
                await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('udhar_khata')
                    .doc(entry['id'])
                    .set(data);
                await _logHistory('edit', entry['id'], entry, data);
              } else {
                await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('udhar_khata')
                    .add(data);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Delete Entry
  Future<void> _deleteEntry(Map<String, dynamic> entry) async {
    final user = _auth.currentUser!;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('udhar_khata')
        .doc(entry['id'])
        .delete();
    await _logHistory('delete', entry['id'], entry, null);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Entry deleted')));
  }

  // Log Edit/Delete to History
  Future<void> _logHistory(String action, String entryId,
      Map<String, dynamic>? oldData, Map<String, dynamic>? newData) async {
    final user = _auth.currentUser!;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'action': action,
      'entryId': entryId,
      'oldData': oldData,
      'newData': newData,
      'timestamp': Timestamp.now(),
    });
  }
}

// History Page
class UdharKhataHistoryPage extends StatelessWidget {
  const UdharKhataHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Udhar Khata History'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('history')
            .where('timestamp', isGreaterThan: Timestamp.fromDate(twoMonthsAgo))
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final history = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final action = entry['action'] as String;
              final timestamp = (entry['timestamp'] as Timestamp).toDate();
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: ListTile(
                  title: Text('$action - ${entry['entryId']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp)}'),
                  trailing: Text(action == 'edit' ? 'Edited' : 'Deleted',
                      style: TextStyle(
                          color: action == 'edit' ? Colors.blue : Colors.red)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
