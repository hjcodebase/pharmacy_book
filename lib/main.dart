import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:med_x/firebase_options.dart';
import 'package:med_x/pages/loginpage.dart';
import 'package:med_x/pages/mainhome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //  FirebaseAuth auth = FirebaseAuth.instance;
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final user = snapshot.data;

              print(user);

              if (user == null) {
                return LoginPage();
              } else {
                return const MainHomePage();
              }
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}



  //   elevatedButtonTheme: ElevatedButtonThemeData(
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Color(0xFF2196F3),
  //           foregroundColor: Colors.white,
  //         ),
  //       ),
  //     ),
  //     home: auth.currentUser == null ? LoginPage() : const StockListScreen(),
  //   );
  // }