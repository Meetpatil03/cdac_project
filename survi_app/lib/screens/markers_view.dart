import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/functions/google_map_launcher.dart';
import 'package:survi_app/functions/open_route_service.dart';
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
  Marker? _startMarker;
  Marker? _endMarker;
  List<Marker> _markers = [];
  List<LatLng> _polylineCoordinates = [];
  List<TaskList> _tasks = [];
  TaskList? _currentTask;

  Future<void> _initializeUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });
    if (userId != null) {
      _loadTasks();
    }
  }

  Future<void> _loadTasks() async {
    if (userId!.isEmpty) {
      return;
    }

    // fetcht all the tasks from the database for the user
    List<TaskList> taskList =
        await _markersDatabase.getFirstIncompleteRoute(userId!);

    setState(() {
      _tasks = taskList;
    });
  }

  Future<void> _loadTask(TaskList task) async {
    setState(() {
      _currentTask = task;

      // start Marker
      _startMarker = Marker(
        point: LatLng(task.startLat, task.startLng),
        child: const Icon(
          Icons.location_pin,
          color: Colors.green,
          size: 40,
        ),
      );

      // end Marker
      _endMarker = Marker(
        point: LatLng(task.endLat, task.endLng),
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      );

      // call OpenRouteService
    });

    final routeCoordinates = await getRouteCoordinates(
        LatLng(task.startLat, task.startLng), LatLng(task.endLat, task.endLng));

    // polyline between start and end point
    setState(() {
      _polylineCoordinates = routeCoordinates;
    });
  }

  Future<void> _showTaskDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Select a Task"),
            content: _tasks.isEmpty
                ? const Text("No Tasks available")
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return ListTile(
                              title: Text(
                                  'Task ${task.id} - Agent : ${task.agentId}'),
                              onTap: () async {
                                // Navigator.pop(context); // close the dialog
                                // _loadTask(task);
                                await launchGoogle(
                                    LatLng(task.startLat, task.startLng),
                                    LatLng(task.endLat, task.endLng));
                              });
                        })),
          );
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
      body: _currentTask == null
          ? const Center(child: Text("No Task to display"))
          : FlutterMap(
              options: MapOptions(
                initialCenter:
                    LatLng(_currentTask!.startLat, _currentTask!.startLng),
                minZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _startMarker != null && _endMarker != null
                      ? [_startMarker!, _endMarker!]
                      : [],
                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showTaskDialog,
        child: const Icon(Icons.assignment),
      ),
    );
  }
}
