import 'package:dental_key/dental_portal/mainscreen/dental-account.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/01_tests_homepage.dart';
import 'package:flutter/material.dart';
import 'package:dental_key/dental_portal/services/BDS_World/BDS_World.dart';
import 'package:dental_key/dental_portal/services/display_dental_clinic/Display_dental_clinic.dart';
import 'package:dental_key/dental_portal/services/ips_books/IPS_Books.dart';
import 'package:dental_key/dental_portal/services/ug_helping_material/UG_helping_material.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_withdr_rehan.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart';
import 'package:dental_key/dental_portal/services/video_guidelines/video_guidelines.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CareerPathways extends StatefulWidget {
  final String accessToken;
  CareerPathways({required this.accessToken});

  @override
  _CareerPathwaysState createState() =>
      _CareerPathwaysState(accessToken: accessToken);
}

class _CareerPathwaysState extends State<CareerPathways> {
  // Define cartItems list to keep track of items in the cart
  List<String> cartItems = [];
  final String accessToken;
  _CareerPathwaysState({required this.accessToken});
  List<String> countries = [];

  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse('YOUR_BACKEND_API_URL'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        countries = data.map((item) => item['name'] as String).toList();
      });
    } else {
      throw Exception('Failed to fetch countries');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                        'assets/images/career_options.png',
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
                                builder: (context) =>
                                    DentalAccount(accessToken: accessToken)),
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
                              builder: (context) =>
                                  ForeignMockExam(accessToken: accessToken)),
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
                              builder: (context) =>
                                  ugHelpingMaterial(accessToken: accessToken)),
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
                              builder: (context) =>
                                  videoguidelines(accessToken: accessToken)),
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
                              builder: (context) => appointmentswithdrrehan(
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
                  'CAREER PATHWAYS & PACKAGES',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.underline, // Underline text
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
                  color: const Color.fromARGB(
                      0, 255, 255, 255), // Changed background color to white
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                child: Text(
                  'Which service will you like to get?.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black, // Set text color to black
                  ),
                  textAlign: TextAlign.justify, // Align text edge to edge
                ),
              ),
            ),
            // Cards section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Country...',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Shopping cart icon and badge
// Shopping cart icon and badge
                  GestureDetector(
/*                    onTap: () {
                      // Calculate the total price
                      double totalPrice = calculateTotalPrice();

                      // Navigate to the cart page only if there are items in the cart
                      if (cartItems.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartPage(
                              cartItems: cartItems,
                              totalPrice: totalPrice,
                            ),
                          ),
                        );
                      } else {
                        // Show a message indicating the cart is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Your cart is empty'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
*/
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.shopping_cart),
                        Positioned(
                          top: -12,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 0, 50, 126),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${cartItems.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // First card: General Information of Licensing, Foreign Study Guidelines, Free - No Charges
            _buildCareerCard(
              context,
              "General Information of Licensing.\nForeign Study Guidelines.\nFREE - NO CHARGES",
              "FREE",
              "Subscribe Free Package", // Provide button label
              () {
                // Show the subscription form
                _showSubscriptionForm(context);
              },
              0, // Add package number
            ),
            _buildCareerCard(
              context,
              "Career Planning and Counselling Session.\nDecision of which option suits you?",
              "£ 25",
              "Add to Cart", // Provide button label
              () {
                _addToCart(context, cartItems, "Career Planning", 25,
                    1); // Pass packageNumber
              },
              1, // Add package number
            ),
            _buildCareerCard(
              context,
              "Guidance in application or documentation of any specific pathway.\nGuidance in scheduling exams and study tips.",
              "£ 50",
              "Add to Cart", // Provide button label
              () {
                _addToCart(context, cartItems, "Guidance in Application", 50,
                    2); // Pass packageNumber
              },
              2, // Add package number
            ),
            _buildCareerCard(
              context,
              "Full assistance in documentation of single exams/licensing pathway.\nAfter booking special study plans and 3 mocks.",
              "£ 300",
              "Add to Cart", // Provide button label
              () {
                _addToCart(
                    context,
                    cartItems,
                    "Full Assistance in Documentation",
                    300,
                    3); // Pass packageNumber
              },
              3, // Add package number
            ),
            _buildCareerCard(
              context,
              "Full assistance in studying abroad.\nFrom documentation to visa processing.",
              "£ 350",
              "Add to Cart", // Provide button label
              () {
                _addToCart(context, cartItems, "Studying Abroad Assistance",
                    350, 4); // Pass packageNumber
              },
              4, // Add package number
            ),
            _buildCareerCard(
              context,
              "Licensing exams chapter-wise guidelines, preparation materials with additional mocks.\nMultiple 20 minutes slots on zoom.",
              "£ 350",
              "Add to Cart", // Provide button label
              () {
                _addToCart(context, cartItems, "Licensing Exams Guidelines",
                    350, 5); // Pass packageNumber
              },
              5, // Add package number
            ),
            _buildCareerCard(
              context,
              "LDS SPECIAL\nONLY FOR LDS PART 1 CANDIDATES\nPassing Surety up to 99%. Covering up from Booking to Passing the exam.",
              "£ 900",
              "Contact Us for Booking", // Provide button label
              () {
                _contactUsForBooking(context, "LDS SPECIAL", 900);
              },
              6, // Add package number
            ),
          ],
        ),
      ),
    );
  }

// Function to handle "Subscribe Free Package" action
  void _showSubscriptionForm(BuildContext context) {
    // Show a modal dialog with the subscription form
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Subscribe Free Package"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Your email address'),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField(
                decoration: InputDecoration(
                    labelText: 'Which country are you interested in?'),
                items: [
                  DropdownMenuItem(
                    child: Text('Pakistan'),
                    value: 'Pakistan',
                  ),
                  DropdownMenuItem(
                    child: Text('India'),
                    value: 'India',
                  ),
                  // Add more countries as needed
                ],
                onChanged: (value) {
                  // Handle dropdown value change
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Implement logic for form submission
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

// Function to handle "Add to Cart" action
  void _addToCart(BuildContext context, List<String> cartItems, String service,
      double price, int packageNumber) {
    // Check if the item is already in the cart
    if (!cartItems.contains("Package $packageNumber: $service - £$price")) {
      // Add the selected item to the cartItems list
      cartItems.add("Package $packageNumber: $service - £$price");

      // Show a snackbar to indicate that the item has been added to the cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$service added to cart'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Show a snackbar to indicate that the item is already in the cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$service is already in the cart'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    // Update the UI by calling setState
    setState(() {});
  }

  // Function to calculate the total price of items in the cart
  double calculateTotalPrice() {
    double totalPrice = 0.0;
    for (String item in cartItems) {
      // Split the item string to extract the price
      List<String> parts = item.split(" - £");
      if (parts.length == 2) {
        totalPrice += double.parse(parts[1]);
      }
    }
    return totalPrice;
  }

  // Function to handle "Contact Us for Booking" action
  void _contactUsForBooking(
      BuildContext context, String service, double price) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _buildModalForm(context, service, price);
      },
    );
  }

  // Function to build modal form
  Widget _buildModalForm(BuildContext context, String service, double price) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Your Email Address'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isEmpty) {
                // Code here
              }
            },
          ),
          SizedBox(height: 20.0),
          Row(
            children: [
              Text('Have you reserved LDS Seat? '),
              DropdownButton<String>(
                onChanged: (value) {},
                items: <String>['Yes', 'No'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          TextFormField(
            decoration:
                InputDecoration(labelText: 'Your RCSEng Membership Number'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isEmpty) {
                // Code here
              }
            },
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              // Implement your submission logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Information received. Our representative will contact you soon."),
                ),
              );
              Navigator.of(context).pop(); // Close the modal form
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerCard(
    BuildContext context,
    String bulletText,
    String packagePrice,
    String buttonLabel, // Add button label parameter
    VoidCallback onPressed, // Add onPressed parameter
    int packageNumber, // Add packageNumber parameter
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      color: Colors.grey[300], // Grey background
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Package number
            Text(
              "Package $packageNumber", // Display package number
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Bullet point text
            Text(
              bulletText,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            // Package price
            Text(
              packagePrice,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (onPressed != null) ...[
              SizedBox(height: 10),
              // Button
              ElevatedButton(
                onPressed: onPressed, // Call onPressed callback
                child: Text(buttonLabel), // Set button label
              ),
            ],
          ],
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

class PackagesPage extends StatelessWidget {
  final String country;

  PackagesPage({required this.country});

  @override
  Widget build(BuildContext context) {
    // Implement fetching and displaying packages for selected country
    return Scaffold(
      appBar: AppBar(
        title: Text('Packages for $country'),
      ),
      body: Center(
        child: Text('Packages for $country'),
      ),
    );
  }
}
