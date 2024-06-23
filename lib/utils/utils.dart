// C:\Users\wkhan\dentalkey\lib\utils\request_utils.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../unread_provider.dart';

Future<void> fetchAndSetUnreadRequests(
    BuildContext context, String accessToken) async {
  final String apiUrl =
      'https://dental-key-738b90a4d87a.herokuapp.com/miscellaneous/get_requests/';

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      List<dynamic> fetchedRequests = json.decode(response.body);

      fetchedRequests = fetchedRequests.map((request) {
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

      List<int> unreadIndices = [];
      for (int i = 0; i < fetchedRequests.length; i++) {
        if (!fetchedRequests[i]['is_read']) {
          unreadIndices.add(i);
        }
      }

      final unreadProvider =
          Provider.of<UnreadProvider>(context, listen: false);
      unreadProvider.setUnreadIndices(unreadIndices);
    } else {
      print('Failed to fetch requests: ${response.statusCode}');
    }
  } catch (error) {
    print('Failed to fetch requests: $error');
  }
}
