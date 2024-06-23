import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/03_my_orders.dart';
import 'package:dental_key/dental_portal/services/career_pathways/CP_dental_my_orders.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/FE_my_orders.dart';
import 'package:dental_key/dental_portal/services/ips_books/dental_my_orders.dart';

class MyOrdersPage extends StatefulWidget {
  final String accessToken;

  MyOrdersPage({required this.accessToken});

  @override
  _MyOrdersPageState createState() =>
      _MyOrdersPageState(accessToken: accessToken);
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final String accessToken;
  bool isLoading = false;
  List<dynamic> bankDetails = [];
  bool showPaymentOptions = false;

  Future<void> fetchBankDetails() async {
    final String apiUrl =
        'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/banks/';

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> fetchedBankDetails = json.decode(response.body);

        // Filter out unpublished bank details
        List<dynamic> publishedBankDetails = fetchedBankDetails
            .where((bank) => bank['publish'] == true)
            .toList();

        setState(() {
          bankDetails = publishedBankDetails;
          isLoading = false;
          showPaymentOptions = true;
        });
      } else {
        print('Failed to fetch bank details: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Failed to fetch bank details: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _generatePdfAndDownload() async {
    final pdf = pw.Document();

    // Load the image from assets
    final imageBytes = await rootBundle.load('assets/logo.png');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Display the image at the top center
              pw.Center(
                child: pw.Image(image, width: 100, height: 100),
              ),
              pw.SizedBox(height: 16.0),
              // Add title
              pw.Center(
                child: pw.Text(
                  'BANK TRANSFER OPTIONS',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue, // Set the color of the text
                  ),
                ),
              ),
              pw.SizedBox(height: 16.0),
              // Check if payment methods are empty and display message
              if (bankDetails.isEmpty)
                pw.Center(
                  child: pw.Text(
                    'Please click on Fetch Payment methods first, then download the list.',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  children: [
                    // Table header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('No.',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Bank Name',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Details',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Table rows
                    ...bankDetails.asMap().entries.map((entry) {
                      int index = entry.key;
                      var bank = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('${index + 1}'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(bank['bank_name']),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                    'Account Holder Name: ${bank['account_holder_name']}'),
                                if (bank['account_number'] != null)
                                  pw.Text(
                                      'Account Number: ${bank['account_number']}'),
                                if (bank['iban'] != null)
                                  pw.Text('IBAN: ${bank['iban']}'),
                                if (bank['swift_bic'] != null)
                                  pw.Text('SWIFT/BIC: ${bank['swift_bic']}'),
                                if (bank['branch_name'] != null)
                                  pw.Text(
                                      'Branch Name: ${bank['branch_name']}'),
                                if (bank['branch_code'] != null)
                                  pw.Text(
                                      'Branch Code: ${bank['branch_code']}'),
                                if (bank['country'] != null)
                                  pw.Text('Country: ${bank['country']}'),
                                if (bank['currency'] != null)
                                  pw.Text('Currency: ${bank['currency']}'),
                                if (bank['additional_information'] != null &&
                                    bank['additional_information'].isNotEmpty)
                                  pw.Text(
                                      'Additional Information: ${bank['additional_information']}'),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'Bank_Transfer_Options.pdf');
  }

  _MyOrdersPageState({required this.accessToken}) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: Stack(
        children: [
          // Background Image Container
          Opacity(
            opacity:
                0.4, // Adjust the opacity to make the background very transparent
            child: Image.asset(
              'assets/images/orders_background.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      OrderCard(
                        title: 'IPS Books',
                        icon: Icons.book,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DentalMyOrders(accessToken: accessToken),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      OrderCard(
                        title: 'Career Pathway Packages',
                        icon: Icons.work,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CPDentalMyOrders(accessToken: accessToken),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      OrderCard(
                        title: 'Undergraduate Tests',
                        icon: Icons.school,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UGTestsOrders(accessToken: accessToken),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      OrderCard(
                        title: 'Postgraduate Exams',
                        icon: Icons.school_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ForeignOrders(accessToken: accessToken),
                            ),
                          );
                        },
                      ),
                      if (isLoading)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 50.0, right: 20.0, left: 20.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      if (showPaymentOptions && !isLoading)
                        Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: bankDetails.length,
                              itemBuilder: (context, index) {
                                var bank = bankDetails[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8.0),
                                        Text(
                                          '${index + 1}. ${bank['bank_name']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          'Account Holder Name: ${bank['account_holder_name']}',
                                          style: TextStyle(
                                              color: Colors.grey[700]),
                                        ),
                                        if (bank['account_number'] != null)
                                          Text(
                                            'Account Number: ${bank['account_number']}',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        if (bank['iban'] != null)
                                          Text(
                                            'IBAN: ${bank['iban']}',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        if (bank['swift_bic'] != null)
                                          Text(
                                            'SWIFT/BIC: ${bank['swift_bic']}',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        if (bank['branch_name'] != null)
                                          Text(
                                            'Branch Name: ${bank['branch_name']}',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        if (bank['branch_code'] != null)
                                          Text(
                                            'Branch Code: ${bank['branch_code']}',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        if (bank['country'] != null)
                                          Text(
                                            'Country: ${bank['country']}',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        if (bank['currency'] != null)
                                          Text(
                                            'Currency: ${bank['currency']}',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        if (bank['additional_information'] !=
                                                null &&
                                            bank['additional_information']
                                                .isNotEmpty)
                                          Text(
                                            'Additional Information: ${bank['additional_information']}',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 10.0, left: 10.0, top: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            fetchBankDetails();
                          },
                          icon: Icon(Icons.search),
                          label: Text('Fetch Bank Transfer Options'),
                        ),
                      ),
                      SizedBox(
                          width: 8), // Add some spacing between the buttons
                      ElevatedButton.icon(
                        onPressed: () {
                          _generatePdfAndDownload();
                        },
                        icon: Icon(Icons.download),
                        label: Text('Download'),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Item {
  Item({
    required this.headerValue,
    required this.expandedValue,
  });

  String headerValue;
  String expandedValue;
}

class OrderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const OrderCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Colors.white, // White icon color
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
