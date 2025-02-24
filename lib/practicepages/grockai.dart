// import 'package:flutter/material.dart';

// class PharmacyStockApp extends StatelessWidget {
//   const PharmacyStockApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Pharmacy Stock Manager',
//       theme: ThemeData(
//         primaryColor: Color(0xFF4CAF50),
//         scaffoldBackgroundColor: Color(0xFFF5F5F5),
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Color(0xFF2196F3),
//             foregroundColor: Colors.white,
//           ),
//         ),
//       ),
//       home: StockListScreen(),
//     );
//   }
// }

// // Data Model
// class StockItem {
//   String name;
//   String category;
//   String batchNo;
//   DateTime purchaseDate;
//   DateTime expiryDate;
//   double purchasePrice;
//   double mep;
//   String distributorName;

//   StockItem({
//     required this.name,
//     required this.category,
//     required this.batchNo,
//     DateTime? purchaseDate,
//     required this.expiryDate,
//     required this.purchasePrice,
//     required this.mep,
//     required this.distributorName,
//   }) : purchaseDate = purchaseDate ?? DateTime.now();
// }

// // Stock List Screen
// class StockListScreen extends StatefulWidget {
//   const StockListScreen({super.key});

//   @override
//   _StockListScreenState createState() => _StockListScreenState();
// }

// class _StockListScreenState extends State<StockListScreen> {
//   List<StockItem> stockItems = [];
//   List<StockItem> filteredItems = [];
//   TextEditingController searchController = TextEditingController();
//   String? filterCategory;
//   bool sortAZ = false;
//   bool sortExpiry = false;
//   DateTime? filterPurchaseMonth;

//   @override
//   void initState() {
//     super.initState();
//     filteredItems = stockItems;
//     searchController.addListener(_filterStocks);
//   }

//   void _filterStocks() {
//     String query = searchController.text.toLowerCase();
//     setState(() {
//       filteredItems = stockItems.where((item) {
//         bool matchesSearch = item.name.toLowerCase().contains(query) ||
//             item.batchNo.toLowerCase().contains(query);
//         bool matchesCategory =
//             filterCategory == null || item.category == filterCategory;
//         bool matchesPurchaseMonth = filterPurchaseMonth == null ||
//             (item.purchaseDate.year == filterPurchaseMonth!.year &&
//                 item.purchaseDate.month == filterPurchaseMonth!.month);
//         return matchesSearch && matchesCategory && matchesPurchaseMonth;
//       }).toList();

//       if (sortAZ) {
//         filteredItems.sort((a, b) => a.name.compareTo(b.name));
//       }
//       if (sortExpiry) {
//         filteredItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
//       }
//     });
//   }

//   void _addStock(StockItem item) {
//     setState(() {
//       stockItems.add(item);
//       _filterStocks();
//     });
//   }

//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String? tempCategory = filterCategory;
//         bool tempSortAZ = sortAZ;
//         bool tempSortExpiry = sortExpiry;
//         DateTime? tempPurchaseMonth = filterPurchaseMonth;

//         return StatefulBuilder(
//           builder: (context, setState) => AlertDialog(
//             title: Text('Filter Options'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 DropdownButton<String>(
//                   value: tempCategory,
//                   hint: Text('Select Category'),
//                   items: ['Tablet', 'Syrup', 'Capsule', 'Cream', 'Other']
//                       .map((cat) =>
//                           DropdownMenuItem(value: cat, child: Text(cat)))
//                       .toList(),
//                   onChanged: (value) => setState(() => tempCategory = value),
//                 ),
//                 CheckboxListTile(
//                   title: Text('Sort A-Z'),
//                   value: tempSortAZ,
//                   onChanged: (value) => setState(() => tempSortAZ = value!),
//                 ),
//                 CheckboxListTile(
//                   title: Text('Nearby Expiry First'),
//                   value: tempSortExpiry,
//                   onChanged: (value) => setState(() => tempSortExpiry = value!),
//                 ),
//                 ListTile(
//                   title: Text(tempPurchaseMonth == null
//                       ? 'Select Purchase Month'
//                       : 'Purchase Month: ${tempPurchaseMonth!.month}/${tempPurchaseMonth!.year}'),
//                   trailing: Icon(Icons.calendar_today),
//                   onTap: () async {
//                     final picked = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime(2020),
//                       lastDate: DateTime(2030),
//                     );
//                     if (picked != null) {
//                       setState(() => tempPurchaseMonth =
//                           DateTime(picked.year, picked.month));
//                     }
//                   },
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     filterCategory = null;
//                     sortAZ = false;
//                     sortExpiry = false;
//                     filterPurchaseMonth = null;
//                   });
//                   _filterStocks();
//                   Navigator.pop(context);
//                 },
//                 child: Text('Clear', style: TextStyle(color: Colors.red)),
//               ),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     filterCategory = tempCategory;
//                     sortAZ = tempSortAZ;
//                     sortExpiry = tempSortExpiry;
//                     filterPurchaseMonth = tempPurchaseMonth;
//                   });
//                   _filterStocks();
//                   Navigator.pop(context);
//                 },
//                 child: Text('Apply'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pharmacy Stock'),
//         backgroundColor: Color(0xFF4CAF50),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.filter_list),
//             onPressed: _showFilterDialog,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search by Name or Batch No',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredItems.length,
//               itemBuilder: (context, index) {
//                 return StockCard(stock: filteredItems[index]);
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final newStock = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => AddStockScreen()),
//           );
//           if (newStock != null) _addStock(newStock);
//         },
//         backgroundColor: Color(0xFF2196F3),
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

// // Stock Card Widget
// class StockCard extends StatelessWidget {
//   final StockItem stock;

//   const StockCard({super.key, required this.stock});

//   void _showDetails(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(stock.name),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Category: ${stock.category}'),
//             Text('Batch No: ${stock.batchNo}'),
//             Text(
//                 'Purchase Date: ${stock.purchaseDate.toString().split(' ')[0]}'),
//             Text('Expiry Date: ${stock.expiryDate.toString().split(' ')[0]}',
//                 style: TextStyle(
//                   color: stock.expiryDate.isBefore(DateTime.now())
//                       ? Color(0xFFFF5722)
//                       : null,
//                 )),
//             Text('Purchase Price: \$${stock.purchasePrice.toStringAsFixed(2)}'),
//             Text('MEP: \$${stock.mep.toStringAsFixed(2)}'),
//             Text('Distributor: ${stock.distributorName}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: () => _showDetails(context),
//       child: Card(
//         margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         elevation: 3.0,
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//         child: Padding(
//           padding: EdgeInsets.all(12.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(stock.category,
//                       style: TextStyle(color: Color(0xFF4CAF50))),
//                   SizedBox(height: 4),
//                   Text(stock.name,
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   Text('Batch: ${stock.batchNo}',
//                       style: TextStyle(fontSize: 12, color: Colors.grey)),
//                 ],
//               ),
//               Text('\$${stock.mep.toStringAsFixed(2)}',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Add Stock Screen
// class AddStockScreen extends StatefulWidget {
//   const AddStockScreen({super.key});

//   @override
//   _AddStockScreenState createState() => _AddStockScreenState();
// }

// class _AddStockScreenState extends State<AddStockScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String name = '';
//   String category = 'Tablet';
//   String batchNo = '';
//   DateTime purchaseDate = DateTime.now();
//   DateTime expiryDate = DateTime.now();
//   String purchasePriceText = '';
//   String mepText = '';
//   String distributorName = '';
//   bool hasError = false;

//   final List<String> categories = [
//     'Tablet',
//     'Syrup',
//     'Capsule',
//     'Cream',
//     'Other'
//   ];

//   Future<void> _selectDate(BuildContext context, bool isPurchase) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isPurchase ? purchaseDate : expiryDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isPurchase) {
//           purchaseDate = picked;
//         } else {
//           expiryDate = picked;
//         }
//       });
//     }
//   }

//   bool _validateForm() {
//     double? purchasePrice = double.tryParse(purchasePriceText);
//     double? mep = double.tryParse(mepText);
//     return _formKey.currentState!.validate() &&
//         purchasePrice != null &&
//         mep != null &&
//         purchasePrice >= 0 &&
//         mep >= 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add New Stock'),
//         backgroundColor: Color(0xFF4CAF50),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Name'),
//                 onChanged: (value) => setState(() => name = value),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Name is required' : null,
//               ),
//               DropdownButtonFormField(
//                 value: category,
//                 items: categories
//                     .map(
//                         (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
//                     .toList(),
//                 onChanged: (value) =>
//                     setState(() => category = value as String),
//                 decoration: InputDecoration(labelText: 'Category'),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Batch No'),
//                 onChanged: (value) => setState(() => batchNo = value),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Batch No is required' : null,
//               ),
//               ListTile(
//                 title: Text(
//                     'Purchase Date: ${purchaseDate.toString().split(' ')[0]}'),
//                 trailing: Icon(Icons.calendar_today),
//                 onTap: () => _selectDate(context, true),
//               ),
//               ListTile(
//                 title:
//                     Text('Expiry Date: ${expiryDate.toString().split(' ')[0]}'),
//                 trailing: Icon(Icons.calendar_today),
//                 onTap: () => _selectDate(context, false),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Purchase Price'),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => setState(() => purchasePriceText = value),
//                 validator: (value) {
//                   if (value!.isEmpty) return 'Price is required';
//                   if (double.tryParse(value) == null || double.parse(value) < 0)
//                     return 'Enter a valid number';
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'MEP'),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => setState(() => mepText = value),
//                 validator: (value) {
//                   if (value!.isEmpty) return 'MEP is required';
//                   if (double.tryParse(value) == null || double.parse(value) < 0)
//                     return 'Enter a valid number';
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Distributor Name'),
//                 onChanged: (value) => setState(() => distributorName = value),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Distributor is required' : null,
//               ),
//               if (hasError)
//                 Padding(
//                   padding: EdgeInsets.only(top: 10),
//                   child: Text(
//                     'Please correct the errors before adding.',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_validateForm()) {
//                     Navigator.pop(
//                       context,
//                       StockItem(
//                         name: name,
//                         category: category,
//                         batchNo: batchNo,
//                         purchaseDate: purchaseDate,
//                         expiryDate: expiryDate,
//                         purchasePrice: double.parse(purchasePriceText),
//                         mep: double.parse(mepText),
//                         distributorName: distributorName,
//                       ),
//                     );
//                   } else {
//                     setState(() => hasError = true);
//                   }
//                 },
//                 child: Text('Add Stock'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:med_x/practicepages/udharkhata.dart';

class HomePharmacyStockApp extends StatelessWidget {
  const HomePharmacyStockApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Dev Pharmax',
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
        home: HomePage(), // Changed to HomePage
      );
}

// Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Dev Pharmax',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Empower Your Pharmacy, Simplify Your Success',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Main Buttons
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildHomeCard(
                          title: 'Udhar Khata',
                          icon: Icons.account_balance_wallet,
                          color: Colors.orangeAccent,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UdharKhataScreen(),
                                ));
                          }, // Placeholder for navigation
                        ),
                        _buildHomeCard(
                          title: 'Stocks',
                          icon: Icons.inventory,
                          color: Colors.teal,
                          onTap: () {}, // Placeholder for navigation
                        ),
                        _buildHomeCard(
                          title: 'New Stock Entry',
                          icon: Icons.add_box,
                          color: Colors.purpleAccent,
                          onTap: () {}, // Placeholder for navigation
                        ),
                        _buildHomeCard(
                          title: 'Sales',
                          icon: Icons.point_of_sale,
                          color: Colors.redAccent,
                          onTap: () {}, // Placeholder for navigation
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHomeCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.8), color],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}

// Placeholder for StockItem (unchanged, just for context)
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

// Add your StockListScreen, StockCard, AddStockScreen classes here unchanged...
