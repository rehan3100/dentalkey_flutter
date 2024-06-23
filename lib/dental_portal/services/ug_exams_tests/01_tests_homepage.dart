import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/dental_portal/services/BDS_World/BDS_World.dart';
import 'package:dental_key/dental_portal/services/career_pathways/career_pathways_homepage.dart';
import 'package:dental_key/dental_portal/services/display_dental_clinic/Display_dental_clinic.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:dental_key/dental_portal/services/ips_books/IPS_Books.dart';
import 'package:dental_key/dental_portal/services/ug_helping_material/UG_helping_material.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_withdr_rehan.dart';

import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/02_UG_cart_page.dart';
import 'package:dental_key/dental_portal/services/video_guidelines/video_guidelines.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ugTestsExams extends StatefulWidget {
  final String accessToken;
  ugTestsExams({required this.accessToken});

  @override
  _ugTestsExamsState createState() =>
      _ugTestsExamsState(accessToken: accessToken);
}

class _ugTestsExamsState extends State<ugTestsExams> {
  List<dynamic> quizzes = [];
  final String accessToken;
  late String quizCategoryUUID;

  _ugTestsExamsState({required this.accessToken});

  final UGCart ugcart = UGCart();
  TextEditingController _searchController = TextEditingController();
  String _searchString = "";
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchQuizzes();
    _searchController.addListener(() {
      setState(() {
        _searchString = _searchController.text;
      });
    });
  }

  Future<void> fetchQuizzes() async {
    quizCategoryUUID = "9c3ea843-7f93-4315-b44f-eae56e93b1af";
    String url =
        "https://dental-key-738b90a4d87a.herokuapp.com/quizzer/quizzes/$quizCategoryUUID";
    try {
      setState(() {
        isLoading = true;
      });

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          quizzes = json.decode(response.body);
        });
        setState(() {
          isLoading = false;
        });

        // Debug: Print UUIDs of quizzes
        print('Quizzes UUIDs:');
        for (var quiz in quizzes) {
          print('- ${quiz['uid']}');
        }
      } else {
        print("Failed to fetch quizzes");
      }
    } catch (e) {
      print("Exception while fetching quizzes: $e");
    }
  }

  Map<String, bool> addedToCartMap = {}; // Track the status of each quiz

  void addToCart(String quizUUID, String title, String description,
      String imageUrl, String price) {
    setState(() {
      ugcart.addToCart(quizUUID, title, description, imageUrl, price);
      addedToCartMap[quizUUID] =
          true; // Update the status to true for this quiz
    });
  }

  bool isQuizAddedToCart(String quizUUID) {
    return addedToCartMap.containsKey(quizUUID) &&
        addedToCartMap[quizUUID] == true;
  }

  Future<void> refreshpage() async {
    await fetchQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    width: double.infinity,
                    height: 300,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
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
                              'assets/images/UGTests.png',
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
                                // Navigate to the desired class, e.g., BottomNavigation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DentalPortalMain(
                                      accessToken: widget.accessToken,
                                    ),
                                  ),
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
                              // Navigate to the desired class, e.g., BottomNavigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BDSWorld(accessToken: accessToken)),
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
                              // Navigate to the desired class, e.g., BottomNavigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        IPS(accessToken: accessToken)),
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
                              // Navigate to the desired class, e.g., BottomNavigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DentalCareerPathways(
                                        accessToken: accessToken)),
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
                              // Navigate to the desired class, e.g., BottomNavigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForeignMockExam(
                                        accessToken: accessToken)),
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
                              // Navigate to the desired class, e.g., BottomNavigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ugHelpingMaterial(
                                        accessToken: accessToken)),
                              );
                            },
                          ),
                          SizedBox(width: 20),
                          _buildContainer(
                            Image.asset(
                              'assets/images/free_books.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                            () {
                              // Navigate to the desired class, e.g., BottomNavigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DKLlibrary(accessToken: accessToken)),
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
                              // Navigate to the desired class, e.g., BottomNavigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => videoguidelines(
                                        accessToken: accessToken)),
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
                              // Navigate to the desired class, e.g., BottomNavigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => displayDentalClinic(
                                        accessToken: accessToken)),
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
                              // Navigate to the desired class, e.g., BottomNavigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        appointmentswithdrrehan(
                                            accessToken: accessToken)),
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
                  Container(
                    child: Center(
                      child: Text(
                        'UNDERGRADUATE EXAMS & TESTS',
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
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 255, 255,
                            255), // Changed background color to white
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
                      child: Text(
                        'Boost your knowledge and exam readiness with our comprehensive study aids',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Set text color to black
                        ),
                        textAlign: TextAlign.justify, // Align text edge to edge
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Quizzes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      if (quizzes[index] != null &&
                          quizzes[index]['title']
                              .toLowerCase()
                              .contains(_searchString.toLowerCase())) {
                        return GestureDetector(
                          onTap: () {
                            showQuizDetailsDialog(
                              context,
                              quizzes[index]['uid'] ?? '',
                              quizzes[index]['title'] ?? '',
                              quizzes[index]['description'] ?? '',
                              quizzes[index]['quiz_image'] ?? '',
                              '${quizzes[index]['currency'] ?? 'GBP'} ${quizzes[index]['price'] ?? 'Free'}',
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(quizzes[index]
                                                  ['quiz_image'] ??
                                              ''),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                        ),
                                        child: Text(
                                          quizzes[index]['title'] ?? '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Price: ${quizzes[index]['currency'] ?? 'GBP'} ${quizzes[index]['price'] ?? 'Free'}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        quizzes[index]['description'] ?? '',
                                        style: TextStyle(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(); // or any other fallback widget
                      }
                    },
                  ),
                  SizedBox(height: 80)
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnderGraduateCartPage(
                  ugcart: ugcart,
                  accessToken: accessToken,
                  quizCategoryUUID: quizCategoryUUID),
            ),
          );
        },
        label: Text('View Cart'),
        icon: Icon(Icons.shopping_cart),
        backgroundColor: Color(0xFF385A92),
        foregroundColor: Colors.white,
        hoverColor: Colors.white,
        focusColor: Colors.white,
        hoverElevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }

  Widget _buildContainer(Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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

  void showQuizDetailsDialog(
    BuildContext context,
    String quizUUID,
    String title,
    String description,
    String imageUrl,
    String price, // Add price parameter
  ) {
    print('Quiz UUID received: $quizUUID'); // Print received quiz UUID
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(imageUrl)
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey,
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(description),
              SizedBox(height: 5),
              Text(
                'Price: $price',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: isQuizAddedToCart(quizUUID)
                  ? null
                  : () {
                      setState(() {
                        addToCart(
                            quizUUID, title, description, imageUrl, price);
                      });
                      Navigator.pop(context); // Close the modal
                    },
              icon: Icon(
                Icons.shopping_cart,
              ),
              label: Text(
                isQuizAddedToCart(quizUUID) ? 'Added to Cart' : 'Add to Cart',
                style: TextStyle(),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class UGCart {
  List<CartItem> items = [];
  late Cart cart = Cart([]); // Initialize cart
  void addToCart(String quizUUID, String title, String description,
      String imageUrl, String price) {
    items.add(CartItem(
        quizUUID: quizUUID,
        title: title,
        description: description,
        quizImage: imageUrl,
        price: price));
  }
}

class CartItem {
  final String quizUUID;
  final String title;
  final String description;
  final String quizImage;
  final String price; // Add price property

  CartItem({
    required this.quizUUID,
    required this.title,
    required this.description,
    required this.quizImage,
    required this.price, // Add price parameter to the constructor
  });
}
