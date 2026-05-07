import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'verification_status_screen.dart';

class DriverProfileSetupScreen extends StatefulWidget {
  const DriverProfileSetupScreen({super.key});

  @override
  State<DriverProfileSetupScreen> createState() => _DriverProfileSetupScreenState();
}

class _DriverProfileSetupScreenState extends State<DriverProfileSetupScreen> {
  String _selectedVehicleType = 'Bus';
  final List<String> _vehicleTypes = ['Bus', 'Car', 'Motorcycle (Okada)', 'Tricycle (Keke)'];

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
                // Header / Back Navigation
                Padding(
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
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),

                // Title Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Your Profile',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: -0.8,
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          'Provide your details to start driving with SafeTransit.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ).animate().fadeIn(delay: 350.ms, duration: 600.ms).slideX(begin: -0.1),
                    ],
                  ),
                ),
                
                // Form Section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        _buildLabel('Full Name'),
                        _buildInputField(hintText: 'Jane Doe'),
                        
                        const SizedBox(height: 20),
                        
                        // Vehicle Type
                        _buildLabel('Vehicle Type'),
                        _buildDropdownField(),
                        
                        const SizedBox(height: 20),
                        
                        // Vehicle ID / Plate Number
                        _buildLabel('Vehicle ID / Plate Number'),
                        _buildInputField(hintText: 'XYZ-9876'),
                        
                        const SizedBox(height: 32),
                      ],
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05),
                  ),
                ),
                
                // Action Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const VerificationStatusScreen()),
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
                      child: Text(
                        'Continue',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.95, 0.95)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildInputField({required String hintText}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1F2937),
        ),
      ),
      child: TextField(
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: AppTheme.mutedForeground.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1F2937),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVehicleType,
          icon: const Icon(LucideIcons.chevronDown, size: 20, color: AppTheme.mutedForeground),
          dropdownColor: const Color(0xFF111827),
          isExpanded: true,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: Colors.white,
          ),
          items: _vehicleTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedVehicleType = newValue;
              });
            }
          },
        ),
      ),
    );
  }
}
