import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'otp_verification_screen.dart';
import 'role_selection_screen.dart';
import 'device_verification_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/entities/user.dart';

class RegisterScreen extends StatefulWidget {
  final bool isDriver;
  const RegisterScreen({super.key, required this.isDriver});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  late String selectedFlag;
  late String selectedCode;

  final List<Map<String, String>> countries = [
    {'name': 'Nokia Test', 'flag': '🌐', 'code': '+99'},
    {'name': 'Nigeria', 'flag': '🇳🇬', 'code': '+234'},
    {'name': 'Kenya', 'flag': '🇰🇪', 'code': '+254'},
    {'name': 'Ghana', 'flag': '🇬🇭', 'code': '+233'},
    {'name': 'South Africa', 'flag': '🇿🇦', 'code': '+27'},
    {'name': 'Rwanda', 'flag': '🇷🇼', 'code': '+250'},
    {'name': 'United States', 'flag': '🇺🇸', 'code': '+1'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isDriver) {
      selectedFlag = '🌐';
      selectedCode = '+99';
    } else {
      selectedFlag = '🇳🇬';
      selectedCode = '+234';
    }
  }

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
          border: Border(top: BorderSide(color: Color(0xFF1F2937), width: 1.5)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Select Country', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : const Color(0xFF111827).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor : const Color(0xFF1F2937)),
                      ),
                      child: Row(
                        children: [
                          Text(country['flag']!, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 16),
                          Expanded(child: Text(country['name']!, style: GoogleFonts.spaceGrotesk(fontSize: 16, color: Colors.white))),
                          Text(country['code']!, style: GoogleFonts.spaceGrotesk(fontSize: 16, color: isSelected ? AppTheme.primaryColor : AppTheme.mutedForeground)),
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

  void _showSecurityWarningDialog(String? swapDate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.red.withOpacity(0.5), width: 2)),
        title: Row(
          children: [
            const Icon(LucideIcons.triangleAlert, color: Colors.red, size: 32),
            const SizedBox(width: 16),
            Text(
              'Security Alert',
              style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A potential SIM swap was detected for this number${swapDate != null ? ' on $swapDate' : ''}.',
              style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.shieldAlert, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'PROCEEDING WILL LOWER YOUR INITIAL DRIVER RATING.',
                      style: GoogleFonts.spaceGrotesk(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.spaceGrotesk(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final name = _nameController.text.trim();
              final email = _emailController.text.trim();
              final phone = _phoneController.text.trim();
              final password = _passwordController.text.trim();
              final fullPhone = '$selectedCode$phone';

              context.read<AuthBloc>().add(SignUpRequested(
                    email: email,
                    password: password,
                    name: name,
                    phoneNumber: fullPhone,
                    userType: widget.isDriver ? UserType.driver : UserType.passenger,
                    confirmSecurityWarning: true,
                  ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Proceed Anyway', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    final fullPhone = '$selectedCode$phone';
    
    context.read<AuthBloc>().add(SignUpRequested(
      email: email,
      password: password,
      name: name,
      phoneNumber: fullPhone,
      userType: widget.isDriver ? UserType.driver : UserType.passenger,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthStateSecurityWarning) {
          _showSecurityWarningDialog(state.swapDate);

        } else if (state is AuthStateAuthenticated) {
          final fullPhone = '$selectedCode${_phoneController.text.trim()}';
          final name = _nameController.text.trim();
          
          if (widget.isDriver) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DeviceVerificationScreen(
                  isDriver: true,
                  phoneNumber: fullPhone,
                  name: name,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  isDriver: false,
                  phoneNumber: fullPhone,
                  name: name,
                ),
              ),
            );
          }
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
              colors: [AppTheme.darkBackground, AppTheme.darkBackground, AppTheme.deepGreen],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthStateLoading;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827).withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                      
                      const SizedBox(height: 40),
                      
                      Text(
                        widget.isDriver ? 'Driver Registration' : 'Create Account',
                        style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'Join the SafeTransit community today.',
                        style: GoogleFonts.spaceGrotesk(fontSize: 16, color: AppTheme.mutedForeground),
                      ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1),
                      
                      const SizedBox(height: 40),
                      
                      _buildTextField(label: 'Full Name', controller: _nameController, hint: 'John Doe', icon: LucideIcons.user),
                      const SizedBox(height: 20),
                      _buildTextField(label: 'Email Address', controller: _emailController, hint: 'example@email.com', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text('Phone Number', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.mutedForeground)),
                          ),
                          Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF1F2937)),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: _showCountryPicker,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0xFF1F2937)))),
                                    child: Row(
                                      children: [
                                        Text(selectedFlag, style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: 8),
                                        Text(selectedCode, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                                        const SizedBox(width: 4),
                                        Icon(LucideIcons.chevronDown, size: 16, color: AppTheme.mutedForeground),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: TextField(
                                      controller: _phoneController,
                                      style: GoogleFonts.spaceGrotesk(fontSize: 18, color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: '000-000-0000',
                                        hintStyle: GoogleFonts.spaceGrotesk(fontSize: 18, color: AppTheme.mutedForeground),
                                        border: InputBorder.none,
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Password',
                        controller: _passwordController,
                        hint: '••••••••',
                        icon: LucideIcons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, color: AppTheme.mutedForeground, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 8,
                            shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                          child: isLoading
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('Sign Up', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint, required IconData icon, bool obscureText = false, Widget? suffixIcon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.mutedForeground)),
        ),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF111827).withOpacity(0.4), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1F2937))),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.spaceGrotesk(color: AppTheme.mutedForeground, fontSize: 16),
              prefixIcon: Icon(icon, color: AppTheme.mutedForeground, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            ),
          ),
        ),
      ],
    );
  }
}
