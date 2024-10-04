import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';


Future<List<File>> pickFiles(BuildContext context) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      return result.paths.map((path) => File(path!)).toList();
    } else if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No Files Selected")));
      return [];
    }
  } catch (e) {
    print(e.toString());
   
  }

   return [];
}
