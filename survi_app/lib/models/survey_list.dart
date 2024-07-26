class SurveyList {
  final int id;
  
  final String description;
  final double longitude;
  final double latitude;
  final String timestamp;
  final String speed;
  final String altitude;

  SurveyList( 
      {required this.id,
      required this.description,
      required this.longitude,
      required this.latitude,
      required this.timestamp,
      required this.speed,
      required this.altitude});
}
