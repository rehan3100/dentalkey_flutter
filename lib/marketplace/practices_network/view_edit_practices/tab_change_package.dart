import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PracticePackageScreen extends StatefulWidget {
  final String practiceId;

  const PracticePackageScreen({super.key, required this.practiceId});

  @override
  State<PracticePackageScreen> createState() => _PracticePackageScreenState();
}

class _PracticePackageScreenState extends State<PracticePackageScreen> {
  List<dynamic> allPackages = [];
  Map<String, dynamic>? currentPackage;
  bool isLoading = true;

  final List<Map<String, dynamic>> featureList = [
    {"label": "Priority Marketplace", "key": "priority_marketplace_placement"},

    // 👥 Staff & Roles
    {"label": "Role Permissions", "key": "role_permissions_enabled"},
    {"label": "Max Roles", "key": "max_roles", "isNumber": true},
    {"label": "Max Staff", "key": "max_staff", "isNumber": true},
    {"label": "Request Locum Staff", "key": "request_locum_staff"},
    {
      "label": "Locum Requests / Month",
      "key": "number_of_locum_requests_per_month",
      "isNumber": true
    },
    {"label": "Staff Education Discounts", "key": "staff_education_discounts"},

    // 📸 Branding & Media
    {
      "label": "Pictures Upload Limit",
      "key": "pictures_upload_limit",
      "isNumber": true
    },
    {"label": "Custom Subdomain", "key": "custom_subdomain_enabled"},

    // 📅 Appointments & Reminders
    {"label": "Appointment System", "key": "appointment_system_enabled"},
    {"label": "Hot-Sell Appointment Promo", "key": "hot_sell_appointment"},
    {"label": "Email Appointment Info", "key": "email_appointment_info"},
    {"label": "1-Month Reminder", "key": "one_month_reminder"},
    {"label": "Half-Month Reminder", "key": "half_month_reminder"},
    {"label": "Weekly Reminder", "key": "weekly_reminder"},
    {"label": "3-Day Reminder", "key": "day_three_reminder"},
    {"label": "Tomorrow Reminder", "key": "tomorrow_reminder"},
    {"label": "Last 3-Hour Reminder", "key": "last_three_hour_reminder"},

    // 📊 Reviews
    {"label": "Reviews Dashboard", "key": "reviews_dashboard_enabled"},
    {
      "label": "Request Reviews Deletion",
      "key": "can_request_reviews_deletion"
    },

    // 💼 Jobs
    {"label": "Job Availability Tag", "key": "job_availablilty_tag"},
    {
      "label": "Job Tag Duration (Days)",
      "key": "job_availablilty_tag_duration_in_days",
      "isNumber": true
    },
    {"label": "Post Job Ads", "key": "post_job_advertisement"},
    {
      "label": "Job Ad Expiry (Days)",
      "key": "job_ad_expiry_in_days",
      "isNumber": true
    },
    {"label": "Receive Applications", "key": "receive_respond_applications"},
    {
      "label": "Job Posts Limit/Year",
      "key": "job_posts_limit_per_year",
      "isNumber": true
    },
    {"label": "Top Notched Job Ads", "key": "top_notched_job_ads"},

    // 🛠️ Support
    {
      "label": "Support Response (hrs)",
      "key": "support_response_time_hours",
      "isNumber": true
    },
    {"label": "Account Manager", "key": "dedicated_account_manager"},
  ];

  @override
  void initState() {
    super.initState();
    loadPackages();
  }

  Future<void> loadPackages() async {
    setState(() => isLoading = true);

    final allUrl = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/packages/");
    final currentUrl = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/packages/${widget.practiceId}/");

    try {
      final responses = await Future.wait([
        http.get(allUrl),
        http.get(currentUrl),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        setState(() {
          allPackages = jsonDecode(responses[0].body);
          currentPackage = jsonDecode(responses[1].body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch packages");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Package fetch error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching packages.")),
      );
    }
  }

  Future<void> requestUpgrade(String newPackageId, String actionType) async {
    final upgradeUrl = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/request-package-upgrade/");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final response = await http.post(
      upgradeUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "practice_id": widget.practiceId,
        "package_id": newPackageId,
      }),
    );

    Navigator.pop(context); // close loader

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${actionType[0].toUpperCase()}${actionType.substring(1)} request submitted!",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final body = jsonDecode(response.body);
      final error = body['detail'] ?? "Failed to change package";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
      );
    }
  }

  Widget buildComparisonTable() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Feature Column
          Container(
            width: 180,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("Feature",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const Divider(height: 1),
                ...featureList.map((feature) {
                  return SizedBox(
                    height: 52,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        feature['label'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Scrollable Columns for Packages
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: allPackages.map((pkg) {
                  return IntrinsicWidth(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(pkg['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          const Divider(height: 1),
                          ...featureList.map((feature) {
                            final value = pkg[feature['key']];
                            Widget cellContent;

                            if (feature['isNumber'] == true) {
                              cellContent = Text(
                                value.toString(),
                                style: const TextStyle(fontSize: 13),
                                textAlign: TextAlign.center,
                              );
                            } else if (value == true) {
                              cellContent = const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20);
                            } else {
                              cellContent = const Icon(Icons.cancel,
                                  color: Colors.red, size: 20);
                            }

                            return SizedBox(
                              height: 52,
                              child: Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: cellContent,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return Colors.brown;
      case 'silver':
        return Colors.grey;
      case 'gold':
        return Colors.amber[700]!;
      case 'diamond':
        return Colors.blue;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final currentId = currentPackage?['id'];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Package List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pkg = allPackages[index];
                  final isCurrent = pkg['id'] == currentId;
                  final color = getTierColor(pkg['name']);
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.workspace_premium,
                                  color: color, size: 30),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "${pkg['name']} Package",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // prevents overflow
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Chip(
                                label: Text(
                                    isCurrent ? "Current Plan" : "Change Plan"),
                                backgroundColor: isCurrent
                                    ? Colors.green[100]
                                    : Colors.orange[50],
                                labelStyle: TextStyle(
                                  color:
                                      isCurrent ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text("£${pkg['monthly_price']}/month",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          if (pkg['description'] != null &&
                              pkg['description'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(pkg['description'],
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 14)),
                            ),
                          if (!isCurrent)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final currentPrice = double.tryParse(
                                            currentPackage?['monthly_price']
                                                    .toString() ??
                                                '0') ??
                                        0;
                                    final selectedPrice = double.tryParse(
                                            pkg['monthly_price'].toString()) ??
                                        0;
                                    final actionType =
                                        selectedPrice > currentPrice
                                            ? "upgrade"
                                            : "downgrade";

                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Confirm Package Change"),
                                        content: Text(
                                            "Are you sure you want to $actionType to the ${pkg['name']} package?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              requestUpgrade(
                                                  pkg['id'].toString(),
                                                  actionType);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.teal),
                                            child: const Text("Confirm"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.upgrade),
                                  label: const Text("Request Change"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: allPackages.length,
              ),
            ),

            // ✅ Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 20, bottom: 8),
                child: Center(
                  child: Text(
                    "📊 Feature Comparison Table",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // ✅ Comparison Table
            SliverToBoxAdapter(child: buildComparisonTable()),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}
