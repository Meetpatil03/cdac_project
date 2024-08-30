import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:survi_app/functions/send_live_location.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapController _mapController = MapController();
  Position? currentPosition;
  List<LatLng> polylinePoints = [];
  double currentZoom = 15.0;
  bool isMapReady = false;
  final SendLiveLocation sendLiveLocation = SendLiveLocation();

  @override
  void initState() {
    super.initState();
    getPosition();
  }

  void getPosition() async {
    currentPosition = await sendLiveLocation.determinePosition();
    if (currentPosition != null) {
      polylinePoints.add(
        LatLng(currentPosition!.latitude, currentPosition!.longitude),
      );
    }

    setState(() {
      isMapReady = true;
    });

    trackPosition();
  }

  void trackPosition() async {
    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    )).listen((Position position) {
      setState(() {
        currentPosition = position;
        polylinePoints.add(LatLng(position.latitude, position.longitude));
        _mapController.move(
            LatLng(position.latitude, position.longitude), currentZoom);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(children: [
        isMapReady && currentPosition != null
            ? FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                      currentPosition!.latitude, currentPosition!.longitude),
                  minZoom: 10,
                ),
                children: [
                    TileLayer(
                      urlTemplate:
                          'https://tiles.stadiamaps.com/tiles/stamen_toner_lite/{z}/{x}/{y}.png?api_key=ed679072-f1e0-4feb-b728-48dbbb2134e5',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                          point: LatLng(currentPosition!.latitude,
                              currentPosition!.longitude),
                          child: const Icon(
                            Icons.fmd_good_sharp,
                            color: Colors.red,
                            size: 25,
                          ))
                    ]),
                    PolylineLayer(polylines: [
                      Polyline(
                        points: polylinePoints,
                        color: Colors.green,
                        strokeWidth: 5.0,
                      ),
                    ]),
                  ])
            : const Center(
                child: CircularProgressIndicator.adaptive(),
              )
      ]),
    );
  }
}
