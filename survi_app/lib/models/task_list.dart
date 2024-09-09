class TaskList {
  final int id;
  final String userId;
  final String agentId;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;

  TaskList(
      {required this.id,
      required this.userId,
      required this.agentId,
      required this.startLat,
      required this.startLng,
      required this.endLat,
      required this.endLng});
}
