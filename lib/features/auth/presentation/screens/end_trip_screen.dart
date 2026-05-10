import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';
import 'package:safetransit_ai/core/theme/app_theme.dart';

class EndTripScreen extends StatelessWidget {
  const EndTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 340),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF1F2937).withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                      ),
                      child: const Icon(
                        LucideIcons.power,
                        color: Color(0xFFEF4444),
                        size: 28,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 20),

                    Text(
                      'End Trip?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Are you sure you want to go offline?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppTheme.mutedForeground,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2937).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF1F2937)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEF4444).withOpacity(0.25),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'End Trip',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
            ),
          ),
        ],
      ),
    );
  }
}
