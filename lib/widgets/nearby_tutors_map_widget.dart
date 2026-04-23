import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:urban_tutor/models/tutor_model.dart';
import 'package:urban_tutor/providers/tutor_provider.dart';
import 'package:urban_tutor/utils/app_colors.dart';

/// A self-contained map widget showing blue pins for every tutor
/// who has geocoded coordinates. Placed between the search bar
/// and category chips on the home page.
class NearbyTutorsMapWidget extends StatefulWidget {
  final void Function(TutorModel tutor) onViewProfile;

  const NearbyTutorsMapWidget({super.key, required this.onViewProfile});

  @override
  State<NearbyTutorsMapWidget> createState() => _NearbyTutorsMapWidgetState();
}

class _NearbyTutorsMapWidgetState extends State<NearbyTutorsMapWidget> {
  GoogleMapController? _mapController;
  LatLng? _userPosition;
  TutorModel? _selectedTutor;
  bool _mapReady = false;

  // Default: Mumbai
  static const _defaultPosition = LatLng(19.0760, 72.8777);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    // Fallback: show map after 4s even if location fails
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_mapReady) setState(() => _mapReady = true);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── Get user location ──────────────────────────────────────────────────────
  Future<void> _getUserLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _mapReady = true);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _mapReady = true);
        return;
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
        if (mounted) {
          setState(() {
            _userPosition = LatLng(pos.latitude, pos.longitude);
            _mapReady = true;
          });
          _mapController?.animateCamera(CameraUpdate.newLatLng(_userPosition!));
        }
      } else {
        // Permission denied — use default
        if (mounted) setState(() => _mapReady = true);
      }
    } catch (_) {
      if (mounted) setState(() => _mapReady = true);
    }
  }

  // ── Build markers ──────────────────────────────────────────────────────────
  Set<Marker> _buildMarkers(List<TutorModel> tutors) {
    return tutors
        .where((t) => t.location.latitude != null && t.location.longitude != null)
        .map((t) => Marker(
              markerId: MarkerId(t.id ?? t.personalInfo.fullName),
              position: LatLng(t.location.latitude!, t.location.longitude!),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              onTap: () => setState(() => _selectedTutor = t),
            ))
        .toSet();
  }

  List<TutorModel> _getMappableTutors(List<TutorModel> tutors) {
    return tutors
        .where((t) => t.location.latitude != null && t.location.longitude != null)
        .toList();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final isTablet = w > 600;
    final isLandscape = w > h;

    // Responsive map height
    double mapHeight;
    if (isTablet) {
      mapHeight = isLandscape ? h * 0.35 : h * 0.22;
    } else {
      mapHeight = isLandscape ? h * 0.45 : h * 0.28;
    }
    mapHeight = mapHeight.clamp(180.0, 320.0);

    return Consumer<TutorProvider>(
      builder: (context, tp, _) {
        final allTutors = tp.tutors;
        final mappable = _getMappableTutors(allTutors);
        final showLoading = !_mapReady && tp.isLoading;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section label ──
              Text(
                'Tutors Near You',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: isTablet ? 20 : 18,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap a pin to preview a tutor',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 12 : 11,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 10),

              // ── Map container ──
              Container(
                height: mapHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: showLoading
                    ? _buildLoadingState()
                    : Stack(
                        children: [
                          // ── Google Map ──
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _userPosition ?? _defaultPosition,
                              zoom: 12.5,
                            ),
                            markers: _buildMarkers(allTutors),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            compassEnabled: false,
                            onMapCreated: (c) => _mapController = c,
                            onTap: (_) => setState(() => _selectedTutor = null),
                            mapType: MapType.normal,
                            // ─── THIS IS THE KEY FIX ───
                            // Without gestureRecognizers, the parent
                            // CustomScrollView consumes all touch events
                            // and the map becomes un-tappable / un-pannable.
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                          ),

                          // ── Tutor count badge ──
                          Positioned(
                            top: 12, left: 12,
                            child: _buildMapLegend(mappable.length),
                          ),

                          // ── My Location button ──
                          Positioned(
                            top: 12, right: 12,
                            child: _buildCustomLocationButton(),
                          ),

                          // ── Preview card ──
                          if (_selectedTutor != null)
                            _buildTutorPreviewCard(isTablet, w),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  LOADING STATE
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primaryBlue, strokeWidth: 2.5),
            const SizedBox(height: 10),
            Text(
              'Finding tutors near you…',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  MAP LEGEND / TUTOR COUNT BADGE
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildMapLegend(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.push_pin_rounded, size: 13, color: AppColors.primaryBlue),
          const SizedBox(width: 4),
          Text(
            count > 0 ? '$count tutors nearby' : 'No tutors mapped yet',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11, color: const Color(0xFF2D2D2D)),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  CUSTOM "MY LOCATION" BUTTON
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildCustomLocationButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (_userPosition != null) {
            _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_userPosition!, 13));
          }
        },
        child: SizedBox(
          width: 40, height: 40,
          child: Icon(Icons.my_location_rounded, color: AppColors.primaryBlue, size: 20),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  TUTOR PREVIEW CARD (slides up from bottom of map)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildTutorPreviewCard(bool isTablet, double screenWidth) {
    final tutor = _selectedTutor!;
    final initials = _getInitials(tutor.personalInfo.fullName);
    final cardWidth = isTablet ? screenWidth * 0.4 : screenWidth - 56;

    return Positioned(
      bottom: 12,
      left: isTablet ? null : 12,
      right: 12,
      child: SizedBox(
        width: isTablet ? cardWidth : null,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, offset, child) {
            return FractionalTranslation(translation: offset, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    // ── Avatar ──
                    CircleAvatar(
                      radius: isTablet ? 28 : 24,
                      backgroundColor: AppColors.primaryBlue,
                      child: tutor.personalInfo.profileImageUrl.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: tutor.personalInfo.profileImageUrl,
                                width: isTablet ? 56 : 48,
                                height: isTablet ? 56 : 48,
                                fit: BoxFit.cover,
                                placeholder: (c, u) => Text(initials, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                errorWidget: (c, u, e) => Text(initials, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                              ),
                            )
                          : Text(initials, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                    const SizedBox(width: 10),

                    // ── Info ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tutor.personalInfo.fullName,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: isTablet ? 14 : 13, color: const Color(0xFF2D2D2D)),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          if (tutor.professionalInfo.subjects.isNotEmpty)
                            Text(
                              tutor.professionalInfo.subjects.join(', '),
                              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF757575)),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 11, color: AppColors.primaryBlue),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  tutor.location.area,
                                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF757575)),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // ── Fees + View button ──
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${tutor.professionalInfo.monthlyRate.toInt()}/mo',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: () => widget.onViewProfile(tutor),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                          ),
                          child: Text('View', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Close button ──
                Positioned(
                  top: 0, right: 0,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTutor = null),
                    child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF999999)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Initials helper ──
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}
