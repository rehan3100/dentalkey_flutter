import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dental_key/marketplace/practices_network/view_edit_practices/practices_roles_setup/practice_role.dart';

class RoleFormScreen extends StatefulWidget {
  final String practiceId;
  final PracticeRole? existingRole;

  const RoleFormScreen({Key? key, required this.practiceId, this.existingRole})
      : super(key: key);

  @override
  State<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final TextEditingController _titleController = TextEditingController();
  Map<String, List<Map<String, dynamic>>> groupedPermissions = {};
  Set<String> selectedPermissionIds = {};
  bool isLoading = true;
  bool isSubmitting = false; // 🔄 NEW

  @override
  void initState() {
    super.initState();
    if (widget.existingRole != null) {
      _titleController.text = widget.existingRole!.title;
      fetchExistingRoleDetails();
    } else {
      fetchPermissions();
    }
  }

  Future<void> fetchExistingRoleDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final ownerEmail = prefs.getString('owner_email') ?? '';

    final res = await http.get(
      Uri.parse(
          "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/practice-role/${widget.existingRole!.id}/"),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Email': ownerEmail,
      },
    );

    if (res.statusCode == 200) {
      final roleData = json.decode(res.body);
      _titleController.text = roleData['title'];
      selectedPermissionIds = (roleData['permissions'] as List)
          .map((perm) => perm['id'].toString())
          .toSet();
      await fetchPermissions();
    } else {
      showError("Failed to load role details");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchPermissions() async {
    final res = await http.get(Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/permissions/grouped/"));
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      setState(() {
        groupedPermissions =
            data.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v)));
        isLoading = false;
      });
    } else {
      showError("Failed to load permissions");
    }
  }

  void submitForm() async {
    setState(() => isSubmitting = true); // 🔄 Start loading
    final prefs = await SharedPreferences.getInstance();
    final ownerEmail = prefs.getString('owner_email') ?? '';

    final payload = {
      "title": _titleController.text.trim(),
      "practice": widget.practiceId,
      "permissions": selectedPermissionIds.toList(),
    };

    final url = widget.existingRole == null
        ? "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/practice-role/"
        : "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/practice-role/${widget.existingRole!.id}/";

    final headers = {
      'Content-Type': 'application/json',
      'X-User-Email': ownerEmail,
    };

    final response = widget.existingRole == null
        ? await http.post(Uri.parse(url),
            headers: headers, body: json.encode(payload))
        : await http.put(Uri.parse(url),
            headers: headers, body: json.encode(payload));

    setState(() => isSubmitting = false); // 🔄 Stop loading

    if (response.statusCode == 201 || response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      showError("Failed to save role");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRole == null ? "Create Role" : "Edit Role"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Role Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Text("Select Permissions",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ...groupedPermissions.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: entry.value.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 6,
                          childAspectRatio: 4.5,
                        ),
                        itemBuilder: (context, index) {
                          final perm = entry.value[index];
                          final id = perm['id'].toString();
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: selectedPermissionIds.contains(id),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedPermissionIds.add(id);
                                } else {
                                  selectedPermissionIds.remove(id);
                                }
                              });
                            },
                            title: Text(
                              perm['name'],
                              style: TextStyle(fontSize: 13),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submitForm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(widget.existingRole == null
                          ? "Create Role"
                          : "Update Role"),
                )
              ],
            ),
    );
  }
}
