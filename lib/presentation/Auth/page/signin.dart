import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify/common/appbar/basic_appbar.dart';
import 'package:spotify/common/helper/is_dark_mode.dart';
import 'package:spotify/core/config/assets/app_vectors.dart';

import '../../../common/widget/basic_elevatedbutton.dart';
import '../../../data/models/auth/signin_req.dart';
import '../../../domain/usecase/auth/signin_usecase.dart';
import '../../../serviece_locator.dart';
import '../../Home/pages/home_page.dart';
import 'widgets/google_or_apple_btn.dart';
import 'widgets/row_text_and_textbtn.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: SvgPicture.asset(
          AppVectors.logo,
          width: 108.w,
          height: 33.h,
          fit: BoxFit.fill,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Sign In",
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15.h,
              ),
              RowTextAndTextBTN(
                title: "If you need any support ",
                clickedTitle: "Click Here",
                onTap: () {},
              ),
              SizedBox(
                height: 26.h,
              ),
              _emailTextField(context),
              SizedBox(
                height: 28.h,
              ),
              _passwordTextField(context),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        "Recovery password",
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black),
                      )),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              basicElevetedButton(
                  title: "Sign In",
                  onPressed: () async {
                    var result = await getIt<SigninUsecase>().call(
                        param: SigninReq(
                      email: _emailController.text.toString(),
                      password: _passwordController.text.toString(),
                    ));
                    result.fold((l) async {
                      var snackBar = SnackBar(
                        content: Text(l),
                        behavior: SnackBarBehavior.floating,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }, (r) async {
                      var snackBar = SnackBar(
                        content: Text(r),
                        behavior: SnackBarBehavior.floating,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                 HomePage()),
                        (route) => false,
                      );
                    });
                  }),
              SizedBox(
                height: 31.h,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  Text(" Or "),
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 36.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GoogleOrAppleBTN(
                    svgName: AppVectors.googleLogo,
                    onTap: () {},
                  ),
                  SizedBox(
                    width: 58.8.w,
                  ),
                  GoogleOrAppleBTN(
                    svgName: AppVectors.appleLogo,
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(
                height: 40.h,
              ),
              RowTextAndTextBTN(
                title: 'Do you have an account? ',
                clickedTitle: 'Sign In',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailTextField(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(hintText: 'Enter Username Or Email')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordTextField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
              hintText: 'Password', suffixIcon: Icon(Icons.visibility))
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }
}
