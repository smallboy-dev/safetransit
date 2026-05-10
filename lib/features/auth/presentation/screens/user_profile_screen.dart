import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'emergency_sos_screen.dart';
import 'notifications_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final user = firebaseService.currentUser;
    final String name = user?.displayName ?? 'Sarah Lee';
    final String phone = user?.phoneNumber ?? '+1 (555) 123-4567';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            blurRadius: 30,
                          ),
                        ],
                        image: const DecorationImage(
                          image: NetworkImage('https://i.pravatar.cc/150?u=sarah'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.camera, color: Colors.black, size: 14),
                      ),
                    ),
                  ],
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Passenger',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: const BoxDecoration(
                          color: AppTheme.mutedForeground,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        phone,
                        style: const TextStyle(
                          color: AppTheme.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),

            _buildSectionLabel('ACCOUNT'),
            _buildMenuRow(LucideIcons.history, 'Ride History'),
            _buildMenuRow(
              LucideIcons.shieldCheck, 
              'Safety Settings', 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencySosScreen())),
            ),
            _buildMenuRow(
              LucideIcons.bell, 
              'Notifications',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
            ),
            
            const SizedBox(height: 24),
            _buildSectionLabel('PREFERENCES'),
            _buildMenuRow(LucideIcons.arrowLeftRight, 'Switch to Driver Mode'),
            _buildMenuRow(LucideIcons.settings, 'App Settings'),
            _buildMenuRow(LucideIcons.info, 'Help & Support'),
            
            const SizedBox(height: 24),
            _buildMenuRow(
              LucideIcons.logOut, 
              'Log Out', 
              isDestructive: true,
              onTap: () {
                firebaseService.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 12),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.mutedForeground,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuRow(IconData icon, String label, {bool isDestructive = false, VoidCallback? onTap}) {
    final color = isDestructive ? const Color(0xFFEF4444) : AppTheme.primaryColor;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111827).withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? color : Colors.white,
                  ),
                ),
              ),
              if (!isDestructive)
                const Icon(LucideIcons.chevronRight, color: AppTheme.mutedForeground, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
