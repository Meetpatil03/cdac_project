

import 'package:survi_app/models/location.dart';

class Task {
  final int taskId;
  final String agentId;
  final List<Location> stops;

  Task({required this.taskId, required this.agentId, required this.stops});
}
