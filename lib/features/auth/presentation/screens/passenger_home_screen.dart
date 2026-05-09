import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final onlineDrivers = snapshot.data?.docs ?? [];
        
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 1. Mock Map Background
              _buildMapBackground(),

              // 2. Top Gradient Overlay
              _buildTopGradient(),

              // 3. Top Search & Profile Bar
              _buildTopBar(),

              // 4. Map Markers
              _buildMapMarkers(onlineDrivers),

              // 5. Bottom Transit Sheet
              _buildBottomTransitSheet(onlineDrivers),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMapBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&q=80&w=2000',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black54,
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  Widget _buildTopGradient() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 150,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: [
            // Search Bar
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, color: AppTheme.mutedForeground, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Where are you going?',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.mutedForeground,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Profile Icon
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?u=passenger'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
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
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1);
  }

  Widget _buildMapMarkers(List<DocumentSnapshot> drivers) {
    // Generate a few random positions for existing drivers to simulate them on our "mock map"
    // In a real app with a real map widget, we'd use their actual Lat/Lng
    return Stack(
      children: [
        ...List.generate(drivers.length, (index) {
          final data = drivers[index].data() as Map<String, dynamic>;
          final type = data['vehicleType']?.toString().toLowerCase() ?? 'bus';
          
          // Spread them out randomly for the demo
          double top = 0.2 + (index * 0.15) % 0.6;
          double left = 0.1 + (index * 0.23) % 0.8;

          return Positioned(
            top: MediaQuery.of(context).size.height * top,
            left: MediaQuery.of(context).size.width * left,
            child: _buildMarker(
              type == 'bus' ? LucideIcons.bus : LucideIcons.car, 
              AppTheme.primaryColor
            ),
          );
        }),
        
        // Current Location Marker
        Positioned(
          top: MediaQuery.of(context).size.height * 0.6,
          left: MediaQuery.of(context).size.width * 0.5,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3B82F6), width: 2),
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat()).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
            duration: 1500.ms,
            curve: Curves.easeInOut,
          ).then().scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1, 1),
          ),
        ),
      ],
    );
  }

  Widget _buildMarker(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 16,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 18),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildBottomTransitSheet(List<DocumentSnapshot> drivers) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F1A).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby Transit',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${drivers.length} Live',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (drivers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.search, color: AppTheme.mutedForeground, size: 40),
                        const SizedBox(height: 16),
                        Text(
                          'Searching for nearby drivers...',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.mutedForeground,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...drivers.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final isSimSwapped = data['isSimSwapped'] ?? false;
                  final riskScore = data['riskScore'] ?? 0;
                  final rating = data['rating'] ?? 4.8;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        if (isSimSwapped) {
                          _showSecurityWarning(context, data['name'] ?? 'Driver', riskScore);
                        } else {
                          // Normal flow - proceed to ride details
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Proceeding to ride details...')),
                          );
                        }
                      },
                      child: _buildRouteCard(
                        '${data['name'] ?? 'Driver'} • ${data['vehicleId'] ?? 'ID'}',
                        data['vehicleType']?.toString().toLowerCase() ?? 'bus',
                        '$rating ⭐',
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1.0, duration: 800.ms, curve: Curves.easeOutQuart);
  }

  void _showSecurityWarning(BuildContext context, String driverName, int riskScore) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(LucideIcons.shieldAlert, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 12),
            Text(
              'Security Alert',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A potential identity risk has been detected for $driverName.',
              style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.shieldAlert, color: Color(0xFFEF4444), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RISK LEVEL: $riskScore%',
                          style: GoogleFonts.spaceGrotesk(
                            color: const Color(0xFFEF4444),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'System detected high-risk activity on this driver\'s network profile. Potential account takeover detected.',
                          style: GoogleFonts.spaceGrotesk(
                            color: const Color(0xFFEF4444).withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'For your safety, we recommend choosing another ride. Do you wish to proceed despite the high risk?',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.mutedForeground, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel Ride',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.mutedForeground),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proceeding despite warning...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Proceed Anyway',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(String route, String type, String eta) {
    final bool isBus = type == 'bus';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isBus ? LucideIcons.bus : LucideIcons.trainFront,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isBus ? 'Bus' : 'Train',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                eta,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'away',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppTheme.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
