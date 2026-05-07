import 'dart:convert';
import 'package:http/http.dart' as http;

class NokiaApiService {
  static const String _baseUrl = 'https://api.nokia.com/network-as-code';
  static const String _apiKey = 'YOUR_NOKIA_API_KEY';
  
  // SIM Swap Detection
  Future<bool> detectSimSwap(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sim-swap/detect'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['simSwapped'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('SIM Swap detection failed: $e');
    }
  }
  
  // Device Swap Detection
  Future<bool> detectDeviceSwap(String phoneNumber, String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/device-swap/detect'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'phoneNumber': phoneNumber,
          'deviceId': deviceId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['deviceSwapped'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Device Swap detection failed: $e');
    }
  }
  
  // Number Verification
  Future<bool> verifyNumber(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/number-verification/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['verified'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Number verification failed: $e');
    }
  }
  
  // Location Retrieval
  Future<Map<String, dynamic>> getLocation(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/location/retrieve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Location retrieval failed');
    } catch (e) {
      throw Exception('Location retrieval failed: $e');
    }
  }
  
  // Geofencing
  Future<void> createGeofence(String fenceId, Map<String, dynamic> fenceData) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/geofencing/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'fenceId': fenceId,
          ...fenceData,
        }),
      );
    } catch (e) {
      throw Exception('Geofence creation failed: $e');
    }
  }
  
  // Device Status/Reachability
  Future<bool> isDeviceReachable(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/device-status/reachability'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['reachable'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Device reachability check failed: $e');
    }
  }
  
  // Congestion Insights
  Future<Map<String, dynamic>> getCongestionInsights(String area) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/congestion/insights?area=$area'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Congestion insights retrieval failed');
    } catch (e) {
      throw Exception('Congestion insights failed: $e');
    }
  }
}
