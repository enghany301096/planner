class ExpenseCategory {
  final String id;
  final String name;
  final int color;
  final int icon;
  final bool isDefault;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      icon: map['icon'],
      isDefault: (map['isDefault'] ?? 0) == 1,
    );
  }

  ExpenseCategory copyWith({
    String? id,
    String? name,
    int? color,
    int? icon,
    bool? isDefault,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
