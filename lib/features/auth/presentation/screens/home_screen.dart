import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:safetransit_ai/core/services/nokia_api_service.dart';
import 'live_tracking_screen.dart';
import 'driver_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = false;
  bool _isVerifyingReachability = false;

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
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: const Icon(LucideIcons.user, color: Colors.white, size: 24),
                        ),
                      ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, John',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Ready to drive',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: AppTheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827).withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF1F2937)),
                            ),
                            child: const Icon(
                              LucideIcons.bell,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1),

                // Vehicle Info
                const _VehicleCard(
                  type: 'Bus',
                  plate: 'XYZ-9876',
                  model: 'Transit Master 2000',
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

                // Small Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: LucideIcons.mapPin,
                        label: 'Trips Today',
                        value: '0',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: LucideIcons.clock,
                        label: 'Hours Online',
                        value: '0.0h',
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const Spacer(),

                // Main Toggle Action
                GestureDetector(
                  onTap: _isVerifyingReachability ? null : () async {
                    if (_isOnline) {
                      setState(() => _isOnline = false);
                      return;
                    }

                    setState(() => _isVerifyingReachability = true);

                    try {
                      final nokiaService = context.read<NokiaApiService>();
                      // Check Device Reachability via Nokia NaC
                      final isReachable = await nokiaService.isDeviceReachable('+2349000000000'); // Mock phone
                      
                      if (!isReachable) {
                        throw Exception('Device is currently unreachable on the network. Please check your data connection.');
                      }

                      if (!mounted) return;
                      setState(() {
                        _isOnline = true;
                        _isVerifyingReachability = false;
                      });
                      
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const LiveTrackingScreen()),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _isVerifyingReachability = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString().replaceAll('Exception: ', '')),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isOnline 
                          ? const Color(0xFFEF4444).withOpacity(0.1) 
                          : AppTheme.primaryColor.withOpacity(0.1),
                      border: Border.all(
                        color: _isOnline ? const Color(0xFFEF4444) : AppTheme.primaryColor,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isOnline 
                              ? const Color(0xFFEF4444).withOpacity(0.3) 
                              : AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 60,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dashed rotating circle
                        RotationTransition(
                          turns: const AlwaysStoppedAnimation(0.5),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isOnline ? const Color(0xFFEF4444) : AppTheme.primaryColor,
                                width: 2,
                                style: BorderStyle.none, // Custom dash needed but placeholder
                              ),
                            ),
                          ),
                        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),
                        
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isVerifyingReachability ? LucideIcons.loader : LucideIcons.power,
                              size: 40,
                              color: _isOnline ? const Color(0xFFEF4444) : AppTheme.primaryColor,
                            ).animate(target: _isVerifyingReachability ? 1 : 0)
                             .rotate(duration: 2.seconds),
                            const SizedBox(height: 8),
                            Text(
                              _isVerifyingReachability ? 'VERIFYING...' : (_isOnline ? 'GO OFFLINE' : 'GO ONLINE'),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _isOnline ? const Color(0xFFEF4444) : AppTheme.primaryColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(duration: 800.ms, curve: Curves.easeOutBack),

                const Spacer(),

                // Security Status Card
                const _SecurityStatusCard(isSafe: true)
                    .animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.mutedForeground),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final String type;
  final String plate;
  final String model;

  const _VehicleCard({
    required this.type,
    required this.plate,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.bus, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$type • $plate',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  model,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: const Icon(LucideIcons.chevronRight, color: AppTheme.mutedForeground, size: 16),
          ),
        ],
      ),
    );
  }
}

class _SecurityStatusCard extends StatelessWidget {
  final bool isSafe;

  const _SecurityStatusCard({required this.isSafe});

  @override
  Widget build(BuildContext context) {
    final statusColor = isSafe ? AppTheme.primaryColor : const Color(0xFFEF4444);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSafe ? LucideIcons.shieldCheck : LucideIcons.shieldAlert,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Status',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mutedForeground,
                  ),
                ),
                Text(
                  isSafe ? 'Safe & Monitored' : 'Risk Detected',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              isSafe ? 'SECURE' : 'ALERT',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
