import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

IconButton backButton(BuildContext context) {
  return IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: Container(
        height: 30.h,
        width: 30.w,
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 15.sp,
          color: Colors.white,
        )),
  );
}
