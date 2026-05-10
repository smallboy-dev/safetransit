import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:safetransit_ai/core/theme/app_theme.dart';
import 'package:safetransit_ai/core/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'end_trip_screen.dart';

import 'package:safetransit_ai/core/services/nokia_api_service.dart';
import 'dart:async';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  bool _isReachable = true;
  String _connectivity = 'DATA';
  Timer? _locationTimer;
  Timer? _durationTimer;
  DateTime _startTime = DateTime.now();
  String _duration = '00:00';
  double? _lat;
  double? _lng;
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initStatusListener();
    _startLocationTracking();
    _startDurationTimer();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = DateTime.now().difference(_startTime);
      final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
      final hours = diff.inHours > 0 ? '${diff.inHours}:' : '';
      
      if (mounted) {
        setState(() {
          _duration = '$hours$minutes:$seconds';
        });
      }
    });
  }

  void _startLocationTracking() {
    
    _updateLiveLocation();

    _locationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _updateLiveLocation();
    });
  }

  Future<void> _updateLiveLocation() async {
    try {
      final nokiaService = context.read<NokiaApiService>();
      final firebaseService = context.read<FirebaseService>();
      final user = firebaseService.currentUser;

      if (user != null) {
        
        const demoPhone = '+99999991000';
        final locationData = await nokiaService.getLocation(demoPhone);
        
        final lat = locationData['latitude'] ?? locationData['lat'] ?? 0.0;
        final lng = locationData['longitude'] ?? locationData['long'] ?? 0.0;

        if (mounted) {
          setState(() {
            _lat = lat;
            _lng = lng;
          });
        }

        final syncData = {
          'lastKnownLocation': {
            'latitude': lat,
            'longitude': lng,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        };

        firebaseService.updateUserData(user.uid, syncData);
        firebaseService.setDocument('drivers', user.uid, syncData, merge: true);
      }
    } catch (e) {
      print('Location refresh error: $e');
    }
  }

  void _initStatusListener() {
    final firebaseService = context.read<FirebaseService>();
    final user = firebaseService.currentUser;
    if (user != null) {
      firebaseService.getDriverStatusStream(user.uid).listen((doc) {
        if (doc.exists && mounted) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _isReachable = data['reachable'] ?? false;
            final connectivityList = data['connectivity'] as List<dynamic>?;
            _connectivity = (connectivityList != null && connectivityList.isNotEmpty) 
                ? connectivityList.join(' + ') 
                : 'NONE';
          });
          
          if (!_isReachable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Warning: Network connectivity lost. Your status is now OFFLINE.'),
                backgroundColor: Color(0xFFEF4444),
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0B0F1A), 
              child: GridPaper(
                color: Colors.white.withOpacity(0.015),
                divisions: 1,
                subdivisions: 1,
                interval: 120,
              ),
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderButton(
                        context,
                        icon: LucideIcons.arrowLeft,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 800.ms),
                            const SizedBox(width: 8),
                            Text(
                              'TRIP ACTIVE',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      _buildHeaderButton(
                        context,
                        icon: LucideIcons.shieldAlert,
                        iconColor: const Color(0xFFEF4444),
                        onTap: () {
                          
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          border: Border.all(color: AppTheme.primaryColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.5),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.navigation,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ).animate(onPlay: (c) => c.repeat()).scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.2, 1.2),
                        duration: 1.5.seconds,
                        curve: Curves.easeInOut,
                      ),
                      Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppTheme.primaryColor, Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(right: 24.0, bottom: 24.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1F2937)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(LucideIcons.crosshair, color: AppTheme.primaryColor, size: 24),
                      ),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border.all(color: const Color(0xFF1F2937)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 32,
                      ),
                    ],
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
                                'Current Status',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: AppTheme.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _isReachable ? AppTheme.primaryColor : const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _isReachable ? AppTheme.primaryColor : const Color(0xFFEF4444),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isReachable ? 'Online' : 'Offline',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_lat != null && _lng != null)
                                Text(
                                  'Loc: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: AppTheme.primaryColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              if (_isReachable) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Network: $_connectivity',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: AppTheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Duration',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: AppTheme.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _duration,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (_, __, ___) => const EndTripScreen(),
                                transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFFEF4444).withOpacity(0.3),
                          ),
                          child: Text(
                            'End Trip',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 1.0, duration: 600.ms, curve: Curves.easeOutQuart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(BuildContext context, {required IconData icon, Color? iconColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
      ),
    );
  }
}
