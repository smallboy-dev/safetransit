import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'otp_verification_screen.dart';
import 'role_selection_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    context.read<AuthBloc>().add(SignInRequested(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthStateAuthenticated) {
          final firebaseService = context.read<FirebaseService>();
          final userData = await firebaseService.getUserData(state.user.id);
          
          String? phoneNumber;
          bool isDriver = false;
          
          if (userData.exists) {
            final data = userData.data() as Map<String, dynamic>;
            phoneNumber = data['phoneNumber'];
            isDriver = data['userType'] == 'driver';
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  isDriver: isDriver,
                  phoneNumber: phoneNumber,
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
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground,
                AppTheme.deepGreen,
              ],
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
                        'Welcome Back',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'Sign in to your account to continue your journey.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: AppTheme.mutedForeground,
                        ),
                      ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1),
                      
                      const SizedBox(height: 48),

                      _buildTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        hint: 'example@email.com',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 24),
                      
                      _buildTextField(
                        label: 'Password',
                        controller: _passwordController,
                        hint: '••••••••',
                        icon: LucideIcons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                            color: AppTheme.mutedForeground,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 16),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms),
                      
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
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
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Sign In',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                      
                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.spaceGrotesk(color: AppTheme.mutedForeground),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.spaceGrotesk(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 1000.ms),
                      
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.mutedForeground,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111827).withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
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
