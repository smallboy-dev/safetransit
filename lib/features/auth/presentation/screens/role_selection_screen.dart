import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'auth_screen.dart';
import 'driver_login_screen.dart';
import 'passenger_login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = 'Driver'; // Default highlighted in design

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                
                // Header (Main Write-up)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    'How would you like to use SafeTransit?',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1),
                
                const SizedBox(height: 40),
                
                // Role Options
                Expanded(
                  child: Column(
                    children: [
                      _RoleCard(
                        title: 'Passenger',
                        icon: LucideIcons.map,
                        isSelected: selectedRole == 'Passenger',
                        onTap: () => setState(() => selectedRole = 'Passenger'),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 16),
                      
                      _RoleCard(
                        title: 'Driver',
                        icon: LucideIcons.car,
                        isSelected: selectedRole == 'Driver',
                        onTap: () => setState(() => selectedRole = 'Driver'),
                      ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1),
                    ],
                  ),
                ),
                
                // Continue Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedRole == 'Driver') {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const DriverLoginScreen()),
                          );
                        } else if (selectedRole == 'Passenger') {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const PassengerLoginScreen()),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const AuthScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.1) 
              : const Color(0xFF111827).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : const Color(0xFF1F2937),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.15),
              blurRadius: 32,
              offset: const Offset(0, 8),
            )
          ] : [],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryColor.withOpacity(0.2) 
                    : const Color(0xFF1F2937),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : AppTheme.mutedForeground,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                ),
              ),
            ),
            
            // Radio Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.mutedForeground,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              ),
              child: isSelected 
                  ? Icon(LucideIcons.check, size: 14, color: Colors.black) 
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
