import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dental_key/dental_portal/services/career_pathways/CP_package_items.dart';

class MyPackages extends StatefulWidget {
  final String accessToken;
  const MyPackages({Key? key, required this.accessToken}) : super(key: key);

  @override
  _MyPackagesState createState() => _MyPackagesState(accessToken: accessToken);
}

class _MyPackagesState extends State<MyPackages> {
  bool isLoading = true;
  final String accessToken;
  List<Package> packages = [];
  Map<String, String> countryImages = {};

  _MyPackagesState({required this.accessToken});

  Future<void> _fetchPackages() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/order-packages/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            packages =
                responseData.map((data) => Package.fromJson(data)).toList();
          });
          await _fetchCountryImages(); // Fetch country images after packages
        }
      } else {
        throw Exception('Failed to fetch packages');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _fetchCountryImages() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/career_pathways/countries/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            isLoading = false;
            for (var country in responseData) {
              countryImages[country['country_name']] = country['country_image'];
            }
          });
        }
      } else {
        throw Exception('Failed to fetch country images');
      }
    } catch (error) {
      print('Error: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> refreshpage() async {
    await _fetchCountryImages();
    await _fetchPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Packages'),
      ),
      body: RefreshIndicator(
        onRefresh: refreshpage,
        child: Stack(
          children: [
            // Background Image Container
            Center(
              child: Opacity(
                opacity:
                    0.1, // Adjust the opacity to make the background very transparent
                child: Image.asset(
                  'assets/images/mystore_back.png',
                  width: 300.0, // Set your desired width
                  height: 400.0, // Set your desired height
                ),
              ),
            ),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : packages.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Sorry, you didn\'t buy anything yet from this category.',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: packages.length,
                          itemBuilder: (context, index) {
                            final package = packages[index];
                            final countryImage = countryImages[package.country];
                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PackageDetailScreen(
                                        packageId: package.packageId,
                                        accessToken: widget.accessToken,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.network(
                                            countryImage!,
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
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  185, 0, 0, 0),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  package.packageName,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  package.country,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color.fromARGB(
                                                        230, 255, 255, 255),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            package.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'You Paid: GBP ${package.price}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.deepPurple,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
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
  }
}

class Package {
  final String packageId;
  final String packageName;
  final String description;
  final String price;
  final String country;

  Package({
    required this.packageId,
    required this.packageName,
    required this.description,
    required this.price,
    required this.country,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      packageId: json['package_id'],
      packageName: json['package_name'],
      description: json['package_description'],
      price: json['package_price'],
      country: json['country'],
    );
  }
}
