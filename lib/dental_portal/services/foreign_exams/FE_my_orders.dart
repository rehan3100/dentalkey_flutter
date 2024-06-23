import 'package:dental_key/dental_portal/mainscreen/dental-account.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/foreignexams_BankTransferform.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ForeignOrders extends StatefulWidget {
  final String accessToken;

  const ForeignOrders({Key? key, required this.accessToken}) : super(key: key);

  @override
  _ForeignOrdersState createState() =>
      _ForeignOrdersState(accessToken: accessToken);
}

class _ForeignOrdersState extends State<ForeignOrders> {
  List<dynamic> requests = [];
  bool isLoading = true;
  List<dynamic> bankDetails = [];
  bool showPaymentOptions = false;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  final Map<String, String> paymentMethodMap = {
    'OB': 'Online Bank Transfer',
    'BB': 'Card Payment',
    'PP': 'Get Package Mock',
  };

  Future<void> fetchBankDetails() async {
    setState(() {
      isLoading = true;
    });

    final String apiUrl =
        'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/banks/';

    try {
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

  Future<void> fetchRequests() async {
    final String apiUrl =
        'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/user_requests/?quiz_category=6c1d0439-39b0-4fe9-aaea-377a79c4ccaa';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> fetchedRequests = json.decode(response.body);

        // Sort requests by order date in descending order (latest first)
        fetchedRequests.sort((a, b) => DateTime.parse(b['request_date'])
            .compareTo(DateTime.parse(a['request_date'])));

        setState(() {
          requests = fetchedRequests;
          isLoading = false;
        });
      } else {
        print('Failed to fetch requests: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Failed to fetch requests: $error');
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

  final String accessToken;
  _ForeignOrdersState({required this.accessToken});
  Future<void> refreshpage() async {
    await fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to the desired screen on back press
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DentalAccount(
              accessToken: accessToken,
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Postgraduate Exams Orders'),
        ),
        body: RefreshIndicator(
          onRefresh: refreshpage,
          child: Stack(children: [
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
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 20.0, left: 20.0, top: 3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    fetchBankDetails();
                                  },
                                  child: Text('Fetch Bank Transfer Options'),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      8), // Add some spacing between the buttons
                              IconButton(
                                onPressed: () {
                                  _generatePdfAndDownload();
                                },
                                icon: Icon(Icons.download),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.0),
                        if (isLoading) CircularProgressIndicator(),
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
                        Divider(), // Separate requests from bank details

                        requests.isEmpty
                            ? Center(
                                child:
                                    Text('You have not placed any order yet.'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  int serialNumber = requests.length -
                                      index; // Reverse serial number
                                  return Padding(
                                    padding:
                                        EdgeInsets.all(8.0), // Add padding here
                                    child: SizedBox(
                                      width: double
                                          .infinity, // Set width to occupy available space
                                      child: Card(
                                        color: Color.fromARGB(255, 193, 222,
                                            247), // Set background color here
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Serial Number: $serialNumber'), // Use generated serial number
                                                  Text('Quiz(zes) selected:'),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: List.generate(
                                                      requests[index][
                                                              'selected_titles']
                                                          .length,
                                                      (quizIndex) => Text(
                                                          '- ${requests[index]['selected_titles'][quizIndex]}'),
                                                    ),
                                                  ),
                                                  Text(
                                                      'Date & Time: ${_formatDateTime(requests[index]['request_date'])}'),
                                                  Text(
                                                      'Total Price: ${requests[index]['request_total_price']}'),
                                                  Text(
                                                      'Chosen Payment Method: ${_formatPaymentMethod(requests[index]['payment_method'])}'),
                                                  Text(
                                                      'Current Order Status: ${requests[index]['request_status']}'),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 8.0,
                                                  right: 10.0,
                                                  left:
                                                      10.0), // Add top and bottom padding here
                                              child: Container(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: requests[index][
                                                              'request_order_status'] !=
                                                          'AP'
                                                      ? null // Set to null to make the button unclickable
                                                      : () {
                                                          // Perform action for unpaid order
                                                          String userId =
                                                              requests[index]
                                                                  ['user'];
                                                          String orderId =
                                                              requests[index][
                                                                  'request_id'];
                                                          String orderPrice =
                                                              requests[index][
                                                                      'request_total_price']
                                                                  .toString();
                                                          print(
                                                              'Order is Awaiting Payment: ${requests[index]['request_order_status']}');

                                                          // Check the chosen payment method
                                                          String paymentMethod =
                                                              requests[index][
                                                                  'payment_method'];

                                                          // Navigate to different screens based on payment method
                                                          if (paymentMethod ==
                                                              'BB') {
                                                            // Navigate to Card Payment Screen (replace with your actual screen)
                                                          } else {
                                                            // Navigate to BankTransferFormScreen (replace with your actual screen)
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        FEBankTransferForm(
                                                                  userId:
                                                                      userId,
                                                                  orderId:
                                                                      orderId,
                                                                  orderprice:
                                                                      orderPrice,
                                                                  accessToken:
                                                                      accessToken,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                  child: Text(requests[index][
                                                              'request_order_status'] !=
                                                          'AP'
                                                      ? 'Paid'
                                                      : 'Pay Now'),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .pressed)) {
                                                          return Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255); // Color when pressed
                                                        }
                                                        return Color(
                                                            0xFF385A92); // Default color
                                                      },
                                                    ),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .pressed)) {
                                                          return Color(
                                                              0xFF385A92); // Text and Icon color when pressed
                                                        }
                                                        return Color.fromARGB(
                                                            255,
                                                            255,
                                                            255,
                                                            255); // Default text color
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
          ]),
        ),
      ),
    );
  }

  // Format payment method function to map abbreviation to full name
  String _formatPaymentMethod(String abbreviation) {
    return paymentMethodMap[abbreviation] ?? abbreviation;
  }

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
