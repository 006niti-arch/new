// lib/screens/unsubscribe_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';

class UnsubscribeScreen extends StatefulWidget {
  const UnsubscribeScreen({super.key});

  @override
  State<UnsubscribeScreen> createState() => _UnsubscribeScreenState();
}

class _UnsubscribeScreenState extends State<UnsubscribeScreen> {
  final _numberController = TextEditingController();
  String _selectedCountryCode = '+91';
  CollectionReference? _unsubscribesRef;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _unsubscribesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('unsubscribes');
    }
  }

  void _addUnsubscribedNumber() async {
    final number = _numberController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (number.isNotEmpty) {
      final fullNumber = '$_selectedCountryCode$number';
      await _unsubscribesRef?.doc(fullNumber).set({'addedOn': Timestamp.now()});
      _numberController.clear();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number.')),
      );
    }
  }

  // THIS FUNCTION IS NOW FIXED
  void _showAddDialog() {
    _selectedCountryCode = '+91';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Unsubscribe List'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CountryCodePicker(
                onChanged: (countryCode) {
                  _selectedCountryCode = countryCode.dialCode ?? '+91';
                },
                initialSelection: 'IN',
                favorite: const ['+91', 'IN'],
              ),
              TextField(
                controller: _numberController,
                decoration: const InputDecoration(hintText: '9876543210'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addUnsubscribedNumber,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_unsubscribesRef == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Unsubscribe List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _unsubscribesRef!.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your unsubscribe list is empty.'));
          }
          
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final number = docs[index].id;
              return ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: Text(number),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove from list',
                  onPressed: () {
                    docs[index].reference.delete();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add a number',
      ),
    );
  }
}