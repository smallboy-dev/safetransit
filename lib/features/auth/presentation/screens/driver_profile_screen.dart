import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';

import 'package:provider/provider.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    print('--- LOGOUT INITIATED ---');
    try {
      final firebaseService = context.read<FirebaseService>();
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('manualLogout', true);

      await prefs.remove('profileSetupComplete');
      await prefs.remove('lastActiveTime');

      await firebaseService.signOut();
      print('Firebase signed out');
      
      if (context.mounted) {
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final user = firebaseService.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: user != null ? firebaseService.documentStream('users', user.uid) : null,
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final name = userData?['name'] ?? 'Driver';
        final vehicleType = userData?['vehicleType'] ?? 'Vehicle';
        final vehicleId = userData?['vehicleId'] ?? 'ID';
        String joinedDate = '2024';
        if (userData?['createdAt'] != null) {
          final dt = userData!['createdAt'] is Timestamp 
              ? (userData!['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(userData!['createdAt'].toString()) ?? DateTime.now();
          joinedDate = '${dt.year}';
        } else if (user?.metadata.creationTime != null) {
          joinedDate = '${user!.metadata.creationTime!.year}';
        }

        final totalTrips = userData?['totalTrips']?.toString() ?? '0';
        final earnings = userData?['earnings']?.toString() ?? '0.0';
        
        int joinedYears = 0;
        if (userData?['createdAt'] != null) {
          final dt = userData!['createdAt'] is Timestamp 
              ? (userData!['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(userData!['createdAt'].toString()) ?? DateTime.now();
          joinedYears = DateTime.now().difference(dt).inDays ~/ 365;
        } else if (user?.metadata.creationTime != null) {
          joinedYears = DateTime.now().difference(user!.metadata.creationTime!).inDays ~/ 365;
        }

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderButton(
                        context,
                        icon: LucideIcons.chevronLeft,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'Profile',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      _buildHeaderButton(
                        context,
                        icon: LucideIcons.logOut,
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                border: Border.all(color: AppTheme.primaryColor, width: 2),
                              ),
                              child: const Icon(LucideIcons.user, color: Colors.white, size: 48),
                            ),
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.star, color: Colors.black, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '4.9',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    const SizedBox(height: 4),
                    Text(
                      'SafeTransit Driver since $joinedDate',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppTheme.mutedForeground,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  ],
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(child: _buildStatItem('Total Trips', totalTrips)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatItem('Earnings', '\$$earnings')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatItem('Joined', '${joinedYears}y')),
                    ],
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildMenuItem(LucideIcons.user, 'Personal Information', 'Name: $name'),
                      _buildMenuItem(LucideIcons.car, 'Vehicle Details', '$vehicleType, $vehicleId'),
                      _buildMenuItem(LucideIcons.wallet, 'Payment & Wallet', 'Withdraw, History'),
                      _buildMenuItem(LucideIcons.fileText, 'Documents', 'License, Insurance'),
                      _buildMenuItem(LucideIcons.messageCircle, 'Support & Help', 'FAQ, Live Chat'),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GestureDetector(
                    onTap: () => _logout(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.logOut, color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Logout',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              color: AppTheme.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppTheme.mutedForeground, size: 18),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, 
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF111827).withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
