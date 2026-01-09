import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChooseModeBtn extends StatelessWidget {
  const ChooseModeBtn({
    super.key,
    required this.svgName,
    required this.modeTitle,
    this.ontap,
  });
  final String svgName;
  final String modeTitle;
  final void Function()? ontap;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: ontap,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 73,
                width: 73,
                decoration: BoxDecoration(
                    color: const Color(0xff30393c).withOpacity(0.5),
                    shape: BoxShape.circle),
                child: Center(
                    child: SvgPicture.asset(
                  svgName,
                  fit: BoxFit.none,
                )),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 17,
        ),
        Text(
          modeTitle,
          style: const TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
