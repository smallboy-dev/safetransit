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
import '../screens/role_selection_screen.dart';
import '../screens/verification_status_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkSessionAndNavigate();
      }
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    try {
      // 1. Check Local Storage + Session Timeout
      final prefs = await SharedPreferences.getInstance();
      final localSetupComplete = prefs.getBool('profileSetupComplete') ?? false;
      final lastActiveString = prefs.getString('lastActiveTime');
      final wasManualLogout = prefs.getBool('manualLogout') ?? false;
      
      // If manual logout, reset and skip auto-resume
      if (wasManualLogout) {
        print('Manual logout detected - skipping auto-resume');
        await prefs.setBool('manualLogout', false);
        if (mounted) {
          context.read<AuthBloc>().add(const AuthStarted());
        }
        return;
      }

      // Check for session expiration (e.g., 1 hour)
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

      // 2. Check Firebase Auth + Firestore (As Backup)
      final firebaseService = context.read<FirebaseService>();
      final user = firebaseService.currentUser;
      final phone = prefs.getString('userPhone');
      final phoneKey = phone?.replaceAll('+', '');

      if (user != null || phoneKey != null) {
        try {
          // Priority 1: Check by phoneKey (persistent across sessions)
          // Priority 2: Check by user.uid
          final idToFetch = phoneKey ?? user?.uid;
          if (idToFetch != null) {
            final doc = await firebaseService.getUserData(idToFetch).timeout(
              const Duration(seconds: 3),
            );

            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>?;
              final setupComplete = data?['profileSetupComplete'] == true;

              if (setupComplete && mounted) {
                print('Session resumed via Firestore (${phoneKey != null ? 'Phone' : 'UID'})');
                // Also sync to local storage for next time
                await prefs.setBool('profileSetupComplete', true);
                
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const VerificationStatusScreen()),
                );
                return;
              }
            }
          }
        } catch (_) {
          // Firestore timed out or errored
        }
      }

      // No session or setup incomplete — start normal flow via AuthBloc
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
            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
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

                // Animated Logo
                const LogoWidget()
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

                const SizedBox(height: 40),

                // App Name
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

                // Tagline
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

                // Loading Indicator (Subtle)
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

