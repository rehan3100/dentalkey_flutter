import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewAppointmentRequestsScreen extends StatefulWidget {
  final String practiceId;

  ViewAppointmentRequestsScreen({required this.practiceId});

  @override
  _ViewAppointmentRequestsScreenState createState() =>
      _ViewAppointmentRequestsScreenState();
}

class _ViewAppointmentRequestsScreenState
    extends State<ViewAppointmentRequestsScreen> {
  List requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final url = Uri.parse(
        "https://your-api.com/practices_setup/incoming-requests/?practice_id=${widget.practiceId}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        requests = jsonDecode(response.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      print("Failed to fetch appointment requests");
    }
  }

  void showConfirmDialog(Map request) async {
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final durationController = TextEditingController(text: '15');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Appointment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("For: ${request['requested_for']['full_name']}"),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: "Date (YYYY-MM-DD)"),
            ),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: "Time (HH:MM)"),
            ),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Duration (min)"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            child: Text("Confirm"),
            onPressed: () async {
              final url = Uri.parse(
                  "https://your-api.com/practices_setup/confirm-appointment/");
              final res = await http.post(
                url,
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "request_id": request['id'],
                  "date": dateController.text,
                  "time": timeController.text,
                  "duration_minutes":
                      int.tryParse(durationController.text) ?? 15,
                }),
              );

              Navigator.pop(context);

              if (res.statusCode == 201) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Appointment confirmed.")));
                fetchRequests();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to confirm appointment.")));
              }
            },
          ),
        ],
      ),
    );
  }

  void showDeclineDialog(Map request) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Decline Request"),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(labelText: "Reason"),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            child: Text("Decline"),
            onPressed: () async {
              final url = Uri.parse(
                  "https://your-api.com/practices_setup/decline-appointment-request/");
              final res = await http.post(
                url,
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "request_id": request['id'],
                  "decline_reason": reasonController.text,
                }),
              );

              Navigator.pop(context);

              if (res.statusCode == 200) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Request declined.")));
                fetchRequests();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to decline request.")));
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Appointment Requests")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? Center(child: Text("No pending requests."))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (_, i) {
                    final r = requests[i];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(r['requested_for']['full_name']),
                        subtitle: Text("${r['nature']} - ${r['mode']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => showConfirmDialog(r),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => showDeclineDialog(r),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
