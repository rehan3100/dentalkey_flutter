import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({Key? key}) : super(key: key); // Corrected constructor

  @override
  _PdfScreenState createState() => _PdfScreenState(); // Corrected method name
}

class _PdfScreenState extends State<PdfScreen> {
  late PdfController pdfController;
  loadController() {
    pdfController = PdfController(
        document: PdfDocument.openAsset('assets/pdfs/StudentForm_2.pdf'));
  }

  @override
    void initState(){
      super.initState();
      loadController();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filename"), // Removed unnecessary TextStyle
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: PdfView(controller: pdfController),
      ), // You can replace this with your PDF viewer widget
    );
  }
}
