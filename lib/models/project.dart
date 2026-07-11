class Project {
  final String id;
  final String name;
  final String description;
  final DateTime? endDate;
  final String status;
  final String? imagePath;

  Project({
    required this.id,
    required this.name,
    required this.description,
    this.endDate,
    this.status = 'active',
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'imagePath': imagePath,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      status: map['status'] ?? 'active',
      imagePath: map['imagePath'],
    );
  }
}
