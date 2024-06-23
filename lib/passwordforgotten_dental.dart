import 'package:dental_key/dental_portal/authentication/login_dental.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DentalPasswordForgot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: EmailField(),
    );
  }
}

class EmailField extends StatefulWidget {
  @override
  _EmailFieldState createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendEmail(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/users/send_reset_code/'),
      body: {'email': _emailController.text},
    );

    if (response.statusCode == 200) {
      // Email sent successfully, navigate to code verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CodeField(email: _emailController.text),
        ),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reset password code')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Enter your email address:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () => _sendEmail(context),
                  child: Text('Send OTP'),
                ),
        ],
      ),
    );
  }
}

class CodeField extends StatefulWidget {
  final String email;

  CodeField({required this.email});

  @override
  _CodeFieldState createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyCode(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/users/verify_reset_code/'),
      body: jsonEncode({
        'email': widget.email,
        'reset_code': _codeController.text,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Code verified successfully, navigate to new password screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordField(
            email: widget.email,
            resetCode: _codeController.text,
          ),
        ),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify reset code')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginDental()),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Enter Code'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Enter the code sent to your email:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Reset Code',
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  // Add validation rules for reset code if needed
                  return null;
                },
              ),
              SizedBox(height: 40),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _verifyCode(context),
                      child: Text('Verify Code'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewPasswordField extends StatefulWidget {
  final String email;
  final String resetCode;

  NewPasswordField({required this.email, required this.resetCode});

  @override
  _NewPasswordFieldState createState() => _NewPasswordFieldState();
}

class _NewPasswordFieldState extends State<NewPasswordField> {
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/users/reset_password/'),
      body: jsonEncode({
        'email': widget.email,
        'reset_code': widget.resetCode,
        'password': _newPasswordController.text,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Password reset successfully, navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginDental()),
        (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password changed successfully')),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset password')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginDental()),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Enter New Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Enter your new password:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                ),
                keyboardType: TextInputType.text,
                obscureText: true,
                validator: (value) {
                  // Add validation rules for new password if needed
                  return null;
                },
              ),
              SizedBox(height: 40),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _resetPassword(context),
                      child: Text('Reset Password'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
