import 'dart:convert';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:survi_app/apis/web_services.dart';
import 'package:survi_app/constants.dart';
import 'package:survi_app/functions/device_info.dart';

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
  Response response;
  print("Submitting Data");
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

    Dio dio = Dio();
    WebService webService = WebService();

    // Ensure the cookie jar is initialized
    await webService.ensureInitialized();

    final cookieJar = webService.cookieJar;

    dio.interceptors.add(CookieManager(cookieJar));

    print("My Cookie: $cookieJar");

    FormData formData = FormData();

    // Add JSON data as a field
    formData.fields.add(MapEntry('data', jsonString));

    // Add files to the request
    for (var file in files) {
      String fileName = file.path.split('/').last; // Extract the filename
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(file.path, filename: fileName),
      ));
    }

    final String url = "$baseUrl/submit";

    String deviceId = (await getDeviceId())!;

    Map<String, String> headers = {
      "Content-Type": "multipart/form-data",
      "ngrok-skip-browser-warning": "69420",
      "deviceid": deviceId
    };

    // Prepare a POST request using MultipartRequest
    // Send POST request using Dio
    response = await dio.post(
      url,
      data: formData,
      options: Options(
        contentType: "multipart/form-data",
        headers: headers,
      ),
    );

    if (response.statusCode == 201) {
      print('Data has been pushed properly');
    } else {
      print('StatusCode: ${response.statusCode}');
      print('Error: ${response.data}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
