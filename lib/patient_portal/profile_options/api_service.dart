import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://dental-key-738b90a4d87a.herokuapp.com';

  static Future<Map<String, dynamic>> fetchDependentDetails(
      String dependentUuid) async {
    final url = '$baseUrl/patients_dental/dependent/$dependentUuid/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch dependent details');
      }
    } catch (error) {
      throw Exception('Error fetching dependent details: $error');
    }
  }

  static Future<Map<String, dynamic>> fetchMedicalHistory(
      String dependentUuid) async {
    final url =
        '$baseUrl/patients_dental/dependent/$dependentUuid/medical-record/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch medical history');
      }
    } catch (error) {
      throw Exception('Error fetching medical history: $error');
    }
  }
}
