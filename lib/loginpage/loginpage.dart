import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  LoginPage({super.key});

  void _loginWithGoogle(BuildContext context) {
    // Placeholder for Firebase Google Sign-In
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google Sign-In Coming Soon!')),
    );
    // After Firebase setup, navigate to HomePage here
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
  }

  void _loginWithEmail(BuildContext context) {
    final email = emailController.text.trim();
    if (email.isNotEmpty && email.contains('@gmail.com')) {
      // Placeholder for Firebase Email Auth
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email Login Coming Soon!')),
      );
      // After Firebase setup, navigate to HomePage here
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid Gmail address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(Icons.local_pharmacy,
                        size: 60, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Dev Pharmax',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your Pharmacy Companion',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Google Sign-In Button
                  ElevatedButton.icon(
                    onPressed: () => _loginWithGoogle(context),
                    icon: Icon(Icons.login, size: 24),
                    label: Text('Continue with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Email Input
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter Gmail Address',
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),

                  // Email Login Button
                  ElevatedButton(
                    onPressed: () => _loginWithEmail(context),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: Text('Login with Email'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
