import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Controllers for form fields
  final _userNameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dlNo1Controller = TextEditingController();
  final _dlNo2Controller = TextEditingController();
  final _gstNoController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load existing profile data from Firestore
  Future<void> _loadProfileData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userNameController.text = data['userName'] ?? '';
          _shopNameController.text = data['shopName'] ?? '';
          _addressController.text = data['address'] ?? '';
          _dlNo1Controller.text = data['dlNo1'] ?? '';
          _dlNo2Controller.text = data['dlNo2'] ?? '';
          _gstNoController.text = data['gstNo'] ?? '';
        });
      }
    }
  }

  // Save profile data to Firestore
  Future<void> _saveProfileData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'userName': _userNameController.text.trim(),
          'shopName': _shopNameController.text.trim(),
          'address': _addressController.text.trim(),
          'dlNo1': _dlNo1Controller.text.trim(),
          'dlNo2': _dlNo2Controller.text.trim(),
          'gstNo': _gstNoController.text.trim().isEmpty
              ? null
              : _gstNoController.text.trim(),
        }, SetOptions(merge: true)); // Merge to avoid overwriting other data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Info'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_userNameController, 'User Name', required: true),
              _buildTextField(_shopNameController, 'Shop Name', required: true),
              _buildTextField(_addressController, 'Address', required: true),
              _buildTextField(_dlNo1Controller, 'DL No 1', required: true),
              _buildTextField(_dlNo2Controller, 'DL No 2', required: true),
              _buildTextField(_gstNoController, 'GST No (Optional)',
                  required: false),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfileData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Profile',
                          style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {required bool required}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => required && (value == null || value.isEmpty)
            ? '$label is required'
            : null,
      ),
    );
  }
}
