import 'package:dental_key/dental_portal/mainscreen/new_message_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../unread_provider.dart';
import 'dentalportal_main.dart';
import 'chat_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:async';

class RehanChatPage extends StatefulWidget {
  final String accessToken;

  RehanChatPage({required this.accessToken});

  @override
  _RehanChatPageState createState() => _RehanChatPageState();
}

class _RehanChatPageState extends State<RehanChatPage> {
  String? profilePictureUrl;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequests = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();
  SharedPreferences? prefs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initPreferences();
    fetchUserProfile();
    fetchRequests();
    searchController.addListener(_filterRequests);
    _startTimer();
  }

  Future<void> _initPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> markAsRead(String requestId, int index) async {
    final String apiUrl =
        'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/requests/update/$requestId/';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json'
        },
        body: json.encode({'is_read': true}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            requests[index]['is_read'] = true;
            filteredRequests[index]['is_read'] = true;
          });
        }
        await prefs?.setBool(requestId, true);
      } else {
        print('Failed to mark as read: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to mark as read: $error');
    }
  }

  Future<void> fetchUserProfile() async {
    var uri = Uri.parse(
        "https://dental-key-738b90a4d87a.herokuapp.com/users/details/");
    var response = await http.get(uri, headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print('User Profile Data: $data');
      if (mounted) {
        setState(() {
          profilePictureUrl = data['profile_picture'];
          print('Profile Picture URL: $profilePictureUrl');
        });
      }
    } else {
      print("Failed to fetch user profile: ${response.statusCode}");
    }
  }

  Future<void> fetchRequests() async {
    final String apiUrl =
        'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/get_requests/';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> fetchedRequests = json.decode(response.body);

        fetchedRequests = fetchedRequests.map((request) {
          String requestId = request['id'];
          request['is_read'] = request['is_read'] ?? false;
          return request;
        }).toList();

        fetchedRequests.sort((a, b) {
          DateTime dateA = DateTime.tryParse(a['modified_on'] ?? '') ??
              DateTime.parse(a['created_on']);
          DateTime dateB = DateTime.tryParse(b['modified_on'] ?? '') ??
              DateTime.parse(b['created_on']);
          return dateB.compareTo(dateA);
        });

        if (mounted) {
          setState(() {
            requests = List<Map<String, dynamic>>.from(fetchedRequests);
            filteredRequests = List<Map<String, dynamic>>.from(fetchedRequests);
            isLoading = false;
          });
        }

        final unreadProvider =
            Provider.of<UnreadProvider>(context, listen: false);
        unreadProvider.setUnreadIndices(getUnreadIndices());
      } else {
        print('Failed to fetch requests: ${response.statusCode}');
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = 'Failed to fetch requests';
          });
        }
      }
    } catch (error) {
      print('Failed to fetch requests: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch requests';
        });
      }
    }
  }

  Future<void> _refreshRequests() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    await fetchRequests();
    await fetchUserProfile();
  }

  void _filterRequests() {
    String query = searchController.text.toLowerCase();
    if (mounted) {
      setState(() {
        filteredRequests = requests.where((request) {
          String message = request['message'].toLowerCase();
          String replyMessage = request['reply_message']?.toLowerCase() ?? '';
          return message.contains(query) || replyMessage.contains(query);
        }).toList();
      });
    }
  }

  List<int> getUnreadIndices() {
    List<int> unreadIndices = [];
    for (int i = 0; i < requests.length; i++) {
      if (!requests[i]['is_read']) {
        unreadIndices.add(i);
      }
    }
    return unreadIndices;
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return 'N/A';
    }
    DateTime dateTime = DateTime.parse(dateTimeStr);
    return timeago.format(dateTime);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    searchController.removeListener(_filterRequests);
    searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Chats'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              icon: SizedBox(
                                width: 30,
                                height: 40,
                                child: Image.asset(
                                    'assets/images/new_message.png'),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewMessagePage(
                                      accessToken: widget.accessToken,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshRequests,
                          child: ListView.builder(
                            itemCount: filteredRequests.length,
                            itemBuilder: (context, index) {
                              var request = filteredRequests[index];
                              bool hasReply =
                                  request['reply_message'] != null &&
                                      request['reply_message'].isNotEmpty;
                              String displayText = hasReply
                                  ? request['reply_message']
                                  : request['message'];
                              String displayDate = hasReply
                                  ? request['modified_on']
                                  : request['created_on'];
                              String? displayAttachment = hasReply
                                  ? request['reply_attachment']
                                  : request['attachment'];

                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatDetails(
                                        message: request['message'],
                                        attachment: request['attachment'],
                                        replyMessage: request['reply_message'],
                                        replyAttachment:
                                            request['reply_attachment'],
                                        createdOn: request['created_on'],
                                        modifiedOn: request['modified_on'],
                                      ),
                                    ),
                                  );
                                  await markAsRead(request['id'], index);

                                  final unreadProvider =
                                      Provider.of<UnreadProvider>(context,
                                          listen: false);
                                  unreadProvider
                                      .setUnreadIndices(getUnreadIndices());
                                },
                                child: Card(
                                  margin: EdgeInsets.all(10),
                                  color: request['is_read']
                                      ? Color.fromARGB(255, 247, 253, 255)
                                      : Color.fromARGB(255, 220, 248, 255),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Container(
                                      height: 70,
                                      alignment: Alignment.center,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Stack(
                                            children: [
                                              profilePictureUrl != null
                                                  ? ClipOval(
                                                      child: Image.network(
                                                        profilePictureUrl!,
                                                        width: 60,
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : _buildDefaultAvatar(),
                                              if (!request['is_read'])
                                                Positioned(
                                                  right: 0,
                                                  child: CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor: Colors.red,
                                                    child: Text(
                                                      '!',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  displayText,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        request['is_read']
                                                            ? FontWeight.normal
                                                            : FontWeight.bold,
                                                  ),
                                                ),
                                                if (displayAttachment != null)
                                                  SizedBox(height: 5),
                                                if (displayAttachment != null)
                                                  Row(
                                                    children: [
                                                      Icon(Icons.attachment),
                                                      SizedBox(width: 5),
                                                      Text('Attachment'),
                                                    ],
                                                  ),
                                                SizedBox(height: 5),
                                                Text(
                                                  _formatDateTime(displayDate),
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 30,
      child: Text('U'),
    );
  }
}
