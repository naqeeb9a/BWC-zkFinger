import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpzk/Screens/FullScreenDisplay/full_screen.dart';
import 'package:fpzk/Screens/ZKFingerScreen/zk_finger_screen.dart';
import 'package:fpzk/Widgets/custom_button.dart';
import 'package:fpzk/Widgets/custom_text.dart';
import 'package:fpzk/utils/app_routes.dart';
import 'package:fpzk/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../Api/api.dart';
import '../Screens/ZKFingerScreen/zk_verification_screen.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class ImageGrid extends StatefulWidget {
  final Map convertedData;
  final Map<dynamic, dynamic> userData;
  const ImageGrid(
      {Key? key, required this.convertedData, required this.userData})
      : super(key: key);

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  pushPage({int? page, Map? fingerList}) {
    if (page == 1) {
      KRoutes.pop(context);
      KRoutes.push(
          context,
          ZKVerificationScreen(
            fingerMap: fingerList!,
            isEnroll: false,
          ));
    } else {
      KRoutes.pop(context);
      KRoutes.push(
          context,
          ZKFingerScreen(
            convertedData: widget.convertedData,
          ));
    }
  }

  popPage() {
    KRoutes.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
        child: CustomButton(
          height: 50,
          buttonColor: primaryColor,
          text: "Scan finger",
          function: () async {
            bool canVibrate = await Vibrate.canVibrate;

            if (canVibrate) {
              var type = FeedbackType.light;
              Vibrate.feedback(type);
            }
            CoolAlert.show(
                context: context,
                type: CoolAlertType.loading,
                barrierDismissible: false);
            var res = await Api.getThumb(
                widget.userData["data"]["oauth"]["access_token"],
                widget.convertedData["data"]["verification"]["id"].toString());
            if (res.statusCode == 200) {
              var jsonData = jsonDecode(res.body);

              if (jsonData["meta"]["data"].length == 0) {
                pushPage(page: 0);
              } else {
                Map fingerDataFp = {
                  "saveFp1": null,
                  "saveFp2": null,
                  "saveFp3": null,
                  "saveFp4": null,
                };
                for (var i = 0; i < jsonData["meta"]["data"].length; i++) {
                  fingerDataFp["saveFp${i + 1}"] =
                      jsonData["meta"]["data"][i]["thumb"];
                }
                pushPage(page: 1, fingerList: fingerDataFp);
              }
            } else {
              popPage();
              Fluttertoast.showToast(msg: res.body);
            }
          },
          textColor: kWhite,
        ),
      ),
      body: FutureBuilder(
        future: Api.getImages(widget.userData["data"]["oauth"]["access_token"],
            widget.convertedData["data"]["verification"]["id"].toString()),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null && snapshot.data.statusCode == 200) {
              var cvtData = jsonDecode(snapshot.data.body);
              return (cvtData["data"]["existing_images"].length == 0)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LottieBuilder.asset(
                            "assets/empty.json",
                            width: MediaQuery.of(context).size.width / 2,
                            repeat: false,
                          ),
                          const CustomText(text: "No images found")
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      cacheExtent: 9999,
                      itemCount: cvtData["data"]["existing_images"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () => KRoutes.push(
                              context,
                              FullScreenImage(
                                image: cvtData["data"]["existing_images"],
                                index: index,
                                // [index]["images"]
                              )),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kGrey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: cvtData["data"]["existing_images"]
                                    [index]["images"],
                                fit: BoxFit.cover,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
                                  child: CircularProgressIndicator(
                                      value: downloadProgress.progress),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Center(
                                  child:
                                      CustomText(text: "Unable to load Image"),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
            } else {
              return Center(
                  child: CustomButton(
                buttonColor: primaryColor,
                height: 50,
                text: "Try Again",
                function: () => setState(() {}),
                textColor: kWhite,
              ));
            }
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) {
                return Shimmer.fromColors(
                  baseColor: kGrey.withOpacity(0.3),
                  highlightColor: kGrey,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
