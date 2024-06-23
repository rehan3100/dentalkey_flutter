import 'package:dental_key/dental_portal/authentication/login_dental.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AccountDeletionPage extends StatefulWidget {
  @override
  _AccountDeletionPageState createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  bool _isDeleting = false;
  String _confirmationText = '';
  final TextEditingController _controller = TextEditingController();

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(
        'accessToken'); // Ensure you use the correct key for access token

    if (token == null) {
      // Handle missing token
      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found.')),
      );
      return;
    }

    final response = await http.delete(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/users/api/delete-account/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    setState(() {
      _isDeleting = false;
    });

    if (response.statusCode == 200) {
      // Handle successful account deletion
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginDental()),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete account: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Account'),
      ),
      body: Center(
        child: _isDeleting
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'To confirm account deletion, please enter "CONFIRM" below:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      onChanged: (value) {
                        setState(() {
                          _confirmationText = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter CONFIRM',
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _confirmationText == 'CONFIRM'
                          ? _deleteAccount
                          : null, // Disable button if text is not 'CONFIRM'
                      child: Text('Delete Account'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
