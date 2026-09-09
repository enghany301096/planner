class IncomeCategory {
  final String id;
  final String name;
  final int color;
  final int icon;
  final bool isDefault;

  IncomeCategory({
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

  factory IncomeCategory.fromMap(Map<String, dynamic> map) {
    return IncomeCategory(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      icon: map['icon'],
      isDefault: (map['isDefault'] ?? 0) == 1,
    );
  }
}
