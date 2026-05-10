import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';

class EmergencySosScreen extends StatelessWidget {
  const EmergencySosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderButton(LucideIcons.arrowLeft, () => Navigator.pop(context)),
                      _buildHeaderButton(LucideIcons.settings, () {}),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      _buildSosButton(),
                      
                      const SizedBox(height: 40),
                      Text(
                        'Emergency Assistance',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Text(
                          'Tap the SOS button to immediately alert emergency services and your trusted contacts.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: AppTheme.mutedForeground,
                            height: 1.5,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.mapPin, color: Color(0xFF3B82F6), size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Share Live Location',
                                style: GoogleFonts.spaceGrotesk(
                                  color: const Color(0xFF3B82F6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('EMERGENCY CONTACTS'),
                      const SizedBox(height: 16),
                      _buildContactRow('Police / Ambulance', '911 - Emergency Services', LucideIcons.shieldAlert, isPrimary: true),
                      const SizedBox(height: 12),
                      _buildContactRow('Jane Doe', 'Sister - Trusted Contact', LucideIcons.user),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEF4444).withOpacity(0.1),
          ),
        ).animate(onPlay: (c) => c.repeat()).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        ).fadeOut(),
        
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEF4444).withOpacity(0.2),
          ),
        ).animate(onPlay: (c) => c.repeat()).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        ),

        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            border: Border.all(color: const Color(0xFFF87171), width: 4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.6),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'SOS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF111827).withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.mutedForeground,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildContactRow(String name, String role, IconData icon, {bool isPrimary = false}) {
    final bgColor = isPrimary ? const Color(0xFFEF4444).withOpacity(0.05) : const Color(0xFF111827).withOpacity(0.4);
    final borderColor = isPrimary ? const Color(0xFFEF4444).withOpacity(0.2) : Colors.white.withOpacity(0.05);
    final iconBgColor = isPrimary ? const Color(0xFFEF4444).withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1);
    final iconColor = isPrimary ? const Color(0xFFEF4444) : AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  role,
                  style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppTheme.mutedForeground),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Icon(LucideIcons.phone, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}
