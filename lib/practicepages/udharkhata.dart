import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For copying phone number

// Customer Model for Udhar Khata
class UdharCustomer {
  String name, address, phoneNumber;
  DateTime date; // Original date of credit
  DateTime? paidDate; // Date when marked paid (null if unpaid)

  UdharCustomer({
    required this.name,
    required this.address,
    this.phoneNumber = '',
    DateTime? date,
    this.paidDate,
  }) : date = date ?? DateTime.now();
}

// Home Page

// Udhar Khata Screen
class UdharKhataScreen extends StatefulWidget {
  const UdharKhataScreen({super.key});

  @override
  _UdharKhataScreenState createState() => _UdharKhataScreenState();
}

class _UdharKhataScreenState extends State<UdharKhataScreen> {
  final customers = <UdharCustomer>[];
  final history = <UdharCustomer>[];
  var filteredCustomers = <UdharCustomer>[];
  final searchController = TextEditingController();
  DateTime? filterDate;

  @override
  void initState() {
    super.initState();
    filteredCustomers = customers;
    searchController.addListener(_filterCustomers);
  }

  void _filterCustomers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCustomers = customers.where((c) {
        final matchesSearch = c.name.toLowerCase().contains(query);
        final matchesDate = filterDate == null ||
            (c.date.year == filterDate!.year &&
                c.date.month == filterDate!.month &&
                c.date.day == filterDate!.day);
        return matchesSearch && matchesDate;
      }).toList();
    });
  }

  void _addCustomer(UdharCustomer customer) => setState(() {
        customers.add(customer);
        _filterCustomers();
      });

  void _markPaid(UdharCustomer customer) => showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Mark as Paid'),
          content: Text('Has ${customer.name} paid the amount?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel')),
            TextButton(
              onPressed: () {
                setState(() {
                  customer.paidDate = DateTime.now();
                  customers.remove(customer);
                  if (customer.paidDate!
                      .isAfter(DateTime.now().subtract(Duration(days: 60)))) {
                    history.add(customer);
                  }
                  _filterCustomers();
                });
                Navigator.pop(dialogContext);
              },
              child: Text('Paid', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );

  void _addMoreForCustomer(UdharCustomer customer) async {
    final newEntry = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddUdharCustomerScreen(
          customers,
          initialCustomer: customer, // Pass existing customer data
        ),
      ),
    );
    if (newEntry != null) _addCustomer(newEntry);
  }

  void _showFilterDialog() => showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Filter by Date'),
          content: ListTile(
            title: Text(filterDate == null
                ? 'Select Date'
                : 'Date: ${filterDate!.toString().split(' ')[0]}'),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() => filterDate = picked);
                _filterCustomers();
                Navigator.pop(dialogContext);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => filterDate = null);
                _filterCustomers();
                Navigator.pop(dialogContext);
              },
              child: Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Udhar Khata'),
          backgroundColor: Color(0xFF4CAF50),
          actions: [
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () => showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text('Payment History (Last 2 Months)'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: history.length,
                      itemBuilder: (_, index) => ListTile(
                        title: Text(history[index].name),
                        subtitle: Text(
                            'Paid on: ${history[index].paidDate!.toString().split(' ')[0]}'),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text('Close'))
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Name',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: _showFilterDialog),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  return GestureDetector(
                    onDoubleTap: () => _markPaid(customer),
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(customer.name,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    SizedBox(height: 6),
                                    Text('Address: ${customer.address}',
                                        style:
                                            TextStyle(color: Colors.white70)),
                                    if (customer.phoneNumber.isNotEmpty)
                                      GestureDetector(
                                        onLongPress: () {
                                          Clipboard.setData(ClipboardData(
                                              text: customer.phoneNumber));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Phone number copied!')));
                                        },
                                        child: Text(
                                            'Phone: ${customer.phoneNumber}',
                                            style: TextStyle(
                                                color: Colors.yellowAccent)),
                                      ),
                                    Text(
                                        'Date: ${customer.date.toString().split(' ')[0]}',
                                        style:
                                            TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.add_circle, color: Colors.white),
                                onPressed: () => _addMoreForCustomer(customer),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newCustomer = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddUdharCustomerScreen(customers)));
            if (newCustomer != null) _addCustomer(newCustomer);
          },
          backgroundColor: Color(0xFF2196F3),
          child: Icon(Icons.add),
        ),
      );
}

// Add Udhar Customer Screen
class AddUdharCustomerScreen extends StatefulWidget {
  final List<UdharCustomer> existingCustomers;
  final UdharCustomer? initialCustomer;

  const AddUdharCustomerScreen(this.existingCustomers,
      {super.key, this.initialCustomer});

  @override
  _AddUdharCustomerScreenState createState() => _AddUdharCustomerScreenState();
}

class _AddUdharCustomerScreenState extends State<AddUdharCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '', address = '', phoneNumber = '';
  DateTime date = DateTime.now();
  List<UdharCustomer> suggestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomer != null) {
      name = widget.initialCustomer!.name;
      address = widget.initialCustomer!.address;
      phoneNumber = widget.initialCustomer!.phoneNumber;
    }
  }

  void _checkName(String value) {
    setState(() {
      name = value;
      if (value.isNotEmpty) {
        suggestions = widget.existingCustomers
            .where((c) => c.name.toLowerCase().startsWith(value.toLowerCase()))
            .toList();
      } else {
        suggestions = [];
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => date = picked);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text('Add Udhar Customer'),
            backgroundColor: Color(0xFF4CAF50)),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: _checkName,
                  validator: (value) =>
                      value!.isEmpty ? 'Name is required' : null,
                  initialValue: widget.initialCustomer?.name,
                ),
                if (suggestions.isNotEmpty)
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Suggestions:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50))),
                          ...suggestions
                              .map((c) => Text('${c.name} - ${c.address}')),
                        ],
                      ),
                    ),
                  ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Address'),
                  onChanged: (value) => address = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Address is required' : null,
                  initialValue: widget.initialCustomer?.address,
                ),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Phone Number (Optional)'),
                  onChanged: (value) => phoneNumber = value,
                  keyboardType: TextInputType.phone,
                  initialValue: widget.initialCustomer?.phoneNumber,
                ),
                ListTile(
                  title: Text('Date: ${date.toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(
                        context,
                        UdharCustomer(
                            name: name,
                            address: address,
                            phoneNumber: phoneNumber,
                            date: date),
                      );
                    }
                  },
                  child: Text('Add Customer'),
                ),
              ],
            ),
          ),
        ),
      );
}

// Placeholder for StockItem, StockListScreen, StockCard, AddStockScreen (unchanged)
class StockItem {
  String name, category, batchNo, distributorName;
  DateTime purchaseDate, expiryDate;
  double purchasePrice, mep;

  StockItem({
    required this.name,
    required this.category,
    required this.batchNo,
    DateTime? purchaseDate,
    required this.expiryDate,
    required this.purchasePrice,
    required this.mep,
    required this.distributorName,
  }) : purchaseDate = purchaseDate ?? DateTime.now();
}
