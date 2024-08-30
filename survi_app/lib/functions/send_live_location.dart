import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SendLiveLocation {
  SendLiveLocation();

  late StreamSubscription<Position>? _positionStream;

  Future<bool> checkPersmissions() async {
    bool isServicesEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isServicesEnabled) {
      return Future.error('Location Services are Disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permenantely denied, we cannot request permission');
    }

    return true;
  }

  Future<void> trackLiveLocation(BuildContext context) async {
    bool servicesGranted = await checkPersmissions();

    if (servicesGranted) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        print("Current Position: ${position.longitude} ${position.latitude}");
      });
    } else {
      print("Some Error Occurred");
    }
  }

  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    print("Location Stopped Tracking");
  }

  Future<Position> determinePosition() async {
    Position? currentPosition;

    bool isServiceEnabled = await checkPersmissions();

    if (isServiceEnabled) {
      currentPosition = await Geolocator.getCurrentPosition();
    }

    return currentPosition!;
  }
}
