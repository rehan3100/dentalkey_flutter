import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final String accessToken;

  const PDFViewerScreen(
      {Key? key,
      required this.pdfUrl,
      required this.title,
      required this.accessToken})
      : super(key: key);

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool isLoading = true;
  String? localFilePath;
  String? email;
  String? phoneNumber;
  String? whatsappNumber;

  @override
  void initState() {
    super.initState();
    _enableScreenshotRestriction();
    _downloadAndSavePdf();
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

  Future<void> _downloadAndSavePdf() async {
    try {
      print('Downloading PDF from URL: ${widget.pdfUrl}');
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        print('PDF fetched successfully.');
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/temp.pdf');
        await file.writeAsBytes(bytes);
        setState(() {
          localFilePath = file.path;
          isLoading = false;
        });
        print('PDF saved to local path: $localFilePath');
      } else {
        print('Failed to download PDF. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userDetails = await fetchUserDetails();
      setState(() {
        email = userDetails['email'];
        phoneNumber = userDetails['phone_number'];
        whatsappNumber = userDetails['whatsapp_number'];
      });
    } catch (e) {
      print(e);
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
        title: Text(widget.title),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : localFilePath != null
              ? Stack(
                  children: [
                    PDFView(
                      filePath: localFilePath!,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: false,
                      onRender: (_pages) {
                        print('Document rendered');
                      },
                      onError: (error) {
                        print('Error rendering document: $error');
                      },
                      onPageError: (page, error) {
                        print('Error on page $page: $error');
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        print('PDF View created');
                      },
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
                )
              : Center(child: Text('Failed to load PDF')),
    );
  }
}
