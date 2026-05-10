import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'otp_verification_screen.dart';

class DeviceVerificationScreen extends StatefulWidget {
  final bool isDriver;
  final String? phoneNumber;
  final String? name;

  const DeviceVerificationScreen({
    super.key,
    required this.isDriver,
    this.phoneNumber,
    this.name,
  });

  @override
  State<DeviceVerificationScreen> createState() => _DeviceVerificationScreenState();
}

class _DeviceVerificationScreenState extends State<DeviceVerificationScreen> {
  String _generatedCode = '';
  bool _isCodeGenerated = false;
  bool _isVerifying = false;
  bool _isVerified = false;

  void _generateCode() {
    setState(() {
      _generatedCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
      _isCodeGenerated = true;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );

    setState(() => _isVerifying = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _isVerified = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.darkBackground, AppTheme.darkBackground, AppTheme.deepGreen],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827).withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Text(
                  'Device Verification',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn().slideX(begin: -0.1),
                
                const SizedBox(height: 12),
                
                Text(
                  'To secure your driver account, we need to link this device to your identity.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    color: AppTheme.mutedForeground,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                
                const SizedBox(height: 48),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isVerified ? AppTheme.primaryColor : const Color(0xFF1F2937),
                      width: _isVerified ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (!_isCodeGenerated)
                        ElevatedButton(
                          onPressed: _generateCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Generate Device Code',
                            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                          ),
                        )
                      else ...[
                        Text(
                          'YOUR SECURITY CODE',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.mutedForeground,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _generatedCode,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 8,
                          ),
                        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 24),
                        
                        if (!_isVerified && !_isVerifying)
                          TextButton.icon(
                            onPressed: _copyToClipboard,
                            icon: const Icon(LucideIcons.copy, size: 18),
                            label: Text(
                              'Copy & Verify',
                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          
                        if (_isVerifying)
                          Column(
                            children: [
                              const CircularProgressIndicator(color: AppTheme.primaryColor),
                              const SizedBox(height: 16),
                              Text(
                                'Linking device...',
                                style: GoogleFonts.spaceGrotesk(color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                          
                        if (_isVerified)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.shieldCheck, color: AppTheme.primaryColor, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Device Linked Successfully',
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ).animate().fadeIn().scale(),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                
                const Spacer(),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isVerified 
                      ? () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtpVerificationScreen(
                              isDriver: widget.isDriver,
                              phoneNumber: widget.phoneNumber,
                              name: widget.name,
                            ),
                          ),
                        )
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      disabledBackgroundColor: const Color(0xFF1F2937),
                    ),
                    child: Text(
                      'Continue to OTP',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Step 1 of 2',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.mutedForeground,
                      fontSize: 14,
                    ),
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
