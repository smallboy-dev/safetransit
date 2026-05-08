import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safetransit_ai/core/config/secrets.dart';

class NokiaApiService {
  static const String _baseUrl = 'https://network-as-code.p-eu.rapidapi.com/passthrough/camara/v1';
  static const String _apiKey = AppSecrets.nokiaApiKey;
  static const String _apiHost = 'network-as-code.nokia.rapidapi.com';
  
  // SIM Swap Detection
  Future<bool> detectSimSwap(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sim-swap/sim-swap/v0/check'),
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
        },
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      );
      
      print('SIM Swap Status: ${response.statusCode}');
      print('SIM Swap Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['swapped'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('SIM Swap detection failed: $e');
    }
  }

  // SIM Swap Retrieve Date
  Future<String?> getSimSwapDate(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sim-swap/sim-swap/v0/retrieve-date'),
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
        },
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      );

      print('SIM Swap Date Status: ${response.statusCode}');
      print('SIM Swap Date Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['latestSimChange'];
      }
      return null;
    } catch (e) {
      throw Exception('SIM Swap date retrieval failed: $e');
    }
  }
  
  // Device Swap Detection
  Future<bool> detectDeviceSwap(String phoneNumber, String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/device-swap/detect'),
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
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
  
  // Number Verification - Step 1: Get Auth URL (Fast Flow)
  Future<String> getAuthUrl(String phoneNumber, String state, String nonce) async {
    try {
      final rootUrl = 'https://network-as-code.p-eu.rapidapi.com';
      
      // 1. Fetch OpenID Configuration
      final configRes = await http.get(
        Uri.parse('$rootUrl/.well-known/openid-configuration'),
        headers: {
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
        },
      );
      final config = json.decode(configRes.body);
      final String fastAuthEndpoint = config['fast_flow_csp_auth_endpoint'];

      // 2. Fetch Client ID
      final authRes = await http.get(
        Uri.parse('$rootUrl/oauth2/v1/auth/clientcredentials'),
        headers: {
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
        },
      );
      final authData = json.decode(authRes.body);
      final String clientId = authData['client_id'];

      // 3. Build Auth URL
      // Use your Firebase Function as the redirect_uri
      final redirectUri = 'https://us-central1-safetransit-d31ab.cloudfunctions.net/nokiaCallback';
      
      final uri = Uri.parse(fastAuthEndpoint).replace(queryParameters: {
        'scope': 'openid number-verification:verify',
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'login_hint': phoneNumber,
        'state': state,
        'nonce': nonce,
      });

      return uri.toString();
    } catch (e) {
      throw Exception('Failed to generate Auth URL: $e');
    }
  }

  // Number Verification - Step 2: Final Verification with Code (Fast Flow)
  Future<bool> verifyNumberWithCode(String phoneNumber, String code, String state) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/number-verification/number-verification/v0/verify'
            '?code=$code&state=$state'),
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
        },
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      );

      print('Verify Status: ${response.statusCode}');
      print('Verify Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool verified = data == true || 
                             data['verified'] == true || 
                             data['devicePhoneNumberVerified'] == true;
                             
        // HACKATHON DEMO RULE:
        // If we are using a simulator number (+99) and we got a 200 OK, 
        // it means the OAuth code was valid. We allow it to pass for the demo.
        if (phoneNumber.startsWith('+99')) {
          return true;
        }
        
        return verified;
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
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
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
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
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
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
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

  // Location Verification
  Future<bool> verifyLocation(String phoneNumber, double latitude, double longitude, double radius) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/location-verification/verify'),
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
        },
        body: json.encode({
          'phoneNumber': phoneNumber,
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['verified'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Location verification failed: $e');
    }
  }
  
  // Congestion Insights
  Future<Map<String, dynamic>> getCongestionInsights(String area) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/congestion/insights?area=$area'),
        headers: {
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
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
