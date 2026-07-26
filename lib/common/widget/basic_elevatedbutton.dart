import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BasicElevatedbutton extends StatelessWidget {
  const BasicElevatedbutton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height,
  });
  final String title;
  final void Function()? onPressed;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style:
          ElevatedButton.styleFrom(minimumSize: Size.fromHeight(height ?? 80.h)),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
