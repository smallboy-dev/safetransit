import 'package:safetransit_ai/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password, String name, String phoneNumber, UserType userType);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}
