import 'package:flutter/material.dart';
import 'package:spotify/common/helper/is_dark_mode.dart';

IconButton backButton(BuildContext context) {
  return IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            color: context.isDarkMode
                ? Colors.white.withOpacity(0.3)
                : const Color(0xff414141).withOpacity(0.2),
            shape: BoxShape.circle),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 15,
          color: context.isDarkMode ? Colors.white : Colors.black,
        )),
  );
}
