import 'dart:async';
import 'dart:io';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:survi_app/apis/submit_api.dart';
import 'package:survi_app/functions/file_picker.dart';
import 'package:survi_app/functions/push_data_sqlite.dart';
import 'package:survi_app/screens/agents_survey_list.dart';
import 'package:survi_app/widgets/custom_text.dart';
import 'package:survi_app/widgets/custom_text_field.dart';


class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController descriptionController = TextEditingController();

  bool hasInternetConnection = false;
  StreamSubscription? _internetConnectionStream;

  double longitude = 0;
  double latitude = 0;
  String time = "";
  String speed = "";
  String altitude = "";
  List<double> coordiantes = [];
  Position? currentPosition;
  List<File> file = [];

  @override
  void initState() {
    super.initState();
    checkLocationServices();
    _internetConnectionStream =
        InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          setState(() {
            hasInternetConnection = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            hasInternetConnection = false;
          });
          break;
        default:
          setState(() {
            hasInternetConnection = false;
          });
      }
    });
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

  Future<void> pushSurveyDataToDatabase() async {
    bool hasInternet = await InternetConnection().hasInternetAccess;
    print("Checking Internet Connection : $hasInternet");
    print(hasInternetConnection);

    if (hasInternetConnection) {
      print("i am in the if Block Statement ${hasInternetConnection}");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Online")));

      pushDataToMongoDB(coordiantes, altitude, speed, time,
          descriptionController.text.toString(), file);
    } else if (!hasInternetConnection) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Offline")));

      //

      pushDataToLocalStorage(descriptionController.text.toString(), longitude,
          latitude, time, speed, altitude, file);
    }
  }

  @override
  void dispose() {
    super.dispose();
    descriptionController.dispose();
    _internetConnectionStream!.cancel();
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
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: descriptionController,
                label: 'Write description Here',
                suffixIcons: const Icon(Icons.edit_calendar),
                obscureText: false,
                textInputType: TextInputType.text,
                function: () {},
                function2: () {},
              ),
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
                onPressed: () async {
                  List<File> pickedFiles = await pickFiles(context);
                  setState(() {
                    file = pickedFiles;
                  });
                },
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
                  pushSurveyDataToDatabase();
                },
                child: const Text(
                  'Send',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AgentsSurveyList()));
                },
                child: const Text(
                  'Navigate to Survey List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
