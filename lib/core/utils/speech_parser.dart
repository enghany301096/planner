class SpeechParser {
  /// Parses the spoken text and returns a Map containing:
  /// - 'taskName': The main task title.
  /// - 'subtasks': A list of subtask titles.
  static Map<String, dynamic> parse(String text) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return {'taskName': '', 'subtasks': <String>[]};
    }

    // List of markers that separate the task name from subtasks
    // Ordered by length descending to match longer keywords first
    final markers = [
      // English
      'with subtasks',
      'and subtasks',
      'with subtask',
      'subtasks',
      'subtask',
      'with steps',
      'steps',
      'todos',
      'todo',
      // Arabic
      'مع المهام الفرعية',
      'المهام الفرعية',
      'مع مهام فرعية',
      'بمهام فرعية',
      'مهام فرعية',
      'مع خطوات',
      'خطوات',
      'مهام',
      'خطوة',
    ];

    String taskPart = cleanText;
    String subtasksPart = '';
    final lowerText = cleanText.toLowerCase();

    for (final marker in markers) {
      final index = lowerText.indexOf(marker);
      if (index != -1) {
        taskPart = cleanText.substring(0, index).trim();
        subtasksPart = cleanText.substring(index + marker.length).trim();
        break;
      }
    }

    // Clean up task title prefixes
    taskPart = _removePrefixes(taskPart);

    // Parse subtasks
    final List<String> subtasks = [];
    if (subtasksPart.isNotEmpty) {
      // Split by common delimiters
      // English: ',', 'and', 'then'
      // Arabic: '،', 'و', 'ثم'
      final rawSubtasks = subtasksPart.split(
        RegExp(r'(?:,|،|\band\b|\bthen\b|\bثم\b|\bو\b)'),
      );
      for (final raw in rawSubtasks) {
        final cleaned = raw.trim();
        // Remove trailing punctuation or extra spaces
        final finalCleaned = cleaned.replaceAll(RegExp(r'[.!?]$'), '').trim();
        if (finalCleaned.isNotEmpty) {
          subtasks.add(finalCleaned);
        }
      }
    }

    return {
      'taskName': taskPart.isEmpty ? cleanText : taskPart,
      'subtasks': subtasks,
    };
  }

  static String _removePrefixes(String input) {
    String text = input.trim();
    final prefixes = [
      // English
      'create a task named',
      'create task named',
      'add a task named',
      'add task named',
      'create a new task',
      'create new task',
      'add a new task',
      'add new task',
      'create a task',
      'create task',
      'add a task',
      'add task',
      'make a task',
      'make task',
      'new task',
      // Arabic
      'إنشاء مهمة جديدة باسم',
      'إنشاء مهمة باسم',
      'إضافة مهمة جديدة باسم',
      'إضافة مهمة باسم',
      'إنشاء مهمة جديدة',
      'إضافة مهمة جديدة',
      'إنشاء مهمة',
      'إضافة مهمة',
      'مهمة جديدة',
      'عمل مهمة',
    ];

    final lower = text.toLowerCase();
    for (final prefix in prefixes) {
      if (lower.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
        break;
      }
    }

    // Capitalize first letter of task name if English
    if (text.isNotEmpty) {
      text = text[0].toUpperCase() + text.substring(1);
    }
    return text;
  }
}
