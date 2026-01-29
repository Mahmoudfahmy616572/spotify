import 'package:flutter/material.dart';
import 'package:spotify/common/helper/is_dark_mode.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  BasicAppbar({super.key, this.title, this.isLeading = false});
  final Widget? title;
  final bool isLeading;
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: title ?? const Text(''),
        elevation: 0,
        leading: isLeading
            ? null
            : IconButton(
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
              ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
