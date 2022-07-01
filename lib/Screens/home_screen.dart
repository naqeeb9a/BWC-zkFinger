import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fpzk/Api/functionality.dart';
import 'package:fpzk/utils/utils.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Provider/user_data_provider.dart';
import '../Widgets/custom_app_bar.dart';
import '../Widgets/custom_button.dart';
import '../Widgets/custom_list_drop_down.dart';
import '../Widgets/custom_text.dart';
import '../utils/app_routes.dart';
import 'Authentication/login.dart';
import 'QRScreen/qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  AnimationController? _animationController;
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));

    _animationController?.forward();

    super.initState();
  }

  logout() {
    Provider.of<LoginInfoProvider>(context, listen: false)
        .changeLoginStatus(false);
    KRoutes.pushAndRemoveUntil(context, const Login());
  }

  @override
  Widget build(BuildContext context) {
    var selectedSociety =
        Provider.of<SelectedSoceityProvider>(context).selectedSoceity;
    dynamic userData = Provider.of<UserDataProvider>(context).userData;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(
          title: "BWC Verification",
          appBar: AppBar(),
          widgets: [
            IconButton(
                onPressed: () async {
                  bool canVibrate = await Vibrate.canVibrate;

                  if (canVibrate) {
                    var type = FeedbackType.light;
                    Vibrate.feedback(type);
                  }
                  SharedPreferences user =
                      await SharedPreferences.getInstance();
                  user.clear();
                  logout();
                },
                icon: const Icon(
                  Icons.logout,
                  color: primaryColor,
                ))
          ],
          appBarHeight: 50,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Image.asset(
                  "assets/logo.png",
                  width: MediaQuery.of(context).size.width / 3,
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 50,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const FittedBox(
                            child: CustomText(text: "Choose a Project")),
                        CustomDropDown(
                          token: userData["data"]["oauth"]["access_token"],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                LottieBuilder.asset(
                  "assets/qr.json",
                  width: MediaQuery.of(context).size.width / 1.5,
                  repeat: false,
                ),
                const SizedBox(
                  height: 50,
                ),
                CustomButton(
                  buttonColor: primaryColor,
                  text: "Scan QR",
                  function: () async {
                    bool canVibrate = await Vibrate.canVibrate;

                    if (canVibrate) {
                      var type = FeedbackType.light;
                      Vibrate.feedback(type);
                    }
                    if (selectedSociety == null) {
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                          text: "Select a Project First",
                          backgroundColor: kblack,
                          lottieAsset: "assets/error.json");
                    } else {
                      pushPage();
                    }
                  },
                  textColor: kWhite,
                ),
                const SizedBox(
                  height: 10,
                ),
                const CustomText(text: "Or"),
                const SizedBox(
                  height: 10,
                ),
                CustomButton(
                  buttonColor: primaryColor,
                  text: "Enter Reg No",
                  function: () async {
                    if (selectedSociety == null) {
                      bool canVibrate = await Vibrate.canVibrate;

                      if (canVibrate) {
                        var type = FeedbackType.light;
                        Vibrate.feedback(type);
                      }
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                          text: "Select a Project First",
                          backgroundColor: kblack,
                          lottieAsset: "assets/error.json");
                    } else {
                      Functionality.openDialogue(context, _controller);
                    }
                  },
                  textColor: kWhite,
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ));
  }

  pushPage() {
    KRoutes.push(context, const QRScreen());
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
