import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:safetransit_ai/core/services/nokia_api_service.dart';
import 'otp_verification_screen.dart';

class PassengerLoginScreen extends StatefulWidget {
  const PassengerLoginScreen({super.key});

  @override
  State<PassengerLoginScreen> createState() => _PassengerLoginScreenState();
}

class _PassengerLoginScreenState extends State<PassengerLoginScreen> {
  String selectedFlag = '🇳🇬';
  String selectedCode = '+234';
  bool _isLoading = false;
  final TextEditingController _phoneController = TextEditingController();

  final List<Map<String, String>> countries = [
    {'name': 'International (Nokia)', 'flag': '🌐', 'code': '+99'},
    {'name': 'Nigeria', 'flag': '🇳🇬', 'code': '+234'},
    {'name': 'Kenya', 'flag': '🇰🇪', 'code': '+254'},
    {'name': 'Ghana', 'flag': '🇬🇭', 'code': '+233'},
    {'name': 'South Africa', 'flag': '🇿🇦', 'code': '+27'},
    {'name': 'Rwanda', 'flag': '🇷🇼', 'code': '+250'},
    {'name': 'United States', 'flag': '🇺🇸', 'code': '+1'},
  ];

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF0B0F1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: Color(0xFF1F2937), width: 1.5),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Country',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  final isSelected = selectedCode == country['code'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFlag = country['flag']!;
                        selectedCode = country['code']!;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : const Color(0xFF111827).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(country['flag']!,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              country['name']!,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Text(
                            country['code']!,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 32.0),
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
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),

                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: -0.8,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideX(begin: -0.1),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          'Enter your phone number to access your account.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 350.ms, duration: 600.ms)
                          .slideX(begin: -0.1),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          'Phone Number',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ),
                      Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF1F2937),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            
                            GestureDetector(
                              onTap: _showCountryPicker,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      selectedFlag,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      selectedCode,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      LucideIcons.chevronDown,
                                      size: 16,
                                      color: AppTheme.mutedForeground,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: TextField(
                                  controller: _phoneController,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '000-000-0000',
                                    hintStyle: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      color: AppTheme.mutedForeground,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final phone = _phoneController.text.trim();
                              if (phone.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please enter a phone number')),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);

                              await Future.delayed(const Duration(seconds: 1));

                              if (!mounted) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OtpVerificationScreen(
                                            isDriver: false,
                                            phoneNumber: phone)),
                              );
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
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Continue',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .scale(begin: const Offset(0.95, 0.95)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
