import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fpzk/Widgets/widget.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final dynamic image;
  final int index;
  final bool uploadedImage;
  const FullScreenImage(
      {Key? key,
      required this.image,
      this.uploadedImage = false,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
          title: "Image Preview",
          appBar: AppBar(),
          widgets: const [],
          automaticallyImplyLeading: true,
          appBarHeight: 50),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.1,
          maxScale: 10,
          child: uploadedImage
              ? Image.memory(
                  base64Decode(image),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                )
              : CarouselSlider(
                  options: CarouselOptions(
                      initialPage: index,
                      height: double.infinity,
                      viewportFraction: 1),
                  items: List.generate(
                      (image as List).length,
                      (indexPage) => Builder(
                            builder: (BuildContext context) {
                              return Center(
                                child: Image.network(
                                  image[indexPage]["images"],
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, object, R) {
                                    return const CustomText(
                                        text: "Unable to load Image");
                                  },
                                ),
                              );
                            },
                          ))),
        ),
      ),
    );
  }
}
