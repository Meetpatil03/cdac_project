import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:survi_app/models/task_list.dart';
import 'package:survi_app/services/markers_database.dart';

class ReadLogs extends StatefulWidget {
  const ReadLogs({super.key});

  @override
  State<ReadLogs> createState() => _ReadLogsState();
}

class _ReadLogsState extends State<ReadLogs> {
  final MarkersDatabase _markersDatabase = MarkersDatabase.instance;
  String? userId;

  Future<String?> _getUserIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    fetchTheMarkers();
  }

  Future<void> _initializeUserId() async {
    String? id = await _getUserIdFromSharedPreferences();
    setState(() {
      userId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks Records'),
        centerTitle: true,
      ),
      body: _Tasks(),
    );
  }

  Future<void> fetchTheMarkers() async {
    List<TaskList> data = await _markersDatabase.getAllRoutes();
    print('Fetched data :$data');
  }

  Widget _Tasks() {
    return FutureBuilder(
        future: _markersDatabase.getAllRoutes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No Tasks List'),
            );
          }

          List<TaskList> taskList = snapshot.data!;

          return ListView.builder(
            itemCount: taskList.length,
            itemBuilder: (context, index) {
              TaskList task = taskList[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text('Task Id: ${task.taskId}'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('agentId: ${task.agentId}'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('latitude: ${task.latitude}'),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('longitude: ${task.longitude}'),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
