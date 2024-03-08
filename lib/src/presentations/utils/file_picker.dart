import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class FilePicker {
  static ImagePicker imagePicker = ImagePicker();
  static ImageCropper imageCropper = ImageCropper();

  static Future<List<File>> pickMultipleImage({int imageQuality = 90}) async {
    final List<XFile> images = await imagePicker.pickMultiImage(
      imageQuality: imageQuality,
    );
    return images.map((e) => File(e.path)).toList();
  }

  static Future<File?> pickSingleImage({bool fromCamera = false}) async {
    final XFile? image = await imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (image == null) return null;
    return File(image.path);
  }

  /// if current [Platform.operatingSystem] is not supported by [ImageCropper],
  /// return the original file
  static Future<File?> cropImage({
    required File file,
    int? maxWidth = 1280,
    double? ratioX,
    double? ratioY,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS && !kIsWeb) return file;

    final CroppedFile? croppedImage = await imageCropper.cropImage(
      sourcePath: file.path,
      maxWidth: maxWidth,
      aspectRatio: ratioX != null || ratioY != null
          ? CropAspectRatio(ratioX: ratioX ?? 1, ratioY: ratioY ?? 1)
          : null,
      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop image'),
        IOSUiSettings(title: 'Crop image'),
      ],
    );
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }
}
