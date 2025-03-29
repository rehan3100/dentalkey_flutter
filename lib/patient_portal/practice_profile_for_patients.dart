import 'package:dental_key/patient_portal/request_appointment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PracticeProfileScreen extends StatefulWidget {
  final String practiceId;
  final String patientId;
  final String dependentUuid;

  PracticeProfileScreen({
    required this.practiceId,
    required this.patientId,
    required this.dependentUuid,
  });

  @override
  _PracticeProfileScreenState createState() => _PracticeProfileScreenState();
}

class _PracticeProfileScreenState extends State<PracticeProfileScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;
  final PageController _pageController = PageController(viewportFraction: 1);
  int selectedTab = 0;

  Future<void> openInMaps() async {
    final address = Uri.encodeComponent(
      "${profile!['practice_name']}, ${profile!['address']['postcode']}",
    );
    final googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$address";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  Future<void> fetchPracticeProfile() async {
    final url = Uri.parse(
      'https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/view-practice-profile/?practice_id=${widget.practiceId}&patient_id=${widget.patientId}&dependent_uuid=${widget.dependentUuid}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        profile = jsonDecode(response.body);
        loading = false;
      });
    } else {
      print("Failed to load practice profile");
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPracticeProfile();
  }

  void showAllReviewsPopup(BuildContext context) {
    final allReviews = profile!['recent_reviews'] as List;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("All Reviews",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
// ⭐ Average Rating in Popup
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        double avg = profile!['review_stats']['average_rating']
                                ?.toDouble() ??
                            0;
                        if (i < avg.floor()) {
                          return Icon(Icons.star,
                              color: Colors.amber, size: 18);
                        } else if (i < avg && avg % 1 != 0) {
                          return Icon(Icons.star_half,
                              color: Colors.amber, size: 18);
                        } else {
                          return Icon(Icons.star_border,
                              color: Colors.amber, size: 18);
                        }
                      }),
                      SizedBox(width: 6),
                      Text(
                        "${profile!['review_stats']['average_rating']} "
                        "(${profile!['review_stats']['total_reviews']} reviews)",
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: allReviews.length,
                      itemBuilder: (context, index) {
                        final rev = allReviews[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rev['patient_name'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text(rev['comment'] ?? ''),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    // Dynamic Stars
                                    ...List.generate(5, (i) {
                                      double rating =
                                          rev['rating']?.toDouble() ?? 0;
                                      return Icon(
                                        i < rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                    SizedBox(width: 6),
                                    Text("${rev['rating']}",
                                        style: TextStyle(fontSize: 13)),

                                    Spacer(),

                                    // Date
                                    Text(rev['created_at'],
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Practice Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Practice Profile')),
        body: Center(child: Text('Unable to load profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(profile!['practice_name'] ?? 'Practice Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 Image Gallery at Top
            if ((profile!['images'] as List).isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * (2.5 / 4),
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: profile!['images'].length,
                      controller: _pageController,
                      itemBuilder: (context, index) {
                        final img = profile!['images'][index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              img['url'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/default_practice.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                color: Colors.black.withOpacity(0.4),
                                child: Text(
                                  img['image_type'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 6),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: profile!['images'].length,
                    effect: WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Colors.blueAccent,
                      dotColor: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),

            // 🏷️ Basic Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          profile!['practice_name'],
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 16, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              "${profile!['type']} Practice",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Text("Address:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    if (profile!['location']['distance_km'] != null)
                      Text("📍 ${profile!['location']['distance_km']} km away"),
                  ]),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📍 Address Text
                      Expanded(
                        child: Text(
                          "${profile!['address']['line_1'] ?? ''}, ${profile!['address']['city'] ?? ''}, ${profile!['address']['postcode'] ?? ''}, ${profile!['address']['country'] ?? ''}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),

                      // 🗺️ View on Map Button
                      TextButton.icon(
                        onPressed: openInMaps,
                        icon: Icon(Icons.map, size: 18),
                        label: Text("View", style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.only(left: 8),
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    ],
                  ),
// 🔄 Custom Tab Switcher
                  SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = 0;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedTab == 0
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: selectedTab == 0
                                    ? [
                                        BoxShadow(
                                          color: Colors.blueAccent
                                              .withOpacity(0.4),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  "Overview",
                                  style: TextStyle(
                                    color: selectedTab == 0
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: selectedTab == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = 1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedTab == 1
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: selectedTab == 1
                                    ? [
                                        BoxShadow(
                                          color: Colors.blueAccent
                                              .withOpacity(0.4),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  "Our Staff",
                                  style: TextStyle(
                                    color: selectedTab == 1
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: selectedTab == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

// 🔁 Conditionally show content
                  if (selectedTab == 0) ...[
                    buildContactInfoCard(),
                    Divider(),
                    buildFacilitiesCard(),
                    Divider(),
                    buildServicesCard(),
                    Divider(),
                    buildOpeningHoursCard(),
                    Divider(),
                    buildReviewsCard(context),
                  ] else ...[
                    buildStaffCard(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          top: false,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentRequestScreen(
                    practiceId: widget.practiceId,
                    patientId: widget.patientId,
                    dependentUuid: widget.dependentUuid,
                  ),
                ),
              );
            },
            icon: Icon(Icons.calendar_month),
            label: Text("Book Appointment"),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContactInfoCard() {
    final contact = profile!['contact'];
    final social = profile!['social_media'];

    Widget buildRow(
        {required IconData icon,
        required String label,
        required String? value,
        void Function()? onTap}) {
      if (value == null || value.trim().isEmpty) return SizedBox();
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.blueAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 14,
                      color: onTap != null ? Colors.blue : Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contact Info",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            buildRow(
              icon: Icons.phone,
              label: 'Phone',
              value: contact['phone_number'],
              onTap: () =>
                  launchUrl(Uri.parse('tel:${contact['phone_number']}')),
            ),
            buildRow(
              icon: Icons.email,
              label: 'Email',
              value: contact['email'],
              onTap: () => launchUrl(Uri.parse('mailto:${contact['email']}')),
            ),
            buildRow(
              icon: Icons.language,
              label: 'Website',
              value: contact['website'],
              onTap: () => launchUrl(Uri.parse(contact['website'])),
            ),
            buildRow(
              icon: Icons.facebook,
              label: 'Facebook',
              value: social['facebook'],
              onTap: () => launchUrl(Uri.parse(social['facebook'])),
            ),
            buildRow(
              icon: Icons.camera_alt_outlined,
              label: 'Instagram',
              value: social['instagram'],
              onTap: () => launchUrl(Uri.parse(social['instagram'])),
            ),
            buildRow(
              icon: Icons.business,
              label: 'LinkedIn',
              value: social['linkedin'],
              onTap: () => launchUrl(Uri.parse(social['linkedin'])),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFacilitiesCard() {
    final facilities = profile!['facilities'];

    List<Widget> facilityItems = [];

    void addFacilityRow(
        {required IconData icon,
        required String label,
        required dynamic value}) {
      if (value == null) return;
      facilityItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.teal),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$label: ${value is bool ? (value ? 'Yes' : 'No') : value}",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    addFacilityRow(
      icon: Icons.chair_alt_outlined,
      label: 'Number of Surgery Rooms',
      value: facilities['number_of_chairs'],
    );

    addFacilityRow(
      icon: Icons.accessible,
      label: 'Accessible for Wheelchair Users',
      value: facilities['wheelchair_accessible'],
    );
    addFacilityRow(
      icon: Icons.computer,
      label: 'TeleDental Services',
      value: facilities['teledental'],
    );

    addFacilityRow(
      icon: Icons.local_hospital,
      label: 'Accepting Emergency Patients',
      value: facilities['accepts_emergency_patients'],
    );
    addFacilityRow(
      icon: Icons.health_and_safety,
      label: 'Accepting New NHS Patients',
      value: facilities['accepting_new_NHS_patients'],
    );
    addFacilityRow(
      icon: Icons.emoji_people,
      label: 'Accepting New Private Patients',
      value: facilities['accepting_new_private_patients'],
    );

    if (facilityItems.isEmpty) return SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Card(
        margin: EdgeInsets.only(top: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Facilities",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10),
              ...facilityItems,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildServicesCard() {
    final services = profile!['services'] as List?;

    if (services == null || services.isEmpty) return SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Card(
        margin: EdgeInsets.only(top: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Services",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 6,
                childAspectRatio: 4.5,
                children: services.map((s) {
                  return Row(
                    children: [
                      Icon(Icons.medical_services_outlined,
                          size: 18, color: Colors.teal),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s,
                          style: TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOpeningHoursCard() {
    final List<String> weekOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    final String today = weekOrder[DateTime.now().weekday - 1];

    List openingHours = List.from(profile!['opening_hours']);
    openingHours.sort((a, b) =>
        weekOrder.indexOf(a['day']).compareTo(weekOrder.indexOf(b['day'])));

    int todayIndex =
        openingHours.indexWhere((e) => e['day'].toString() == today);
    if (todayIndex != -1) {
      openingHours = [
        ...openingHours.sublist(todayIndex),
        ...openingHours.sublist(0, todayIndex)
      ];
    }

    if (openingHours.isEmpty) return SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Card(
        margin: EdgeInsets.only(top: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Opening Hours",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10),
              ...openingHours.map<Widget>((oh) {
                final bool isClosed = oh['is_closed'] == true;
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isClosed ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isClosed
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        child: Text(
                          oh['day'],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        isClosed
                            ? "Closed"
                            : "${oh['opening_time']} - ${oh['closing_time']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isClosed ? Colors.red : Colors.green.shade800,
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReviewsCard(BuildContext context) {
    final reviewStats = profile!['review_stats'];
    final recentReviews = profile!['recent_reviews'] as List;

    if (reviewStats == null || recentReviews.isEmpty) return SizedBox();

    double avgRating = reviewStats['average_rating']?.toDouble() ?? 0;
    int totalReviews = reviewStats['total_reviews'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Card(
        margin: EdgeInsets.only(top: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Reviews + Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Reviews",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        if (i < avgRating.floor()) {
                          return Icon(Icons.star,
                              color: Colors.amber, size: 18);
                        } else if (i < avgRating && avgRating % 1 != 0) {
                          return Icon(Icons.star_half,
                              color: Colors.amber, size: 18);
                        } else {
                          return Icon(Icons.star_border,
                              color: Colors.amber, size: 18);
                        }
                      }),
                      SizedBox(width: 6),
                      Text(avgRating.toStringAsFixed(1),
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 4),

              // Row: (X reviews) + View All
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("($totalReviews reviews)",
                      style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  TextButton(
                    onPressed: () => showAllReviewsPopup(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text("View All",
                        style: TextStyle(fontSize: 12, color: Colors.blue)),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // 🔁 3 Recent Reviews
              ...recentReviews.take(3).map<Widget>((rev) {
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rev['patient_name'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        if (rev['comment'] != null)
                          Text(
                            rev['comment'],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              double rating = rev['rating']?.toDouble() ?? 0;
                              return Icon(
                                i < rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                            SizedBox(width: 6),
                            Text("${rev['rating'] ?? ''}",
                                style: TextStyle(fontSize: 13)),
                            Spacer(),
                            Text(rev['created_at'] ?? '',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStaffCard() {
    final staff = profile!['staff_members'] as List;

    if (staff.isEmpty) return SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Card(
        margin: EdgeInsets.only(top: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Our Staff",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10),
              ...staff.map((s) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(
                        s['staff_type'] == 'Clinical'
                            ? Icons.medical_services
                            : Icons.admin_panel_settings,
                        color: Colors.teal,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              Text("${s['role']} • ${s['staff_type']}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600])),
                            ]),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
