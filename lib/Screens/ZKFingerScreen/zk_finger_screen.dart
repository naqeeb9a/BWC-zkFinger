import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:fpzk/Screens/ZKFingerScreen/zk_verification_screen.dart';
import 'package:fpzk/Widgets/widget.dart';
import 'package:fpzk/utils/app_routes.dart';
import 'package:fpzk/utils/utils.dart';

import '../../Provider/info_provider.dart';

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
  dynamic value;
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
    Provider.of<InfoProvider>(context, listen: false).updateMessage(res);
  }

  @override
  void initState() {
    initializeFp();

    super.initState();
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
    return Scaffold(
      appBar: BaseAppBar(
          title: "Scan finger",
          automaticallyImplyLeading: true,
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CustomText(
                text:
                    "Scan thumb first and then use the index finger 1 to enroll",
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
                    if (fCounter == 2) {
                      fingerData["finger$fingerIndex"]!["image$counter"] =
                          snapshot.data["image"];
                      counter++;
                      if (snapshot.data["saveFp"] != null) {
                        fingerDataFp["saveFp$fingerIndex"] =
                            snapshot.data["saveFp"];
                      }
                      if (counter > 3) {
                        fingerIndex++;
                        if (fingerIndex < 5) {
                          Future.delayed(const Duration(milliseconds: 600), () {
                            enrollScanning();
                          });
                          counter = 1;
                        } else {
                          stopScanning();
                        }
                      }
                    }
                    return Column(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.memory(
                              image!,
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
                          color: snapshot.data["message"].toString() ==
                                  "Enroll failed"
                              ? Colors.red
                              : snapshot.data["message"].toString() ==
                                      "Enroll successful"
                                  ? Colors.green
                                  : Colors.blue,
                        ),
                        const SizedBox(
                          height: 20,
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
              CustomButton(
                  buttonColor: primaryColor,
                  text: "Retake fingerprints",
                  textColor: kWhite,
                  function: () async {
                    bool canVibrate = await Vibrate.canVibrate;

                    if (canVibrate) {
                      var type = FeedbackType.light;
                      Vibrate.feedback(type);
                    }
                    fingerIndex = 1;
                    counter = 1;
                    fCounter = 1;
                    fingerData = {
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
                    fingerDataFp = {
                      "saveFp1": null,
                      "saveFp2": null,
                    };
                    await stopScanning();
                    await initializeFp();
                    setState(() {});
                  }),
              const SizedBox(
                height: 10,
              ),
              CustomButton(
                  buttonColor: primaryColor,
                  text: "Verify fingerprint",
                  textColor: kWhite,
                  function: () async {
                    bool canVibrate = await Vibrate.canVibrate;

                    if (canVibrate) {
                      var type = FeedbackType.light;
                      Vibrate.feedback(type);
                    }
                    if (fingerData["finger2"]!["image3"].length == 0) {
                      Fluttertoast.showToast(msg: "Register all fingers first");
                    } else {
                      await stopScanning();
                      pushScreen();
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
    );
  }

  popScreen() {
    KRoutes.pop(context);
  }

  stopScanning() async {
    await methodChannel.invokeMethod("stop_fingerprint_zk");
  }

  enrollScanning() async {
    await methodChannel.invokeMethod("enroll_fingerprint_zk");
    fCounter = 2;
  }

  pushpop() {
    KRoutes.pop(context);
    KRoutes.push(context, ZKFingerScreen(convertedData: widget.convertedData));
  }

  @override
  void dispose() {
    eventChannel.receiveBroadcastStream((event) => null);
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
}
