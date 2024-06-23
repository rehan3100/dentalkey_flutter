import 'dart:io';
import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/main.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dental_key/dental_portal/services/BDS_World/BDS_World.dart';
import 'package:dental_key/dental_portal/services/career_pathways/career_pathways_homepage.dart';
import 'package:dental_key/dental_portal/services/display_dental_clinic/Display_dental_clinic.dart';
import 'package:dental_key/dental_portal/services/ips_books/IPS_Books.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/01_tests_homepage.dart';
import 'package:dental_key/dental_portal/services/ug_helping_material/UG_helping_material.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_withdr_rehan.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:dental_key/dental_portal/services/video_guidelines/video_guidelines.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart'; // Add this line
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart'
    as file_picker_flutter; // Assuming your prefix is file_picker_flutter
import 'package:http_parser/http_parser.dart';

class DKLlibrary extends StatefulWidget {
  final String accessToken;

  DKLlibrary({required this.accessToken});

  @override
  _DKLlibraryState createState() => _DKLlibraryState();
}

class _DKLlibraryState extends State<DKLlibrary> {
  String? selectedMaterialNature;
  String? userUuid;
  bool isLoading = false;
  int _selectedIndex = 0;
  TextEditingController _bookSearchController = TextEditingController();
  TextEditingController _articleSearchController = TextEditingController();
  TextEditingController _uploadController =
      TextEditingController(); // Define _uploadController
  TextEditingController _requestController =
      TextEditingController(); // Define _requestController
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  String selectedCategory = ''; // Define selectedCategory
  TextEditingController additionalInfoController = TextEditingController();
  TextEditingController titleControllerforupload = TextEditingController();
  TextEditingController authorControllerforupload = TextEditingController();
  String selectedCategoryforupload = '';
  TextEditingController proposedCategoryController = TextEditingController();
  File? selectedFile; // Use nullable type for selectedFile
  String? fileName;
  TextEditingController publicationDateController =
      TextEditingController(); // Added
  DateTime? selectedPublicationDate;
  List<dynamic> books = [];
  List<dynamic> articles = [];
  List<String> categories = ['Uncategorized'];
  List<String> materialNatureLabels = []; // Define materialNatureLabels
  final Map<String, String> materialNatureValues = {
    'Book': 'B',
    'Article': 'A',
  };

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/dental_key_library/categories/'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<String> categoryNames = data.map<String>((category) {
        return category['name'];
      }).toList();
      setState(() {
        categories = categoryNames;
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> fetchMaterialNature() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/dental_key_library/material_nature/'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> materialNatureOptions =
          List<Map<String, dynamic>>.from(data);
      materialNatureLabels = materialNatureOptions.map<String>((option) {
        return option['label']; // Use 'label' instead of 'value'
      }).toList();
      setState(() {
        selectedMaterialNature =
            materialNatureLabels.isNotEmpty ? materialNatureLabels[0] : '';
      });
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load material nature options');
    }
  }

  Future<void> fetchBooks() async {
    try {
      print("Fetching books...");

      final response = await http.get(
        Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/dental_key_library/books/?search=${_bookSearchController.text.trim()}',
        ),
        headers: {
          "Authorization": "Bearer ${widget.accessToken}",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> modifiedBooks =
            data.map<Map<String, dynamic>>(
          (book) {
            book['uploaded_by'] = book['uploaded_by']['full_name'];
            book['category'] = book['category']['name'];
            return book;
          },
        ).toList();

        print("Books before filtering: $modifiedBooks");

        setState(() {
          books = modifiedBooks;
        });

        print("Books after filtering: $books");
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print("Error fetching books: $e");
    }
  }

  Future<void> fetchArticles() async {
    try {
      print("Fetching articles...");
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/dental_key_library/articles/?search=${_articleSearchController.text.trim()}'),
        headers: {
          "Authorization": "Bearer ${widget.accessToken}",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> modifiedArticles =
            data.map<Map<String, dynamic>>((article) {
          article['uploaded_by'] = article['uploaded_by']['full_name'];
          article['category'] = article['category']['name'];
          return article;
        }).toList();
        print("Articles before filtering: $modifiedArticles");

        setState(() {
          articles = modifiedArticles;
        });

        print("Articles after filtering: $articles");
      } else {
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      print("Error fetching articles: $e");
    }
  }

  Future<void> viewbookFile(String bookId) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/dental_key_library/books/$bookId/file'),
        headers: {
          "Authorization": "Bearer ${widget.accessToken}",
        },
      );

      if (response.statusCode == 301 || response.statusCode == 302) {
        final redirectUrl = response.headers['location'];

        final redirectResponse = await http.get(
          Uri.parse(redirectUrl!),
          headers: {
            "Authorization": "Bearer ${widget.accessToken}",
          },
        );

        if (redirectResponse.statusCode == 200) {
          await _handleFileDownload(redirectResponse);
        } else {
          print(
              "Failed to fetch the book file data after redirect: ${redirectResponse.statusCode}");
          print("Response body: ${redirectResponse.body}");
        }
      } else if (response.statusCode == 200) {
        await _handleFileDownload(response);
      } else {
        print("Failed to fetch the book file data: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching file: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> viewarticleFile(String articleId) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/dental_key_library/articles/$articleId/file'),
        headers: {
          "Authorization": "Bearer ${widget.accessToken}",
        },
      );

      if (response.statusCode == 301 || response.statusCode == 302) {
        final redirectUrl = response.headers['location'];

        final redirectResponse = await http.get(
          Uri.parse(redirectUrl!),
          headers: {
            "Authorization": "Bearer ${widget.accessToken}",
          },
        );

        if (redirectResponse.statusCode == 200) {
          await _handleFileDownload(redirectResponse);
        } else {
          print(
              "Failed to fetch the article file data after redirect: ${redirectResponse.statusCode}");
          print("Response body: ${redirectResponse.body}");
        }
      } else if (response.statusCode == 200) {
        await _handleFileDownload(response);
      } else {
        print("Failed to fetch the article file data: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching file: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleFileDownload(http.Response response) async {
    var tempDir = await getTemporaryDirectory();
    var file = File('${tempDir.path}/example.pdf');
    await file.writeAsBytes(response.bodyBytes);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(filePath: file.path),
      ),
    ).then((_) {
      setState(() {
        isLoading = false;
      });
    });
    print("Navigating to PDFViewerScreen with file path: ${file.path}");
  }

  void showBookDetails(BuildContext context, Map<String, dynamic> book) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Author:',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${book['author']}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category:',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${book['category']}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Publication Year:',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${book['publication_year']}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Uploaded By:',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${book['uploaded_by']}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Close the bottom modal sheet
                    setState(() {
                      isLoading = true;
                    });
                    await viewbookFile(book['id']);
                  },
                  child: Text('View File'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showArticleDetails(BuildContext context, Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Author:',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${article['author']}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category:',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${article['category']}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Publication Year:',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${article['publication_year']}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Uploaded By:',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${article['uploaded_by']}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Close the bottom modal sheet
                    setState(() {
                      isLoading = true;
                    });
                    await viewarticleFile(article['id']);
                  },
                  child: Text('View File'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
    fetchArticles();
    fetchCategories(); // Add this line
    fetchMaterialNature(); // Add this line
    selectedCategory = categories.isNotEmpty
        ? categories[0]
        : ''; // Initialize selectedCategory
  }

  Future<void> _sendMaterialRequest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      Map<String, dynamic> payload = Jwt.parseJwt(accessToken!);
      userUuid = payload['user_id'];

      print("Inside _sendMaterialRequest");
      final url =
          'https://dental-key-738b90a4d87a.herokuapp.com/dental_key_library/material-request/';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.accessToken}',
      };

      final data = {
        // Use the map to get the value to be sent to the backend
        "material_nature": materialNatureValues[selectedMaterialNature!]!,
        "title": titleController.text,
        "author": authorController.text,
        "category": selectedCategory,
        "additional_information": additionalInfoController.text,
        "requested_by": userUuid,
      };

      print("Data to be sent: $data");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      );

      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 201) {
        print("Material request sent successfully");
        _showDialog(); // Show dialog upon successful submission
      } else {
        print("Failed to send material request");
      }
    } catch (e, stackTrace) {
      print("Error sending material request: $e");
      print(stackTrace);
    }
  }

  // Function to show the dialog
  Future<void> _showDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Request Submitted"),
          content: Text("Your material request has been submitted."),
          actions: [
            TextButton(
              onPressed: () {
                // Clear all input fields
                titleController.clear();
                authorController.clear();
                additionalInfoController.clear();
                // You can add similar lines to clear other fields
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DentalPortalMain(accessToken: widget.accessToken),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      final result = await file_picker_flutter.FilePicker.platform.pickFiles(
        type: file_picker_flutter.FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final fileName = path.basename(file.path);
        setState(() {
          selectedFile = file;
          this.fileName = fileName;
        });
      } else {
        print("No file selected");
      }
    } catch (e) {
      print("Error selecting file: $e");
    }
  }

  Future<void> _uploadFile(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        print("Access token not found");
        return;
      }

      final Map<String, dynamic> payload = Jwt.parseJwt(accessToken!);
      final userUuid = payload['user_id'];

      print("userUuid: $userUuid");
      print("selectedFile: $selectedFile");

      if (selectedFile == null) {
        print("No file selected");
        return;
      }

      if (userUuid == null) {
        print("User ID is null. Fetching user ID...");
        // Fetch user ID
        // For example:
        // final userUuid = await fetchUserUuid();
        // You need to implement fetchUserUuid() function to fetch user ID
        return;
      }

      final url = Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/dental_key_library/user-upload/');
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      // Prepare data to be sent
      final Map<String, String> data = {
        "title": titleControllerforupload.text,
        "author": authorControllerforupload.text,
        "category": selectedCategoryforupload,
        "material_nature": selectedMaterialNature!,
        "publication_date": publicationDateController.text, // Added
        "proposed_category": proposedCategoryController.text,
        "uploaded_by": userUuid,
      };

      // Create multipart request for the file
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(headers)
        ..fields.addAll(data)
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          selectedFile!.path,
          filename: path.basename(selectedFile!.path),
          contentType: MediaType('application', 'pdf'),
        ));

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print("PDF uploaded successfully");
        // Show dialog box
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Upload Successful"),
              content: Text("PDF uploaded successfully"),
              actions: [
                TextButton(
                  onPressed: () {
                    // Clear all the fields
                    titleControllerforupload.clear();
                    authorControllerforupload.clear();
                    proposedCategoryController.clear();
                    setState(() {
                      selectedFile = null;
                      fileName = null; // Clear fileName
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        print("Failed to upload PDF");
      }
    } catch (e) {
      print("Error uploading PDF: $e");
    }
  }

  Future<void> refreshpage() async {
    await fetchBooks();
    await fetchArticles();
    await fetchCategories(); // Add this line
    await fetchMaterialNature(); // Add this line
    ;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToHomePage();
        return false;
      },
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: refreshpage,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Container 1: containing asset image
                    Container(
                      width: 150,
                      height: 300,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: Color(0xFF385A92),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/free_books.png',
                                width: 150,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                      thickness: 3.0,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DentalPortalMain(
                                            accessToken: widget.accessToken)),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_back,
                                      size: 30,
                                      color: Colors.black,
                                    ),
                                    Icon(
                                      Icons.home,
                                      size: 30,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            _buildContainer(
                              Image.asset(
                                'assets/images/BDS_World_logo.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BDSWorld(
                                          accessToken: widget.accessToken)),
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            _buildContainer(
                              Image.asset(
                                'assets/images/ips_logo.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          IPS(accessToken: widget.accessToken)),
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            _buildContainer(
                              Image.asset(
                                'assets/images/career_options.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DentalCareerPathways(
                                              accessToken: widget.accessToken)),
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            _buildContainer(
                              Image.asset(
                                'assets/images/mock_exams.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForeignMockExam(
                                          accessToken: widget.accessToken)),
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            _buildContainer(
                              Image.asset(
                                'assets/images/UGTests.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ugTestsExams(
                                          accessToken: widget.accessToken)),
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            _buildContainer(
                              Image.asset(
                                'assets/images/helping_material.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ugHelpingMaterial(
                                          accessToken: widget.accessToken)),
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            _buildContainer(
                              Image.asset(
                                'assets/images/multimedia.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => videoguidelines(
                                          accessToken: widget.accessToken)),
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            _buildContainer(
                              Image.asset(
                                'assets/images/dental_unit.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => displayDentalClinic(
                                          accessToken: widget.accessToken)),
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            _buildContainer(
                              Image.asset(
                                'assets/images/rehanappointment.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          appointmentswithdrrehan(
                                              accessToken: widget.accessToken)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0, bottom: 20),
                      child: Container(
                        width: 150,
                        height: 1,
                        color: Colors.black, // Color of the line
                      ),
                    ),
                    const Center(
                      child: Text(
                        'DENTAL KEY LIBRARY',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration:
                              TextDecoration.underline, // Underline text
                        ),
                        textAlign: TextAlign.center, // Align text centrally
                      ),
                    ),
                    _selectedIndex == 0
                        ? Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, left: 15.0, top: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 2.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller:
                                                      _bookSearchController,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: "Search Books",
                                                    border: InputBorder
                                                        .none, // No border
                                                    enabledBorder: InputBorder
                                                        .none, // No border when enabled
                                                    focusedBorder: InputBorder
                                                        .none, // No border when focused
                                                    errorBorder: InputBorder
                                                        .none, // No border when there's an error
                                                    disabledBorder: InputBorder
                                                        .none, // No border when disabled
                                                    prefixIcon: Icon(
                                                        Icons.search,
                                                        color: Colors.grey),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 15.0),
                                                  ),
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  onSubmitted: (value) {
                                                    fetchBooks(); // Call fetchBooks() when search is submitted
                                                    // Close the keyboard
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  fetchBooks(); // Call fetchBooks() when search button is pressed
                                                  // Close the keyboard
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                },
                                                style: ButtonStyle(
                                                  shape:
                                                      MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18.0),
                                                    ),
                                                  ),
                                                ),
                                                child: Text("Search"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: books.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return buildCardBooks(context, index);
                                  },
                                ),
                              ],
                            ),
                          )
                        : _selectedIndex == 1
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Material Nature',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 2.0,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 2.0,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                      ),
                                      value: selectedMaterialNature,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedMaterialNature = newValue!;
                                        });
                                      },
                                      items: materialNatureLabels
                                          .map<DropdownMenuItem<String>>(
                                        (String materialNature) {
                                          return DropdownMenuItem<String>(
                                            value: materialNature,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: Text(materialNature),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                      dropdownColor: Colors.white,
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: titleControllerforupload,
                                      decoration: InputDecoration(
                                        labelText: 'Title',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 2.0,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 2.0,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: authorControllerforupload,
                                      decoration: InputDecoration(
                                        labelText: 'Author',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 2.0,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 2.0,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      value: selectedCategory,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedCategory = newValue!;
                                        });
                                      },
                                      items: categories
                                          .map<DropdownMenuItem<String>>(
                                              (String category) {
                                        return DropdownMenuItem<String>(
                                          value: category,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            child: Text(category),
                                          ),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'Category',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 2.0,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 2.0,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                      ),
                                      dropdownColor: Colors.white,
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: proposedCategoryController,
                                      decoration: InputDecoration(
                                        labelText: 'Proposed Category',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 2.0,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 2.0,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: publicationDateController,
                                      decoration: InputDecoration(
                                        labelText: 'Publication Date',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Color(0xFF385A92),
                                            width: 2.0,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 2.0,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.calendar_today),
                                          onPressed: () {
                                            _selectPublicationDate(context);
                                          },
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: _selectFile,
                                          child: Text("Select File"),
                                        ),
                                        SizedBox(width: 10),
                                        Text(fileName ?? ""),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => _uploadFile(context),
                                        child: Text("Upload File"),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _selectedIndex == 2
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Material Nature',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 2.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2.0,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal:
                                                    12.0), // Add horizontal padding
                                          ),
                                          value: selectedMaterialNature,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedMaterialNature =
                                                  newValue!;
                                            });
                                          },
                                          items: materialNatureLabels
                                              .map<DropdownMenuItem<String>>(
                                            (String materialNature) {
                                              return DropdownMenuItem<String>(
                                                value: materialNature,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal:
                                                          12.0), // Add padding to the DropdownMenuItem
                                                  child: Text(materialNature),
                                                ),
                                              );
                                            },
                                          ).toList(),
                                          dropdownColor: Colors
                                              .white, // Set the dropdown menu background color to white
                                        ),
                                        SizedBox(height: 10),
                                        TextField(
                                          controller: titleController,
                                          decoration: InputDecoration(
                                            labelText: 'Title',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 2.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2.0,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal:
                                                    12.0), // Add horizontal padding
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        TextField(
                                          controller: authorController,
                                          decoration: InputDecoration(
                                            labelText: 'Author',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 2.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2.0,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal:
                                                    12.0), // Add horizontal padding
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        DropdownButtonFormField<String>(
                                          value: selectedCategory,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedCategory = newValue!;
                                            });
                                          },
                                          items: categories
                                              .map<DropdownMenuItem<String>>(
                                                  (String category) {
                                            return DropdownMenuItem<String>(
                                              value: category,
                                              child: Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal:
                                                        12.0), // Add padding to the DropdownMenuItem
                                                child: Text(category),
                                              ),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            labelText: 'Category',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 2.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2.0,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal:
                                                    12.0), // Add horizontal padding
                                          ),
                                          dropdownColor: Colors
                                              .white, // Set the dropdown menu background color to white
                                        ),
                                        SizedBox(height: 10),
                                        TextField(
                                          controller: additionalInfoController,
                                          decoration: InputDecoration(
                                            labelText: 'Additional Information',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF385A92),
                                                width: 2.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2.0,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal:
                                                    12.0), // Add horizontal padding
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(
                                          width: double
                                              .infinity, // Make the button take the full width
                                          child: ElevatedButton(
                                            onPressed: _sendMaterialRequest,
                                            child: Text("Request"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _selectedIndex == 3
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            right: 15.0, left: 15.0, top: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30.0),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 2,
                                                          blurRadius: 5,
                                                          offset: Offset(0,
                                                              3), // changes position of shadow
                                                        ),
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 2.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: TextField(
                                                              controller:
                                                                  _articleSearchController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                hintText:
                                                                    "Search Articles",
                                                                border: InputBorder
                                                                    .none, // No border
                                                                enabledBorder:
                                                                    InputBorder
                                                                        .none, // No border when enabled
                                                                focusedBorder:
                                                                    InputBorder
                                                                        .none, // No border when focused
                                                                errorBorder:
                                                                    InputBorder
                                                                        .none, // No border when there's an error
                                                                disabledBorder:
                                                                    InputBorder
                                                                        .none, // No border when disabled
                                                                prefixIcon: Icon(
                                                                    Icons
                                                                        .search,
                                                                    color: Colors
                                                                        .grey),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        vertical:
                                                                            15.0),
                                                              ),
                                                              textAlignVertical:
                                                                  TextAlignVertical
                                                                      .center,
                                                              onSubmitted:
                                                                  (value) {
                                                                fetchArticles(); // Call fetchArticles() when search is submitted
                                                                // Close the keyboard
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                              },
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              fetchArticles(); // Call fetchArticles() when search button is pressed
                                                              // Close the keyboard
                                                              FocusScope.of(
                                                                      context)
                                                                  .unfocus();
                                                            },
                                                            style: ButtonStyle(
                                                              shape: MaterialStateProperty
                                                                  .all<
                                                                      RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              18.0),
                                                                ),
                                                              ),
                                                            ),
                                                            child:
                                                                Text("Search"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: articles.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return buildCardArticles(
                                                    context, index);
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(), // Add more conditions if needed
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: _buildBottomNavBarItems(),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType
              .fixed, // Ensure the items are evenly spaced
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.library_books),
        label: 'Books',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.upload),
        label: 'Upload',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.request_page),
        label: 'Request',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.article),
        label: 'Articles',
      ),
    ];
  }

  Future<void> _selectPublicationDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedPublicationDate) {
      setState(() {
        selectedPublicationDate = pickedDate;
        publicationDateController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Widget buildCardBooks(BuildContext context, int index) {
    Map<String, dynamic> book = books[index];
    bool isStyle1 = index % 2 == 0;

    return GestureDetector(
      onTap: () {
        showBookDetails(context, book);
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                isStyle1
                    ? 'assets/images/books_background.jpg'
                    : 'assets/images/books_backgrounding.jpg',
              ),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isStyle1
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isStyle1
                        ? Colors.indigo
                        : Color.fromARGB(255, 68, 177, 227),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Author: ${book['author']}',
                  style: TextStyle(
                    color: isStyle1
                        ? const Color.fromARGB(255, 43, 43, 43)
                        : Colors.grey[300],
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Category: ${book['category']}',
                  style: TextStyle(
                    color: isStyle1 ? Colors.grey[800] : Colors.grey[300],
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCardArticles(BuildContext context, int index) {
    Map<String, dynamic> article = articles[index];
    bool isStyle1 = index % 2 == 0;

    return GestureDetector(
      onTap: () {
        showArticleDetails(context, article);
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                isStyle1
                    ? 'assets/images/articles_back_two.jpg'
                    : 'assets/images/articles_back_one.jpeg',
              ),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isStyle1
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isStyle1
                        ? Colors.indigo
                        : Color.fromARGB(255, 68, 177, 227),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Author: ${article['author']}',
                  style: TextStyle(
                    color: isStyle1
                        ? const Color.fromARGB(255, 43, 43, 43)
                        : Colors.grey[300],
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Category: ${article['category']}',
                  style: TextStyle(
                    color: isStyle1 ? Colors.grey[800] : Colors.grey[300],
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Pass the onTap function to GestureDetector
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        padding: EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}

class PDFViewerScreen extends StatefulWidget {
  final String filePath;

  const PDFViewerScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  @override
  void initState() {
    super.initState();
    _enableScreenshotRestriction();
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
      body: PDFView(
        filePath: widget.filePath,
      ),
    );
  }
}
