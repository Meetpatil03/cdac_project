import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';

Future<void> pushDataToMongoDB(
  double longitude,double latitude,String altitude,String speed,String time,String remark,String subdepartment,String assetowner,String projectName,String assettype,String subtype,String assetyear,String assetname,String status,List<File> files
) async {
   
  try {
    Map<String, dynamic> data = {
      "location": {"coordinates": [longitude,latitude], "altitude": altitude},
      "speed": speed,
      "time": time,
      "remark": remark,
      "subdepartment": subdepartment,
      "owner": assetowner,
      "projectName": projectName,
      "type": assettype,
      "subtype": subtype,
      "asset_year": assetyear,
      "asset_name": assetname,
      "status": status
    };

    String jsonString = jsonEncode(data);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    String finalToken = "Token ";
    finalToken += token.toString();

    String identifier = (await UniqueIdentifier.serial)!;

    var uri = Uri.parse(
        'https://f811-2409-40c2-101a-6dfb-c099-36eb-2a49-3190.ngrok-free.app/submit/');
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
