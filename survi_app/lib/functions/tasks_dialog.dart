import 'package:flutter/material.dart';
import 'package:survi_app/models/task_list.dart';
import 'package:survi_app/services/markers_database.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showStops(BuildContext context, int taskId) async {
  MarkersDatabase _markersDatabase = MarkersDatabase.instance;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      actions: [
        ElevatedButton(
          onPressed: () async {
            final taskList =
                await _markersDatabase.getParticularTasksRoute(taskId);
            await _launchNavigation(taskList);
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Go",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      title: const Text("Stops"),
      content: FutureBuilder(
        future: _markersDatabase.getParticularTasksRoute(taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Center(
              child: Text("Something Went Wrong"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No Stops Available"),
            );
          }

          print(snapshot.data);

          return Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: const Text(
                    "Stop",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                  ),
                  subtitle: Text(
                    "Lat: ${snapshot.data![index].latitude}, Lng: ${snapshot.data![index].longitude}",
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _launchNavigation(List<TaskList> taskList) async {

  if (taskList.isNotEmpty) {
    // set the origin as the first task and destination as the last
    final origin = taskList.first;
    final destination = taskList.last;

    final waypoints = taskList
        .skip(1)
        .take(taskList.length - 2)
        .map((task) => '${task.latitude},${task.longitude}')
        .join('|');

    // construct url with origin, destination and waypoints
    final googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=$waypoints&travelmode=driving';

    // launch the Google Maps app or open in browser if app is unavaible

    print("I am above the googleMapsLauncher");
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
      print("I have launched the map");
    } else {
      throw 'Could not Launch $googleMapsUrl';
    }
  } else {
    print("task List is Empty");
  }
}
