import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:safetransit_ai/core/services/nokia_api_service.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'live_tracking_screen.dart';
import 'driver_profile_screen.dart';
import 'safety_status_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = false;
  bool _isVerifyingReachability = false;
  String _driverName = 'Loading...';
  String _vehicleType = '...';
  String _vehicleId = '...';
  bool _isSimSwapped = false;
  bool _isTrackingOpen = false;
  bool _isShowingAcceptDialog = false;

  StreamSubscription? _profileSubscription;

  @override
  void initState() {
    super.initState();
    _startProfileStream();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _startProfileStream() {
    try {
      final firebaseService = context.read<FirebaseService>();
      final user = firebaseService.currentUser;
      
      if (user != null) {
        _profileSubscription = firebaseService.documentStream('users', user.uid).listen((doc) {
          if (doc.exists && mounted) {
            final data = doc.data() as Map<String, dynamic>;
            final activePassengerId = data['activePassengerId'];
            
            setState(() {
              _driverName = data['name'] ?? 'Driver';
              _vehicleType = data['vehicleType'] ?? 'Vehicle';
              _vehicleId = data['vehicleId'] ?? 'ID';
              _isSimSwapped = data['isSimSwapped'] ?? false;
              _isOnline = data['isOnline'] ?? false;
            });

            final status = data['status'] ?? 'idle';
            if (activePassengerId != null && _isOnline) {
              if (status == 'pending' && !_isShowingAcceptDialog) {
                _showAcceptDialog(activePassengerId);
              } else if (status == 'active' && !_isTrackingOpen) {
                _isTrackingOpen = true;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LiveTrackingScreen(),
                  ),
                ).then((_) {
                  _isTrackingOpen = false;
                });
              }
            }
          }
        });
      }
    } catch (e) {
      print('Error starting profile stream: $e');
    }
  }

  Future<void> _showAcceptDialog(String passengerId) async {
    _isShowingAcceptDialog = true;
    final firebaseService = context.read<FirebaseService>();
    
    // Fetch passenger name
    String passengerName = 'A passenger';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(passengerId).get();
      if (doc.exists) {
        passengerName = doc.data()?['name'] ?? 'A passenger';
      }
    } catch (e) {
      print('Failed to get passenger details: $e');
    }

    if (!mounted) return;
    
    // Trigger real-time notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔔 New Ride Request from $passengerName!'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.user, size: 48, color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Text(
                'New Ride Request',
                style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '$passengerName wants to book you for a ride.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(fontSize: 16, color: AppTheme.mutedForeground),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final user = firebaseService.currentUser;
                        if (user != null) {
                          await firebaseService.updateUserData(user.uid, {
                            'activePassengerId': null,
                            'status': 'idle',
                            'geofenceStatus': 'idle',
                          });
                        }
                        _isShowingAcceptDialog = false;
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Reject', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final user = firebaseService.currentUser;
                        if (user != null) {
                          await firebaseService.updateUserData(user.uid, {
                            'status': 'active',
                          });
                        }
                        _isShowingAcceptDialog = false;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Accept', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
              children: [
                
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
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DriverProfileScreen()),
                              );
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                border:
                                    Border.all(color: const Color(0xFF1F2937)),
                              ),
                              child: const Icon(LucideIcons.user,
                                  color: Colors.white, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, $_driverName',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Ready: $_vehicleId',
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
                              border:
                                  Border.all(color: const Color(0xFF1F2937)),
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
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1),

                _VehicleCard(
                  type: _vehicleType,
                  plate: _vehicleId,
                  model: 'SafeTransit Verified',
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

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

                GestureDetector(
                  onTap: _isVerifyingReachability
                      ? null
                      : () async {
                          if (_isOnline) {
                            setState(() => _isOnline = false);

                            final firebaseService = context.read<FirebaseService>();
                            final user = firebaseService.currentUser;
                            if (user != null) {
                              firebaseService.updateUserData(user.uid, {
                                'isOnline': false,
                                'updatedAt': DateTime.now().toIso8601String(),
                              });
                            }
                            return;
                          }

                          setState(() => _isVerifyingReachability = true);

                          try {
                            final nokiaService = context.read<NokiaApiService>();
                            final firebaseService = context.read<FirebaseService>();
                            final user = firebaseService.currentUser;

                            if (user == null) {
                              throw Exception('User not authenticated');
                            }

                            const demoPhone = '+99999991000';

                            print('Step 1: Subscribing to Reachability for $demoPhone...');
                            await nokiaService.subscribeToReachability(demoPhone, user.uid).timeout(
                              const Duration(seconds: 10),
                              onTimeout: () => throw Exception('Reachability subscription timed out'),
                            );

                            print('Step 2: Retrieving live location from NaC network...');
                            final locationData = await nokiaService.getLocation(demoPhone).timeout(
                              const Duration(seconds: 10),
                              onTimeout: () => throw Exception('Location retrieval timed out'),
                            );
                            
                            final lat = locationData['latitude'] ?? locationData['lat'] ?? 0.0;
                            final lng = locationData['longitude'] ?? locationData['long'] ?? 0.0;
                            print('Location received: $lat, $lng');

                            print('Step 3: Verifying SIM integrity...');
                            final isSimSwapped = await nokiaService.detectSimSwap(demoPhone);
                            String? swapDate;
                            int riskScore = 0;
                            double rating = 4.8; 
                            
                            if (isSimSwapped) {
                              swapDate = await nokiaService.getSimSwapDate(demoPhone);
                              riskScore = 98; 
                              rating = 2.1; 
                              print('WARNING: SIM SWAP DETECTED at $swapDate. Risk: $riskScore%, Rating: $rating');
                            }

                            print('Step 4: Syncing status to Firestore...');
                            final updateData = {
                              'isOnline': true,
                              'reachable': true,
                              'isSimSwapped': isSimSwapped,
                              'simSwapDate': swapDate,
                              'riskScore': riskScore,
                              'rating': rating,
                              'lastKnownLocation': {
                                'latitude': lat,
                                'longitude': lng,
                              },
                              'lastOnlineAt': DateTime.now().toIso8601String(),
                              'updatedAt': DateTime.now().toIso8601String(),
                            };

                            firebaseService.updateUserData(user.uid, updateData).catchError((e) {
                              print('Non-fatal Firestore error (users): $e');
                              return null;
                            });
                            
                            firebaseService.setDocument('drivers', user.uid, {
                              ...updateData,
                              'driverId': user.uid,
                            }).catchError((e) {
                              print('Non-fatal Firestore error (drivers): $e');
                              return null;
                            });

                            print('Activation complete. Driver is now ONLINE.');
                            if (!mounted) return;
                            setState(() {
                              _isVerifyingReachability = false;
                              _isOnline = true;
                            });
                          } catch (e) {
                            print('Go Online Error: $e');
                            if (!mounted) return;
                            setState(() => _isVerifyingReachability = false);
                            
                            String errorMsg = e.toString().replaceAll('Exception: ', '');
                            if (errorMsg.contains('500')) {
                              errorMsg = "Network Error: Please ensure Firestore API is enabled in Google Console.";
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMsg),
                                backgroundColor: const Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 5),
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
                        color: _isOnline
                            ? const Color(0xFFEF4444)
                            : AppTheme.primaryColor,
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
                        
                        RotationTransition(
                          turns: const AlwaysStoppedAnimation(0.5),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isOnline
                                    ? const Color(0xFFEF4444)
                                    : AppTheme.primaryColor,
                                width: 2,
                                style: BorderStyle
                                    .none, 
                              ),
                            ),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .rotate(duration: 10.seconds),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isVerifyingReachability
                                  ? LucideIcons.loader
                                  : LucideIcons.power,
                              size: 40,
                              color: _isOnline
                                  ? const Color(0xFFEF4444)
                                  : AppTheme.primaryColor,
                            )
                                .animate(
                                    target: _isVerifyingReachability ? 1 : 0)
                                .rotate(duration: 2.seconds),
                            const SizedBox(height: 8),
                            Text(
                              _isVerifyingReachability
                                  ? 'VERIFYING...'
                                  : (_isOnline ? 'GO OFFLINE' : 'GO ONLINE'),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _isOnline
                                    ? const Color(0xFFEF4444)
                                    : AppTheme.primaryColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .scale(duration: 800.ms, curve: Curves.easeOutBack),

                const Spacer(),

                _SecurityStatusCard(isSafe: !_isSimSwapped)
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .slideY(begin: 0.1),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      {required IconData icon, required String label, required String value}) {
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
            child: const Icon(LucideIcons.chevronRight,
                color: AppTheme.mutedForeground, size: 16),
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
    final statusColor =
        isSafe ? AppTheme.primaryColor : const Color(0xFFEF4444);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SafetyStatusScreen()),
        );
      },
      child: Container(
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
      ),
    );
  }
}
