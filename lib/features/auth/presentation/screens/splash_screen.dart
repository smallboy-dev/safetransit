import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:safetransit_ai/core/widgets/logo_widget.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../screens/welcome_screen.dart';
import '../screens/verification_status_screen.dart';
import 'otp_verification_screen.dart';
import 'driver_profile_setup_screen.dart';
import 'passenger_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkSessionAndNavigate();
      }
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    try {
      
      final prefs = await SharedPreferences.getInstance();
      final localSetupComplete = prefs.getBool('profileSetupComplete') ?? false;
      final lastActiveString = prefs.getString('lastActiveTime');
      final wasManualLogout = prefs.getBool('manualLogout') ?? false;

      if (wasManualLogout) {
        print('Manual logout detected - skipping auto-resume');
        await prefs.setBool('manualLogout', false);
        if (mounted) {
          context.read<AuthBloc>().add(const AuthStarted());
        }
        return;
      }

      bool isSessionExpired = false;
      if (lastActiveString != null) {
        final lastActive = DateTime.parse(lastActiveString);
        final difference = DateTime.now().difference(lastActive);
        if (difference.inHours >= 1) {
          isSessionExpired = true;
          print('Session expired: ${difference.inHours} hours passed');
          await prefs.remove('profileSetupComplete');
          await prefs.remove('lastActiveTime');
        }
      }

      if (localSetupComplete && !isSessionExpired && mounted) {
        print('Session resumed via Local Storage');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const VerificationStatusScreen()),
        );
        return;
      }

      final firebaseService = context.read<FirebaseService>();
      final user = firebaseService.currentUser;

      if (user != null) {
        try {
          
          final doc = await firebaseService.getUserData(user.uid).timeout(
            const Duration(seconds: 3),
          );

          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>?;
            final setupComplete = data?['profileSetupComplete'] == true;
            final phoneNumber = data?['phoneNumber'];
            final isDriver = data?['userType'] == 'driver';

            if (setupComplete && mounted) {
              print('Session resumed via Firestore UID: ${user.uid}');
              await prefs.setBool('profileSetupComplete', true);
              
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const VerificationStatusScreen()),
              );
              return;
            } else if (mounted) {
              final phoneVerified = data?['isVerified'] == true || data?['phoneVerified'] == true;
              
              if (!phoneVerified) {
                
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => OtpVerificationScreen(
                    isDriver: isDriver,
                    phoneNumber: phoneNumber,
                    name: data?['name'],
                  )),
                );
              } else if (isDriver) {
                
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => DriverProfileSetupScreen(
                    phoneNumber: phoneNumber,
                    name: data?['name'],
                  )),
                );
              } else {
                
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => PassengerHomeScreen()),
                );
              }
              return;
            }
          }
        } catch (_) {
          
        }
      }

      if (mounted) {
        context.read<AuthBloc>().add(const AuthStarted());
      }
    } catch (e) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthStarted());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateAuthenticated || state is AuthStateUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground,
                AppTheme.deepGreen,
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                const LogoWidget()
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

                const SizedBox(height: 40),

                Text(
                  'SafeTransit AI',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 12),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Text(
                    'Secure Mobility Powered by Telecom Intelligence',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: AppTheme.mutedForeground,
                      height: 1.625,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.2),

                const Spacer(),

                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor.withOpacity(0.5),
                    ),
                    strokeWidth: 2,
                  ),
                ).animate().fadeIn(delay: 1200.ms),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

