import 'package:dental_key/dental_portal/mainscreen/dentalportal_main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../notification_provider.dart';
import 'package:logging/logging.dart';

class DentalNotificationPage extends StatefulWidget {
  final String accessToken;

  DentalNotificationPage({required this.accessToken});

  @override
  _DentalNotificationPageState createState() => _DentalNotificationPageState();
}

class _DentalNotificationPageState extends State<DentalNotificationPage> {
  List notifications = [];
  List filteredNotifications = [];
  bool isLoading = true;
  String filter = 'All';
  final Logger _logger = Logger('DentalNotificationPage');

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    const String baseUrl = 'https://dental-key-738b90a4d87a.herokuapp.com';

    try {
      _logger.info('Fetching notifications...');
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/display/'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _logger.info(
            'Notifications fetched successfully: ${responseData.length} items');

        if (mounted) {
          setState(() {
            notifications = responseData.map((notification) {
              return {
                'id': notification['id'],
                'title': notification['title'] ?? 'No title',
                'message': notification['message'] ?? 'No message',
                'image': notification['image'] != null
                    ? '${notification['image']}'
                    : '',
                'created_at': notification['created_at'] ?? '',
                'publish_at': notification['publish_at'] ?? '',
              };
            }).toList();

            // Sort notifications by publish_at in descending order
            notifications.sort((a, b) => DateTime.parse(b['publish_at'])
                .compareTo(DateTime.parse(a['publish_at'])));

            filterNotifications();
            updateUnreadCount();
            isLoading = false;
          });
        }
      } else {
        _logger
            .warning('Failed to fetch notifications: ${response.statusCode}');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      _logger.severe('Error fetching notifications: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void updateUnreadCount() {
    SharedPreferences.getInstance().then((prefs) {
      List<String> unreadIds = notifications
          .where((notification) {
            return !(prefs.getBool(notification['id'].toString()) ?? false);
          })
          .map((notification) => notification['id'].toString())
          .toList();
      _logger.info('Unread notifications count: ${unreadIds.length}');
      Provider.of<NotificationProvider>(context, listen: false)
          .setUnreadNotificationIndices(unreadIds);
    });
  }

  Future<void> _refreshNotifications() async {
    await fetchNotifications();
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              DentalPortalMain(accessToken: widget.accessToken)),
    );
    return false;
  }

  void filterNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (filter == 'Unread') {
        filteredNotifications = notifications.where((notification) {
          return !(prefs.getBool(notification['id'].toString()) ?? false);
        }).toList();
      } else if (filter == 'Read') {
        filteredNotifications = notifications.where((notification) {
          return prefs.getBool(notification['id'].toString()) ?? false;
        }).toList();
      } else {
        filteredNotifications = notifications;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          automaticallyImplyLeading: true,
          centerTitle: false,
          backgroundColor: Color(0xFF385A92),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          actions: [
            DropdownButton<String>(
              value: filter,
              icon: Icon(Icons.filter_list, color: Colors.white),
              dropdownColor: Color(0xFF385A92),
              underline: SizedBox(),
              onChanged: (String? newValue) {
                setState(() {
                  filter = newValue!;
                  filterNotifications();
                });
              },
              items: <String>['All', 'Unread', 'Read']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshNotifications,
                child: ListView.builder(
                  itemCount: filteredNotifications.length,
                  itemBuilder: (BuildContext context, int index) {
                    return NotificationCard(
                      notification: filteredNotifications[index],
                      updateUnreadCount: updateUnreadCount,
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback updateUnreadCount;

  NotificationCard(
      {required this.notification, required this.updateUnreadCount});

  Future<void> markAsRead(BuildContext context, String notificationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(notificationId, true);
    Provider.of<NotificationProvider>(context, listen: false)
        .removeUnreadNotificationIndex(notificationId);
    updateUnreadCount();
  }

  Future<bool> isNotificationRead(String notificationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationId) ?? false;
  }

  String timeAgo(String publishAt) {
    final DateTime publishDate = DateTime.parse(publishAt);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(publishDate);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day(s) ago';
    } else {
      return DateFormat.yMMMd().format(publishDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isNotificationRead(notification['id'].toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        bool isRead = snapshot.data ?? false;

        return InkWell(
          onTap: () async {
            await markAsRead(context, notification['id'].toString());
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final double screenHeight = MediaQuery.of(context).size.height;
                return AlertDialog(
                  title: Text(notification['title']),
                  content: SizedBox(
                    height: screenHeight * 0.4,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          notification['image'] != ''
                              ? Image.network(notification['image'])
                              : SizedBox.shrink(),
                          SizedBox(height: 8.0),
                          Text(notification['message']),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    Text(
                      '${timeAgo(notification['publish_at'])}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: isRead
                ? const Color.fromARGB(255, 255, 255, 255)
                : Color.fromARGB(255, 238, 238, 238),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: notification['image'] != ''
                        ? NetworkImage(notification['image'])
                        : AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                    radius: 30.0,
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          notification['message'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          '${timeAgo(notification['publish_at'])}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
