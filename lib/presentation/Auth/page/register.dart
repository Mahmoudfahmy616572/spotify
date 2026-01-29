import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify/common/appbar/basic_appbar.dart';
import 'package:spotify/common/widget/basic_elevatedbutton.dart';
import 'package:spotify/core/config/assets/app_vectors.dart';
import 'package:spotify/domain/usecase/auth/sighnup_usecase.dart';

import '../../../data/models/auth/create_user_req.dart';
import '../../../serviece_locator.dart';
import '../../Home/pages/home_page.dart';
import 'widgets/google_or_apple_btn.dart';
import 'widgets/row_text_and_textbtn.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
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
                "Register",
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
              _fullNameTextField(context),
              SizedBox(
                height: 28.h,
              ),
              _emailTextField(context),
              SizedBox(
                height: 28.h,
              ),
              _passwordTextField(context),
              SizedBox(
                height: 33.h,
              ),
              basicElevetedButton(
                  title: "Register",
                  onPressed: () async {
                    var result = await getIt<SighnupUsecase>().call(
                        param: CreateUserReq(
                      email: _emailController.text.toString(),
                      password: _passwordController.text.toString(),
                      username: _usernameController.text.toString(),
                    ));
                    result.fold((l) {
                      var snackbar = SnackBar(
                        content: Text(l),
                        behavior: SnackBarBehavior.floating,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    }, (r) async {
                      var snackbar = SnackBar(
                        content: Text(r),
                        behavior: SnackBarBehavior.floating,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => HomePage()),
                        (route) => false,
                      );
                    });
                  }),
              SizedBox(
                height: 25.h,
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
                height: 29.h,
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
                height: 30.h,
              ),
              RowTextAndTextBTN(
                title: 'Not A Member ? ',
                clickedTitle: 'Register Now',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fullNameTextField(BuildContext context) {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(hintText: 'Full Name')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _emailTextField(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(hintText: 'Enter Email')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordTextField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
              hintText: 'Enter Password', suffixIcon: Icon(Icons.visibility))
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }
}
