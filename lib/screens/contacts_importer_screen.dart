// lib/screens/contacts_importer_screen.dart
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_sender/screens/manual_input_screen.dart';
import 'package:whatsapp_sender/theme/app_theme.dart';

class ContactsImporterScreen extends StatefulWidget {
  const ContactsImporterScreen({super.key});

  @override
  State<ContactsImporterScreen> createState() => _ContactsImporterScreenState();
}

class _ContactsImporterScreenState extends State<ContactsImporterScreen> {
  List<Contact> _contacts = [];
  List<Contact> _selectedContacts = [];
  bool _isLoading = true;
  String _statusMessage = 'Loading contacts...';

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  Future<void> _getContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      final contacts = await ContactsService.getContacts(withThumbnails: false);
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } else {
      setState(() {
        _statusMessage = 'Permission denied. Please enable contacts permission in your phone settings.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Contacts'),
        actions: [
          // Show the 'Next' button only if contacts are selected
          if (_selectedContacts.isNotEmpty)
            TextButton(
              onPressed: () {
                final selectedNumbers = _selectedContacts
                    .map((c) => c.phones?.first.value) // Get the first phone number
                    .where((p) => p != null) // Filter out any nulls
                    .cast<String>()
                    .toList();

                // Navigate to the manual input screen, pre-filling the numbers
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManualInputScreen(
                      initialNumbers: selectedNumbers,
                    ),
                  ),
                );
              },
              child: Text('Next (${_selectedContacts.length})'),
            )
        ],
      ),
      body: _isLoading
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(_statusMessage)]))
          : _contacts.isEmpty
              ? Center(child: Text(_statusMessage))
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    // Only show contacts that have at least one phone number
                    if (contact.phones == null || contact.phones!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final isSelected = _selectedContacts.contains(contact);
                    return ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedContacts.add(contact);
                            } else {
                              _selectedContacts.remove(contact);
                            }
                          });
                        },
                      ),
                      title: Text(contact.displayName ?? 'No Name'),
                      subtitle: Text(contact.phones!.first.value ?? 'No number'),
                    );
                  },
                ),
    );
  }
}