import 'package:flutter/material.dart';

class PharmacyStockApp extends StatelessWidget {
  const PharmacyStockApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Pharmacy Stock Manager',
        theme: ThemeData(
          primaryColor: Color(0xFF4CAF50),
          scaffoldBackgroundColor: Color(0xFFF5F5F5),
          textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: StockListScreen(),
      );
}

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

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  _StockListScreenState createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  final stockItems = <StockItem>[];
  var filteredItems = <StockItem>[];
  final searchController = TextEditingController();
  String? filterCategory;
  bool sortAZ = false, sortExpiry = false;
  DateTime? filterPurchaseMonth;

  @override
  void initState() {
    super.initState();
    filteredItems = stockItems;
    searchController.addListener(_filterStocks);
  }

  void _filterStocks() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = stockItems.where((item) {
        final matchesSearch = item.name.toLowerCase().contains(query) ||
            item.batchNo.toLowerCase().contains(query);
        final matchesCategory =
            filterCategory == null || item.category == filterCategory;
        final matchesMonth = filterPurchaseMonth == null ||
            (item.purchaseDate.year == filterPurchaseMonth!.year &&
                item.purchaseDate.month == filterPurchaseMonth!.month);
        return matchesSearch && matchesCategory && matchesMonth;
      }).toList();

      if (sortAZ) filteredItems.sort((a, b) => a.name.compareTo(b.name));
      if (sortExpiry)
        filteredItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    });
  }

  void _addStock(StockItem item) => setState(() {
        stockItems.add(item);
        _filterStocks();
      });

  void _showFilterDialog() => showDialog(
        context: context,
        builder: (context) {
          var tempCategory = filterCategory;
          var tempSortAZ = sortAZ;
          var tempSortExpiry = sortExpiry;
          var tempPurchaseMonth = filterPurchaseMonth;

          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text('Filter Options'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: tempCategory,
                    hint: Text('Select Category'),
                    items: ['Tablet', 'Syrup', 'Capsule', 'Cream', 'Other']
                        .map((cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) => setState(() => tempCategory = value),
                  ),
                  CheckboxListTile(
                    title: Text('Sort A-Z'),
                    value: tempSortAZ,
                    onChanged: (value) => setState(() => tempSortAZ = value!),
                  ),
                  CheckboxListTile(
                    title: Text('Nearby Expiry First'),
                    value: tempSortExpiry,
                    onChanged: (value) =>
                        setState(() => tempSortExpiry = value!),
                  ),
                  ListTile(
                    title: Text(tempPurchaseMonth == null
                        ? 'Select Purchase Month'
                        : 'Month: ${tempPurchaseMonth!.month}/${tempPurchaseMonth!.year}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null)
                        setState(() => tempPurchaseMonth =
                            DateTime(picked.year, picked.month));
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      filterCategory = null;
                      sortAZ = false;
                      sortExpiry = false;
                      filterPurchaseMonth = null;
                    });
                    _filterStocks();
                    Navigator.pop(context);
                  },
                  child: Text('Clear', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      filterCategory = tempCategory;
                      sortAZ = tempSortAZ;
                      sortExpiry = tempSortExpiry;
                      filterPurchaseMonth = tempPurchaseMonth;
                    });
                    _filterStocks();
                    Navigator.pop(context);
                  },
                  child: Text('Apply'),
                ),
              ],
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Pharmacy Stock'),
          backgroundColor: Color(0xFF4CAF50),
          actions: [
            IconButton(
                icon: Icon(Icons.filter_list), onPressed: _showFilterDialog)
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Name or Batch No',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) =>
                    StockCard(stock: filteredItems[index]),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newStock = await Navigator.push(
                context, MaterialPageRoute(builder: (_) => AddStockScreen()));
            if (newStock != null) _addStock(newStock);
          },
          backgroundColor: Color(0xFF2196F3),
          child: Icon(Icons.add),
        ),
      );
}

class StockCard extends StatelessWidget {
  final StockItem stock;

  const StockCard({super.key, required this.stock});

  void _showDetails(BuildContext context) => showDialog(
        context: context,
        builder: (dialogueContext) => AlertDialog(
          title: Text(stock.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${stock.category}'),
              Text('Batch No: ${stock.batchNo}'),
              Text(
                  'Purchase Date: ${stock.purchaseDate.toString().split(' ')[0]}'),
              Text('Expiry Date: ${stock.expiryDate.toString().split(' ')[0]}',
                  style: TextStyle(
                      color: stock.expiryDate.isBefore(DateTime.now())
                          ? Color(0xFFFF5722)
                          : null)),
              Text(
                  'Purchase Price: \$${stock.purchasePrice.toStringAsFixed(2)}'),
              Text('MEP: \$${stock.mep.toStringAsFixed(2)}'),
              Text('Distributor: ${stock.distributorName}'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogueContext),
                child: Text('Close'))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPress: () => _showDetails(context),
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.category,
                        style: TextStyle(color: Color(0xFF4CAF50))),
                    SizedBox(height: 4),
                    Text(stock.name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Batch: ${stock.batchNo}',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Text('\$${stock.mep.toStringAsFixed(2)}',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
}

class AddStockScreen extends StatefulWidget {
  const AddStockScreen({super.key});

  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '', category = 'Tablet', batchNo = '', distributorName = '';
  DateTime purchaseDate = DateTime.now(), expiryDate = DateTime.now();
  String purchasePriceText = '', mepText = '';
  bool hasError = false;
  final categories = ['Tablet', 'Syrup', 'Capsule', 'Cream', 'Other'];

  Future<void> _selectDate(bool isPurchase) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isPurchase ? purchaseDate : expiryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null)
      setState(() => isPurchase ? purchaseDate = picked : expiryDate = picked);
  }

  bool _validateForm() {
    final purchasePrice = double.tryParse(purchasePriceText);
    final mep = double.tryParse(mepText);
    return _formKey.currentState!.validate() &&
        purchasePrice != null &&
        mep != null &&
        purchasePrice >= 0 &&
        mep >= 0;
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
                  decoration: InputDecoration(labelText: 'MEP'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() => mepText = value),
                  validator: (value) => value!.isEmpty
                      ? 'MEP is required'
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
                  onPressed: () {
                    if (_validateForm()) {
                      Navigator.pop(
                        context,
                        StockItem(
                          name: name,
                          category: category,
                          batchNo: batchNo,
                          purchaseDate: purchaseDate,
                          expiryDate: expiryDate,
                          purchasePrice: double.parse(purchasePriceText),
                          mep: double.parse(mepText),
                          distributorName: distributorName,
                        ),
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
