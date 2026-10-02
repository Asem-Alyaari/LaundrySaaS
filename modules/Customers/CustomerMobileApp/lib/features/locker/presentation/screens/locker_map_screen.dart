import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../addresses/presentation/controllers/customer_address_controller.dart';
import '../../data/models/locker_dto.dart';
import '../../data/repositories/locker_repository.dart';

class LockerMapScreen extends StatefulWidget {
  const LockerMapScreen({super.key});

  @override
  State<LockerMapScreen> createState() => _LockerMapScreenState();
}

class _LockerMapScreenState extends State<LockerMapScreen> {
  final LockerRepository _repository = LockerRepository();
  GoogleMapController? _mapController;

  LatLng _currentSearchCenter = const LatLng(15.3070, 44.2477); // الافتراضي: صنعاء (حيث المغاسل المسجلة)
  String _currentSearchTitle = 'جاري تحديد الموقع...';
  double _searchRadiusKm = 15.0;

  bool _isLoading = true;
  String? _errorMessage;
  List<LockerDto> _lockers = [];
  LockerDto? _selectedLocker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationAndFetch();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// تحديد نقطة البداية (العنوان المسجل أو GPS) وجلب المغاسل
  Future<void> _initializeLocationAndFetch() async {
    final addrCtrl = Provider.of<CustomerAddressController>(context, listen: false);

    // إذا لم تكن العناوين محملة بعد، نقوم بتحميلها
    if (addrCtrl.addresses.isEmpty && !addrCtrl.isLoading) {
      await addrCtrl.loadAddresses();
    }

    final selected = addrCtrl.selectedAddress;
    if (selected != null && selected.latitude != 0.0 && selected.longitude != 0.0) {
      _currentSearchCenter = LatLng(selected.latitude, selected.longitude);
      _currentSearchTitle = selected.title;
      await _fetchNearbyLockers();
      return;
    }

    // إذا لم يتوفر عنوان محدد، نحاول جلب موقع الـ GPS الحالي
    await _tryFetchGpsLocation(fallbackToDefault: true);
  }

  Future<void> _tryFetchGpsLocation({bool fallbackToDefault = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (fallbackToDefault) {
          _currentSearchTitle = 'الموقع الافتراضي';
          await _fetchNearbyLockers();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'خدمة الموقع (GPS) غير مفعلة.';
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (fallbackToDefault) {
          _currentSearchTitle = 'الموقع الافتراضي';
          await _fetchNearbyLockers();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'تم رفض إذن الوصول للموقع.';
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      _currentSearchCenter = LatLng(position.latitude, position.longitude);
      _currentSearchTitle = 'موقعي الحالي 📍';
      await _fetchNearbyLockers();
    } catch (_) {
      if (fallbackToDefault) {
        _currentSearchTitle = 'الموقع الافتراضي';
        await _fetchNearbyLockers();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'تعذر الحصول على موقعك الحالي.';
        });
      }
    }
  }

  Future<void> _fetchNearbyLockers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.fetchNearby(
        latitude: _currentSearchCenter.latitude,
        longitude: _currentSearchCenter.longitude,
        radius: _searchRadiusKm,
      );

      if (mounted) {
        setState(() {
          _lockers = list;
          _selectedLocker = list.isNotEmpty ? list.first : null;
          _isLoading = false;
        });

        // تحريك الكاميرا للمركز أو أول مغسلة
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _selectedLocker != null
                    ? LatLng(_selectedLocker!.latitude, _selectedLocker!.longitude)
                    : _currentSearchCenter,
                zoom: 14.5,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'تعذر الاتصال بالسيرفر لجلب المغاسل.';
        });
      }
    }
  }

  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0;
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  String _formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()} متر';
    }
    return '${km.toStringAsFixed(1)} كم';
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // علامة موقع البحث الحالي للعميل
    markers.add(
      Marker(
        markerId: const MarkerId('user_search_center'),
        position: _currentSearchCenter,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: 'موقعك المعتمد للبحث',
          snippet: _currentSearchTitle,
        ),
      ),
    );

    // علامات المغاسل
    for (final locker in _lockers) {
      final isSelected = _selectedLocker?.id == locker.id;
      final dist = _calculateDistanceKm(
        _currentSearchCenter.latitude,
        _currentSearchCenter.longitude,
        locker.latitude,
        locker.longitude,
      );

      markers.add(
        Marker(
          markerId: MarkerId(locker.id),
          position: LatLng(locker.latitude, locker.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueRed,
          ),
          zIndexInt: isSelected ? 2 : 1,
          infoWindow: InfoWindow(
            title: locker.name,
            snippet: '${locker.address} • يبعد ${_formatDistance(dist)}',
          ),
          onTap: () {
            setState(() {
              _selectedLocker = locker;
            });
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(LatLng(locker.latitude, locker.longitude)),
            );
          },
        ),
      );
    }

    return markers;
  }

  void _showAddressSelectionBottomSheet() {
    final addrCtrl = Provider.of<CustomerAddressController>(context, listen: false);
    final addresses = addrCtrl.addresses;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'اختر موقع البحث عن المغاسل',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.my_location, color: AppColors.primary),
                  ),
                  title: const Text('موقعي الحالي (GPS)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('استخدام إحداثيات موقعك الحالي عبر GPS'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _tryFetchGpsLocation();
                  },
                ),
                const Divider(),
                if (addresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'لا توجد عناوين محفوظة بعد. يمكنك إضافة عنوان جديد من شاشة إدارة العناوين.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: addresses.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final addr = addresses[index];
                        final isChosen = _currentSearchCenter.latitude == addr.latitude &&
                            _currentSearchCenter.longitude == addr.longitude;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isChosen ? AppColors.primary : Colors.grey.shade100,
                            child: Icon(
                              Icons.location_on,
                              color: isChosen ? Colors.white : AppColors.primary,
                            ),
                          ),
                          title: Text(addr.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            addr.description.isNotEmpty ? addr.description : '${addr.latitude}, ${addr.longitude}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: isChosen ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() {
                              _currentSearchCenter = LatLng(addr.latitude, addr.longitude);
                              _currentSearchTitle = addr.title;
                            });
                            _fetchNearbyLockers();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المغاسل القريبة 🧺'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
              onPressed: _fetchNearbyLockers,
            ),
          ],
        ),
        body: Stack(
          children: [
            // ─── 1. خريطة Google ───
            GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _currentSearchCenter,
                zoom: 14.0,
              ),
              markers: _buildMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),

            // ─── 2. كرت تحديد عنوان البحث العلوي ───
            Positioned(
              top: 12,
              right: 16,
              left: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'نقطة البحث الحالية',
                              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _currentSearchTitle,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddressSelectionBottomSheet,
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text('تغيير', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.primaryLight.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── 3. أزرار التحكم الدائرية على الخريطة ───
            Positioned(
              right: 16,
              bottom: _selectedLocker != null ? 240 : 100,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'btn_gps',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    onPressed: () => _tryFetchGpsLocation(),
                    tooltip: 'تحديد موقعي عبر GPS',
                    child: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    heroTag: 'btn_zoom_center',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: _currentSearchCenter, zoom: 15),
                        ),
                      );
                    },
                    tooltip: 'الرجوع لنقطة البحث',
                    child: const Icon(Icons.center_focus_strong),
                  ),
                ],
              ),
            ),

            // ─── 4. مؤشر التحميل ───
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    elevation: 6,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(width: 16),
                          Text('جاري البحث عن المغاسل القريبة...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ─── 5. كرت النتائج أو رسالة عدم وجود مغاسل (السفلي) ───
            if (!_isLoading)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildBottomPanel(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    if (_errorMessage != null) {
      return Card(
        color: Colors.red.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _fetchNearbyLockers,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    if (_lockers.isEmpty) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.store_mall_directory_outlined, size: 44, color: Colors.orange),
              const SizedBox(height: 8),
              Text(
                'لا توجد مغاسل ضمن نطاق ${_searchRadiusKm.toInt()} كم من موقعك',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'يمكنك زيادة نطاق البحث أو اختيار عنوان آخر من القائمة أعلاه.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchRadiusKm += 15.0;
                      });
                      _fetchNearbyLockers();
                    },
                    icon: const Icon(Icons.zoom_out_map, size: 16),
                    label: Text('توسيع لـ ${(_searchRadiusKm + 15).toInt()} كم'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddressSelectionBottomSheet,
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('تغيير العنوان'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // عرض المغسلة المحددة وقائمة المغاسل
    final selected = _selectedLocker ?? _lockers.first;
    final dist = _calculateDistanceKm(
      _currentSearchCenter.latitude,
      _currentSearchCenter.longitude,
      selected.latitude,
      selected.longitude,
    );

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.local_laundry_service, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selected.address.isNotEmpty ? selected.address : 'العنوان مسجل على الخريطة',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDistance(dist),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // قائمة أفقية لاختيار مغاسل أخرى إن وجدت
            if (_lockers.length > 1) ...[
              const Text(
                'المغاسل المتوفرة في النطاق:',
                style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _lockers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final item = _lockers[i];
                    final isSel = item.id == selected.id;
                    return ChoiceChip(
                      label: Text(item.name),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : Colors.black87,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() {
                          _selectedLocker = item;
                        });
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(LatLng(item.latitude, item.longitude)),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم اختيار "${selected.name}" بنجاح'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Navigator.pop(context, selected);
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('اختيار هذه المغسلة والطلب الآن', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
