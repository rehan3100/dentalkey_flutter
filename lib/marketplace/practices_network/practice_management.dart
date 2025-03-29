import 'package:dental_key/marketplace/practices_network/edit_owner_profile.dart';
import 'package:dental_key/marketplace/practices_network/view_edit_practices/view_edit_practices.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:dental_key/main_screen.dart';
import 'package:dental_key/marketplace/practices_network/add_new_practice.dart';

class PracticeManagementScreen extends StatefulWidget {
  final String ownerId;

  PracticeManagementScreen({required this.ownerId});

  @override
  _PracticeManagementScreenState createState() =>
      _PracticeManagementScreenState();
}

class _PracticeManagementScreenState extends State<PracticeManagementScreen> {
  List<dynamic> practices = [];
  Map<String, dynamic>? ownerDetails;
  bool isLoading = true;
  String errorMessage = '';
  bool isOwnerCardExpanded = false;
  bool isEditing = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  Color getStatusColor(String? status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending Verification':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      case 'Suspended':
        return Colors.grey;
      case 'Awaiting Payment':
        return Colors.blueGrey;
      default:
        return Colors.blue;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    await fetchOwnerDetails();
    await fetchPractices();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchOwnerDetails() async {
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/get-owner-details/${widget.ownerId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          ownerDetails = decoded;
          nameController.text = decoded['full_name'] ?? '';
          phoneController.text = decoded['phone_number'] ?? '';
          emailController.text = decoded['email'] ?? '';
          companyController.text = decoded['company_registered_name'] ?? '';
          countryController.text = decoded['country_of_origin'] ?? '';
          statusController.text = decoded['registration_status'] ?? '';
        });
      } else {
        setState(() {
          errorMessage = "Failed to load owner details.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error. Please try again!";
      });
    }
  }

  Future<void> fetchPractices() async {
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/get-practices/${widget.ownerId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          practices = jsonDecode(response.body);
        });
      } else {
        setState(() {
          errorMessage = "Failed to load practices.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error. Please try again!";
      });
    }
  }

  Future<void> deletePractice(String practiceId) async {
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/delete-practice/$practiceId");

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Practice deleted successfully!")),
        );
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete practice.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error. Please try again!")),
      );
    }
  }

  Future<void> showUpgradeDialog(BuildContext parentContext) async {
    // Store safe context
    final scaffoldContext = context;

    // Step 1: Show loader using root navigator
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Step 2: Fetch plans
    final response = await http.get(
      Uri.parse(
          "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/get-all-plans/"),
    );

    // Step 3: Dismiss loader using root navigator
    if (mounted) {
      Navigator.of(parentContext, rootNavigator: true).pop();
    }

    if (response.statusCode != 200) {
      if (mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(content: Text("Failed to fetch plans")),
        );
      }
      return;
    }

    final List<dynamic> plans = jsonDecode(response.body);
    final String currentPlanName = ownerDetails?['plan']?['name'] ?? '';
    final String ownerId = widget.ownerId;

    // Step 4: Show upgrade dialog
    if (!mounted) return;

    showDialog(
      context: scaffoldContext,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Upgrade Your Plan",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final planName = plan['name'];
                      final price = plan['monthly_price'];
                      final maxPractices = plan['max_practices'];
                      final planId = plan['id'].toString();
                      final isCurrent = planName == currentPlanName;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.workspace_premium,
                                      size: 26, color: Colors.teal[700]),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "$planName Plan",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isCurrent)
                                    Chip(
                                      label: const Text("Current"),
                                      backgroundColor: Colors.grey[300],
                                      labelStyle:
                                          const TextStyle(color: Colors.black),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "£$price/month • Up to $maxPractices practices",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700]),
                              ),
                              if (!isCurrent) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side:
                                          const BorderSide(color: Colors.teal),
                                      foregroundColor: Colors.teal[700],
                                    ),
                                    onPressed: () async {
                                      Navigator.of(ctx)
                                          .pop(); // Close plan dialog

                                      // Show loader again using parent context
                                      showDialog(
                                        context: parentContext,
                                        barrierDismissible: false,
                                        builder: (_) => const Center(
                                            child: CircularProgressIndicator()),
                                      );

                                      // API request
                                      final upgradeResponse = await http.post(
                                        Uri.parse(
                                            "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/request-upgrade/"),
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: jsonEncode({
                                          'owner_id': ownerId,
                                          'plan_id': planId,
                                        }),
                                      );

                                      // Dismiss loader
                                      if (mounted) {
                                        Navigator.of(parentContext,
                                                rootNavigator: true)
                                            .pop();
                                      }

                                      if (!mounted) return;

                                      if (upgradeResponse.statusCode == 201) {
                                        final msg =
                                            jsonDecode(upgradeResponse.body)[
                                                    'message'] ??
                                                "Request sent!";
                                        ScaffoldMessenger.of(scaffoldContext)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(msg),
                                              backgroundColor: Colors.green),
                                        );
                                      } else {
                                        final errMsg =
                                            jsonDecode(upgradeResponse.body)[
                                                    'detail'] ??
                                                "Upgrade failed.";
                                        ScaffoldMessenger.of(scaffoldContext)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text("Error: $errMsg"),
                                              backgroundColor: Colors.red),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.upgrade),
                                    label: const Text("Request Upgrade"),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(scaffoldContext).pop(),
                  child: const Text("Close",
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void navigateToAddPractice() {
    final int maxAllowed = int.tryParse(
            ownerDetails?['plan']?['max_practices']?.toString() ?? '1') ??
        1;
    final int totalPractices =
        practices.length; // ✅ Actual registered practices

    if (totalPractices >= maxAllowed) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Practice Limit Reached"),
          content: Text(
            "⚠️ You declared $totalPractices practices,\n"
            "but your current plan allows only $maxAllowed.\nPlease upgrade your plan.",
            style: TextStyle(
              color: Colors.red[800],
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: Icon(Icons.upgrade),
              label: Text("Upgrade Plan"),
              onPressed: () => showUpgradeDialog(context),
            )
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPracticeScreen(ownerId: widget.ownerId),
      ),
    ).then((_) => fetchData()); // ✅ Refresh after practice added
  }

  Future<void> showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log Out"),
          content: Text(
              "Are you sure you want to log out and return to the main screen?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Log Out", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    await showLogoutConfirmationDialog();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final String ownerName = ownerDetails?['full_name'] ?? '';

    final int totalPractices = practices.length;
    final int allowedPractices = int.tryParse(
            ownerDetails?['plan']?['max_practices']?.toString() ?? '1') ??
        1;
    final int numberOfDeclaredNumberofPractices =
        int.tryParse(ownerDetails?['number_of_practices']?.toString() ?? '1') ??
            1;

    final String monthlyPrice =
        ownerDetails?['plan']?['monthly_price']?.toString() ?? '0.00';
    final String planName = ownerDetails?['plan']?['name'] ?? 'Unknown';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Welcome back, $ownerName"),
          leading: IconButton(
            tooltip: 'Log out',
            onPressed: showLogoutConfirmationDialog,
            icon: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.1416), // 180° in radians
              child: Icon(Icons.logout),
            ),
          ),
          actions: [
            IconButton(icon: Icon(Icons.refresh), onPressed: fetchData),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: fetchData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  if (ownerDetails != null) ...[
                    buildOwnerCard(),
                    buildPlanCards(planName, monthlyPrice, allowedPractices,
                        totalPractices),
                  ],

                  if (numberOfDeclaredNumberofPractices > allowedPractices)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Card(
                        color: Colors.red[50],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.red[800]),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Your plan allows only $allowedPractices practices.\nYou have told that you have $numberOfDeclaredNumberofPractices practices under your name.",
                                      style: TextStyle(
                                          color: Colors.red[800],
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () => showUpgradeDialog(context),
                                icon: Icon(Icons.upgrade),
                                label: Text("Upgrade Plan"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 15),

                  /// 🏥 Practice List
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : practices.isEmpty
                          ? Center(
                              child: Text("No practices found. Add a new one!"))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: practices.length,
                              itemBuilder: (context, index) {
                                final practice = practices[index];
                                return Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.teal[100],
                                        radius: 24,
                                        child: Icon(Icons.local_hospital,
                                            color: Colors.teal[800], size: 28),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              practice['practice_name'] ??
                                                  'Unnamed Practice',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(
                                                  practice['status']),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              practice['status'] ?? '',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text("ID: ${practice['id']}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700])),
                                      trailing: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16),
                                      onTap: () {
                                        final status = practice['status'] ?? '';

                                        if (status == 'Pending Verification') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "⏳ This practice is pending verification. Access is temporarily restricted."),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          return;
                                        }

                                        if (status == 'Rejected') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "❌ This practice was rejected. Please contact support."),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                          return;
                                        }

                                        if (status == 'Suspended') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "🚫 This practice is suspended. Access is disabled."),
                                              backgroundColor: Colors.grey,
                                            ),
                                          );
                                          return;
                                        }

                                        // ✅ Allow access for Approved & Awaiting Payment
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewEditPracticeScreen(
                                              ownerId: widget.ownerId,
                                              practiceId: practice['id'],
                                            ),
                                          ),
                                        ).then((result) {
                                          if (result == true) fetchData();
                                        });
                                      }),
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: navigateToAddPractice,
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          SizedBox(width: 8),
          Text("$label: ",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey[800])),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOwnerCard() {
    final name = ownerDetails?['full_name'] ?? '';
    final phone = ownerDetails?['phone_number'] ?? '';
    final email = ownerDetails?['email'] ?? '';
    final company = ownerDetails?['company_registered_name'] ?? '';
    final country = ownerDetails?['country_of_origin'] ?? '';
    final declared = ownerDetails?['number_of_practices'] ?? 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditOwnerProfileScreen(
              ownerDetails: ownerDetails!,
            ),
          ),
        ).then((_) => fetchData()); // Refresh after editing
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.business, color: Colors.teal, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      company,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Divider(thickness: 1),
              buildInfoRow(Icons.email, "Email", email),
              buildInfoRow(Icons.phone, "Phone", phone),
              buildInfoRow(Icons.flag, "Country", country),
              buildInfoRow(
                  Icons.layers, "Practices Declared", declared.toString(),
                  valueColor: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlanCards(
      String planName, String planPrice, int allowed, int using) {
    final List<Map<String, dynamic>> cardData = [
      {
        "icon": Icons.workspace_premium,
        "title": "Plan",
        "value": planName,
        "color": Colors.teal
      },
      {
        "icon": Icons.monetization_on,
        "title": "Price",
        "value": "£$planPrice/mo",
        "color": Colors.indigo
      },
      {
        "icon": Icons.verified_user,
        "title": "Allowed",
        "value": "$allowed",
        "color": Color.fromARGB(255, 214, 119, 180)
      },
      {
        "icon": Icons.bar_chart,
        "title": "Using",
        "value": "$using",
        "color": Colors.orange
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: cardData.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1, // square
        ),
        itemBuilder: (context, index) {
          final data = cardData[index];
          return buildInfoCard(
            data['icon'],
            data['title'],
            data['value'],
            data['color'],
          );
        },
      ),
    );
  }

  Widget buildInfoCard(IconData icon, String title, String value, Color color) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
            SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditableField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> saveOwnerEdits() async {
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/update-profile/");
    print(jsonEncode({
      "id": widget.ownerId,
      "full_name": nameController.text,
      "phone_number": phoneController.text,
      "company_registered_name": companyController.text,
      "country_of_origin": countryController.text,
    }));

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "id": widget.ownerId,
        "full_name": nameController.text,
        "phone_number": phoneController.text,
        "company_registered_name": companyController.text,
        "country_of_origin": countryController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        isEditing = false;
        fetchData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile")),
      );
    }
  }
}
