import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:med_x/FirebaseDB/firestore_data.dart';
import 'package:med_x/pages/scanbarcode.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  _StockListScreenState createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  // final stockItems = <StockItem>[];
  // var filteredItems = <StockItem>[];
  //final searchController = TextEditingController();
  String? filterCategory;
  bool sortAZ = false, sortExpiry = false;
  DateTime? filterPurchaseMonth;
  int ExpiryLimit = 0;

  // void initState() {
  //   super.initState();
  //   // filteredItems = stockItems;
  //   searchController.addListener(_filterStocks);
  // }

  // void _filterStocks() {
  //   final query = searchController.text.toLowerCase();
  //   setState(() {
  //     filteredItems = stockItems.where((item) {
  //       final matchesSearch = item.name.toLowerCase().contains(query) ||
  //           item.batchNo.toLowerCase().contains(query);
  //       final matchesCategory =
  //           filterCategory == null || item.category == filterCategory;
  //       final matchesMonth = filterPurchaseMonth == null ||
  //           (item.purchaseDate.year == filterPurchaseMonth!.year &&
  //               item.purchaseDate.month == filterPurchaseMonth!.month);
  //       return matchesSearch && matchesCategory && matchesMonth;
  //     }).toList();

  //     if (sortAZ) filteredItems.sort((a, b) => a.name.compareTo(b.name));
  //     if (sortExpiry) {
  //       filteredItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
  //     }
  //   });
  // }

  // void _addStock(StockItem item) => setState(() {
  //       stockItems.add(item);
  //       _filterStocks();
  //     });

  // void _showFilterDialog() => showDialog(
  //       context: context,
  //       builder: (context) {
  //         var tempCategory = filterCategory;
  //         var tempSortAZ = sortAZ;
  //         var tempSortExpiry = sortExpiry;
  //         var tempPurchaseMonth = filterPurchaseMonth;

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
  //                   onChanged: (value) =>
  //                       setState(() => tempSortExpiry = value!),
  //                 ),
  //                 ListTile(
  //                   title: Text(tempPurchaseMonth == null
  //                       ? 'Select Purchase Month'
  //                       : 'Month: ${tempPurchaseMonth!.month}/${tempPurchaseMonth!.year}'),
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
  //                   //    _filterStocks();
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
  //                   // _filterStocks();
  //                   Navigator.pop(context);
  //                 },
  //                 child: Text('Apply'),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     );

  showFilter() {
    bool tempAtoZ = sortAZ;
    int tempExpiryLimit = ExpiryLimit;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, newState) {
          return AlertDialog(
            title: Text('Filter Options'),
            content: Column(
              children: [
                CheckboxListTile(
                    title: Text("A to Z"),
                    value: tempAtoZ,
                    onChanged: (newValue) {
                      newState(() {
                        tempAtoZ = newValue!;
                      });
                    }),
                PopupMenuButton<int>(
                  icon: Icon(Icons.filter_alt),
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 0,
                        child: Text('All Expiry'),
                      ),
                      const PopupMenuItem(
                        value: 1,
                        child: Text('1 Month'),
                      ),
                      const PopupMenuItem(
                        value: 2,
                        child: Text('2 Months'),
                      ),
                      const PopupMenuItem(
                        value: 3,
                        child: Text('3 Months'),
                      ),
                      const PopupMenuItem(
                        value: 6,
                        child: Text('6 Months'),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    tempExpiryLimit = value;
                  },
                )
              ],
            ),
            actions: [
              MaterialButton(
                onPressed: () {},
                child: Text("Clear"),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);

                  setState(() {
                    sortAZ = tempAtoZ;
                    ExpiryLimit = tempExpiryLimit;
                  });
                },
                child: Text("Apply"),
              )
            ],
          );
        });
      },
    );
  }

  //final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String searchText = '';
  final FirestoreData firestoreData = FirestoreData();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Pharmacy Stock'),
          backgroundColor: Color(0xFF4CAF50),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarcodeScannerPage(),
                ),
              );
            },
            icon: Icon(Icons.camera_alt),
          ),
          actions: [
            IconButton(icon: Icon(Icons.filter_list), onPressed: showFilter)
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                //controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by Name or Batch No',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: firestoreData.getMedicines(
                      searchText, sortAZ, ExpiryLimit),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData) {
                      return Center(child: Text('No Data Found'));
                    }
                    var medicines = snapshot.data!;
                    return ListView.builder(
                        itemCount: medicines.length,
                        itemBuilder: (context, index) {
                          Timestamp time = medicines[index]['expirydate'];

                          return ListTile(
                            title: Text(medicines[index]['name']),
                            subtitle: Text(medicines[index]['batchno']),
                            trailing: Text(
                                '${time.toDate().day}/${time.toDate().month}/${time.toDate().year}'),
                          );
                        });
                  }),
            ),
          ],
        ),
      );
}
