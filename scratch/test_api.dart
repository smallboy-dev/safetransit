import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

// Use uuid package if available, or simple random string for CLI test
String generateRandomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(length, (index) => chars[(index + 1) % chars.length]).join();
}

void main() async {
  const String baseUrl = 'https://network-as-code.p-eu.rapidapi.com';
  const String apiKey = '35552c2071msh27670bfc90849a6p1639b3jsn0041b59fd1f1';
  const String apiHost = 'network-as-code.nokia.rapidapi.com';
  const String phoneNumber = '+99999991000'; // Success simulator number

  try {
    print('=========================================');
    print('    SafeTransit AI Security Engine       ');
    print('=========================================');

    // -----------------------------------------------------
    // STEP 1: CLIENT CREDENTIALS (for 2-legged APIs like SIM Swap)
    // -----------------------------------------------------
    print('\n[1/5] Fetching Client Credentials...');
    final authResponse = await http.get(
      Uri.parse('$baseUrl/oauth2/v1/auth/clientcredentials'),
      headers: {'x-rapidapi-key': apiKey, 'x-rapidapi-host': apiHost},
    );

    if (authResponse.statusCode != 200) throw Exception('Auth failed: ${authResponse.body}');
    final authData = json.decode(authResponse.body);
    final String clientId = authData['client_id'];
    final String clientSecret = authData['client_secret'];

    // Get Access Token for SIM Swap
    print('      Requesting Server-to-Server Token...');
    final configResponse = await http.get(
      Uri.parse('$baseUrl/.well-known/openid-configuration'),
      headers: {'x-rapidapi-key': apiKey, 'x-rapidapi-host': apiHost},
    );
    final configData = json.decode(configResponse.body);
    final String tokenEndpoint = configData['token_endpoint'];

    final tokenResponse = await http.post(
      Uri.parse(tokenEndpoint),
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );
    print('Response (Token): ${tokenResponse.body}');
    final tokenMap = json.decode(tokenResponse.body);
    final String? accessToken = tokenMap['access_token'];
    if (accessToken == null) throw Exception('Access token missing: ${tokenResponse.body}');

    // -----------------------------------------------------
    // STEP 2: SIM SWAP CHECK (MUST BE FIRST)
    // -----------------------------------------------------
    print('\n[2/5] Running SIM Swap Guard for $phoneNumber...');
    final simCheck = await http.post(
      Uri.parse('$baseUrl/passthrough/camara/v1/sim-swap/sim-swap/v0/check'),
      headers: {
        'Content-Type': 'application/json',
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': apiHost,
      },
      body: json.encode({'phoneNumber': phoneNumber}),
    );

    print('Response (Check): ${simCheck.body}');
    final bool isSwapped = json.decode(simCheck.body)['swapped'] == true;
    if (isSwapped) {
      final simDateRes = await http.post(
        Uri.parse('$baseUrl/passthrough/camara/v1/sim-swap/sim-swap/v0/retrieve-date'),
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': apiHost,
        },
        body: json.encode({'phoneNumber': phoneNumber}),
      );
      final swapDate = json.decode(simDateRes.body)['latestSimChange'];
      print('❌ ERROR: SIM SWAP DETECTED!');
      print('Registration failed: SIM swap detected on $swapDate');
      return;
    }
    print('✅ SIM Swap Clear. Proceeding...');

    // -----------------------------------------------------
    // STEP 3: NUMBER VERIFICATION (FAST AUTH FLOW - 3-legged)
    // -----------------------------------------------------
    print('\n[3/5] Starting Number Verification (3-Legged Auth)...');
    final String fastAuthEndpoint = configData['fast_flow_csp_auth_endpoint'];
    final String state = 'state_${generateRandomString(8)}';
    final String nonce = 'nonce_${generateRandomString(8)}';
    final String redirectUri = 'https://safetransit.ai/auth/callback';

    final authUrl = Uri.parse(fastAuthEndpoint).replace(queryParameters: {
      'scope': 'dpv:FraudPreventionAndDetection number-verification:verify',
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'login_hint': phoneNumber,
      'state': state,
      'nonce': nonce,
    });

    print('\n👉 ACTION REQUIRED: Open this URL in your device browser to give consent:');
    print(authUrl.toString());
    print('\n(Simulating user consent callback...)');
    
    // In a real app, the browser/webview redirects back with a code.
    // For this CLI test, we simulate receiving the code manually if we had one.
    // Since we are in a sandbox simulator (+999), we can assume a valid code for testing logic.
    const String mockCode = 'MOCK_AUTH_CODE_FROM_REDIRECT';

    // -----------------------------------------------------
    // STEP 4: CALL VERIFY API (FAST FLOW)
    // -----------------------------------------------------
    print('\n[4/5] Calling Number Verification API with Auth Code...');
    final verifyRes = await http.post(
      Uri.parse('$baseUrl/passthrough/camara/v1/number-verification/number-verification/v0/verify'
          '?code=$mockCode&state=$state'),
      headers: {
        'Content-Type': 'application/json',
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': apiHost,
      },
      body: json.encode({'phoneNumber': phoneNumber}),
    );

    print('Response Status: ${verifyRes.statusCode}');
    print('Response Body: ${verifyRes.body}');

    // -----------------------------------------------------
    // STEP 5: FINAL DECISION
    // -----------------------------------------------------
    final bool isVerified = verifyRes.body == 'true' || json.decode(verifyRes.body)['verified'] == true;
    
    if (isVerified) {
      print('\n🎉 SUCCESS: Number Verified. Registration Complete!');
    } else {
      print('\n❌ FAILED: Number Verification Failed. Access Blocked.');
    }

  } catch (e) {
    print('\n🔥 SYSTEM ERROR: $e');
  }
}