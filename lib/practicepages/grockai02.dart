// import 'package:flutter/material.dart';
// import 'package:med_x/firebase/stocks/stocks_add.dart';

// class PharmacyStockApp extends StatelessWidget {
//   const PharmacyStockApp({super.key});

//   @override
//   Widget build(BuildContext context) => MaterialApp(
//         title: 'Pharmacy Stock Manager',
      
//         home: StockListScreen(),
//       );
// }

// class StockItem {
//   String name, category, batchNo, distributorName;
//   DateTime purchaseDate, expiryDate;
//   double purchasePrice, mep;

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


// class StockCard extends StatelessWidget {
//   final StockItem stock;

//   const StockCard({super.key, required this.stock});

//   void _showDetails(BuildContext context) => showDialog(
//         context: context,
//         builder: (dialogueContext) => AlertDialog(
//           title: Text(stock.name),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Category: ${stock.category}'),
//               Text('Batch No: ${stock.batchNo}'),
//               Text(
//                   'Purchase Date: ${stock.purchaseDate.toString().split(' ')[0]}'),
//               Text('Expiry Date: ${stock.expiryDate.toString().split(' ')[0]}',
//                   style: TextStyle(
//                       color: stock.expiryDate.isBefore(DateTime.now())
//                           ? Color(0xFFFF5722)
//                           : null)),
//               Text(
//                   'Purchase Price: \$${stock.purchasePrice.toStringAsFixed(2)}'),
//               Text('MEP: \$${stock.mep.toStringAsFixed(2)}'),
//               Text('Distributor: ${stock.distributorName}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(dialogueContext),
//                 child: Text('Close'))
//           ],
//         ),
//       );

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onLongPress: () => _showDetails(context),
//         child: Card(
//           margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           elevation: 3,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: EdgeInsets.all(12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(stock.category,
//                         style: TextStyle(color: Color(0xFF4CAF50))),
//                     SizedBox(height: 4),
//                     Text(stock.name,
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     Text('Batch: ${stock.batchNo}',
//                         style: TextStyle(fontSize: 12, color: Colors.grey)),
//                   ],
//                 ),
//                 Text('\$${stock.mep.toStringAsFixed(2)}',
//                     style:
//                         TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//         ),
//       );
// }
