class ProjectMember {
  final String id;
  final String projectId;
  final String name;
  final String? phone;
  final String? email;
  final int color;

  const ProjectMember({
    required this.id,
    required this.projectId,
    required this.name,
    this.phone,
    this.email,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'projectId': projectId,
    'name': name,
    'phone': phone,
    'email': email,
    'color': color,
  };

  factory ProjectMember.fromMap(Map<String, dynamic> map) => ProjectMember(
    id: map['id'] as String,
    projectId: map['projectId'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String?,
    email: map['email'] as String?,
    color: map['color'] as int? ?? 0xFF6366F1,
  );

  ProjectMember copyWith({
    String? id,
    String? projectId,
    String? name,
    String? phone,
    String? email,
    int? color,
  }) {
    return ProjectMember(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      color: color ?? this.color,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
