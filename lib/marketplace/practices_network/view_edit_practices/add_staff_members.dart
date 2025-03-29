import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class InviteStaffScreen extends StatefulWidget {
  final String practiceId;
  final String ownerEmail;

  const InviteStaffScreen({
    super.key,
    required this.practiceId,
    required this.ownerEmail,
  });

  @override
  State<InviteStaffScreen> createState() => _InviteStaffScreenState();
}

class _InviteStaffScreenState extends State<InviteStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _joiningDate;
  DateTime? _endDate;
  int _noticePeriodWeeks = 12;

  String _staffType = 'Clinical';
  String? _selectedRoleId;
  List<PracticeRole> _roles = [];
  bool isLoadingRoles = true;
  bool isSubmitting = false;
  String? _responseMessage;

  @override
  void initState() {
    super.initState();
    loadRoles();
  }

  Future<void> loadRoles() async {
    final url = Uri.parse(
      "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/practice-role/?practice=${widget.practiceId}",
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Email': widget.ownerEmail,
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        _roles = data.map((json) => PracticeRole.fromJson(json)).toList();
        isLoadingRoles = false;
      });
    } else {
      setState(() => isLoadingRoles = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to load practice roles")),
      );
    }
  }

  Future<void> inviteStaff() async {
    setState(() => isSubmitting = true);

    final url = Uri.parse(
      'https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/invite-staff/',
    );

    final body = jsonEncode({
      'email': _emailController.text.trim(),
      'staff_type': _staffType,
      'practice': widget.practiceId,
      'practice_role': _selectedRoleId,
      'notice_period_weeks': _noticePeriodWeeks,
      'date_joining': _joiningDate != null
          ? DateFormat('yyyy-MM-dd').format(_joiningDate!)
          : null,
      'date_ending':
          _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-User-Email': widget.ownerEmail,
        },
        body: body,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = data['message'] +
            (data['signup_link'] != null
                ? "\nSignup Link: ${data['signup_link']}"
                : "");

        setState(() => _responseMessage = message);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) Navigator.pop(context, true);
      } else {
        setState(
            () => _responseMessage = data['error'] ?? "Failed to send invite");
      }
    } catch (e) {
      setState(() => _responseMessage = "Error: $e");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> pickDate({
    required BuildContext context,
    required DateTime? currentDate,
    required ValueChanged<DateTime> onPicked,
    required DateTime firstDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime(2035),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invite New Staff")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  DropdownButtonFormField<String>(
                    value: _staffType,
                    decoration: const InputDecoration(labelText: 'Staff Type'),
                    items: ['Clinical', 'Non-Clinical']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _staffType = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Staff Email'),
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  isLoadingRoles
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          value: _selectedRoleId,
                          decoration:
                              const InputDecoration(labelText: 'Assign Role'),
                          items: _roles
                              .map((role) => DropdownMenuItem<String>(
                                    value: role.id,
                                    child: Text(role.title),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedRoleId = value),
                          validator: (value) =>
                              value == null ? 'Please select a role' : null,
                        ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Start Date'),
                    controller: TextEditingController(
                      text: _joiningDate != null
                          ? DateFormat('yyyy-MM-dd').format(_joiningDate!)
                          : '',
                    ),
                    onTap: () {
                      pickDate(
                        context: context,
                        currentDate: _joiningDate,
                        onPicked: (picked) =>
                            setState(() => _joiningDate = picked),
                        firstDate: DateTime(2023),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'End Date (optional)'),
                    controller: TextEditingController(
                      text: _endDate != null
                          ? DateFormat('yyyy-MM-dd').format(_endDate!)
                          : '',
                    ),
                    onTap: () {
                      pickDate(
                        context: context,
                        currentDate: _endDate,
                        onPicked: (picked) => setState(() => _endDate = picked),
                        firstDate:
                            DateTime(2000), // or any reasonable past date
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: '12',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Notice Period (in weeks)',
                    ),
                    onChanged: (value) {
                      _noticePeriodWeeks = int.tryParse(value) ?? 12;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text("Send Invite"),
                    onPressed: isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              inviteStaff();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_responseMessage != null)
                    Text(
                      _responseMessage!,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PracticeRole {
  final String id;
  final String title;

  PracticeRole({required this.id, required this.title});

  factory PracticeRole.fromJson(Map<String, dynamic> json) {
    return PracticeRole(
      id: json['id'],
      title: json['title'],
    );
  }
}
