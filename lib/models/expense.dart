class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? paymentMethodId;
  final String? note;
  final String? taskId; // nullable — links back to a paid task
  final String currency;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.paymentMethodId,
    this.note,
    this.taskId,
    this.currency = 'L.E',
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

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      paymentMethodId: map['paymentMethodId'],
      note: map['note'],
      taskId: map['taskId'],
      currency: map['currency'] ?? 'L.E',
    );
  }

  Expense copyWith({
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
    return Expense(
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
