class TaskList {
  final int id;
  final int taskId;
  final String userId;
  final String agentId;
  final String routeId;
  final double latitude;
  final double longitude;
  final int status;

  TaskList(
      {required this.id,
      required this.taskId,
      required this.userId,
      required this.agentId,
      required this.routeId,
      required this.latitude,
      required this.longitude,
      required this.status});
}
