class Income {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? paymentMethodId;
  final String? note;
  final String? taskId;
  final String currency;

  Income({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.paymentMethodId,
    this.note,
    this.taskId,
    this.currency = 'EGP',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'paymentMethodId': paymentMethodId,
      'note': note,
      'taskId': taskId,
      'currency': currency,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      title: (map['title'] as String?)?.isNotEmpty == true
          ? map['title'] as String
          : '',
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      paymentMethodId: map['paymentMethodId'],
      note: map['note'],
      taskId: map['taskId'],
      currency: map['currency'] ?? 'EGP',
    );
  }

  Income copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? paymentMethodId,
    String? note,
    String? taskId,
    String? currency,
  }) {
    return Income(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      note: note ?? this.note,
      taskId: taskId ?? this.taskId,
      currency: currency ?? this.currency,
    );
  }
}
