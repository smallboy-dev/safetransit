import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'home_screen.dart';

class VerificationStatusScreen extends StatelessWidget {
  final bool isSuccess;

  const VerificationStatusScreen({
    super.key,
    this.isSuccess = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isSuccess ? AppTheme.primaryColor : const Color(0xFFEF4444);
    final statusIcon = isSuccess ? LucideIcons.check : LucideIcons.triangleAlert;
    final title = isSuccess ? "You're Verified" : "Verification Issue Detected";
    final subtext = isSuccess 
        ? "You can now go online and start receiving ride requests." 
        : "Please try again or contact support to resolve this issue.";

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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.2),
                                blurRadius: 32,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 2.seconds),

                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            statusIcon,
                            size: 56,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 48),

                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 16),
                    
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        subtext,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: AppTheme.mutedForeground,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2),
                  ],
                ),
                
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isSuccess) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        foregroundColor: isSuccess ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: statusColor.withOpacity(0.2),
                      ),
                      child: Text(
                        isSuccess ? 'Continue' : 'Try Again',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
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
