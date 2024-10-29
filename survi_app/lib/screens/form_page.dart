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
import 'package:survi_app/models/regions_list.dart';
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

  final GlobalKey<FormState> _formkey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey4 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey5 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey6 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey7 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey8 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey9 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey10 = GlobalKey<FormState>();

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
  String? regionsValue;
  List<String> regionsItems = [];
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
  int activeCurrentStep = 0;
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.addListener(() {
      // You Can listen to the Scroll events here
      print("Scroll Position : ${_scrollController.position.pixels}");
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

  Future<void> pushSurveyDataToDatabase(
      String regionValue,
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
      print("i am in the if Block Statement $hasInternetConnection");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Online")));

      pushDataToMongoDB(
          regionValue,
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

      pushDataToLocalStorage(
          regionValue,
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
    }
  }

  Future<void> fetchDeptMasterList() async {
    List<RegionsList> regions = await _fetchMasterTable.getRegionsList();

    setState(() {
      regionsItems = regions.map((e) => e.regionsName).toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    descriptionController.dispose();
    _internetConnectionStream!.cancel();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    List<Step> stepList() => [
          Step(
            state: activeCurrentStep > 0
                ? StepState.complete
                : activeCurrentStep == 0
                    ? StepState.editing
                    : StepState.indexed,
            stepStyle: StepStyle(
              color: activeCurrentStep > 0 ? Colors.green : Colors.transparent,
              indexStyle: const TextStyle(fontSize: 18),
            ),
            title: const Text(
              'Project Name',
              style: TextStyle(fontSize: 18),
            ),
            content: Form(
              key: _formkey1,
              child: CustomTextField(
                controller: projectNameController,
                label: 'Enter Project-Name',
                suffixIcons: const Icon(Icons.pending_actions),
                obscureText: false,
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the Project Name';
                  }
                  return null;
                },
              ),
            ),
          ),
          Step(
            state: activeCurrentStep > 1
                ? StepState.complete
                : activeCurrentStep == 1
                    ? StepState.editing
                    : StepState.indexed,
            stepStyle: StepStyle(
              color: activeCurrentStep > 1 ? Colors.green : Colors.transparent,
              indexStyle: const TextStyle(fontSize: 18),
            ),
            title: const Text(
              'Select Region',
              style: TextStyle(fontSize: 18),
            ),
            content: Form(
              key: _formkey2,
              child: CustomDropDown(
                value: regionsValue,
                items: regionsItems,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select Region ';
                  }

                  return null;
                },
                onChanged: (value) async {
                  if (value != null) {
                    List<Owners>? owners =
                        await _fetchMasterTable.getOwnersList(value.toString());

                    setState(() {
                      regionsValue = value;
                      ownerItems = owners.map((e) => e.ownerName).toList();
                      ownersValue = null;
                      deptValue = null;
                      assetsValue = null;
                      assetsSubTypeValue = null;
                    });
                  }
                },
                hint: 'Select Region',
              ),
            ),
          ),
          Step(
            state: activeCurrentStep > 2
                ? StepState.complete
                : activeCurrentStep == 2
                    ? StepState.editing
                    : StepState.indexed,
            stepStyle: StepStyle(
              color: activeCurrentStep > 2 ? Colors.green : Colors.transparent,
              indexStyle: const TextStyle(fontSize: 18),
            ),
            title: const Text(
              'Owner',
              style: TextStyle(fontSize: 18),
            ),
            content: Form(
              key: _formkey3,
              child: CustomDropDown(
                value: ownersValue,
                items: ownerItems,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Select Owner";
                  }
                  return null;
                },
                onChanged: (value) async {
                  if (value != null) {
                    List<Department>? departments = await _fetchMasterTable
                        .getDepartmentList(value.toString());
                    setState(() {
                      ownersValue = value;
                      deptItems =
                          departments.map((e) => e.departmentName).toList();
                      deptValue = null;
                      assetsValue = null;
                      assetsSubTypeValue = null;
                    });
                  }
                },
                hint: 'Choose-owners-List',
              ),
            ),
          ),
          Step(
            state: activeCurrentStep > 3
                ? StepState.complete
                : activeCurrentStep == 3
                    ? StepState.editing
                    : StepState.indexed,
            stepStyle: StepStyle(
              color: activeCurrentStep > 3 ? Colors.green : Colors.transparent,
              indexStyle: const TextStyle(fontSize: 18),
            ),
            title: const Text(
              "Department",
              style: TextStyle(fontSize: 18),
            ),
            content: Form(
              key: _formkey4,
              child: CustomDropDown(
                value: deptValue,
                items: deptItems,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select Department';
                  }

                  return null;
                },
                onChanged: (value) async {
                  if (value != null) {
                    List<AssetList>? assets =
                        await _fetchMasterTable.getAssetList(value.toString());
                    setState(() {
                      deptValue = value;
                      assetItems = assets.map((e) => e.assetsName).toList();
                      assetsValue = null;
                      assetsSubTypeValue = null;
                    });
                  }
                },
                hint: 'Choose Department',
              ),
            ),
          ),
          Step(
            state: activeCurrentStep > 4
                ? StepState.complete
                : activeCurrentStep == 4
                    ? StepState.editing
                    : StepState.indexed,
            stepStyle: StepStyle(
              color: activeCurrentStep > 4 ? Colors.green : Colors.transparent,
              indexStyle: const TextStyle(fontSize: 18),
            ),
            title: const Text(
              'Assets',
              style: TextStyle(fontSize: 18),
            ),
            content: Form(
              key: _formkey5,
              child: CustomDropDown(
                value: assetsValue,
                items: assetItems,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select Asset';
                  }

                  return null;
                },
                onChanged: (value) async {
                  if (value != null) {
                    List<AssetsSubTypeList>? assetSubList =
                        await _fetchMasterTable
                            .getAssetsSubTypeList(value.toString());
                    setState(() {
                      assetsValue = value;
                      assetSubTypeItems =
                          assetSubList.map((e) => e.assetsSubTypeName).toList();
                      assetsSubTypeValue = null;
                    });
                  }
                },
                hint: 'Select Asset',
              ),
            ),
          ),
          Step(
            state: activeCurrentStep > 5
                ? StepState.complete
                : activeCurrentStep == 5
                    ? StepState.editing
                    : StepState.indexed,
            stepStyle: StepStyle(
              color: activeCurrentStep > 5 ? Colors.green : Colors.transparent,
              indexStyle: const TextStyle(fontSize: 18),
            ),
            title: const Text(
              'Sub-Type',
              style: TextStyle(fontSize: 18),
            ),
            content: Form(
              key: _formkey6,
              child: CustomDropDown(
                value: assetsSubTypeValue,
                items: assetSubTypeItems,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select SubType';
                  }

                  return null;
                },
                onChanged: (value) =>
                    setState(() => assetsSubTypeValue = value),
                hint: 'Choose-Assets SubType',
              ),
            ),
          ),
          Step(
            state: activeCurrentStep > 6
                ? StepState.complete
                : activeCurrentStep == 6
                    ? StepState.editing
                    : StepState.indexed,
            stepStyle: StepStyle(
              color: activeCurrentStep > 6 ? Colors.green : Colors.transparent,
              indexStyle: const TextStyle(fontSize: 18),
            ),
            title: const Text(
              'Name',
              style: TextStyle(fontSize: 18),
            ),
            content: Form(
              key: _formkey7,
              child: CustomTextField(
                controller: assetNameController,
                label: 'Enter Assets-Name',
                suffixIcons: const Icon(Icons.pending_actions),
                obscureText: false,
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Asset Name';
                  }
                  return null;
                },
              ),
            ),
          ),
          Step(
            state: activeCurrentStep > 7
                ? StepState.complete
                : activeCurrentStep == 7
                    ? StepState.editing
                    : StepState.indexed,
            stepStyle: StepStyle(
              color: activeCurrentStep > 7 ? Colors.green : Colors.transparent,
              indexStyle: const TextStyle(fontSize: 18),
            ),
            title: const Text(
              'Description',
              style: TextStyle(fontSize: 18),
            ),
            content: Form(
              key: _formkey8,
              child: CustomTextField(
                controller: descriptionController,
                label: 'Write description Here',
                suffixIcons: const Icon(Icons.edit_calendar),
                obscureText: false,
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Provide Description';
                  }

                  return null;
                },
              ),
            ),
          ),
          Step(
            state: activeCurrentStep > 8
                ? StepState.complete
                : activeCurrentStep == 8
                    ? StepState.editing
                    : StepState.indexed,
            stepStyle: StepStyle(
              color: activeCurrentStep > 8 ? Colors.green : Colors.transparent,
              indexStyle: const TextStyle(fontSize: 18),
            ),
            title: const Text(
              'Date',
              style: TextStyle(fontSize: 18),
            ),
            content: Form(
              key: _formkey9,
              child: TextFormField(
                controller: dateController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pick Date';
                  }

                  return null;
                },
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
            ),
          ),
          Step(
            state: activeCurrentStep > 9
                ? StepState.complete
                : activeCurrentStep == 9
                    ? StepState.editing
                    : StepState.indexed,
            stepStyle: StepStyle(
              color: activeCurrentStep > 9 ? Colors.green : Colors.transparent,
              indexStyle: const TextStyle(fontSize: 18),
            ),
            title: const Text(
              'Purpose',
              style: TextStyle(fontSize: 18),
            ),
            content: Form(
              key: _formKey10,
              child: CustomDropDown(
                value: statusValue,
                items: statusItems,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select Status';
                  }

                  return null;
                },
                onChanged: (value) => setState(() => statusValue = value),
                hint: 'Select Status of Work',
              ),
            ),
          ),
        ];

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
              Stepper(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  currentStep: activeCurrentStep,
                  onStepContinue: () {
                    if (activeCurrentStep == 0 &&
                            _formkey1.currentState!.validate() ||
                        activeCurrentStep == 1 &&
                            _formkey2.currentState!.validate() ||
                        activeCurrentStep == 2 &&
                            _formkey3.currentState!.validate() ||
                        activeCurrentStep == 3 &&
                            _formkey4.currentState!.validate() ||
                        activeCurrentStep == 4 &&
                            _formkey5.currentState!.validate() ||
                        activeCurrentStep == 5 &&
                            _formkey6.currentState!.validate() ||
                        activeCurrentStep == 6 &&
                            _formkey7.currentState!.validate() ||
                        activeCurrentStep == 7 &&
                            _formkey8.currentState!.validate() ||
                        activeCurrentStep == 8 &&
                            _formkey9.currentState!.validate() ||
                        activeCurrentStep == 9 &&
                            _formKey10.currentState!.validate()) {
                      if (activeCurrentStep < (stepList().length - 1)) {
                        setState(() {
                          activeCurrentStep += 1;
                        });
                        _scrollController.animateTo(activeCurrentStep * 100,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.linear);
                      }
                    }
                  },
                  onStepTapped: (index) {
                    if (index > activeCurrentStep) {
                      return;
                    } else {
                      setState(() {
                        activeCurrentStep = index;
                      });
                      _scrollController.animateTo(index * 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.linear);
                    }
                  },
                  onStepCancel: () {
                    if (activeCurrentStep == 0) {
                      return;
                    } else {
                      setState(() {
                        activeCurrentStep -= 1;
                      });
                      _scrollController.animateTo(activeCurrentStep * 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.linear);
                    }
                  },
                  steps: stepList()),
              SizedBox(
                height: size.height * 0.025,
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
                  // if ((regionsValue?.isNotEmpty ?? false) &&
                  //     longitude != 0 &&
                  //     latitude != 0 &&
                  //     altitude.isNotEmpty &&
                  //     speed.isNotEmpty &&
                  //     time.isNotEmpty &&
                  //     descriptionController.text.isNotEmpty &&
                  //     (deptValue?.isNotEmpty ?? false) &&
                  //     (ownersValue?.isNotEmpty ?? false) &&
                  //     projectNameController.text.isNotEmpty &&
                  //     (assetsValue?.isNotEmpty ?? false) &&
                  //     (assetsSubTypeValue?.isNotEmpty ?? false) &&
                  //     dateController.text.isNotEmpty &&
                  //     assetNameController.text.isNotEmpty &&
                  //     statusValue!.isNotEmpty &&
                  //     file.isNotEmpty) {
                  //   pushSurveyDataToDatabase(
                  //       regionsValue!,
                  //       longitude,
                  //       latitude,
                  //       altitude,
                  //       speed,
                  //       time,
                  //       descriptionController.text.toString(),
                  //       deptValue!,
                  //       ownersValue!,
                  //       projectNameController.text.toString(),
                  //       assetsValue!,
                  //       assetsSubTypeValue!,
                  //       dateController.text.toString(),
                  //       assetNameController.text.toString(),
                  //       statusValue!,
                  //       file);
                  // } else {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: Text("Some of the Field is Empty"),
                  //     ),
                  //   );

                  //   print(
                  //       " Regions : $regionsValue \n longitude : $longitude \n latitude : $latitude \n altitude : $altitude \n speed : $speed \n time : $time \n description : ${descriptionController.text.toString()} \n deptValue : $deptValue \n ownerValue : $ownersValue \n projectName : ${projectNameController.text.toString()} \n assetsValue : $assetsValue \n assetSubTypeName : $assetsSubTypeValue \n date : ${dateController.text.toString()} \n assetName : ${assetNameController.text.toString()} \n statusValue : $statusValue \n file : $file");
                  // }


                        pushSurveyDataToDatabase(
                        "Europe",
                        longitude,
                        latitude,
                        altitude,
                        speed,
                        time,
                        descriptionController.text.toString(),
                        "Finance",
                        "Government",
                        projectNameController.text.toString(),
                        "Building",
                        "Residential Building",
                        dateController.text.toString(),
                        assetNameController.text.toString(),
                        "Survey",
                        file);

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
