import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:dental_key/dental_portal/services/career_pathways/CP_dental_my_orders.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class CPBankTransferForm extends StatefulWidget {
  final String userId;
  final String orderId;
  final String orderprice;
  final String accessToken;

  CPBankTransferForm({
    required this.userId,
    required this.orderId,
    required this.orderprice,
    required this.accessToken,
  });

  @override
  _CPBankTransferFormState createState() =>
      _CPBankTransferFormState(accessToken: accessToken);
}

class _CPBankTransferFormState extends State<CPBankTransferForm> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _bankNameController = TextEditingController();
  String? selectedBankTransferOption;
  List<String> bankTransferOptions = [];
  Map<String, String> bankTransferOptionsMap = {};
  final TextEditingController orderpriceController = TextEditingController();
  bool isLoading = false; // Add this state variable
  List<dynamic> bankDetails = [];
  bool showPaymentOptions = false;
  bool optionsisLoading = false;

  String getSelectedBankTransferCode() {
    return bankTransferOptionsMap[selectedBankTransferOption]!;
  }

  final String accessToken;
  _CPBankTransferFormState({required this.accessToken});

  @override
  void initState() {
    super.initState();
    fetchBankTransferOptions();
    orderpriceController.text = widget.orderprice;
  }

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

  Future<void> fetchBankTransferOptions() async {
    try {
      final Uri apiUrl = Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/bank_transfer_options/');
      final http.Response response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          bankTransferOptions = data
              .map<String>((option) => option['option'].toString())
              .toList();
          bankTransferOptionsMap = {
            for (var option in data)
              option['option'].toString(): option['id'].toString()
          };
        });
      } else {
        print(
            'Failed to fetch bank transfer options: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching bank transfer options: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Transfer Form'),
      ),
      body: Stack(children: [
        // Background image with transparency
        Opacity(
          opacity: 0.2, // Set the desired opacity here
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cards.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Main content
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'User ID: ${widget.userId}',
                        style: TextStyle(fontSize: 14), // Set text size
                      ),
                      Text(
                        'Order ID: ${widget.orderId}',
                        style: TextStyle(
                          fontSize: 14,
                        ), // Set text size
                      ),
                      Text(
                        'Price: GBP ${orderpriceController.text}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold), // Set text size
                      ),
                      SizedBox(
                        height: 10,
                      ),
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
                      if (optionsisLoading)
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      if (showPaymentOptions && !optionsisLoading)
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
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedBankTransferOption,
                        decoration: InputDecoration(labelText: 'Paid in'),
                        onChanged: (value) {
                          setState(() {
                            selectedBankTransferOption = value;
                          });
                        },
                        items: bankTransferOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _bankNameController,
                        decoration:
                            InputDecoration(labelText: 'Your Bank Name'),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: getImage,
                            child: Text('Select Image'),
                          ),
                          SizedBox(width: 20),
                          _image == null
                              ? Text('No image selected.')
                              : Image.file(
                                  _image!,
                                  height: 150,
                                ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.grey[200], // Light grey background color
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      isLoading
                          ? CircularProgressIndicator() // Show loader if loading
                          : ElevatedButton(
                              onPressed: submitForm,
                              child: Text('Submit'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ]),
    );
  }

  Future<void> getImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Image selected: ${_image!.path}');
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> submitForm() async {
    final Uri apiUrl = Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/bank_payment/');

    if (selectedBankTransferOption == null) {
      print('Please select a bank transfer option.');
      return;
    }

    setState(() {
      isLoading = true; // Show loader when starting submission
    });

    print('Submitting form...');
    print('User ID: ${widget.userId}');
    print('Order ID: ${widget.orderId}');
    print('Order Price: ${widget.orderprice}');
    print('Bank Transfer Option: ${getSelectedBankTransferCode()}');
    print('Bank Name: ${_bankNameController.text}');

    var request = http.MultipartRequest('POST', apiUrl);
    request.headers['Authorization'] = 'Bearer ${widget.accessToken}';

    // Add form fields
    request.fields['user'] = widget.userId;
    request.fields['PackageOrdered'] = widget.orderId;
    request.fields['package_order_total_price'] = widget.orderprice;
    request.fields['bank_transfer_options'] = getSelectedBankTransferCode();
    request.fields['bank_name'] = _bankNameController.text;

    // Add image file
    if (_image != null) {
      print('Adding image to request: ${_image!.path}');
      request.files.add(await http.MultipartFile.fromPath(
        'payment_screenshot',
        _image!.path,
        filename: 'payment_screenshot.jpg',
        contentType: MediaType('image', 'jpg'),
      ));
    } else {
      print('No image selected.');
      setState(() {
        isLoading = false; // Hide loader if no image is selected
      });
      return;
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('Payment successful');

        // Update order status
        final updateOrderStatusUrl = Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/api/v1/orders/${widget.orderId}/update_status/');
        final updateOrderResponse = await http.post(
          updateOrderStatusUrl,
          headers: {'Authorization': 'Bearer ${widget.accessToken}'},
          body: {'package_order_status': 'PD'},
        );

        print(
            'Update order status response: ${updateOrderResponse.statusCode}');
        print('Update order status response body: ${updateOrderResponse.body}');

        if (updateOrderResponse.statusCode == 200) {
          print('Order status updated successfully');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CPDentalMyOrders(accessToken: accessToken)),
          );
        } else {
          print(
              'Failed to update order status: ${updateOrderResponse.reasonPhrase}');
        }
      } else {
        print('Failed to make payment: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error submitting form: $e');
    } finally {
      setState(() {
        isLoading = false; // Hide loader when submission is complete
      });
    }
  }
}
