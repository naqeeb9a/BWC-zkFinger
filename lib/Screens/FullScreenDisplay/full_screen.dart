import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fpzk/Widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:fpzk/utils/utils.dart';

class FullScreenImage extends StatefulWidget {
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
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  final TransformationController _transformationController =
      TransformationController();
  final CarouselController carouselController = CarouselController();
  late TapDownDetails _doubleTapDetails;
  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

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
        child: widget.uploadedImage
            ? GestureDetector(
                onDoubleTapDown: _handleDoubleTapDown,
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 10,
                  child: Image.memory(
                    base64Decode(widget.image),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  CarouselSlider(
                      carouselController: carouselController,
                      options: CarouselOptions(
                          initialPage: widget.index,
                          height: double.infinity,
                          scrollPhysics: const NeverScrollableScrollPhysics(),
                          viewportFraction: 1),
                      items: List.generate(
                          (widget.image as List).length,
                          (indexPage) => Builder(
                                builder: (BuildContext context) {
                                  return Center(
                                    child: GestureDetector(
                                      onDoubleTapDown: _handleDoubleTapDown,
                                      onDoubleTap: _handleDoubleTap,
                                      child: InteractiveViewer(
                                          transformationController:
                                              _transformationController,
                                          minScale: 0.1,
                                          maxScale: 10,
                                          child: CachedNetworkImage(
                                            imageUrl: widget.image[indexPage]
                                                ["images"],
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                            height: double.infinity,
                                            progressIndicatorBuilder:
                                                (BuildContext context,
                                                    String child,
                                                    DownloadProgress
                                                        loadingProgress) {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        value: loadingProgress
                                                            .progress),
                                              );
                                            },
                                            errorWidget: (context, object, R) {
                                              return const CustomText(
                                                  text: "Unable to load Image");
                                            },
                                          )),
                                    ),
                                  );
                                },
                              ))),
                  Positioned(
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () {
                              carouselController.previousPage();
                            },
                            child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: kWhite,
                                child: Center(child: Icon(Icons.arrow_back)))),
                        GestureDetector(
                            onTap: () {
                              carouselController.nextPage();
                            },
                            child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: kWhite,
                                child:
                                    Center(child: Icon(Icons.arrow_forward)))),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }
}
