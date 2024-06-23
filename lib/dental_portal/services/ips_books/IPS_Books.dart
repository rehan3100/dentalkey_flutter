import 'dart:io';
import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_withdr_rehan.dart';
import 'package:dental_key/dental_portal/services/career_pathways/career_pathways_homepage.dart';
import 'package:dental_key/dental_portal/services/ips_books/dental_cart_page.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dental_key/utils/PdfViewerPage.dart';
import 'package:dental_key/dental_portal/services/BDS_World/BDS_World.dart';
import 'package:dental_key/dental_portal/services/display_dental_clinic/Display_dental_clinic.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/01_tests_homepage.dart';
import 'package:dental_key/dental_portal/services/ug_helping_material/UG_helping_material.dart';

import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart';
import 'package:dental_key/dental_portal/services/video_guidelines/video_guidelines.dart';

class IPS extends StatefulWidget {
  final String accessToken;
  IPS({required this.accessToken});

  @override
  _IPSBooksState createState() => _IPSBooksState(accessToken: accessToken);
}

class _IPSBooksState extends State<IPS> {
  late List<Book> books = [];
  late Cart cart = Cart([]); // Initialize cart
  bool isLoading = false;
  final String accessToken;
  _IPSBooksState({required this.accessToken});

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      setState(() {
        isLoading = true;
      });

      var response = await http.get(Uri.parse(
          "https://dental-key-738b90a4d87a.herokuapp.com/ips/bookslist/"));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<Book> fetchedBooks = [];
        for (var item in jsonData) {
          fetchedBooks.add(Book.fromJson(item));
        }
        setState(() {
          books = fetchedBooks;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load books');
      }
    } catch (error) {
      print('Error fetching books: $error');
    }
  }

  Map<Book, bool> addedToCartMap = {}; // Track the status of each book

  void addToCart(Book book) {
    setState(() {
      cart.items.add(book);
      addedToCartMap[book] = true; // Update the status to true for this book
    });
  }

  bool isBookAddedToCart(Book book) {
    return addedToCartMap.containsKey(book) && (addedToCartMap[book] == true);
  }

// Method to load PDF asynchronously
  Future<void> _loadPdfAsync(String pdfUrl) async {
    try {
      setState(() {
        isLoading = true;
      });

      var response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });

        var tempDir = await getTemporaryDirectory();

        // Create a file in the temporary directory
        var file = File('${tempDir.path}/example.pdf');

        // Write the PDF data to the file
        await file.writeAsBytes(response.bodyBytes);

        // Navigate to a new screen to display the PDF
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerPage(
              pdfPath: file.path,
              accessToken: accessToken,
            ),
          ),
        );
      } else {
        print('Failed to fetch PDF file. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching PDF file: $error');
    }
  }

  Future<void> refreshpage() async {
    await fetchBooks();
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
                  Container(
                    width: 150,
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
                              'assets/images/ips_logo.png',
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
                                      accessToken: accessToken,
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
                              'assets/images/UGTests.png',
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
                                        ugTestsExams(accessToken: accessToken)),
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
                    child: const Center(
                      child: Text(
                        'ABOUT IPS',
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
                    padding: EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: EdgeInsets.only(right: 16.0, left: 16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 255, 255,
                            255), // Changed background color to white
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
                      child: Text(
                        'Welcome to a revolutionary approach to dental education with our Instant Prep Series. Tailored specifically for BDS syllabi, our books offer a streamlined and comprehensive resource to support students on their academic journey. With meticulously curated content and a focus on clarity and accuracy, our series is designed to empower dental students with the knowledge and tools they need to succeed. Join us as we redefine the standards of dental learning and pave the way for excellence in education.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Set text color to black
                        ),
                        textAlign: TextAlign.justify, // Align text edge to edge
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 50.0, right: 10.0, left: 10.0),
                    child: SingleChildScrollView(
                        child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      shrinkWrap: true, // Add this line
                      physics: NeverScrollableScrollPhysics(), // Add this line
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return DraggableScrollableSheet(
                                  expand: false,
                                  builder: (BuildContext context,
                                      ScrollController scrollController) {
                                    return SingleChildScrollView(
                                      controller: scrollController,
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.network(
                                              books[index].cover_image,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              books[index].book_name,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              maxLines:
                                                  3, // Set the maximum number of lines
                                              overflow: TextOverflow
                                                  .ellipsis, // Handle overflow
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Price: GBP ${books[index].price}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              books[index].description,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton.icon(
                                                  onPressed: isBookAddedToCart(
                                                          books[index])
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            addToCart(
                                                                books[index]);
                                                          });
                                                          Navigator.pop(
                                                              context); // Close the modal
                                                        },
                                                  icon: Icon(
                                                    Icons.shopping_cart,
                                                  ),
                                                  label: Text(
                                                    isBookAddedToCart(
                                                            books[index])
                                                        ? 'Added to Cart'
                                                        : 'Add to Cart',
                                                    style: TextStyle(),
                                                  ),
                                                ),
                                                ElevatedButton.icon(
                                                  onPressed: books[index]
                                                              .glimpse_file !=
                                                          null
                                                      ? () {
                                                          Navigator.pop(
                                                              context); // Close the modal
                                                          _loadPdfAsync(books[
                                                                  index]
                                                              .glimpse_file);
                                                        }
                                                      : null,
                                                  icon: Icon(
                                                    Icons.visibility,
                                                  ),
                                                  label: Text('View Glimpse',
                                                      style: TextStyle()),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  books[index].cover_image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  books[index].book_name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
                  ),
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
            MaterialPageRoute(builder: (context) => CartPage(cart: cart)),
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

class Book {
  final String book_id;
  final String book_name;
  final String description;
  final String price;
  final String cover_image;
  final String glimpse_file;
  final String ebook_file;

  Book({
    required this.book_id,
    required this.book_name,
    required this.description,
    required this.price,
    required this.cover_image,
    required this.glimpse_file,
    required this.ebook_file,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      book_id: json['book_id'],
      book_name: json['book_name'],
      description: json['description'],
      price: json['price'],
      cover_image: json['cover_image'],
      glimpse_file: json['glimpse_file'],
      ebook_file: json['ebook_file'],
    );
  }
}

class Cart {
  List<Book> items;

  Cart(this.items);
}
