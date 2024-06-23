import 'package:dental_key/dental_portal/mainscreen/chat_with_dr_Rehan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:file_picker/file_picker.dart';

class NewMessagePage extends StatefulWidget {
  final String accessToken;

  NewMessagePage({
    required this.accessToken,
  });

  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  PlatformFile? _pickedFile;
  bool _isLoading = false;
  late String? userUUID;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> payload = Jwt.parseJwt(widget.accessToken);
    userUUID = payload['user_id'] as String?;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (userUUID == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User UUID not found. Unable to submit request.'),
        ));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      print('Form is valid. Preparing to send request...');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/requests/'),
      );
      request.headers['Authorization'] = 'Bearer ${widget.accessToken}';
      request.fields['user'] = userUUID!;
      request.fields['message'] = _messageController.text;
      request.fields['is_read'] =
          'true'; // Add this line to include the is_read field

      if (_pickedFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'attachment',
          _pickedFile!.path!,
        ));
      }

      var response = await request.send();

      print('Response status: ${response.statusCode}');
      response.stream.transform(utf8.decoder).listen((value) {
        print('Response body: $value');
      });

      if (response.statusCode == 201) {
        _messageController.clear();
        setState(() {
          _pickedFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Request submitted successfully!'),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  RehanChatPage(accessToken: widget.accessToken)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to submit request.'),
        ));
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      print('Form is not valid.');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Message'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                labelText: 'Message',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(16.0),
                                hintText:
                                    'Please submit your complete request in a single message. Avoid sending multiple messages.',
                              ),
                              maxLines: 8,
                              minLines: 2,
                              maxLength: 2000,
                              expands: false,
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.top,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your message';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: _pickFile,
                              icon: Icon(Icons.attach_file),
                              label: Text('Attach File'),
                            ),
                            if (_pickedFile != null) Text(_pickedFile!.name),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitRequest,
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text('Submit'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
