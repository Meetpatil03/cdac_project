import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:survi_app/apis/submit_api.dart';
import 'package:survi_app/functions/file_picker.dart';
import 'package:survi_app/functions/push_data_sqlite.dart';
import 'package:survi_app/models/assets_list.dart';
import 'package:survi_app/models/assets_sub_type_list.dart';
import 'package:survi_app/models/department_list.dart';
import 'package:survi_app/models/owners_list.dart';
import 'package:survi_app/screens/agents_survey_list.dart';
import 'package:survi_app/services/fetch_master_table.dart';
import 'package:survi_app/widgets/custom_text.dart';
import 'package:survi_app/widgets/custom_text_field.dart';
import 'package:survi_app/widgets/drop_down_list.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController assetNameController = TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  final FetchMasterTable _fetchMasterTable = FetchMasterTable.instance;

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
  String? value1;
  String? deptValue;
  String? ownersValue;
  String? assetsValue;
  String? assetsSubTypeValue;
  String? statusValue;
  var regionItems = ["Mumbai", "Delhi", "Kolkata", "Chennai"];
  List<String> deptItems = [];
  List<String> ownerItems = [];
  List<String> assetItems = [];
  List<String> assetSubTypeItems = [];
  List<String> statusItems = ['Survey', "Maintenance"];

  var assetsTypeItems = [
    "Land",
    "Building",
    "Plant",
    "Workshop",
    "Machinery",
    "Transformer",
    "Generator",
    "Pole",
    "Transmissions",
    "Lines"
  ];

  var entryTypeItems = ["Survey", "Maintenance"];

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

    fetchDeptMasterList();
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

  Future<void> pushSurveyDataToDatabase(
      double longitude,
      double latitude,
      String altitude,
      String speed,
      String time,
      String remark,
      String subdepartment,
      String assetowner,
      String projectName,
      String assettype,
      String subtype,
      String assetyear,
      String assetname,
      String status,
      List<File> file) async {
    bool hasInternet = await InternetConnection().hasInternetAccess;
    print("Checking Internet Connection : $hasInternet");
    print(hasInternetConnection);

    if (hasInternetConnection) {
      print("i am in the if Block Statement ${hasInternetConnection}");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Online")));

      pushDataToMongoDB(
          longitude,
          latitude,
          altitude,
          speed,
          time,
          remark,
          subdepartment,
          assetowner,
          projectName,
          assettype,
          subtype,
          assetyear,
          assetname,
          status,
          file);
    } else if (!hasInternetConnection) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Offline")));

      //

      pushDataToLocalStorage(descriptionController.text.toString(), longitude,
          latitude, time, speed, altitude, file);
    }
  }

  Future<void> fetchDeptMasterList() async {
    List<Department>? departments = await _fetchMasterTable.getDepartmentList();
    List<Owners>? owners = await _fetchMasterTable.getOwnersList();
    List<AssetList>? assets = await _fetchMasterTable.getAssetList();
    List<AssetsSubTypeList>? assetSubList =
        await _fetchMasterTable.getAssetsSubTypeList();
    setState(() {
      deptItems = departments.map((e) => e.departmentName).toList();
      ownerItems = owners.map((e) => e.ownerName).toList();
      assetItems = assets.map((e) => e.assetsName).toList();
      assetSubTypeItems = assetSubList.map((e) => e.assetsSubTypeName).toList();
    });
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
              const SizedBox(
                height: 10,
              ),
              CustomTextField(
                controller: projectNameController,
                label: 'Enter Project-Name',
                suffixIcons: const Icon(Icons.pending_actions),
                obscureText: false,
                textInputType: TextInputType.text,
                function: () {},
                function2: () {},
              ),
              SizedBox(
                height: size.height * 0.025,
              ),
              CustomDropDown(
                value: value1,
                items: regionItems,
                onChanged: (value) => setState(() => value1 = value),
                hint: 'Select Region',
              ),
              SizedBox(
                height: size.height * 0.025,
              ),
              CustomDropDown(
                value: deptValue,
                items: deptItems,
                onChanged: (value) => setState(() => deptValue = value),
                hint: 'Choose Department',
              ),
              SizedBox(
                height: size.height * 0.025,
              ),
              CustomDropDown(
                value: ownersValue,
                items: ownerItems,
                onChanged: (value) => setState(() => ownersValue = value),
                hint: 'Choose-owners-List',
              ),
              SizedBox(
                height: size.height * 0.025,
              ),
              CustomDropDown(
                value: assetsValue,
                items: assetItems,
                onChanged: (value) => setState(() => assetsValue = value),
                hint: 'Select Asset',
              ),
              SizedBox(
                height: size.height * 0.025,
              ),
              CustomDropDown(
                value: assetsSubTypeValue,
                items: assetSubTypeItems,
                onChanged: (value) =>
                    setState(() => assetsSubTypeValue = value),
                hint: 'Choose-Assets SubType',
              ),
              SizedBox(
                height: size.height * 0.025,
              ),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 5, color: Colors.blue),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: "Tap to Select Date",
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 5.0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 5.0),
                      borderRadius: BorderRadius.circular(15),
                    )),
                onTap: () async {
                  FocusScope.of(context)
                      .requestFocus(FocusNode()); // To dismiss the keyboard

                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      dateController.text = "${pickedDate.toLocal()}"
                          .split(' ')[0]; // Format the date as needed
                    });
                  }
                },
              ),
              SizedBox(
                height: size.width * 0.025,
              ),
              CustomTextField(
                controller: assetNameController,
                label: 'Enter Assets-Name',
                suffixIcons: const Icon(Icons.pending_actions),
                obscureText: false,
                textInputType: TextInputType.text,
                function: () {},
                function2: () {},
              ),
              SizedBox(
                height: size.height * 0.025,
              ),
              CustomDropDown(
                value: statusValue,
                items: statusItems,
                onChanged: (value) => setState(() => statusValue = value),
                hint: 'Select Status of Work',
              ),
              SizedBox(
                height: size.height * 0.025,
              ),
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
                height: size.height * 0.025,
              ),
              longitude == 0 && latitude == 0
                  ? const Text(
                      'Fetching-Location.....',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  if (longitude != 0 &&
                      latitude != 0 &&
                      altitude.isNotEmpty &&
                      speed.isNotEmpty &&
                      time.isNotEmpty &&
                      descriptionController.text.isNotEmpty &&
                      deptValue!.isNotEmpty &&
                      ownersValue!.isNotEmpty &&
                      projectNameController.text.isNotEmpty &&
                      assetsValue!.isNotEmpty &&
                      assetsSubTypeValue!.isNotEmpty &&
                      dateController.text.isNotEmpty &&
                      assetNameController.text.isNotEmpty &&
                      statusValue!.isNotEmpty &&
                      file.isNotEmpty) {
                    pushSurveyDataToDatabase(
                        longitude,
                        latitude,
                        altitude,
                        speed,
                        time,
                        descriptionController.text.toString(),
                        deptValue!,
                        ownersValue!,
                        projectNameController.text.toString(),
                        assetsValue!,
                        assetsSubTypeValue!,
                        dateController.text.toString(),
                        assetNameController.text.toString(),
                        statusValue!,
                        file);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Some of the Field is Empty"),
                      ),
                    );
                  }
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
