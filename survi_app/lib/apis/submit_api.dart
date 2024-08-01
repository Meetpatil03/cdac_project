import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';

Future<void> pushDataToMongoDB(
  List<double> coordinates,
  String altitude,
  String speed,
  String time,
  String description,
  List<File> files,
) async {
   var assetYear = DateTime(2022, 12, 31);
  try {
    Map<String, dynamic> data = {
      "location": {"coordinates": coordinates, "altitude": altitude},
      "speed": speed,
      "time": time,
      "remark": description,
      "sub_department": "abc-sub Department",
      "asset_owner": "abc asset-owner",
      "asset_type": "abc asset-type",
      "sub_type": "abc sub-type",
      "asset_year": assetYear.toIso8601String(),
      "asset_name": "abc asset-name",
      "status": "abc status"
    };

    String jsonString = jsonEncode(data);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    String finalToken = "Token ";
    finalToken += token.toString();

    String identifier = (await UniqueIdentifier.serial)!;

    var uri = Uri.parse(
        'https://1f82-2409-4081-2e07-491e-99ae-45b2-bfd6-4321.ngrok-free.app/submit/');
    var request = http.MultipartRequest('POST', uri)
      ..fields['data'] = jsonString
      ..headers['ngrok-skip-browser-warning'] = "69420"
      ..headers['authorization'] = finalToken
      ..headers['deviceid'] = identifier;

    List<Map<String, dynamic>> fileBytesList = [];

    // Read file bytes and store in the list
    for (var file in files) {
      List<int> fileBytes = await file.readAsBytes();
      fileBytesList
          .add({'filename': file.path.split('/').last, 'bytes': fileBytes});
    }

    // Add files to the request
    for (var fileData in fileBytesList) {
      request.files.add(http.MultipartFile.fromBytes(
        'files',
        fileData['bytes'],
        filename: fileData['filename'],
      ));
    }

    var response = await request.send();

    var responseBody = await http.Response.fromStream(response);
    print(responseBody.body.toString());

    if (responseBody.statusCode == 201) {
      print('data has been pushed properly');
    } else {
      print(' StatusCode : ${response.statusCode}');
    }

   
  } catch (e) {
    print(e.toString());
  }
}
