import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:safetransit_ai/core/widgets/logo_widget.dart';
import '../bloc/auth_bloc.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/role_selection_screen.dart';

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
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthStarted());
      }
    });
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
