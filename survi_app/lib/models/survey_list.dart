class SurveyList {
  final int id;
  final int sendstatus;
  final String region;
  final String description;
  final double longitude;
  final double latitude;
  final String timestamp;
  final String speed;
  final String altitude;
  final String subdepartment;
  final String assetowner;
  final String projectName;
  final String assettype;
  final String subtype;
  final String assetyear;
  final String assetname;
  final String purpose;

  SurveyList( 
      {required this.id,
      required this.region,
      required this.sendstatus,
      required this.description,
      required this.longitude,
      required this.latitude,
      required this.timestamp,
      required this.speed,
      required this.altitude,
      required this.subdepartment,
      required this.assetowner,
      required this.projectName,
      required this.assettype,
      required this.subtype,
      required this.assetyear,
      required this.assetname,
      required this.purpose});
}
