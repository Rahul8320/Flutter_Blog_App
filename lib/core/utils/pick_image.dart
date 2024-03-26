import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> pickImage() async {
  try {
    final selectedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (selectedFile != null) {
      return File(selectedFile.path);
    }

    return null;
  } catch (e) {
    return null;
  }
}
