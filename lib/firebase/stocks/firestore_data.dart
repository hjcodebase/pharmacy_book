import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// class FirestoreData {
//   Stream<List<Map<String, dynamic>>> getMedicineList(bool alphabatically, String search) {
//     Query query = FirebaseFirestore.instance
//         .collection("users")
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .collection("medicines");
//     Query searchQuery = query;

//     // if (alphabatically == true) {
//     //   return searchQuery.orderBy("name").snapshots();
//     // } else {
//     //   return searchQuery.snapshots();
//     // }

//     final stream = alphabatically
//         ? searchQuery.orderBy("name").snapshots()
//         : searchQuery.snapshots();

//     return stream.map(
//       (snapshot) {
//         final searchlower = search.toLowerCase();

//         return snapshot.docs
//             .map(
//           (doc) => doc.data() as Map<String, dynamic>,
//         )
//             .where((medicine) {
//           final name = (medicine['name'] as String?)?.toLowerCase() ?? '';
//           final batchNo = (medicine['batchno'] as String?)?.toLowerCase() ?? '';
//           return name.contains(searchlower) || batchNo.contains(searchlower);
//         }).toList();
//       },
//     );
//   }
// }

class FirestoreData {
  Stream<List<Map<String, dynamic>>> getMedicines(
      String search, bool sortByName, int expiryMonths) {
    final baseQuery = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("medicines");

    return (sortByName ? baseQuery.orderBy("name") : baseQuery).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).where((med) {
// Get today’s date to check expiry
            final today = DateTime.now();

            final name = (med['name'] as String?)?.toLowerCase() ?? '';
            // Get the batch number and make it small letters
            final batch = (med['batchno'] as String?)?.toLowerCase() ?? '';
            // Get the expiry date (when it goes bad)
            final expiry = (med['expirydate'] as Timestamp?)?.toDate();

            // Check if the name starts with what the user typed OR batch has it anywhere
            final matchesSearch =
                name.startsWith(search) || batch.contains(search.toLowerCase());

            // If we don’t care about expiry, just use the search result
            // if (expiry == null) return matchesSearch;
            if (expiryMonths == 0 || expiry == null) return matchesSearch;
            // Figure out the last day we care about (like 1 month from today)
            final endDate =
                DateTime(today.year, today.month + expiryMonths, today.day);
            // Check if medicine expires soon (after today but before the limit)
            final isNearExpiry =
                expiry.isAfter(today) && expiry.isBefore(endDate);

            // Show medicine only if it matches search AND expires soon
            return matchesSearch && isNearExpiry;
          }).toList(),
        );
  }
}
