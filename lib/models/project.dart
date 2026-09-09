class Project {
  static const coverImage = 'image';
  static const coverIcon = 'icon';

  final String id;
  final String name;
  final String description;
  final DateTime? endDate;
  final String status;
  final String? imagePath;
  final String? customer;
  final String coverType;
  final int? icon;

  Project({
    required this.id,
    required this.name,
    required this.description,
    this.endDate,
    this.status = 'active',
    this.imagePath,
    this.customer,
    this.coverType = coverImage,
    this.icon,
  });

  bool get usesIconCover => coverType == coverIcon;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'imagePath': imagePath,
      'customer': customer,
      'coverType': coverType,
      'icon': icon,
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
      customer: map['customer'] as String?,
      coverType: (map['coverType'] as String?)?.isNotEmpty == true
          ? map['coverType'] as String
          : coverImage,
      icon: map['icon'] == null ? null : (map['icon'] as num).toInt(),
    );
  }
}
