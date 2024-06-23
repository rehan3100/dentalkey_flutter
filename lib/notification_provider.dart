import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationProvider with ChangeNotifier {
  List<String> _unreadNotificationIndices = [];
  final Logger _logger = Logger('NotificationProvider');

  List<String> get unreadNotificationIndices => _unreadNotificationIndices;

  void setUnreadNotificationIndices(List<String> indices) {
    _unreadNotificationIndices = indices;
    _logger.info('Setting unread notifications: $indices');
    notifyListeners();
  }

  void clearUnreadNotificationIndices() {
    _unreadNotificationIndices = [];
    _logger.info('Clearing all unread notifications');
    notifyListeners();
  }

  void addUnreadNotificationIndex(String index) {
    _unreadNotificationIndices.add(index);
    _logger.info('Adding unread notification: $index');
    notifyListeners();
  }

  void removeUnreadNotificationIndex(String index) {
    _unreadNotificationIndices.remove(index);
    _logger.info('Removing unread notification: $index');
    notifyListeners();
  }

  Future<void> loadUnreadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? openedNotificationStrings =
        prefs.getStringList('opened_notifications');
    _unreadNotificationIndices = openedNotificationStrings ?? [];
    _logger.info('Loaded unread notifications: $openedNotificationStrings');
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> openedNotificationStrings =
        prefs.getStringList('opened_notifications') ?? [];
    openedNotificationStrings.add(id);
    await prefs.setStringList(
        'opened_notifications', openedNotificationStrings);
    removeUnreadNotificationIndex(id);
  }

  Future<void> clearOpenedNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('opened_notifications');
    clearUnreadNotificationIndices();
  }

  Future<void> fetchNotifications(String accessToken) async {
    const String baseUrl = 'https://dental-key-738b90a4d87a.herokuapp.com';

    try {
      _logger.info('Fetching notifications...');
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/display/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _logger.info(
            'Notifications fetched successfully: ${responseData.length} items');

        List<String> unreadIds = responseData.map<String>((notification) {
          return notification['id'].toString();
        }).toList();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        unreadIds =
            unreadIds.where((id) => !(prefs.getBool(id) ?? false)).toList();

        setUnreadNotificationIndices(unreadIds);
      } else {
        _logger
            .warning('Failed to fetch notifications: ${response.statusCode}');
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      _logger.severe('Error fetching notifications: $e');
    }
  }
}
