import 'package:safetransit_ai/features/auth/domain/entities/user.dart';
import 'package:safetransit_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'package:safetransit_ai/core/services/nokia_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseService _firebaseService;
  final NokiaApiService _nokiaApiService;

  AuthRepositoryImpl({
    required FirebaseService firebaseService,
    required NokiaApiService nokiaApiService,
  })  : _firebaseService = firebaseService,
        _nokiaApiService = nokiaApiService;

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseService.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _firebaseService.getUserData(firebaseUser.uid);
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) return null;

      return User.fromMap({
        'id': firebaseUser.uid,
        ...userData,
      });
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<User> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseService.signInWithEmailAndPassword(email, password);
      final userDoc = await _firebaseService.getUserData(userCredential.user!.uid);
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) {
        throw Exception('User data not found');
      }

      return User.fromMap({
        'id': userCredential.user!.uid,
        ...userData,
      });
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<User> signUp(String email, String password, String name, String phoneNumber, UserType userType) async {
    try {
      final userCredential = await _firebaseService.createUserWithEmailAndPassword(email, password);
      final userId = userCredential.user!.uid;

      // Phone number verification is now handled at the UI level via Nokia Fast Flow
      // final isPhoneVerified = await _nokiaApiService.verifyNumber(phoneNumber);
      // if (!isPhoneVerified) {
      //   throw Exception('Phone number verification failed');
      // }

      final userData = {
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'userType': userType.toString(),
        'isVerified': false,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'lastActiveAt': DateTime.now().toIso8601String(),
        'rating': 0.0,
      };

      await _firebaseService.createUserData(userId, userData);

      return User.fromMap({
        'id': userId,
        ...userData,
      });
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.resetPassword(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
}
