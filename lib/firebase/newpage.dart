// class ReLoginPage extends StatefulWidget {
//   const ReLoginPage({super.key});

//   @override
//   State<ReLoginPage> createState() => _ReLoginPageState();
// }

// class _ReLoginPageState extends State<ReLoginPage> {
//   final TextEditingController _controller = TextEditingController();

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   void sendMsg() {
//     if (_controller.text.isNotEmpty) {
//       _firestore
//           .collection('messages')
//           .add({"msg": _controller.text, "time": DateTime.now()});

//       _controller.clear();

//       print("yes working on");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Container(
//                   color: Colors.amber,
//                   child: StreamBuilder(
//                       stream: _firestore
//                           .collection('messages')
//                           .orderBy("time", descending: false)
//                           .snapshots(),
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData) return Center();
//                         List<DocumentSnapshot> docs = snapshot.data!.docs;

//                         return ListView.builder(
//                           itemCount: docs.length,
//                           itemBuilder: (context, index) {
//                             Map<String, dynamic> data =
//                                 docs[index].data() as Map<String, dynamic>;

//                             return Text(data["msg"]);
//                           },
//                         );
//                       }),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _controller,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           fillColor: Colors.grey,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: sendMsg,
//                       icon: Icon(Icons.send),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ));
//   }
// }
