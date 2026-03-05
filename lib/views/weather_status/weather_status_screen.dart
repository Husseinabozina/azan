import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:azan/core/components/global_copyright_footer.dart';

class WeatherStatusScreen extends StatefulWidget {
  const WeatherStatusScreen({super.key});

  @override
  State<WeatherStatusScreen> createState() => _WeatherStatusScreenState();
}

class _WeatherStatusScreenState extends State<WeatherStatusScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isWeatherEnabled = false;
  int _weatherSource = 0;
  String? _manualLat;
  String? _manualLng;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _isWeatherEnabled = CacheHelper.getWeatherEnabled();
      _weatherSource = CacheHelper.getWeatherSource();
      _manualLat = CacheHelper.getManualWeatherLat();
      _manualLng = CacheHelper.getManualWeatherLng();
    });
  }

  void _saveSettings() {
    CacheHelper.setWeatherEnabled(_isWeatherEnabled);
    CacheHelper.setWeatherSource(_weatherSource);
    if (_manualLat != null && _manualLng != null) {
      CacheHelper.setManualWeatherLat(_manualLat!);
      CacheHelper.setManualWeatherLng(_manualLng!);
    }
  }

  Future<void> _showGpsDialog() async {
    final latController = TextEditingController(text: _manualLat ?? '');
    final lngController = TextEditingController(text: _manualLng ?? '');
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 60.w : 20.w,
            vertical: isLandscape ? 35.h : 40.h,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isLandscape ? 550 : double.infinity,
              maxHeight: isLandscape ? 450.h : 500.h,
            ),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppTheme.dialogBackgroundColor,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5.w,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.enter_gps_coordinates.tr(),
                  style: TextStyle(
                    fontSize: isLandscape ? 22.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dialogTitleColor,
                  ),
                ),
                SizedBox(height: 18.h),
                SizedBox(
                  height: 56.h,
                  child: TextField(
                    controller: latController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(fontSize: 18.sp),
                    decoration: InputDecoration(
                      labelText: LocaleKeys.latitude.tr(),
                      hintText: '24.7136',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  height: 56.h,
                  child: TextField(
                    controller: lngController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(fontSize: 18.sp),
                    decoration: InputDecoration(
                      labelText: LocaleKeys.longitude.tr(),
                      hintText: '46.6753',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(
                      text: LocaleKeys.common_cancel.tr(),
                      color: AppTheme.cancelButtonBackgroundColor,
                      textColor: AppTheme.cancelButtonTextColor,
                      onTap: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 14.w),
                    _buildButton(
                      text: LocaleKeys.common_ok.tr(),
                      color: AppTheme.primaryButtonBackground,
                      textColor: AppTheme.primaryButtonTextColor,
                      onTap: () {
                        final lat = latController.text.trim();
                        final lng = lngController.text.trim();
                        if (lat.isEmpty || lng.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                LocaleKeys.please_fill_all_fields.tr(),
                              ),
                            ),
                          );
                          return;
                        }
                        if (double.tryParse(lat) == null ||
                            double.tryParse(lng) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                LocaleKeys.invalid_coordinates.tr(),
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _manualLat = lat;
                          _manualLng = lng;
                          _weatherSource = 1;
                        });
                        _saveSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const GlobalCopyrightFooter(),
      key: _scaffoldKey,
      drawer: CustomDrawer(context: context),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              CacheHelper.getSelectedBackground(),
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                SizedBox(
                  height: isLandscape ? 50.h : 52.h,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        icon: Icon(
                          Icons.menu,
                          color: AppTheme.primaryTextColor,
                          size: 24.r,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.accentColor,
                          size: 24.r,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: isLandscape
                      ? _buildLandscapeContent()
                      : _buildPortraitContent(),
                ),

                // Bottom Bar
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16.r,
                          color: AppTheme.accentColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          LocaleKeys.weather_info_text.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Icon + Title
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2.w,
                    ),
                  ),
                  child: Icon(
                    Icons.thermostat,
                    size: 40.r,
                    color: AppTheme.accentColor,
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  LocaleKeys.weather_status.tr(),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  LocaleKeys.weather_status_subtitle.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(width: 20.w),

          // Right: Settings
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildToggleCard(),
                SizedBox(height: 15.h),
                if (_isWeatherEnabled) _buildSourceCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Column(
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2.w,
              ),
            ),
            child: Icon(
              Icons.thermostat,
              size: 40.r,
              color: AppTheme.accentColor,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            LocaleKeys.weather_status.tr(),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            LocaleKeys.weather_status_subtitle.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          _buildToggleCard(),
          SizedBox(height: 15.h),
          if (_isWeatherEnabled) _buildSourceCard(),
        ],
      ),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isWeatherEnabled
              ? AppTheme.accentColor
              : Colors.white.withOpacity(0.2),
          width: 1.5.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isWeatherEnabled ? Icons.cloud : Icons.cloud_off,
            size: 32.r,
            color: _isWeatherEnabled
                ? AppTheme.accentColor
                : AppTheme.secondaryTextColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.enable_weather.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: _isWeatherEnabled
                        ? AppTheme.accentColor
                        : AppTheme.primaryTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  LocaleKeys.enable_weather_hint.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isWeatherEnabled,
            onChanged: (v) {
              setState(() => _isWeatherEnabled = v);
              _saveSettings();
            },
            activeColor: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.my_location, size: 28.r, color: AppTheme.accentColor),
              SizedBox(width: 8.w),
              Text(
                LocaleKeys.weather_source.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          _buildSourceOption(
            title: LocaleKeys.weather_source_auto.tr(),
            subtitle: LocaleKeys.weather_source_auto_hint.tr(),
            isSelected: _weatherSource == 0,
            onTap: () {
              setState(() => _weatherSource = 0);
              _saveSettings();
            },
          ),
          SizedBox(height: 10.h),
          _buildSourceOption(
            title: LocaleKeys.weather_source_manual.tr(),
            subtitle: _manualLat != null
                ? 'Lat: $_manualLat, Lng: $_manualLng'
                : LocaleKeys.weather_source_manual_no_coords.tr(),
            isSelected: _weatherSource == 1,
            onTap: _showGpsDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentColor
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.accentColor
                      : AppTheme.secondaryTextColor,
                  width: 2.w,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.accentColor
                          : AppTheme.primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.secondaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
