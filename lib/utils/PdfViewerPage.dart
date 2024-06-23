import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PdfViewerPage extends StatefulWidget {
  final String pdfPath;
  final String accessToken;

  const PdfViewerPage(
      {Key? key, required this.pdfPath, required this.accessToken})
      : super(key: key);

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? email;
  String? phoneNumber;
  String? whatsappNumber;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _enableScreenshotRestriction();
    _fetchUserDetails();
  }

  Future<void> _enableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  Future<void> _disableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userDetails = await fetchUserDetails();
      setState(() {
        email = userDetails['email'];
        phoneNumber = userDetails['phone_number'];
        whatsappNumber = userDetails['whatsapp_number'];
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails() async {
    var uri = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/users/details/");
    var response = await http.get(uri, headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  @override
  void dispose() {
    _disableScreenshotRestriction();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                PDFView(
                  filePath: widget.pdfPath,
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Transform.rotate(
                      angle: -0.785398, // 45 degrees in radians
                      child: Text(
                        '$email\n$phoneNumber\n$whatsappNumber',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              30, // Adjust font size to ensure it fits within the screen
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(
                              0.11), // Black color with reduced opacity
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
