import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/project_task.dart';
import '../core/services/database_helper.dart';

typedef TaskPaidCallback = Future<void> Function(ProjectTask task, bool isPaid);

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  final Map<String, List<ProjectTask>> _tasks = {}; // projectId -> tasks

  /// Optional callback fired when a task's isPaid status changes.
  /// Wired to ExpensesProvider in HomeScreen after providers are available.
  TaskPaidCallback? onTaskPaidChanged;

  List<Project> get projects => _projects;

  List<ProjectTask> getTasks(String projectId) {
    return _tasks[projectId] ?? [];
  }

  int get totalTasksCount {
    return _tasks.values
        .expand((element) => element)
        .where((t) => !t.isArchived)
        .length;
  }

  int get completedTasksCount {
    return _tasks.values
        .expand((element) => element)
        .where((t) => t.isCompleted && !t.isArchived)
        .length;
  }

  int get pendingTasksCount {
    return _tasks.values
        .expand((element) => element)
        // Bug fix #4: pending = not yet started (toDo only), not all non-completed
        .where((t) => t.status == 'toDo' && !t.isArchived)
        .length;
  }

  int get inProgressTasksCount {
    return _tasks.values
        .expand((element) => element)
        .where((t) => t.status == 'inProgress' && !t.isArchived)
        .length;
  }

  double get totalEarnings {
    return _tasks.values
        .expand((element) => element)
        .where((t) => !t.isArchived)
        .fold(0.0, (sum, t) => sum + t.cost);
  }

  double get paidEarnings {
    return _tasks.values
        .expand((element) => element)
        .where((t) => t.isPaid && !t.isArchived)
        .fold(0.0, (sum, t) => sum + t.cost);
  }

  double get unpaidEarnings {
    return _tasks.values
        .expand((element) => element)
        .where((t) => !t.isPaid && !t.isArchived)
        .fold(0.0, (sum, t) => sum + t.cost);
  }

  Future<void> loadData() async {
    try {
      _projects = await DatabaseHelper.instance.getProjects();
      final allTasks = await DatabaseHelper.instance.getAllTasks();
      _tasks.clear();
      for (var task in allTasks) {
        if (_tasks.containsKey(task.projectId)) {
          _tasks[task.projectId]!.add(task);
        } else {
          _tasks[task.projectId] = [task];
        }
      }
    } catch (e) {
      debugPrint('ProjectProvider loadData error: $e');
    }
    notifyListeners();
  }

  Future<void> loadTasks(String projectId) async {
    try {
      _tasks[projectId] = await DatabaseHelper.instance.getTasks(projectId);
    } catch (e) {
      debugPrint('ProjectProvider loadTasks error: $e');
    }
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    await DatabaseHelper.instance.insertProject(project);
    _projects.add(project);
    notifyListeners();
  }

  Future<void> updateProject(Project project) async {
    await DatabaseHelper.instance.updateProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String id) async {
    await DatabaseHelper.instance.deleteProject(id);
    _projects.removeWhere((p) => p.id == id);
    _tasks.remove(id);
    notifyListeners();
  }

  Future<void> addTask(ProjectTask task) async {
    await DatabaseHelper.instance.insertTask(task);
    if (_tasks.containsKey(task.projectId)) {
      _tasks[task.projectId]!.add(task);
    } else {
      _tasks[task.projectId] = [task];
    }
    notifyListeners();
  }

  Future<void> updateTask(ProjectTask task) async {
    // Detect payment status change to trigger expense auto-creation/removal
    final existingTask = _tasks[task.projectId]
        ?.firstWhere((t) => t.id == task.id, orElse: () => task);
    final paymentChanged =
        existingTask != null && existingTask.isPaid != task.isPaid;

    ProjectTask taskToUpdate = task;
    if (task.status == 'done' && task.timerEndAt == null) {
      taskToUpdate = task.copyWith(
        timerEndAt: DateTime.now(),
        timerStartAt: task.timerStartAt ?? task.startDate,
      );
    }
    await DatabaseHelper.instance.updateTask(taskToUpdate);
    if (_tasks.containsKey(taskToUpdate.projectId)) {
      final index = _tasks[taskToUpdate.projectId]!.indexWhere(
        (t) => t.id == taskToUpdate.id,
      );
      if (index != -1) {
        _tasks[taskToUpdate.projectId]![index] = taskToUpdate;
        notifyListeners();
      }
    }
    // Fire expense callback after state is updated
    if (paymentChanged && onTaskPaidChanged != null) {
      await onTaskPaidChanged!(taskToUpdate, taskToUpdate.isPaid);
    }
  }

  Future<void> deleteTask(String id, String projectId) async {
    await DatabaseHelper.instance.deleteTask(id);
    if (_tasks.containsKey(projectId)) {
      _tasks[projectId]!.removeWhere((t) => t.id == id);
      notifyListeners();
    }
  }

  Future<void> toggleTaskTimer(String taskId, String projectId) async {
    final tasks = _tasks[projectId];
    if (tasks == null) return;

    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = tasks[index];
    final now = DateTime.now();
    ProjectTask updatedTask;

    if (task.isTimerRunning) {
      // Stop Timer
      final startTime = task.lastStartTime ?? now;
      final difference = now.difference(startTime).inSeconds;
      final newTimeSpent = task.timeSpentInSeconds + difference;

      double newCost = task.cost;
      if (task.hourlyRate > 0) {
        newCost = (newTimeSpent / 3600.0) * task.hourlyRate;
        // Round to 2 decimal places to avoid long floating point numbers
        newCost = double.parse(newCost.toStringAsFixed(2));
      }

      updatedTask = task.copyWith(
        timeSpentInSeconds: newTimeSpent,
        cost: newCost,
        isTimerRunning: false,
        lastStartTime: null,
        timerEndAt: now,
      );
    } else {
      // Start Timer
      updatedTask = task.copyWith(
        isTimerRunning: true,
        lastStartTime: now,
        timerStartAt: task.timerStartAt ?? now,
      );
    }

    await updateTask(updatedTask);
  }
}
