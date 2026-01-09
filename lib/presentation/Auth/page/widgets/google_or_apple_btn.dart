import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class GoogleOrAppleBTN extends StatelessWidget {
  const GoogleOrAppleBTN({
    super.key,
    required this.svgName,
    this.onTap,
  });
  final String svgName;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        svgName,
        height: 30,
        width: 37,
      ),
    );
  }
}
