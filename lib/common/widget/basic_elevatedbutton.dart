import 'package:flutter/material.dart';

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
          ElevatedButton.styleFrom(minimumSize: Size.fromHeight(height ?? 80)),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
