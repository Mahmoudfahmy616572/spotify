import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RowTextAndTextBTN extends StatelessWidget {
  const RowTextAndTextBTN({
    super.key,
    required this.title,
    required this.clickedTitle,
    this.onTap,
  });
  final String title;
  final String clickedTitle;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xffE1E1E1),
              fontWeight: FontWeight.normal),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            clickedTitle,
            style: TextStyle(
                fontSize: 14.sp,
                color: Color(0xff38B432),
                fontWeight: FontWeight.normal),
          ),
        ),
      ],
    );
  }
}
