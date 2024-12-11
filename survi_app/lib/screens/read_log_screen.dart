import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survi_app/functions/tasks_dialog.dart';

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
          int totalTask = 0;
          for (int i = 0; i < taskList.length; i++) {
            TaskList task = taskList[i];
            if (task.taskId != totalTask) {
              totalTask++;
            }
          }

          print(totalTask);
          return ListView.builder(
              itemCount: totalTask,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.yellow,
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05),
                          const Text(
                            "Task",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () async {
                         await showStops(context, index + 1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          "Go",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }
}
