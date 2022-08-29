import 'dart:convert';
import 'dart:typed_data';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpzk/Screens/ZKFingerScreen/updated_text.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import "package:http/http.dart" as http;
import 'package:fpzk/Screens/ZKFingerScreen/zk_verification_screen.dart';
import 'package:fpzk/Widgets/widget.dart';
import 'package:fpzk/utils/app_routes.dart';
import 'package:fpzk/utils/utils.dart';

import '../../Provider/info_provider.dart';
import '../../Provider/user_data_provider.dart';

class ZKFingerScreen extends StatefulWidget {
  final Map convertedData;
  const ZKFingerScreen({Key? key, required this.convertedData})
      : super(key: key);

  @override
  State<ZKFingerScreen> createState() => _ZKFingerScreenState();
}

class _ZKFingerScreenState extends State<ZKFingerScreen> {
  final MethodChannel methodChannel =
      const MethodChannel("com.example.fpzk/method_channel");
  final EventChannel eventChannel =
      const EventChannel("com.example.fpzk/event_channel");

  Map fingerDataFp = {
    "saveFp1": null,
    "saveFp2": null,
    "saveFp3": null,
    "saveFp4": null,
  };
  Map<String, Map<String, dynamic>> fingerData = {
    "finger1": {
      "image1": null,
      "image2": null,
      "image3": null,
    },
    "finger2": {
      "image1": null,
      "image2": null,
      "image3": null,
    },
    "finger3": {
      "image1": null,
      "image2": null,
      "image3": null,
    },
    "finger4": {
      "image1": null,
      "image2": null,
      "image3": null,
    },
  };
  dynamic image;
  Uint8List? uListImage;

  int fingerIndex = 1;
  int counter = 1;
  int fCounter = 1;
  Stream fpData = const Stream.empty();
  initializeFp() async {
    await methodChannel.invokeMethod("initialize_fingerprint_zk");
    Future.delayed(const Duration(milliseconds: 600), () async {
      await enrollScanning();
    });
  }

  getStreamFp() {
    fpData = eventChannel.receiveBroadcastStream().map((event) => event);
    return fpData;
  }

  updateValue(res) {
    context.read<InfoProvider>().updateMessage(res);
  }

  @override
  void initState() {
    initializeFp();
    super.initState();
  }

  verifyFp() async {
    var res =
        await methodChannel.invokeMethod("verify_fingerprint_zk", fingerDataFp);
    updateValue(res);
  }

  pushScreen() {
    KRoutes.push(
        context,
        ZKVerificationScreen(
          fingerMap: fingerDataFp,
          isEnroll: true,
          convertedData: widget.convertedData,
          fingerData: fingerData,
        ));
  }

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<UserDataProvider>(context).userData;
    return Scaffold(
      appBar: BaseAppBar(
          title: "Scan finger",
          automaticallyImplyLeading: true,
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const CustomText(
                  text:
                      "Start with the right thumb first and then use the index finger for scanning",
                  fontsize: 20,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder(
                  stream: getStreamFp(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      image = base64Decode(snapshot.data["image"]);
                      if (fCounter == 2 &&
                          snapshot.data["message"].toString() !=
                              "Please perform the same scan 3 times for the enrollment") {
                        fingerData["finger$fingerIndex"]!["image$counter"] =
                            snapshot.data["image"];
                        counter++;
                        if (snapshot.data["saveFp"] != null) {
                          fingerDataFp["saveFp$fingerIndex"] =
                              snapshot.data["saveFp"];
                        }
                        if (counter > 3) {
                          verifyFp();
                        }
                      }
                      return Column(
                        children: [
                          image == null
                              ? LottieBuilder.asset(
                                  "assets/fpScanner.json",
                                  width: 200,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(
                                    image,
                                    height: 200,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  )),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomText(
                            text: snapshot.data["message"].toString(),
                            fontsize: 20,
                            color: (snapshot
                                            .data["message"]
                                            .toString() ==
                                        "Enroll failed" ||
                                    snapshot.data["message"].toString() ==
                                        "identify fail" ||
                                    snapshot.data["message"].toString() ==
                                        "Please perform the same scan 3 times for the enrollment")
                                ? Colors.red
                                : snapshot.data["message"].toString() ==
                                        "Enroll successful"
                                    ? Colors.green
                                    : Colors.blue,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const CustomText(
                            text: "Right Hand",
                            fontsize: 20,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          fingerIcons1(),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            thickness: 1,
                            color: kblack,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const CustomText(
                            text: "Left Hand",
                            fontsize: 20,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          fingerIcons2()
                        ],
                      );
                    } else {
                      return LottieBuilder.asset(
                        "assets/fpScanner.json",
                        width: 200,
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                const UpdatedText(),
                const SizedBox(
                  height: 20,
                ),
                CustomButton(
                    buttonColor: primaryColor,
                    text: "Retake fingerprints",
                    textColor: kWhite,
                    function: () async {
                      showLoader();
                      bool canVibrate = await Vibrate.canVibrate;

                      if (canVibrate) {
                        var type = FeedbackType.light;
                        Vibrate.feedback(type);
                      }
                      await resetLastFp();
                      popScreen();
                    }),
                const SizedBox(
                  height: 10,
                ),
                CustomButton(
                    buttonColor: primaryColor,
                    text: "Next fingerprints",
                    textColor: kWhite,
                    function: () async {
                      fingerIndex++;
                      if (fingerIndex < 5) {
                        enrollScanning();
                        counter = 1;
                      } else {
                        fCounter = 1;
                        counter = 1;
                        verifyFp();
                      }
                    }),
                const SizedBox(
                  height: 10,
                ),
                CustomButton(
                    buttonColor: primaryColor,
                    text: "Save fingerprints",
                    textColor: kWhite,
                    function: () async {
                      if (fingerData["finger4"]!["image3"] != null) {
                        bool canVibrate = await Vibrate.canVibrate;

                        if (canVibrate) {
                          var type = FeedbackType.light;
                          Vibrate.feedback(type);
                        }
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.loading,
                            barrierDismissible: false);
                        var res = await http.post(
                            Uri.parse(
                                "http://167.99.236.246/bwc/frontend/web/api/scanner/save-thumb-member-data"),
                            headers: {
                              "last_login_token": userData["data"]["oauth"]
                                  ["access_token"],
                            },
                            body: {
                              "member_id": widget.convertedData["data"]
                                      ["verification"]["member_id"]
                                  .toString(),
                              "file_id": widget.convertedData["data"]
                                      ["verification"]["id"]
                                  .toString(),
                              "thumb_arr": jsonEncode({
                                "fingerprint1": [
                                  {
                                    "data": fingerDataFp["saveFp1"],
                                    "img": fingerData["finger1"]!["image3"]
                                  }
                                ],
                                "fingerprint2": [
                                  {
                                    "data": fingerDataFp["saveFp2"],
                                    "img": fingerData["finger2"]!["image3"]
                                  }
                                ],
                                "fingerprint3": [
                                  {
                                    "data": fingerDataFp["saveFp3"],
                                    "img": fingerData["finger3"]!["image3"]
                                  }
                                ],
                                "fingerprint4": [
                                  {
                                    "data": fingerDataFp["saveFp4"],
                                    "img": fingerData["finger4"]!["image3"]
                                  }
                                ],
                              })
                            });
                        if (res.statusCode == 200) {
                          popScreen();
                          popScreen();
                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.info,
                              text: "Synced successfully");
                        } else {
                          popScreen();
                          Fluttertoast.showToast(msg: "Try again");
                        }
                      } else {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.info,
                            title: "Please Scan all fingers first");
                      }
                    }),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  popScreen() {
    KRoutes.pop(context);
  }

  stopScanning() async {
    await methodChannel.invokeMethod("stop_fingerprint_zk");
  }

  enrollScanning() async {
    var res = await methodChannel.invokeMethod("enroll_fingerprint_zk");
    fCounter = 2;
    updateValue(res);
  }

  pushpop() {
    KRoutes.pop(context);
    KRoutes.push(context, ZKFingerScreen(convertedData: widget.convertedData));
  }

  @override
  void dispose() {
    stopScanning();
    super.dispose();
  }

  fingerIcons1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const CustomText(text: "Thumb"),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: fingerData["finger1"]!["image1"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: fingerData["finger1"]!["image2"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: fingerData["finger1"]!["image3"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                )
              ],
            ),
          ],
        ),
        Column(
          children: [
            const CustomText(text: "Index finger 1"),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: fingerData["finger2"]!["image1"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: fingerData["finger2"]!["image2"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: fingerData["finger2"]!["image3"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  fingerIcons2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const CustomText(text: "Thumb"),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: fingerData["finger3"]!["image1"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: fingerData["finger3"]!["image2"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: fingerData["finger3"]!["image3"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                )
              ],
            ),
          ],
        ),
        Column(
          children: [
            const CustomText(text: "Index finger 1"),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: fingerData["finger4"]!["image1"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: fingerData["finger4"]!["image2"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: fingerData["finger4"]!["image3"] != null
                      ? Colors.green
                      : primaryColor,
                  child: const Icon(
                    Icons.fingerprint_outlined,
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  showLoader() {
    CoolAlert.show(
        context: context,
        type: CoolAlertType.loading,
        barrierDismissible: false);
  }

  resetLastFp() async {
    if (counter == 1 && fingerIndex > 1) {
      fingerIndex--;
      counter = 1;
      counter = 1;
      fCounter = 1;

      fingerData["finger$fingerIndex"]!["image1"] = null;
      fingerData["finger$fingerIndex"]!["image2"] = null;
      fingerData["finger$fingerIndex"]!["image3"] = null;
    } else {
      counter = 1;
      counter = 1;
      fCounter = 1;
      fingerData["finger$fingerIndex"]!["image1"] = null;
      fingerData["finger$fingerIndex"]!["image2"] = null;
      fingerData["finger$fingerIndex"]!["image3"] = null;
    }

    await stopScanning();
    await initializeFp();
    setState(() {});
  }

  // resetAllFp() async {
  //   fingerIndex = 1;
  //   counter = 1;
  //   fCounter = 1;
  //   fingerData = {
  //     "finger1": {
  //       "image1": null,
  //       "image2": null,
  //       "image3": null,
  //     },
  //     "finger2": {
  //       "image1": null,
  //       "image2": null,
  //       "image3": null,
  //     },
  //     "finger3": {
  //       "image1": null,
  //       "image2": null,
  //       "image3": null,
  //     },
  //     "finger4": {
  //       "image1": null,
  //       "image2": null,
  //       "image3": null,
  //     },
  //   };
  //   fingerDataFp = {
  //     "saveFp1": null,
  //     "saveFp2": null,
  //     "saveFp3": null,
  //     "saveFp4": null,
  //   };
  //   await stopScanning();
  //   await initializeFp();
  //   setState(() {});
  // }
}
