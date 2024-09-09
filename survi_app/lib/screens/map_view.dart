import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:survi_app/apis/retrieve_routes_api.dart';
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
  LatLng? mapCenter;

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
      mapCenter = LatLng(currentPosition!.latitude, currentPosition!.longitude);
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
        mapCenter = LatLng(position.latitude, position.longitude);
        _mapController.move(mapCenter!, currentZoom);
      });
    });
  }

  void zoomIn() {
    setState(() {
      currentZoom += 1;
      _mapController.move(mapCenter!, currentZoom);
    });
  }

  void zoomOut() {
    setState(() {
      currentZoom -= 1;
      _mapController.move(mapCenter!, currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              retrieveRoutesApi();
            },
            icon: const Icon(Icons.map),
          ),
        ],
      ),
      body: Stack(children: [
        isMapReady && currentPosition != null
            ? FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                      currentPosition!.latitude, currentPosition!.longitude),
                  onPositionChanged: (camera, hasGesture) {
                    if (hasGesture) {
                      setState(() {
                        mapCenter = camera.center;
                      });
                    }
                  },
                  minZoom: 10,
                ),
                children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(currentPosition!.latitude,
                              currentPosition!.longitude),
                          child: const Icon(
                            Icons.fmd_good_sharp,
                            color: Colors.red,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
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
              ),
        Positioned(
          bottom: 30,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton(
                onPressed: zoomIn,
                mini: true,
                child: const Icon(Icons.zoom_in),
              ),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                onPressed: zoomOut,
                mini: true,
                child: const Icon(Icons.zoom_out),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
