// lib/screens/file_upload_screen.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:whatsapp_sender/providers/campaign_provider.dart';
import 'package:whatsapp_sender/screens/campaign_status_screen.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});
  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final _campaignNameController = TextEditingController();
  final _messageController = TextEditingController();
  double _delayValue = 8.0;
  String? _fileName;
  List<String> _parsedNumbers = [];
  bool _canSubmit = false;
  final String _unsubText = 'Reply "STOP" to unsubscribe.';
  bool _isMessagePristine = true;

  @override
  void initState() {
    super.initState();
    _campaignNameController.addListener(_validateForm);
    _messageController.addListener(_validateForm);
  }

  void _validateForm() {
    final messageBody = _messageController.text.replaceAll(_unsubText, '').trim();
    final isFormValid = _campaignNameController.text.trim().isNotEmpty &&
                        messageBody.isNotEmpty &&
                        _parsedNumbers.isNotEmpty;
    if (_canSubmit != isFormValid) {
      setState(() {
        _canSubmit = isFormValid;
      });
    }
  }

  void _onMessageChanged(String text) {
    if (_isMessagePristine) return;
    String body = text.replaceAll(_unsubText, '').trim();
    String newText = '$body\n\n$_unsubText';
    if (text != newText) {
      _messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: body.length),
      );
    }
  }

  void _onMessageTap() {
    if (_isMessagePristine) {
      setState(() {
        _messageController.text = '\n\n$_unsubText';
        _isMessagePristine = false;
      });
      _messageController.selection = const TextSelection.collapsed(offset: 0);
    }
  }

  @override
  void dispose() {
    _campaignNameController.removeListener(_validateForm);
    _messageController.removeListener(_validateForm);
    _campaignNameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickAndParseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );
    if (result == null) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    List<String> numbers = [];
    try {
      if (file.extension == 'csv') {
        String content;
        if (bytes.length > 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
          content = utf8.decode(bytes.sublist(3));
        } else {
          content = utf8.decode(bytes);
        }
        final rows = const CsvToListConverter(shouldParseNumbers: false).convert(content);
        for (var i = 1; i < rows.length; i++) {
          if (rows[i].isNotEmpty) {
            numbers.add(rows[i][0].toString().trim());
          }
        }
      } else if (file.extension == 'xlsx') {
        var excel = Excel.decodeBytes(bytes);
        var sheet = excel.tables[excel.tables.keys.first];
        if (sheet != null) {
          for (var i = 1; i < sheet.rows.length; i++) {
            final cell = sheet.rows[i].first;
            if (cell != null) {
              numbers.add(cell.value.toString().trim());
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error parsing file: $e")),
      );
    }
    setState(() {
      _fileName = file.name;
      _parsedNumbers = numbers.where((n) => n.trim().startsWith('+')).toList();
    });
    _validateForm();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Campaign from File')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. Campaign Name (Mandatory)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _campaignNameController,
              decoration: const InputDecoration(
                hintText: 'e.g., Festival Greetings',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const Divider(height: 30),
            const Text('2. Select a CSV or Excel File (Mandatory)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Ensure all numbers include a country code (e.g., +91).'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Select File'),
              onPressed: _pickAndParseFile,
            ),
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    'Selected: $_fileName\nFound ${_parsedNumbers.length} valid numbers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _parsedNumbers.isNotEmpty ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const Divider(height: 30),
            const Text('3. Compose Your Message (Mandatory)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              onTap: _onMessageTap,
              onChanged: _onMessageChanged,
              // THIS IS THE FIX
               keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your message here...\n(Use Shift + Enter for new lines on web)', // Added hint
                prefixIcon: Icon(Icons.message_outlined),
              ),
            ),
            const Divider(height: 30),
            Text('4. Set Message Delay: ${_delayValue.toInt()} seconds', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              value: _delayValue,
              min: 5,
              max: 60,
              divisions: 11,
              label: '${_delayValue.toInt()}s',
              onChanged: (value) {
                setState(() {
                  _delayValue = value;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded),
                label: const Text('Start Campaign'),
                onPressed: _canSubmit ? () {
                  Provider.of<CampaignProvider>(context, listen: false).setupCampaign(
                    campaignName: _campaignNameController.text.trim(),
                    numbers: _parsedNumbers,
                    message: _messageController.text.trim(),
                    delay: _delayValue.toInt(),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CampaignStatusScreen()),
                  );
                } : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}