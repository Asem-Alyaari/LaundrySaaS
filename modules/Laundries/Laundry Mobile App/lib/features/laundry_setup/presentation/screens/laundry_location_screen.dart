import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../data/models/laundry_dto.dart';
import '../../data/repositories/laundry_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

class LaundryLocationScreen extends StatefulWidget {
  final String tenant;
  final String accessToken;
  final String name;
  final String phoneNumber;
  final String city;
  final String district;
  final String street;
  final String buildingNumber;

  const LaundryLocationScreen({
    super.key,
    required this.tenant,
    required this.accessToken,
    required this.name,
    required this.phoneNumber,
    required this.city,
    required this.district,
    required this.street,
    required this.buildingNumber,
  });

  @override
  State<LaundryLocationScreen> createState() => _LaundryLocationScreenState();
}

class _LaundryLocationScreenState extends State<LaundryLocationScreen> {
  // Default fallback: Riyadh, KSA
  static const LatLng _defaultLocation = LatLng(24.7136, 46.6753);

  final _laundryRepository = LaundryRepository();

  GoogleMapController? _mapController;
  LatLng _selectedLocation = _defaultLocation;
  bool _gettingLocation = false;
  bool _saving = false;
  String? _errorMessage;
  bool _locationSet = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _gettingLocation = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _errorMessage = 'خدمة تحديد الموقع غير مفعّلة. يرجى تفعيل GPS من إعدادات الجهاز.';
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _errorMessage = 'تم رفض إذن الوصول للموقع. يرجى السماح للتطبيق باستخدام موقعك.';
          });
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _errorMessage = 'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.';
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;

      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = newLocation;
        _locationSet = true;
      });
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 16),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'تعذّر تحديد الموقع الحالي. يمكنك سحب الخريطة ووضع العلامة يدوياً.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _gettingLocation = false);
      }
    }
  }

  void _onCameraMove(CameraPosition position) {
    _selectedLocation = position.target;
  }

  Future<void> _saveAndFinish() async {
    if (!_locationSet) {
      setState(() {
        _errorMessage = 'يرجى تحديد موقع المغسلة على الخريطة ثم الحفظ.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final dto = CreateUpdateLaundryDto(
        name: widget.name,
        phoneNumber: widget.phoneNumber,
        address: CreateUpdateAddressDto(
          city: widget.city,
          district: widget.district,
          street: widget.street,
          buildingNumber: widget.buildingNumber,
        ),
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );

      final created = await _laundryRepository.createLaundry(
        tenant: widget.tenant,
        accessToken: widget.accessToken,
        dto: dto,
      );

      if (mounted) {
        context.read<AuthController>().setLaundryId(created.id);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'تحديد موقع المغسلة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Header hint card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.my_location_rounded,
                    color: Color(0xFF0284C7), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'حدد موقع المغسلة على الخريطة. سيظهر هذا الموقع للعملاء للعثور على مغسلة قريبة منهم.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF0F172A),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Map area
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation,
                        zoom: 14,
                      ),
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      onMapCreated: (controller) =>
                          _mapController = controller,
                      onCameraMove: _onCameraMove,
                    ),
                  ),
                ),

                // Center pin marker
                IgnorePointer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFEF4444),
                        size: 46,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'موقع المغسلة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Current location FAB
                Positioned(
                  bottom: 16,
                  right: 32,
                  child: FloatingActionButton(
                    heroTag: 'currentLocation',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0284C7),
                    elevation: 3,
                    onPressed:
                        _gettingLocation ? null : _fetchCurrentLocation,
                    child: _gettingLocation
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF0284C7),
                            ),
                          )
                        : const Icon(Icons.my_location_rounded, size: 24),
                  ),
                ),
              ],
            ),
          ),

          // Bottom save card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.place_outlined,
                          color: Color(0xFF64748B), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _locationSet
                            ? 'خط العرض: ${_selectedLocation.latitude.toStringAsFixed(6)}  |  خط الطول: ${_selectedLocation.longitude.toStringAsFixed(6)}'
                            : 'لم يتم تحديد الموقع بعد',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveAndFinish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        disabledBackgroundColor: const Color(0xFF94A3B8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'حفظ والبدء',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
}
