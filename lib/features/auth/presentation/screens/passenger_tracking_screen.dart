import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PassengerTrackingScreen extends StatefulWidget {
  final String driverId;
  final Map<String, dynamic> driverData;

  const PassengerTrackingScreen({
    super.key, 
    required this.driverId, 
    required this.driverData
  });

  @override
  State<PassengerTrackingScreen> createState() => _PassengerTrackingScreenState();
}

class _PassengerTrackingScreenState extends State<PassengerTrackingScreen> {
  
  final double _passengerLat = 6.5244;
  final double _passengerLng = 3.3792;
  bool _isRatingDialogShowing = false;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.driverId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? widget.driverData;
        final isOnline = data['isOnline'] ?? false;
        final status = data['status'] ?? 'idle';
        final activePassengerId = data['activePassengerId'];
        final geofenceStatus = data['geofenceStatus'] ?? 'idle';

        if (geofenceStatus == 'entered' && context.mounted) {
          Future.microtask(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🚀 Driver has entered your pickup zone!'),
                backgroundColor: AppTheme.primaryColor,
                duration: Duration(seconds: 5),
              ),
            );
          });
        }

        if ((!isOnline || activePassengerId == null) && context.mounted) {
          if (!_isRatingDialogShowing) {
            _isRatingDialogShowing = true;
            Future.microtask(() {
              _showRatingDialog(context, data);
            });
          }
          return const Scaffold(body: SizedBox.shrink());
        }

        final location = data['lastKnownLocation'] as Map<String, dynamic>?;
        final driverLat = location?['latitude'] ?? 0.0;
        final driverLng = location?['longitude'] ?? 0.0;

        return Scaffold(
          backgroundColor: AppTheme.darkBackground,
          body: Stack(
            children: [
              
              _buildMockMap(driverLat, driverLng),

              _buildTrackingDetails(data, driverLat, driverLng),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleButton(LucideIcons.arrowLeft, () => Navigator.pop(context)),
                      GestureDetector(
                        onTap: () => _showShareDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.share2, color: AppTheme.primaryColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'SHARE LOCATION',
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildCircleButton(LucideIcons.shieldAlert, () => _showSOSDialog(), color: Colors.red),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMockMap(double driverLat, double driverLng) {
    return Container(
      color: const Color(0xFF0B0F1A),
      child: Stack(
        children: [
          
          GridPaper(
            color: Colors.white.withOpacity(0.01),
            divisions: 1,
            interval: 100,
          ),

          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 1),
              ),
              child: Center(
                child: Text(
                  '300m NAC RADIUS',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds, color: AppTheme.primaryColor.withOpacity(0.1)),

          Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            top: MediaQuery.of(context).size.height * 0.4 + (driverLat - _passengerLat) * 500,
            left: MediaQuery.of(context).size.width * 0.5 + (driverLng - _passengerLng) * 500,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryColor.withOpacity(0.5), blurRadius: 12),
                    ],
                  ),
                  child: const Icon(LucideIcons.bus, color: Colors.black, size: 20),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Driver',
                    style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingDetails(Map<String, dynamic> data, double lat, double lng) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?u=driver'), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? 'Driver', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('${data['vehicleId'] ?? 'ID'} • ${data['vehicleType'] ?? 'Bus'}', style: GoogleFonts.spaceGrotesk(color: AppTheme.mutedForeground, fontSize: 14)),
                    ],
                  ),
                ),
                _buildCircleButton(LucideIcons.phone, () {}, color: Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFF1F2937)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('DISTANCE', '0.8 km'),
                _buildInfoColumn('ETA', '3 min'),
                _buildInfoColumn('SECURITY', 'SECURE', color: AppTheme.primaryColor),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Cancel Trip', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(color: AppTheme.mutedForeground, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.spaceGrotesk(color: color ?? Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, Map<String, dynamic> driverData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Trip Completed', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How was your trip with ${driverData['name'] ?? 'the driver'}?', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
            const SizedBox(height: 24),
            ElevatedButton(
               onPressed: () {
                 FirebaseFirestore.instance.collection('flags').add({
                    'driverId': widget.driverId,
                    'reason': 'Customer flagged this driver',
                    'timestamp': FieldValue.serverTimestamp(),
                 });
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Driver has been flagged and suspended for review.'), backgroundColor: Colors.red)
                 );
                 Navigator.pop(context); 
                 if (Navigator.canPop(context)) Navigator.pop(context); 
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.red.withOpacity(0.1),
                 foregroundColor: Colors.red,
                 elevation: 0,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.red)),
                 minimumSize: const Size(double.infinity, 50),
               ),
               child: Text('Flag Driver (Safety Issue)', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
               onPressed: () {
                 Navigator.pop(context);
                 if (Navigator.canPop(context)) Navigator.pop(context);
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppTheme.primaryColor,
                 foregroundColor: Colors.black,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 minimumSize: const Size(double.infinity, 50),
               ),
               child: Text('Submit Rating', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
            )
          ]
        ),
      ),
    );
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.shieldAlert, color: Colors.red),
            const SizedBox(width: 8),
            Text('Emergency SOS', style: GoogleFonts.spaceGrotesk(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do you want to send an emergency alert to SafeTransit admin?', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.phone, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency Hotline', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 12)),
                        Text('+1 (800) 555-SAFE', style: GoogleFonts.spaceGrotesk(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.phoneCall, color: Colors.white),
                    onPressed: () async {
                      final uri = Uri.parse('tel:+18005550000');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                    style: IconButton.styleFrom(backgroundColor: Colors.red),
                  )
                ],
              ),
            ),
          ]
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.spaceGrotesk(color: AppTheme.mutedForeground)),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('emergencies').add({
                'passengerId': context.read<FirebaseService>().currentUser?.uid,
                'driverId': widget.driverId,
                'timestamp': FieldValue.serverTimestamp(),
                'status': 'active',
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🚨 Emergency Alert Sent! Help is on the way.'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text('Send Alert', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Share Live Location', style: GoogleFonts.spaceGrotesk(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppTheme.primaryColor, child: Icon(LucideIcons.link, color: Colors.black)),
                title: Text('Share via Apps (WhatsApp, etc.)', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Share.share('Track my SafeTransit ride live: https://safetransit.ai/track/${widget.driverId}');
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(LucideIcons.messageSquare, color: Colors.white)),
                title: Text('SMS Emergency Contact', style: GoogleFonts.spaceGrotesk(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final uri = Uri.parse('sms:?body=Track my SafeTransit ride live: https://safetransit.ai/track/${widget.driverId}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }
}
