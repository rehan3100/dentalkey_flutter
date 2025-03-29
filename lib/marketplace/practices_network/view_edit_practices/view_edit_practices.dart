import 'package:dental_key/marketplace/practices_network/view_edit_practices/tab_change_package.dart';
import 'package:dental_key/marketplace/practices_network/view_edit_practices/practices_roles_setup/tab_practice_positions.dart';
import 'package:dental_key/marketplace/practices_network/view_edit_practices/tab_staff_members.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'tab_basic_details.dart';
import 'tab_practice_pictures.dart';
import 'tab_opening_hours.dart';
import 'tab_services.dart';
import 'tab_reviews.dart';

class ViewEditPracticeScreen extends StatefulWidget {
  final String ownerId;
  final String practiceId;
  final int initialTabIndex; // ✅ Add this

  const ViewEditPracticeScreen({
    super.key,
    required this.ownerId,
    required this.practiceId,
    this.initialTabIndex = 0, // ✅ Default to tab 0 (Basic Details)
  });
  @override
  State<ViewEditPracticeScreen> createState() => _ViewEditPracticeScreenState();
}

class _ViewEditPracticeScreenState extends State<ViewEditPracticeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  bool isDeleting = false;

  int numberOfChairs = 1;
  String practiceName = "Practice";

  final List<Tab> tabs = const [
    Tab(icon: Icon(Icons.info), text: "Basic Details"),
    Tab(icon: Icon(Icons.workspace_premium), text: "Package"),
    Tab(icon: Icon(Icons.image), text: "Pictures"),
    Tab(icon: Icon(Icons.access_time), text: "Opening Hours"),
    Tab(icon: Icon(Icons.medical_services), text: "Services"),
    Tab(icon: Icon(Icons.reviews), text: "Reviews"),
    Tab(icon: Icon(Icons.manage_accounts), text: "Roles"),
    Tab(icon: Icon(Icons.people), text: "Staff"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex, // ✅ FIXED
    );
    fetchPracticeDetails();
  }

  Future<void> fetchPracticeDetails() async {
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/get-practice/${widget.practiceId}/");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          numberOfChairs = data['number_of_chairs'] ?? 1;
          practiceName = data['practice_name'] ?? "Practice";
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load practice details.");
      }
    } catch (e) {
      print("❌ Error fetching practice: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deletePractice() async {
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/delete-practice/${widget.practiceId}/");

    setState(() => isDeleting = true);

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Practice deleted successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete practice.")),
        );
      }
    } catch (e) {
      print("❌ Delete Error: $e");
    }

    setState(() => isDeleting = false);
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Practice"),
        content: const Text(
            "Are you sure you want to permanently delete this practice?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              deletePractice();
            },
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          practiceName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[100]),
            tooltip: "Delete Practice",
            onPressed: isDeleting ? null : confirmDelete,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BasicDetailsScreen(
            ownerId: widget.ownerId,
            practiceId: widget.practiceId,
          ),
          PracticePackageScreen(practiceId: widget.practiceId),
          PicturesTab(
            practiceId: widget.practiceId,
            numberOfChairs: numberOfChairs,
          ),
          OpeningHoursTab(
            ownerId: widget.ownerId,
            practiceId: widget.practiceId,
          ),
          ServicesTab(practiceId: widget.practiceId),
          ReviewsTab(practiceId: widget.practiceId),
          PracticeRolesScreen(practiceId: widget.practiceId),
          FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());

              final prefs = snapshot.data!;
              final ownerEmail = prefs.getString('owner_email') ?? '';

              return StaffListScreen(
                practiceId: widget.practiceId,
                ownerEmail: ownerEmail,
              );
            },
          ),
        ],
      ),
    );
  }
}
