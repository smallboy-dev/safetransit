import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'driver_profile_setup_screen.dart';
import 'home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final bool isDriver;
  const OtpVerificationScreen({super.key, this.isDriver = false});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  int _timerSeconds = 30;
  Timer? _timer;
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final int _otpLength = 6;

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Simulating Nokia identity propagation:
    // Because Nokia already verified the identity, we auto-fill the "Session OTP"
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _otpController.text = '123456';
        });
      }
    });

    // Auto-focus the hidden input field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

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
                // Header / Back Navigation
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827).withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1F2937),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.chevronLeft,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),

                // Title Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.messageSquare,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 24),
                      Text(
                        'Verify Your Number',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: -0.8,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          'Enter the 6-digit code sent to your phone',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            color: AppTheme.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn(delay: 350.ms, duration: 600.ms).slideY(begin: 0.2),
                      const SizedBox(height: 16),
                      
                      // Nokia Verified Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.check, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Verified via Nokia NaC Security',
                              style: GoogleFonts.spaceGrotesk(
                                color: const Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 500.ms).scale(),
                    ],
                  ),
                ),
                
                // Form Section
                Expanded(
                  child: Column(
                    children: [
                      // OTP Input Area (Hidden TextField + Stylized Boxes)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0,
                            child: TextField(
                              controller: _otpController,
                              focusNode: _focusNode,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              maxLength: _otpLength,
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: const InputDecoration(
                                counterText: '',
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _focusNode.requestFocus(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_otpLength, (index) {
                                final hasValue = _otpController.text.length > index;
                                final char = hasValue ? _otpController.text[index] : '';
                                final isFocused = _otpController.text.length == index;
                                
                                return Container(
                                  width: 46,
                                  height: 56,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isFocused 
                                        ? AppTheme.primaryColor.withOpacity(0.1) 
                                        : const Color(0xFF111827).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isFocused 
                                          ? AppTheme.primaryColor 
                                          : (hasValue ? const Color(0xFF10B981) : const Color(0xFF1F2937)),
                                      width: isFocused || hasValue ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isFocused ? [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.15),
                                        blurRadius: 12,
                                      )
                                    ] : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: isFocused
                                      ? Container(
                                          width: 2,
                                          height: 24,
                                          color: AppTheme.primaryColor,
                                        ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 500.ms)
                                      : Text(
                                          char,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500,
                                            color: hasValue ? Colors.white : AppTheme.mutedForeground,
                                          ),
                                        ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 32),
                      
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Resend code in ",
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppTheme.mutedForeground,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _formatTime(_timerSeconds),
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _timerSeconds == 0 ? () {
                              setState(() => _timerSeconds = 30);
                              _startTimer();
                            } : null,
                            child: Text(
                              'Resend code',
                              style: GoogleFonts.spaceGrotesk(
                                color: _timerSeconds == 0 ? AppTheme.primaryColor : AppTheme.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 650.ms),
                      
                      const Spacer(),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.isDriver) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const DriverProfileSetupScreen()),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: AppTheme.primaryColor.withOpacity(0.2),
                          ),
                          child: Text(
                            'Verify',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
