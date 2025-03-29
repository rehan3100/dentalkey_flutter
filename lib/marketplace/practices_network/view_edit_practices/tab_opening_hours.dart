import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OpeningHoursTab extends StatefulWidget {
  final String ownerId;
  final String practiceId;

  OpeningHoursTab({required this.ownerId, required this.practiceId});

  @override
  _OpeningHoursTabState createState() => _OpeningHoursTabState();
}

class _OpeningHoursTabState extends State<OpeningHoursTab> {
  List<Map<String, dynamic>> openingHours = [];
  bool isLoading = true;

  final List<String> weekdays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  @override
  void initState() {
    super.initState();
    fetchOpeningHours();
  }

  Future<void> fetchOpeningHours() async {
    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/opening-hours/${widget.practiceId}/");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (mounted) {
          if (data.isEmpty) {
            initDefaultHours();
          } else {
            Map<String, Map<String, dynamic>> tempMap = {
              for (var item in data)
                item['day']: {
                  "day": item['day'],
                  "is_closed": item['is_closed'],
                  "opening_time": item['opening_time'] != null
                      ? _parseTime(item['opening_time'])
                      : TimeOfDay(hour: 9, minute: 0),
                  "closing_time": item['closing_time'] != null
                      ? _parseTime(item['closing_time'])
                      : TimeOfDay(hour: 17, minute: 0),
                }
            };

            openingHours = weekdays.map((day) {
              return tempMap.containsKey(day)
                  ? tempMap[day]!
                  : {
                      "day": day,
                      "is_closed": false,
                      "opening_time": TimeOfDay(hour: 9, minute: 0),
                      "closing_time": TimeOfDay(hour: 17, minute: 0),
                    };
            }).toList();
          }
          setState(() => isLoading = false);
        }
      } else {
        print("❌ Failed to load opening hours");
        initDefaultHours();
      }
    } catch (e) {
      print("❌ Error: $e");
      initDefaultHours();
    }
  }

  void initDefaultHours() {
    openingHours = weekdays.map((day) {
      return {
        "day": day,
        "is_closed": false,
        "opening_time": TimeOfDay(hour: 9, minute: 0),
        "closing_time": TimeOfDay(hour: 17, minute: 0),
      };
    }).toList();
    if (mounted) setState(() => isLoading = false);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> saveOpeningHours() async {
    final List<Map<String, dynamic>> formattedData = openingHours.map((day) {
      return {
        "practice": widget.practiceId,
        "day": day['day'],
        "is_closed": day['is_closed'],
        "opening_time":
            day['is_closed'] ? null : _formatTime(day['opening_time']),
        "closing_time":
            day['is_closed'] ? null : _formatTime(day['closing_time']),
      };
    }).toList();

    final url = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/save-opening-hours/${widget.practiceId}/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formattedData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Opening hours saved successfully!")),
        );
        fetchOpeningHours();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to save opening hours.")),
        );
      }
    } catch (e) {
      print("❌ Error while saving: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Network error. Try again.")),
      );
    }
  }

  Future<void> selectTime(
      BuildContext context, int index, bool isOpening) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpening
          ? openingHours[index]['opening_time']
          : openingHours[index]['closing_time'],
    );

    if (picked != null) {
      setState(() {
        if (isOpening) {
          openingHours[index]['opening_time'] = picked;
        } else {
          openingHours[index]['closing_time'] = picked;
        }
      });
    }
  }

  Widget buildDayCard(int index) {
    final day = openingHours[index];
    final isClosed = day['is_closed'];

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🟩 Row: Day + Closed Checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day['day'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.teal,
                  ),
                ),
                Row(
                  children: [
                    Text("Closed"),
                    Checkbox(
                      value: isClosed,
                      onChanged: (val) {
                        setState(() => day['is_closed'] = val ?? false);
                      },
                    ),
                  ],
                ),
              ],
            ),

            /// 🕘 Row: Opening and Closing Times
            if (!isClosed)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => selectTime(context, index, true),
                        child: Chip(
                          label: Text(
                              "Open: ${day['opening_time'].format(context)}"),
                          backgroundColor: Colors.green.shade50,
                          labelStyle: TextStyle(color: Colors.green.shade800),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => selectTime(context, index, false),
                        child: Chip(
                          label: Text(
                              "Close: ${day['closing_time'].format(context)}"),
                          backgroundColor: Colors.red.shade50,
                          labelStyle: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SafeArea(
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: openingHours.length,
                        itemBuilder: (context, index) => buildDayCard(index),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text("Save Opening Hours"),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: saveOpeningHours,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
  }
}
