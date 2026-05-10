import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';

class SafetyStatusScreen extends StatelessWidget {
  const SafetyStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final user = firebaseService.currentUser;

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
          'Safety Status',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.info, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null ? firebaseService.documentStream('users', user.uid) : null,
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final isSafe = !(data['isSimSwapped'] ?? false);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                
                _buildStatusCard(isSafe),
                
                const SizedBox(height: 32),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SYSTEM DIAGNOSTICS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mutedForeground,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDiagnosticRow(LucideIcons.smartphone, 'Device Integrity', isSafe ? 'Secured' : 'Compromised', isSafe),
                _buildDiagnosticRow(LucideIcons.cpu, 'SIM Card Status', 'Verified', true),
                _buildDiagnosticRow(LucideIcons.wifi, 'Network Encryption', 'Active', true),
                _buildDiagnosticRow(LucideIcons.mapPin, 'Location Services', 'Tracking', true),
                
                if (!isSafe) ...[
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 12,
                      shadowColor: const Color(0xFFEF4444).withOpacity(0.3),
                    ),
                    child: Text(
                      'Run Full Diagnostics',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(bool isSafe) {
    final color = isSafe ? AppTheme.primaryColor : const Color(0xFFEF4444);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 4),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 40),
              ],
            ),
            child: Icon(isSafe ? LucideIcons.shieldCheck : LucideIcons.shieldAlert, color: color, size: 48),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 2000.ms,
          ),
          const SizedBox(height: 24),
          Text(
            isSafe ? 'Safe' : 'Risk Detected',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isSafe ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isSafe 
              ? 'Your device is actively monitored and reporting no security issues.'
              : 'Suspicious activity or unauthorized modifications have been detected on this device.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: AppTheme.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticRow(IconData icon, String title, String status, bool isGood) {
    final statusColor = isGood ? AppTheme.primaryColor : const Color(0xFFEF4444);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF000000),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: AppTheme.mutedForeground, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isGood ? LucideIcons.shieldCheck : LucideIcons.shieldAlert, color: statusColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: GoogleFonts.spaceGrotesk(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
