import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/customer_address.dart';
import '../controllers/customer_address_controller.dart';

class MapAddressPickerScreen extends StatefulWidget {
  final CustomerAddress? addressToEdit;

  const MapAddressPickerScreen({super.key, this.addressToEdit});

  @override
  State<MapAddressPickerScreen> createState() => _MapAddressPickerScreenState();
}

class _MapAddressPickerScreenState extends State<MapAddressPickerScreen> {
  // الموقع الافتراضي: الرياض
  static const LatLng _defaultLocation = LatLng(24.7136, 46.6753);

  GoogleMapController? _mapController;
  LatLng _selectedLocation = _defaultLocation;
  AddressType _selectedType = AddressType.home;

  final TextEditingController _titleController = TextEditingController(text: 'المنزل');
  final TextEditingController _notesController = TextEditingController();

  bool _isDefault = false;
  bool _gettingLocation = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final item = widget.addressToEdit;

    if (item != null) {
      _selectedLocation = LatLng(item.latitude, item.longitude);
      _selectedType = item.type;
      _titleController.text = item.title;
      _notesController.text = item.buildingOrFloor ?? item.deliveryNotes ?? '';
      _isDefault = item.isDefault;
    } else {
      // جلب الموقع الحالي تلقائياً عند الدخول للشاشة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchCurrentLocation();
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _titleController.dispose();
    _notesController.dispose();
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
            _errorMessage = 'خدمة الموقع (GPS) غير مفعلة. يرجى تفعيلها من إعدادات جهازك.';
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
            _errorMessage = 'تم رفض إذن الوصول للموقع. يمكنك سحب الخريطة واختيار الموقع يدوياً.';
          });
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _errorMessage = 'إذن الموقع مرفوض دائماً. يمكنك تحريك الخريطة لتحديد موقعك.';
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;

      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = newLocation;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 16.5),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'تعذر جلب موقع GPS تلقائياً. يمكنك تحريك الخريطة واختيار الموقع.';
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

  Future<void> _saveLocation() async {
    setState(() => _isSaving = true);

    final controller = context.read<CustomerAddressController>();
    final notes = _notesController.text.trim();

    String title = _titleController.text.trim();
    if (title.isEmpty) {
      switch (_selectedType) {
        case AddressType.home:
          title = 'المنزل';
          break;
        case AddressType.work:
          title = 'العمل';
          break;
        case AddressType.other:
          title = 'عنوان آخر';
          break;
      }
    }

    final address = CustomerAddress(
      id: widget.addressToEdit?.id ?? '',
      title: title,
      type: _selectedType,
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      description: 'موقع محدد عبر الخريطة',
      buildingOrFloor: notes.isNotEmpty ? notes : null,
      deliveryNotes: notes.isNotEmpty ? notes : null,
      isDefault: _isDefault,
      createdAt: widget.addressToEdit?.createdAt ?? DateTime.now(),
    );

    final success = await controller.saveAddress(address);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  widget.addressToEdit != null
                      ? 'تم تحديث موقع العنوان بنجاح ✨'
                      : 'تم حفظ الموقع والعنوان في حسابك بنجاح ✨',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            content: Text(controller.errorMessage ?? 'فشل حفظ العنوان، حاول مجدداً'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.addressToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          isEditing ? 'تعديل موقع العنوان' : 'تحديد موقع التوصيل',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // ─── 1. بطاقة إرشادية علوية ناعمة (Hint Card) ───
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'حرّك الخريطة وضع المؤشر على موقعك بدقة، أو اضغط زر GPS لتحديد موقعك الحالي تلقائياً.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── رسالة الخطأ إن وجدت ───
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ─── 2. منطقة الخريطة التفاعلية مع المؤشر المركزي وزر GPS ───
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // الخريطة مع حواف منحنية أنيقة
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation,
                        zoom: 16,
                      ),
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: (ctrl) => _mapController = ctrl,
                      onCameraMove: _onCameraMove,
                    ),
                  ),
                ),

                // مؤشر المنتصف الثابت
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_shipping_rounded, size: 13, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'نقطة التوصيل',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Icon(
                          Icons.location_on,
                          color: AppColors.error,
                          size: 46,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // زر تحديد الموقع الحالي GPS
                Positioned(
                  bottom: 16,
                  left: 36,
                  child: FloatingActionButton(
                    heroTag: 'currentLocation',
                    mini: true,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 3,
                    onPressed: _gettingLocation ? null : _fetchCurrentLocation,
                    child: _gettingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(Icons.my_location_rounded, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // ─── 3. بطاقة التأكيد السفلية الثابتة والسهلة ───
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: AppColors.cardBorder)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // اختيار نوع العنوان (أزرار سريعة)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypePill(
                          type: AddressType.home,
                          title: 'المنزل',
                          icon: Icons.home_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTypePill(
                          type: AddressType.work,
                          title: 'العمل',
                          icon: Icons.business_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTypePill(
                          type: AddressType.other,
                          title: 'أخرى',
                          icon: Icons.location_on_rounded,
                        ),
                      ),
                    ],
                  ),

                  // حقل اسم العنوان المخصص إذا اختار "أخرى"
                  if (_selectedType == AddressType.other) ...[
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: 'اسم العنوان (مثال: بيت الوالدة، المزرعة)',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                          prefixIcon: Icon(Icons.bookmark_outline_rounded, color: AppColors.textSecondary, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // حقل المبنى والملاحظات الاختياري
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: TextField(
                      controller: _notesController,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: const InputDecoration(
                        hintText: 'المبنى / رقم الشقة أو ملاحظات للسائق (اختياري)',
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        prefixIcon: Icon(Icons.apartment_rounded, color: AppColors.textSecondary, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // السطر السفلي: إحداثيات الموقع وخيار تعيين كافتراضي
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // إحداثيات GPS
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${_selectedLocation.latitude.toStringAsFixed(4)}°, ${_selectedLocation.longitude.toStringAsFixed(4)}°',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // خيار الافتراضي
                      Row(
                        children: [
                          const Text(
                            'عنوان رئيسي',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _isDefault,
                              activeColor: AppColors.primary,
                              onChanged: (val) => setState(() => _isDefault = val),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // زر الحفظ الرئيسي الكبير والواضح
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        disabledBackgroundColor: const Color(0xFF94A3B8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'تأكيد وحفظ موقع العنوان',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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

  Widget _buildTypePill({
    required AddressType type,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          if (_titleController.text.isEmpty ||
              _titleController.text == 'المنزل' ||
              _titleController.text == 'العمل' ||
              _titleController.text == 'عنوان آخر') {
            _titleController.text = title;
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
