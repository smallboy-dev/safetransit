import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verification_status_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverProfileSetupScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? name;
  const DriverProfileSetupScreen({super.key, this.phoneNumber, this.name});

  @override
  State<DriverProfileSetupScreen> createState() => _DriverProfileSetupScreenState();
}

class _DriverProfileSetupScreenState extends State<DriverProfileSetupScreen> {
  late final TextEditingController _nameController;
  final _vehicleIdController = TextEditingController();
  String _selectedVehicleType = 'Bus';
  final List<String> _vehicleTypes = ['Bus', 'Car', 'Motorcycle (Okada)', 'Tricycle (Keke)'];
  bool _isLoading = false;
  String? _resumedPhoneNumber;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _resumedPhoneNumber = widget.phoneNumber;

    if (widget.name == null || widget.name!.isEmpty || widget.phoneNumber == null) {
      _fetchProfileData();
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      final firebaseService = context.read<FirebaseService>();
      final user = firebaseService.currentUser;
      if (user != null) {
        final doc = await firebaseService.getUserData(user.uid);
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          if (mounted) {
            setState(() {
              _nameController.text = data?['name'] ?? '';
              _resumedPhoneNumber = data?['phoneNumber'];
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vehicleIdController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    print('Starting profile save...');
    if (_nameController.text.trim().isEmpty || _vehicleIdController.text.trim().isEmpty) {
      print('Validation failed: Name or Vehicle ID is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseService = context.read<FirebaseService>();
      var user = firebaseService.currentUser;
      print('Current User: ${user?.uid}');

      if (user == null) {
        throw Exception('User session lost. Please log in again.');
      }

      if (user != null) {
        final profileData = {
          'name': _nameController.text.trim(),
          'vehicleType': _selectedVehicleType,
          'vehicleId': _vehicleIdController.text.trim(),
          'phoneNumber': _resumedPhoneNumber ?? widget.phoneNumber,
          'userType': 'driver',
          'profileSetupComplete': true,
          'uid': user.uid,
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        print('Saving to Firestore (users/${user.uid}): $profileData');
        
        try {
          
          await firebaseService.updateUserData(user.uid, profileData);
          print('Firestore operation successful');
        } catch (e) {
          print('Firestore error: $e');
        }

        if (mounted) {
          print('Saving setup status and phone to SharedPreferences');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('profileSetupComplete', true);
          if (widget.phoneNumber != null) {
            await prefs.setString('userPhone', widget.phoneNumber!);
          }
          
          print('Navigating to VerificationStatusScreen');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const VerificationStatusScreen(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print('Caught Exception during save: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                        size: 20,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),

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

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        _buildLabel('Full Name'),
                        _buildInputField(
                          controller: _nameController,
                          hintText: 'Jane Doe',
                          readOnly: true,
                        ),
                        
                        const SizedBox(height: 20),

                        _buildLabel('Vehicle Type'),
                        _buildDropdownField(),
                        
                        const SizedBox(height: 20),

                        _buildLabel('Vehicle ID / Plate Number'),
                        _buildInputField(
                          controller: _vehicleIdController,
                          hintText: 'XYZ-9876',
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
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
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFF1F2937).withOpacity(0.3) : const Color(0xFF111827).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1F2937),
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          color: readOnly ? Colors.white60 : Colors.white,
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
