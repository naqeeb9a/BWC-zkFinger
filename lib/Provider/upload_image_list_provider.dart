import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageListProvider extends ChangeNotifier {
  List images = [];
  updateImageList(XFile value) async {
    var result = await FlutterImageCompress.compressWithFile(
      value.path,
      minWidth: 2250,
      minHeight: 3000,
      quality: 50,
    );
    images.add({"file": base64Encode(result!.toList())});
    notifyListeners();
  }

  emptyImageList() {
    images.clear();
    notifyListeners();
  }
}
