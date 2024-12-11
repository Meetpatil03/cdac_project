import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:survi_app/apis/web_services.dart';
import 'package:survi_app/functions/send_live_location.dart';
import 'package:survi_app/screens/form_page.dart';
import 'package:survi_app/screens/login_screens/login_page.dart';
import 'package:survi_app/screens/map_view.dart';
import 'package:survi_app/screens/read_log_screen.dart';
import 'package:survi_app/widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isTrackingPerson = false;
  final SendLiveLocation liveLocation = SendLiveLocation();

  @override
  void dispose() {
    super.dispose();
    liveLocation.stopTracking();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Future<void> logout() async {
      WebService webService = WebService();

      // ensure to Intialise cookie
      await webService.ensureInitialized();

      await webService.cookieJar.deleteAll();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AssetTracker",
          style: TextStyle(
              fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            onPressed: logout,
            style: IconButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size.height * 0.065,
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.25),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FormPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                  backgroundColor: Colors.purple,
                  minimumSize: Size(140, 50),
                  ),
              child: const Text(
                'Survey Form',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: size.height * 0.05,
          ),
          GestureDetector(
            onTap: () async {
              if (!isTrackingPerson) {
                setState(() {
                  isTrackingPerson = !isTrackingPerson;
                  // start Sending location to admin
                });
                await liveLocation.trackLiveLocation();
              } else {
                setState(() {
                  isTrackingPerson = !isTrackingPerson;
                });
                liveLocation.stopTracking();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              padding: const EdgeInsets.all(8),
              height: 50,
              width: isTrackingPerson ? 240 : 140,
              decoration: BoxDecoration(
                color: isTrackingPerson ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(isTrackingPerson ? 15 : 5),
              ),
              child: isTrackingPerson
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.gps_fixed),
                        Text(
                          'Stop Tracking',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        )
                      ],
                    )
                  : const Text(
                      'Start Tracking',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Colors.white),
                    ),
            ),
          ),
          SizedBox(height: size.height * 0.08),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MapView(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 50),
                shape: const RoundedRectangleBorder(),
                backgroundColor: Colors.green),
            child: const Text(
              "Map",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.08),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ReadLogs()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: const RoundedRectangleBorder(),
              minimumSize: Size(140, 50)
            ),
            child: const Text(
              'Task List',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          // ElevatedButton(
          //     onPressed: () {
          //       Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (context) => const MarkersMapView(),
          //         ),
          //       );
          //     },
          //     child: const Text('Markers Liat')),
          // SizedBox(height: 20),
        ],
      ),
    );
  }
}
