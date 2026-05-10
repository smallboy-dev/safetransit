import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Notifications',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Read All',
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('TODAY'),
            const SizedBox(height: 12),
            _buildNotificationRow(
              LucideIcons.bus,
              AppTheme.primaryColor,
              'Bus arriving in 2 minutes',
              'Line 4 • Downtown is approaching your stop. Please have your pass ready.',
              '10:42 AM',
              isUnread: true,
            ),
            _buildNotificationRow(
              LucideIcons.shieldCheck,
              const Color(0xFF10B981),
              'Driver verified',
              'Michael Scott has been verified and is currently driving your route securely.',
              '09:15 AM',
              isUnread: true,
            ),
            _buildNotificationRow(
              LucideIcons.triangleAlert,
              const Color(0xFFEF4444),
              'Delay detected',
              'Heavy traffic reported ahead. Expect a delay of approximately 5-8 minutes.',
              '08:30 AM',
              isUnread: false,
            ),
            
            const SizedBox(height: 32),
            _buildSectionLabel('YESTERDAY'),
            const SizedBox(height: 12),
            _buildNotificationRow(
              LucideIcons.creditCard,
              Colors.white,
              'Payment successful',
              'Your weekly transit pass has been renewed successfully for \$25.00.',
              '4:20 PM',
              isUnread: false,
            ),
            _buildNotificationRow(
              LucideIcons.mapPin,
              Colors.white,
              'Trip Completed',
              'You arrived at South District Hub. Thank you for riding with us.',
              '9:05 AM',
              isUnread: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.mutedForeground,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNotificationRow(IconData icon, Color color, String title, String message, String time, {bool isUnread = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? AppTheme.primaryColor.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUnread ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: AppTheme.mutedForeground,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 12, top: 8),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 1000.ms),
        ],
      ),
    );
  }
}
