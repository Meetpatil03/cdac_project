import 'package:flutter/material.dart';
import 'package:survi_app/functions/push_local_to_mongodb.dart';
import 'package:survi_app/models/survey_file_list.dart';
import 'package:survi_app/models/survey_list.dart';
import 'package:survi_app/models/survey_with_files.dart';
import 'package:survi_app/services/database_services.dart';

class AgentsSurveyList extends StatefulWidget {
  const AgentsSurveyList({super.key});

  @override
  State<AgentsSurveyList> createState() => _AgentsSurveyListState();
}

class _AgentsSurveyListState extends State<AgentsSurveyList> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                pushLocalDataToMongoDB();
              },
              icon: const Icon(Icons.send))
        ],
      ),
      body: _surveyLists(),
    );
  }

  Widget _surveyLists() {
    return FutureBuilder(
        future: _databaseServices.getSurveysWithFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Surveys Found'));
          }

          List<SurveyWithFiles> surveysWithFiles = snapshot.data!;

          return ListView.builder(
              itemCount: surveysWithFiles.length,
              itemBuilder: (context, index) {
                SurveyWithFiles surveyWithFiles = surveysWithFiles[index];
                SurveyList survey = surveyWithFiles.survey;
                List<SurveyFileList> files = surveyWithFiles.files;
                return GestureDetector(
                  onLongPress: () {
                    DatabaseServices.instance.deleteSurvey(survey.id);
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 5),
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'id : ${survey.id}\n description : ${survey.description}\n timeStamp: ${survey.timestamp} \n send_status : ${survey.sendstatus}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Files:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        ...files.map((file) => Text(file.filePath)).toList(),
                      ],
                    ),
                  ),
                );
              });
        });
  }
}
