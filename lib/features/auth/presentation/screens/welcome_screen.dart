import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'role_selection_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),

                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.shieldCheck,
                    color: AppTheme.primaryColor,
                    size: 50,
                  ),
                ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 32),

                Text(
                  'SafeTransit AI',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1.5,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 16),

                Text(
                  'Verified security for every journey. Powered by Nokia NaC technology.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    color: AppTheme.mutedForeground,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                
                const Spacer(flex: 3),

                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF1F2937), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: const Color(0xFF111827).withOpacity(0.4),
                        ),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                  ],
                ),
                
                const SizedBox(height: 48),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.lock, size: 14, color: AppTheme.mutedForeground),
                    const SizedBox(width: 8),
                    Text(
                      'End-to-End Verified Identity',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppTheme.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1000.ms),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
