import 'package:survi_app/models/survey_file_list.dart';
import 'package:survi_app/models/survey_list.dart';

class SurveyWithFiles {
  final SurveyList survey;
  final List<SurveyFileList> files;

  SurveyWithFiles({required this.survey, required this.files});
}
