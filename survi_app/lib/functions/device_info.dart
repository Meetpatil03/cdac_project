import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:geolocator/geolocator.dart';

Future<String> getIMEINumber() async {
  String imeiNumber = "";
  try {
    imeiNumber =
        await FlutterDeviceImei.instance.getIMEI() ?? 'Unkown Platform Verison';
  } on PlatformException {
    imeiNumber = "Failed to get the platform version";
  }

  return imeiNumber;
}

Future<Map<String, dynamic>> getDeviceInfo() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Map<String, dynamic> deviceDetials = {};

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    deviceDetials = {
      'device': androidInfo.device,
      'model': androidInfo.model,
      'imei': await getIMEINumber(),
      'time': await getTimeZone(),
      'location': await getLocation(),
    };
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    deviceDetials = {
      'device': iosInfo.name,
      'model': iosInfo.model,
      'imei': 'IOS Doesn\'t  have IMEI Number',
      'time': await getTimeZone(),
      'location': await getLocation(),
    };
  }

  print(deviceDetials);
  return deviceDetials;
}

// Function to get the Current Location
Future<Position?> getCurrentLocation() async {
  bool isServiceEnabled;
  LocationPermission permission;

  isServiceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!isServiceEnabled) {
    print('Location Services are disabled');
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location Permission are denied');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print(
        'Location Permission are Denied forever, He can\'t request permission');
    return null;
  }

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  return position;

  // List<Placemark> placemarks =
  //     await placemarkFromCoordinates(position.latitude, position.longitude);
  // String address;
  // if (placemarks.isNotEmpty) {
  //   Placemark place = placemarks[0];
  //   address = "${place.locality}, ${place.country}";
  // } else {
  //   address = "Sorry unable to Fetch";
  // }

  // return address;
}

Future<Map<String, dynamic>> getLocation() async {
  Map<String, dynamic> location = {};
  final position = await getCurrentLocation();

  // List<Placemark> placemarks =
  //     await placemarkFromCoordinates(position!.latitude, position.longitude);

  // if (placemarks.isNotEmpty) {
  //   Placemark place = placemarks[0];
  //   location = "${place.locality}, ${place.country}";
  // } else {
  //   location = "Sorry Fetching Error";
  // }

  location = {
    "longitude": position!.longitude,
    "latitude": position.latitude,
  };

  return location;
}

Future<String> getTimeZone() async {
  final time = await getCurrentLocation();
  return time!.timestamp.toString();
}

Future<String?> getAndroidDeviceId() async {
  try {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;

    return await getIMEINumber();
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<String?> getIsoDeviceId() async {
  try {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final iosInfo = await deviceInfoPlugin.iosInfo;

    return iosInfo.identifierForVendor;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<String?> getDeviceId() async {
  if (Platform.isAndroid) {
    return await getAndroidDeviceId();
  } else if (Platform.isIOS) {
    return await getIsoDeviceId();
  }
  return null;
}
