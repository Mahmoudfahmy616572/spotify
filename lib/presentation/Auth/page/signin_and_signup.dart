import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify/common/helper/is_dark_mode.dart';
import 'package:spotify/common/widget/basic_elevatedbutton.dart';
import 'package:spotify/core/config/assets/app_images.dart';
import 'package:spotify/core/config/assets/app_vectors.dart';
import 'package:spotify/presentation/Auth/page/register.dart';
import 'package:spotify/presentation/Auth/page/signin.dart';

import '../../../common/appbar/basic_appbar.dart';

class SigninAndSignup extends StatelessWidget {
  const SigninAndSignup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BasicAppbar(),
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(AppVectors.topRightUnion),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SvgPicture.asset(AppVectors.bottomRightUnion),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Image.asset(
              AppImages.bottomLeftRegAndSigninImg,
              fit: BoxFit.fill,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppVectors.logo,
                    width: 235,
                    height: 71,
                  ),
                  const SizedBox(
                    height: 55,
                  ),
                  const Text(
                    "Enjoy listening to music",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 21),
                  const Text(
                    "Spotify is a proprietary Swedish audio streaming and media services provider ",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        color: Color(0xff797979)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: basicElevetedButton(
                              title: "Register",
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            RegisterPage()));
                              })),
                      Expanded(
                          flex: 1,
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            SigninPage()));
                              },
                              child: Text(
                                "Sign in",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                    color: context.isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                              )))
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
