import 'package:firebase_auth/firebase_auth.dart';

class ErrorHelper {
  static String getMessage(dynamic error) {
    print('ErrorHelper: Mapping error -> $error');
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'email-already-in-use':
          return 'This email is already in use by another account.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-credential':
          return 'Invalid login credentials. Please check your email and password.';
        case 'operation-not-allowed':
          return 'Sign-in with email and password is not enabled.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return 'Authentication failed: ${error.message ?? 'Unknown error'}';
      }
    }

    String message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }
    
    return message;
  }
}
