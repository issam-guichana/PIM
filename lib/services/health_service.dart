import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/Models/health_data.dart';

class HealthService {
  static const MethodChannel _channel = MethodChannel('healthkit_channel');
  final String _baseUrl = 'http://192.168.1.9:3000/health';

  // Function to retrieve health data from HealthKit
  Future<Map<String, dynamic>> fetchHealthData() async {
    try {
      // Call to native code to retrieve HealthKit data
      final data = await _channel.invokeMethod<Map<dynamic, dynamic>>('getHealthData');
      // Return the data as a map and ensure all keys and values are strings
      return data?.map((key, value) => MapEntry(key.toString(), value)) ?? {};
    } catch (e) {
      // In case of error, return an empty error message
      print("Error fetching HealthKit data: $e");
      return {};
    }
  }

  /// Fetches health data history from the backend
  Future<List<HealthData>> fetchHealthHistory(String userId, int days) async {
    final String url = '$_baseUrl/history/$userId/$days';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Log the response to check
        print('✅ API Response: $data');

        // Convert the JSON data to a list of HealthData objects
        return data.map((item) => HealthData.fromJson(item)).toList();
      } else {
        // Handle non-200 responses
        print('⚠️ Error retrieving history: ${response.statusCode}');
        throw Exception('Failed to fetch health history');
      }
    } catch (e) {
      // Handle errors related to the connection or JSON parsing
      print('🔴 Connection or JSON parsing error: $e');
      throw Exception('Error connecting to the server');
    }
  }
}

