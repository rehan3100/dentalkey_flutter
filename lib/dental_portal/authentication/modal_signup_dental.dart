import 'package:dental_key/dental_portal/authentication/login_dental.dart';
import 'package:flutter/material.dart';

class DentalProfileApproval extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.only(top: 40.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: SingleChildScrollView(
              // Wrap Column with SingleChildScrollView
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text(
                    'Thank you for sending request to join',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Image.asset(
                    'assets/logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Your credentials have been sent to our admin panel, once approved, you will be notified through your given email within next 24 hours.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'You cannot login until your credentials are under approval. Make sure to reply email immediately, if you’re being contacted regarding your profile approval.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginDental()),
                      );
                      // Add your login function here
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 40.0,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                child: Container(
                  color: Colors.green,
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 32.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
