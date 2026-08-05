import 'dart:math' show sin, cos;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify/core/config/theme/app_colors.dart';

class SpatialAudioPage extends StatefulWidget {
  const SpatialAudioPage({super.key});

  @override
  State<SpatialAudioPage> createState() => _SpatialAudioPageState();
}

class _SpatialAudioPageState extends State<SpatialAudioPage>
    with TickerProviderStateMixin {
  bool _spatialEnabled = false;
  double _intensity = 0.7;
  String _selectedPreset = 'Immersive';
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _presets = [
    {'name': 'Immersive', 'icon': Icons.surround_sound, 'description': 'Full 3D surround experience'},
    {'name': 'Concert Hall', 'icon': Icons.stadium, 'description': 'Large venue reverb'},
    {'name': 'Studio', 'icon': Icons.headphones, 'description': 'Clean studio monitoring'},
    {'name': 'Intimate', 'icon': Icons.hearing, 'description': 'Close and personal sound'},
  ];

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_spatialEnabled && !_rotateController.isAnimating) {
      _rotateController.repeat();
    } else if (!_spatialEnabled && _rotateController.isAnimating) {
      _rotateController.stop();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Spatial Audio',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildVisualization(),
            SizedBox(height: 28.h),
            _buildToggle(),
            SizedBox(height: 24.h),
            _buildIntensitySlider(),
            SizedBox(height: 28.h),
            _buildPresets(),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualization() {
    return Container(
      width: 280.w,
      height: 280.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[900],
        border: Border.all(
          color: _spatialEnabled
              ? AppColors.primaryColor.withOpacity(0.5)
              : Colors.grey[800]!,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * 3.14159,
                child: CustomPaint(
                  size: Size(260.w, 260.w),
                  painter: _SpatialRingsPainter(
                    enabled: _spatialEnabled,
                    intensity: _intensity,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _spatialEnabled
                    ? 0.95 + _pulseController.value * 0.1
                    : 1.0,
                child: Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _spatialEnabled
                        ? AppColors.primaryColor
                        : Colors.grey[700],
                    boxShadow: _spatialEnabled
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor
                                  .withOpacity(0.4 + _pulseController.value * 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    Icons.headphones,
                    color: Colors.white,
                    size: 32.sp,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 20.w,
            child: _buildSpeakerDot('L', _spatialEnabled),
          ),
          Positioned(
            bottom: 20.w,
            child: _buildSpeakerDot('R', _spatialEnabled),
          ),
          Positioned(
            left: 20.w,
            child: _buildSpeakerDot('LS', _spatialEnabled),
          ),
          Positioned(
            right: 20.w,
            child: _buildSpeakerDot('RS', _spatialEnabled),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerDot(String label, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AppColors.primaryColor.withOpacity(0.3)
            : Colors.grey[800],
        border: Border.all(
          color: active ? AppColors.primaryColor : Colors.grey[700]!,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '3D Audio',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Enable spatial sound processing',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Switch(
            value: _spatialEnabled,
            onChanged: (val) => setState(() => _spatialEnabled = val),
            activeColor: AppColors.primaryColor,
            activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensitySlider() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intensity',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(_intensity * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primaryColor,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: AppColors.primaryColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 3.h,
            ),
            child: Slider(
              value: _intensity,
              onChanged: _spatialEnabled
                  ? (val) => setState(() => _intensity = val)
                  : null,
              min: 0.0,
              max: 1.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtle', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
              Text('Maximum', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Presets',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        ...(_presets.map((preset) {
          final isSelected = _selectedPreset == preset['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedPreset = preset['name']),
            child: Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.15)
                    : Colors.grey[900],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey[800]!,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    preset['icon'] as IconData,
                    color: isSelected ? AppColors.primaryColor : Colors.grey,
                    size: 24.sp,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset['name'] as String,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          preset['description'] as String,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle,
                        color: AppColors.primaryColor, size: 22.sp),
                ],
              ),
            ),
          );
        })),
      ],
    );
  }
}

class _SpatialRingsPainter extends CustomPainter {
  final bool enabled;
  final double intensity;

  _SpatialRingsPainter({required this.enabled, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final radius = (size.width / 2) * (i / 5);
      paint.color = enabled
          ? AppColors.primaryColor.withOpacity((0.3 - i * 0.06) * intensity)
          : Colors.grey[800]!.withOpacity(0.2);
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 12; i++) {
      final angle = (2 * 3.14159 / 12) * i;
      final r = size.width * 0.42;
      final dx = cx + r * cos(angle);
      final dy = cy + r * sin(angle);
      dotPaint.color = enabled
          ? AppColors.primaryColor.withOpacity(0.5 * intensity)
          : Colors.grey[700]!.withOpacity(0.3);
      canvas.drawCircle(Offset(dx, dy), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_SpatialRingsPainter oldDelegate) =>
      oldDelegate.enabled != enabled || oldDelegate.intensity != intensity;
}
