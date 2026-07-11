import 'dart:convert';

class ProjectTask {
  final String id;
  final String projectId;
  final String name;
  final String details;
  final List<String> attachments;
  final DateTime startDate;
  final DateTime? endDate;
  final double cost;
  final String currency;
  final bool isCompleted;
  final String status;
  final String type; // 'newFeature', 'bug', 'enhancement'
  final List<Map<String, dynamic>> subTasks;
  final bool isPaid;
  final String? paymentMethodId;
  final int timeSpentInSeconds;
  final bool isTimerRunning;
  final DateTime? lastStartTime;
  final DateTime? timerStartAt;
  final DateTime? timerEndAt;
  final bool isArchived;

  final double estimatedTime;
  final double hourlyRate;

  ProjectTask({
    required this.id,
    required this.projectId,
    required this.name,
    required this.details,
    required this.attachments,
    required this.startDate,
    this.endDate,
    required this.cost,
    this.currency = 'USD',
    this.isCompleted = false,
    this.status = 'todo',
    this.type = 'newFeature',
    this.subTasks = const [],
    this.isPaid = false,
    this.paymentMethodId,
    this.timeSpentInSeconds = 0,
    this.isTimerRunning = false,
    this.lastStartTime,
    this.timerStartAt,
    this.timerEndAt,
    this.estimatedTime = 0.0,
    this.hourlyRate = 0.0,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'details': details,
      'attachments': jsonEncode(attachments),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cost': cost,
      'currency': currency,
      'isCompleted': isCompleted ? 1 : 0,
      'status': status,
      'type': type,
      'subTasks': jsonEncode(subTasks),
      'isPaid': isPaid ? 1 : 0,
      'paymentMethodId': paymentMethodId,
      'timeSpentInSeconds': timeSpentInSeconds,
      'isTimerRunning': isTimerRunning ? 1 : 0,
      'lastStartTime': lastStartTime?.toIso8601String(),
      'timerStartAt': timerStartAt?.toIso8601String(),
      'timerEndAt': timerEndAt?.toIso8601String(),
      'estimatedTime': estimatedTime,
      'hourlyRate': hourlyRate,
      'isArchived': isArchived ? 1 : 0,
    };
  }

  factory ProjectTask.fromMap(Map<String, dynamic> map) {
    return ProjectTask(
      id: map['id'],
      projectId: map['projectId'],
      name: map['name'],
      details: map['details'],
      attachments: List<String>.from(jsonDecode(map['attachments'] ?? '[]')),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      cost: map['cost'],
      currency: map['currency'] ?? 'USD',
      isCompleted: map['isCompleted'] == 1,
      status: map['status'] ?? 'todo',
      type: map['type'] ?? 'newFeature',
      subTasks: List<Map<String, dynamic>>.from(
        jsonDecode(map['subTasks'] ?? '[]'),
      ),
      isPaid: map['isPaid'] == 1,
      paymentMethodId: map['paymentMethodId'],
      timeSpentInSeconds: map['timeSpentInSeconds'] ?? 0,
      isTimerRunning: map['isTimerRunning'] == 1,
      lastStartTime: map['lastStartTime'] != null
          ? DateTime.parse(map['lastStartTime'])
          : null,
      timerStartAt: map['timerStartAt'] != null
          ? DateTime.parse(map['timerStartAt'])
          : null,
      timerEndAt: map['timerEndAt'] != null
          ? DateTime.parse(map['timerEndAt'])
          : null,
      estimatedTime: map['estimatedTime'] ?? 0.0,
      hourlyRate: map['hourlyRate'] ?? 0.0,
      isArchived: map['isArchived'] == 1,
    );
  }

  ProjectTask copyWith({
    String? id,
    String? projectId,
    String? name,
    String? details,
    List<String>? attachments,
    DateTime? startDate,
    DateTime? endDate,
    double? cost,
    String? currency,
    bool? isCompleted,
    String? status,
    String? type,
    List<Map<String, dynamic>>? subTasks,
    bool? isPaid,
    String? paymentMethodId,
    int? timeSpentInSeconds,
    bool? isTimerRunning,
    DateTime? lastStartTime,
    DateTime? timerStartAt,
    DateTime? timerEndAt,
    double? estimatedTime,
    double? hourlyRate,
    bool? isArchived,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      details: details ?? this.details,
      attachments: attachments ?? this.attachments,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
      type: type ?? this.type,
      subTasks: subTasks ?? this.subTasks,
      isPaid: isPaid ?? this.isPaid,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      timeSpentInSeconds: timeSpentInSeconds ?? this.timeSpentInSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      lastStartTime: lastStartTime ?? this.lastStartTime,
      timerStartAt: timerStartAt ?? this.timerStartAt,
      timerEndAt: timerEndAt ?? this.timerEndAt,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
