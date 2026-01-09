import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify/core/config/assets/app_images.dart';
import 'package:spotify/core/config/assets/app_vectors.dart';
import 'package:spotify/core/config/theme/app_colors.dart';
import 'package:spotify/presentation/chooseMode/pages/choose_mode.dart';

import '../../../common/widget/basic_elevatedbutton.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(AppImages.getStarted),
                      fit: BoxFit.fill)),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child: SvgPicture.asset(AppVectors.logo)),
                  Spacer(),
                  Text(
                    "Enjoy listening to music",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sagittis enim purus sed phasellus. Cursus ornare id scelerisque aliquam.",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 37,
                  ),
                  basicElevetedButton(
                    title: 'Get started',
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => ChooseMode()));
                    },
                  )
                ],
              ))
        ],
      ),
    );
  }
}
