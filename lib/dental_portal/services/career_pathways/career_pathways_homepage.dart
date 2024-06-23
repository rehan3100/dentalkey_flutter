import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:dental_key/dental_portal/services/career_pathways/CP_cart.dart';
import 'package:flutter/material.dart';
import 'package:dental_key/dental_portal/services/BDS_World/BDS_World.dart';
import 'package:dental_key/dental_portal/services/display_dental_clinic/Display_dental_clinic.dart';
import 'package:dental_key/dental_portal/services/ips_books/IPS_Books.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/01_tests_homepage.dart';
import 'package:dental_key/dental_portal/services/ug_helping_material/UG_helping_material.dart';
import 'package:dental_key/dental_portal/services/make_appointment_with_Rehan/appointments_withdr_rehan.dart';
import 'package:dental_key/dental_portal/services/foreign_exams/foreign_mockexams.dart';
import 'package:dental_key/dental_portal/services/dental_key_library/01_dkl_homepage.dart';
import 'package:dental_key/dental_portal/services/video_guidelines/video_guidelines.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DentalCareerPathways extends StatefulWidget {
  final String accessToken;
  DentalCareerPathways({required this.accessToken});

  @override
  _DentalCareerPathwaysState createState() =>
      _DentalCareerPathwaysState(accessToken: accessToken);
}

class _DentalCareerPathwaysState extends State<DentalCareerPathways> {
  final String accessToken;
  List<Map<String, dynamic>> countries = [];
  List<Package> packages = [];
  String? selectedCountry;
  String? countryName; // Add countryName variable
  bool isfetchLoading = false;
  bool isLoading = false; // Track loading state
  bool isFetchingPackages = false; // Track package fetching state

  _DentalCareerPathwaysState({required this.accessToken});

  Future<void> fetchCountries() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/countries/'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        countries = data
            .map<Map<String, dynamic>>((item) => {
                  'country_name': item['country_name'],
                  'country_description': item['country_description'],
                  'country_image': item['country_image'],
                })
            .toList();
      });
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to fetch countries');
    }
  }

  Future<void> fetchPackages(String countryName) async {
    // Find the country_id (UUID) based on the selected country name
    String countryId = await fetchCountryId(countryName);
    if (countryId.isNotEmpty) {
      final response = await http.get(Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/country/$countryId/packages/'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          packages = data
              .map((item) => Package(
                    package_id: item['package_id'],
                    name: item['package_name'],
                    description: item['package_description'],
                    currency: item['package_currency'],
                    price: double.parse(
                      item['package_price'],
                    ),
                    country: item['country'],
                  ))
              .toList();
        });
      } else {
        throw Exception('Failed to fetch packages: ${response.statusCode}');
      }
    } else {
      throw Exception('Failed to fetch country id for $countryName');
    }
  }

  Future<String> fetchCountryId(String countryName) async {
    final response = await http.get(Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/countries/'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      for (var item in data) {
        if (item['country_name'] == countryName) {
          return item['country_id'];
        }
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  List<Map<String, dynamic>> get cartItems {
    List<Package> addedPackages =
        packages.where((package) => package.isAddedToCart).toList();
    return addedPackages.map((package) {
      return {
        'package_id': package.package_id,
        'name': package.name,
        'price': package.price,
        'currency': package.currency,
        'country': package.country, // Include the package currency
      };
    }).toList();
  }

  Future<void> refreshPage() async {
    await fetchCountries();
    if (countryName?.isNotEmpty ?? false) {
      await fetchPackages(countryName!); // Fixed method call
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refreshPage,
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
                                      builder: (context) => DentalPortalMain(
                                          accessToken: accessToken)),
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
                    child: Center(
                      child: Text(
                        'CAREER PATHWAYS & PACKAGES',
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
                        'Chart your dental career with ease! Explore exciting career options, clear pathways, and enticing packages designed to help you reach your professional aspirations in dentistry.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Set text color to black
                        ),
                        textAlign: TextAlign.justify, // Align text edge to edge
                      ),
                    ),
                  ),
                  if (isFetchingPackages) // Show loader if fetching packages
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 50.0, right: 20.0, left: 20.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 50, right: 15, left: 15),
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isFetchingPackages = true;
                              selectedCountry =
                                  countries[index]['country_name'];
                              countryName =
                                  selectedCountry; // Update countryName variable
                              fetchPackages(selectedCountry!).then((_) {
                                setState(() {
                                  isFetchingPackages = false;
                                });
                              });
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: Image.network(
                                                countries[index]
                                                    ['country_image'],
                                                width: double.infinity,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(8.0),
                                                color: Colors.black54,
                                                child: Text(
                                                  countries[index]
                                                      ['country_name'],
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
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
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Text(
                                    countries[index]['country_description'],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                if (selectedCountry ==
                                        countries[index]['country_name'] &&
                                    packages.isNotEmpty)
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: packages.length,
                                      itemBuilder: (context, i) {
                                        final package = packages[i];
                                        return Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              package.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 5),
                                                Text(
                                                  package.description,
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  'Price: ${package.currency} ${package.price}',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                SizedBox(height: 8.0),
                                                _buildPackageButton(package),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (isfetchLoading) // Show loader if loading
                    Center(
                      child: CircularProgressIndicator(),
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
          if (countryName != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CpCartPage(
                  accessToken: accessToken,
                  cartItems: cartItems,
                  countryName: countryName!, // Use the non-nullable version
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Country name is null.'),
              ),
            );
          }
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

  Widget _buildPackageButton(Package package) {
    if (package.isAddedToCart) {
      return ElevatedButton(
        onPressed: () {
          // Handle removing package from cart
          setState(() {
            package.isAddedToCart = false;
          });
        },
        child: Text('Added in Order List'),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          // Handle adding package to cart
          setState(() {
            package.isAddedToCart = true;
          });
        },
        child: Text('Get this Package'),
      );
    }
  }
}

class Package {
  final String package_id;
  final String name;
  final String description;
  final String currency; // Add currency field
  final double price;
  final String country;
  bool isAddedToCart;

  Package({
    required this.package_id,
    required this.name,
    required this.description,
    required this.currency,
    required this.price,
    required this.country,
    this.isAddedToCart = false,
  });
}
