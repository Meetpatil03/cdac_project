import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/constants.dart';

Future<void> pushDataToMongoDB(
    String region,
    double longitude,
    double latitude,
    String altitude,
    String speed,
    String time,
    String remark,
    String subdepartment,
    String assetowner,
    String projectName,
    String assettype,
    String subtype,
    String assetyear,
    String assetname,
    String status,
    List<File> files) async {
  try {
    // Prepare JSON data
    Map<String, dynamic> data = {
      "region": region,
      "location": {
        "coordinates": [longitude, latitude],
        "altitude": altitude,
        "speed": speed,
        "time": time,
      },
      "description": remark,
      "department": subdepartment,
      "owner": assetowner,
      "projectName": projectName,
      "assetType": assettype,
      "schemeComponent": "the form is uploaded from mobile",
      "year": assetyear,
      "assets": assetname,
      "status": status,
    };

    String jsonString = jsonEncode(data);
    print(data);

    // Retrieve token and cookies from SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    final cookies = prefs.getString('cookies');

    // Prepare a POST request using MultipartRequest
    var uri = Uri.parse('$baseUrl/submit/');
    var request = http.MultipartRequest('POST', uri)
      ..headers['ngrok-skip-browser-warning'] = '69420';

    // Add cookies to the request (if available)
    if (cookies != null) {
      request.headers['Cookie'] = cookies; // Set cookies directly in headers
    }

    // Add JSON data as a field
    request.fields['data'] = jsonString;

    // Add files to the request
    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        file.path,
        filename: file.path.split('/').last, // Set the filename correctly
      ));
    }

    // Send the request and await the response
    var response = await request.send();

    // Read and print the response
    var responseBody = await http.Response.fromStream(response);
    print(responseBody.body);

    if (response.statusCode == 201) {
      print('Data has been pushed properly');
    } else {
      print('StatusCode: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
