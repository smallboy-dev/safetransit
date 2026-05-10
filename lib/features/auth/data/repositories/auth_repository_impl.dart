import 'package:safetransit_ai/features/auth/domain/entities/user.dart';
import 'package:safetransit_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'package:safetransit_ai/core/services/nokia_api_service.dart';
import 'package:safetransit_ai/core/exceptions/auth_exceptions.dart';

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
      rethrow;
    }
  }

  @override
  Future<User> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseService.signInWithEmailAndPassword(email, password);
      final userDoc = await _firebaseService.getUserData(userCredential.user!.uid);
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) {
        throw Exception('User data not found in Firestore');
      }

      return User.fromMap({
        'id': userCredential.user!.uid,
        ...userData,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> signUp(String email, String password, String name, String phoneNumber, UserType userType, {bool confirmedSimSwap = false}) async {
    try {
      
      print('AuthRepository: Performing SIM Swap Check via Nokia NaC...');
      bool isSimSwapped = false;
      String? simSwapDate;
      int riskScore = 0;
      double initialRating = 5.0;

      try {
        isSimSwapped = await _nokiaApiService.detectSimSwap(phoneNumber);
        if (isSimSwapped) {
          simSwapDate = await _nokiaApiService.getSimSwapDate(phoneNumber);
          riskScore = 98; 
          print('WARNING: SIM SWAP DETECTED at $simSwapDate. Risk: $riskScore%');

          if (!confirmedSimSwap) {
            throw SimSwapException(swapDate: simSwapDate);
          }

          initialRating = 2.5; 
          print('User confirmed SIM swap risk. Proceeding with reduced rating: $initialRating');
        }
      } on SimSwapException {
        rethrow; 
      } catch (e) {
        print('Nokia SIM Swap Check Error: $e');
        
      }

      final userCredential = await _firebaseService.createUserWithEmailAndPassword(email, password);
      final userId = userCredential.user!.uid;

      final userData = {
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'userType': userType.name,
        'isVerified': false,
        'profileSetupComplete': false,
        'isActive': true,
        'isSimSwapped': isSimSwapped,
        'simSwapDate': simSwapDate,
        'riskScore': riskScore,
        'createdAt': DateTime.now().toIso8601String(),
        'lastActiveAt': DateTime.now().toIso8601String(),
        'rating': initialRating,
      };

      print('AuthRepository: Waiting for Auth state to stabilize...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('AuthRepository: Attempting to create Firestore document for UID: $userId');
      await _firebaseService.createUserData(userId, userData);
      print('AuthRepository: Firestore document created successfully');

      return User.fromMap({
        'id': userId,
        ...userData,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }
}
