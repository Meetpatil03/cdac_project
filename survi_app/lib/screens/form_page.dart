import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:survi_app/apis/submit_api.dart';
import 'package:survi_app/widgets/custom_text.dart';
import 'package:survi_app/widgets/custom_text_field.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController descriptionController = TextEditingController();

  double longitude = 0;
  double latitude = 0;
  String time = "";
  String speed = "";
  String altitude = "";
  List<double> coordiantes = [];
  Position? currentPosition;
  List<File> file = [];

  @override
  void dispose() {
    super.dispose();
    descriptionController.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkLocationServices();
  }

  void checkLocationServices() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, prompt the user to enable them.
      _showLocationSettingsDialog();
      return;
    }

    // Check if permission is granted.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, prompt the user to enable them.
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, prompt the user to enable them in settings.
      _showLocationSettingsDialog();
      return;
    }

    // Location services are enabled and permissions are granted.
    // You can now access the location.
    currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      longitude = currentPosition!.longitude;
      latitude = currentPosition!.latitude;
      speed = currentPosition!.speedAccuracy.toString();
      time = currentPosition!.timestamp.toString();
      altitude = currentPosition!.altitude.toString();
      coordiantes.add(longitude);
      coordiantes.add(latitude);
    });
  }

  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'Please enable location services to continue using this app.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Settings'),
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void pickFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
  );

  if (result != null) {
    setState(() {
      file = result.paths.map((path) => File(path!)).toList();
    });
  } else {
    // User canceled the picker
  }
}

  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          fontSize: 30,
          text: 'Agents Survey',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
                controller: descriptionController,
                label: 'Write description Here',
                suffixIcons: const Icon(Icons.edit_calendar),
                obscureText: false,
                textInputType: TextInputType.text, function: () {  }, function2: () {  },),
            SizedBox(
              height: size.height * 0.05,
            ),
            longitude == 0 && latitude == 0
                ? const Text(
                    'Fetching-Location.....',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Logitude : $longitude',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Latitude : $latitude',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'timeStamp : $time',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Speed : $speed',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
            SizedBox(
              height: size.height * 0.05,
            ),
            ElevatedButton(
              onPressed: pickFiles,
              child: const Text('Upload files'),
            ),
            file.isNotEmpty
              ? Column(
                  children: file.map((file) {
                    return Text(file.path.split('/').last);
                  }).toList(),
                )
              : Container(),
            SizedBox(
              height: size.height * 0.05,
            ),
            ElevatedButton(
              onPressed: () {
                pushDataToMongoDB(coordiantes, altitude, speed, time,
                    descriptionController.text.toString(), file);
              },
              child: const Text(
                'Send',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
