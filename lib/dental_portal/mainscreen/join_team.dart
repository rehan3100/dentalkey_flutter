import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class JoinTeam extends StatefulWidget {
  @override
  _JoinTeamState createState() => _JoinTeamState();
}

class _JoinTeamState extends State<JoinTeam> {
  final TextEditingController _messageController = TextEditingController();
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _loadAccessToken();
  }

  Future<void> _loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('accessToken');
    });
  }

  Future<void> _submitForm() async {
    final message = _messageController.text;
    if (message.isNotEmpty && _accessToken != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_accessToken!);
      String userId = decodedToken[
          'user_id']; // Assuming 'user_id' is the key in your token

      final response = await http.post(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/join-team/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(<String, String>{
          'message': message,
          'user': userId, // Include the user ID in the request
        }),
      );

      if (response.statusCode == 201) {
        // Clear the message field
        _messageController.clear();
        // Close the keyboard
        FocusScope.of(context).unfocus();
        // Show the pop-up message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Request Submitted'),
              content: Text(
                  'Thank you for your interest in joining our team. Your application has been successfully submitted. Our team will review your application, and one of our representatives will contact you soon to schedule an interview.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        print('Success: ${response.body}');
      } else {
        print('Failed to submit: ${response.body}');
      }
    } else {
      print('Message is empty or access token is not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Team'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please explain about yourself and how do you think that you are capable to join this team?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _messageController,
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
