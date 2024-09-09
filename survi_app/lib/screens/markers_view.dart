import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/models/task_list.dart';
import 'package:survi_app/services/markers_database.dart';

class MarkersMapView extends StatefulWidget {
  const MarkersMapView({super.key});

  @override
  State<MarkersMapView> createState() => _MarkersMapViewState();
}

class _MarkersMapViewState extends State<MarkersMapView> {
  final MarkersDatabase _markersDatabase = MarkersDatabase.instance;
  String? userId;
  List<Marker> _markers = [];
  List<LatLng> _polylineCoordinates = [];

  Future<void> _initializeUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });
    if (userId != null) {
      await _loadRoutesAndMarkers();
    }
  }

  Future<void> _loadRoutesAndMarkers() async {
    if (userId == null) {
      return;
    }

    List<TaskList> taskList = await _markersDatabase.getRoutesByUserId(userId!);
    List<Marker> markers = [];
    List<LatLng> polylineCoordinates = [];

    for (var task in taskList) {
      // start Marker
      markers.add(
        Marker(
          point: LatLng(task.startLat, task.startLng),
          child: const Icon(
            Icons.location_pin,
            color: Colors.green,
            size: 40,
          ),
        ),
      );

      // end Marker
      markers.add(
        Marker(
          point: LatLng(task.endLat, task.endLng),
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40,
          ),
        ),
      );

      // polyline points
      polylineCoordinates.add(LatLng(task.startLat, task.startLng));
      polylineCoordinates.add(LatLng(task.endLat, task.endLng));
    }

    setState(() {
      _markers = markers;
      _polylineCoordinates = polylineCoordinates;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks Record'),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: LatLng(51.505, -0.09), minZoom: 10),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: _markers),
          PolylineLayer(
            polylines: [
              Polyline(
                  points: _polylineCoordinates,
                  strokeWidth: 4.0,
                  color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}
