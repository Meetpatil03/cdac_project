import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/functions/google_map_launcher.dart';
import 'package:survi_app/functions/open_route_service.dart';
import 'package:survi_app/functions/send_live_location.dart';
import 'package:survi_app/models/task_list.dart';
import 'package:survi_app/services/markers_database.dart';

class MarkersMapView extends StatefulWidget {
  const MarkersMapView({super.key});

  @override
  State<MarkersMapView> createState() => _MarkersMapViewState();
}

class _MarkersMapViewState extends State<MarkersMapView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks Record'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("Work in Progress"),
      ),
    );
  }
}
