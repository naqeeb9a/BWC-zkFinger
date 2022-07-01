import 'dart:convert';

import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fpzk/Api/api.dart';
import 'package:fpzk/Api/functionality.dart';
import 'package:fpzk/Provider/user_data_provider.dart';
import 'package:fpzk/Screens/home_screen.dart';

import 'package:fpzk/Widgets/custom_loader.dart';
import 'package:cool_alert/cool_alert.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widgets/widget.dart';
import '../../utils/app_routes.dart';
import '../../utils/utils.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  @override
  void initState() {
    Functionality.checkLoginStatus(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isUserLogin = Provider.of<LoginInfoProvider>(context).isLoggedIn;
    if (isUserLogin) {
      return const Scaffold(body: CustomLoader());
    } else {
      return Scaffold(
        appBar: BaseAppBar(
            title: "Login",
            appBar: AppBar(),
            widgets: const [],
            appBarHeight: 50),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Image.asset(
                          "assets/logo.png",
                          width: 200,
                          height: 200,
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: CustomText(text: "Username"),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                          controller: _username,
                          suffixIcon: const Icon(Icons.person_outline),
                          keyboardtype: TextInputType.text,
                          function: (value) {
                            if (value!.isEmpty) {
                              return "Field can't be empty";
                            } else {
                              return null;
                            }
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: CustomText(text: "Password"),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FormTextField(
                        controller: _password,
                        isPass: true,
                        suffixIcon: const Icon(Icons.visibility_outlined),
                        function: (value) {
                          if (value!.isEmpty) {
                            return "Field can't be empty";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: CustomButton(
                            buttonColor: primaryColor,
                            textColor: Colors.white,
                            text: "login",
                            function: () async {
                              bool canVibrate = await Vibrate.canVibrate;

                              if (canVibrate) {
                                var type = FeedbackType.light;
                                Vibrate.feedback(type);
                              }
                              if (!_formKey.currentState!.validate()) {
                                CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.error,
                                    text: "Fill all the fields",
                                    lottieAsset: "assets/error.json");
                              } else {
                                CoolAlert.show(
                                    context: context,
                                    barrierDismissible: false,
                                    type: CoolAlertType.loading,
                                    lottieAsset: "assets/loader.json");
                                Response response = await Api.login(
                                  username: _username.text,
                                  password: _password.text,
                                );

                                if (response.statusCode == 200) {
                                  SharedPreferences user =
                                      await SharedPreferences.getInstance();

                                  user.setString("loggedInUser", response.body);
                                  updateData(jsonDecode(response.body));
                                  popPage();
                                  pushPage();
                                } else if (response.statusCode == 509) {
                                  popPage();
                                  CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.error,
                                      title: "Invalid Device",
                                      text: "No Device Found",
                                      lottieAsset: "assets/error.json");
                                } else if (response.statusCode == 501) {
                                  popPage();
                                  CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.error,
                                      text: "Invalid Cnic or Password",
                                      lottieAsset: "assets/error.json");
                                } else if (response.statusCode == 500) {
                                  popPage();
                                  CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.error,
                                      text: "Server Error",
                                      lottieAsset: "assets/error.json");
                                } else {
                                  popPage();
                                  CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.error,
                                      text: "Something went wrong",
                                      lottieAsset: "assets/error.json");
                                }
                              }
                            },
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  updateData(response) {
    Provider.of<UserDataProvider>(context, listen: false)
        .updateUserData(response);
  }

  popPage() {
    KRoutes.pop(context);
  }

  pushPage() {
    KRoutes.pushAndRemoveUntil(context, const HomeScreen());
  }
}
