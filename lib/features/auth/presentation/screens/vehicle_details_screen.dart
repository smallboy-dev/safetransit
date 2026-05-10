import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'passenger_tracking_screen.dart';
import 'package:safetransit_ai/core/services/nokia_api_service.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> driverData;
  final String driverId;

  const VehicleDetailsScreen({
    super.key, 
    required this.driverData, 
    required this.driverId
  });

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  bool _isStartingTrip = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.driverId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? widget.driverData;
        final isOnline = data['isOnline'] ?? false;
        final status = data['status'] ?? 'idle';

        if (_isStartingTrip && context.mounted) {
          if (status == 'active') {
            Future.microtask(() {
              if (mounted) setState(() => _isStartingTrip = false);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PassengerTrackingScreen(
                    driverId: widget.driverId,
                    driverData: data,
                  ),
                ),
              );
            });
          } else if (status == 'idle') {
            Future.microtask(() {
              if (mounted) setState(() => _isStartingTrip = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Driver rejected the trip request.'), backgroundColor: Colors.red),
              );
            });
          }
        }

        if (!isOnline && context.mounted) {
          Future.microtask(() {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('The driver is no longer online.')),
              );
            }
          });
          return const SizedBox.shrink();
        }
        
        final name = data['name'] ?? 'Driver';
        final vehicleId = data['vehicleId'] ?? 'ID';
        final vehicleType = data['vehicleType'] ?? 'Vehicle';
        final rating = (data['rating'] ?? 5.0).toDouble();
        final isVerified = data['isVerified'] ?? true;

        final eta = '3 min'; 

        return Scaffold(
          backgroundColor: AppTheme.darkBackground,
          body: Stack(
            children: [
              
              CustomScrollView(
                slivers: [
                  
                  SliverAppBar(
                    backgroundColor: AppTheme.darkBackground.withOpacity(0.8),
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    centerTitle: true,
                    title: Text(
                      'Vehicle Details',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(LucideIcons.share2, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          _buildVehicleSummary(vehicleId, vehicleType),
                          
                          const SizedBox(height: 32),

                          _buildSectionLabel('YOUR DRIVER'),
                          const SizedBox(height: 12),
                          _buildDriverCard(name, isVerified, rating),
                          
                          const SizedBox(height: 32),

                          _buildSectionLabel('JOURNEY PROGRESS'),
                          const SizedBox(height: 12),
                          _buildJourneyCard(eta),
                          
                          const SizedBox(height: 120), 
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              _buildStickyFooter(context, data),
            ],
          ),
        );
      }
    );
  }

  Widget _buildVehicleSummary(String vehicleId, String vehicleType) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.bus, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle #$vehicleId',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '$vehicleType • Active Route',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: AppTheme.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.mutedForeground,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildDriverCard(String name, bool isVerified, double rating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?u=driver'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.shieldCheck, color: AppTheme.primaryColor, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: GoogleFonts.spaceGrotesk(
                                color: AppTheme.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '$rating ⭐',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.phone, color: Colors.white, size: 20),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF1F2937),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildJourneyCard(String eta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Arrival',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: AppTheme.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    eta,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.clock, color: AppTheme.primaryColor, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF1F2937)),
          const SizedBox(height: 24),

          _buildRouteStep('North Station', '09:12 AM', isCompleted: true, isLast: false),
          _buildRouteStep('Downtown Station', 'Arriving in $eta', isCurrent: true, isLast: false),
          _buildRouteStep('South District Hub', '10:05 AM', isLast: true),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRouteStep(String station, String time, {bool isCompleted = false, bool isCurrent = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isCompleted ? AppTheme.primaryColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent || isCompleted ? AppTheme.primaryColor : AppTheme.mutedForeground,
                    width: 2,
                  ),
                ),
                child: isCompleted ? const Icon(LucideIcons.check, color: Colors.black, size: 10) : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppTheme.primaryColor : const Color(0xFF1F2937),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent ? Colors.white : AppTheme.mutedForeground,
                    ),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: isCurrent ? AppTheme.primaryColor : AppTheme.mutedForeground.withOpacity(0.7),
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context, Map<String, dynamic> data) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppTheme.darkBackground,
              AppTheme.darkBackground.withOpacity(0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: ElevatedButton(

          onPressed: _isStartingTrip ? null : () async {
            setState(() => _isStartingTrip = true);
            final firebaseService = context.read<FirebaseService>();
            final nokiaService = context.read<NokiaApiService>();
            final passenger = firebaseService.currentUser;
            
            if (passenger != null) {

              try {
                final driverPhone = data['phoneNumber'] ?? '';
                if (driverPhone.isNotEmpty) {
                  await nokiaService.createGeofence(
                    phoneNumber: driverPhone,
                    driverId: widget.driverId,
                    latitude: 6.5244,
                    longitude: 3.3792,
                    radius: 300,
                  );
                  print('Geofence subscription created for $driverPhone');
                }
              } catch (e) {
                print('Geofencing setup failed: $e');
              }

              await firebaseService.updateUserData(widget.driverId, {
                'activePassengerId': passenger.uid,
                'status': 'pending', // Wait for driver to accept
                'geofenceStatus': 'monitoring',
                'updatedAt': FieldValue.serverTimestamp(),
              });
              // Wait for stream to detect status change to 'active'
            } else {
              setState(() => _isStartingTrip = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 12,
            shadowColor: AppTheme.primaryColor.withOpacity(0.3),
          ),
          child: _isStartingTrip
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Waiting for driver...',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Book Now',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
