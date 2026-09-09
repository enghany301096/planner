enum PaymentMethodType { cash, visa, bank }

class PaymentMethod {
  final String id;
  final String name;
  final int color;
  final int icon;
  final PaymentMethodType type;
  final String? cardNumber;
  final double startingBalance;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.type = PaymentMethodType.cash,
    this.cardNumber,
    this.startingBalance = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'type': type.name,
      'cardNumber': cardNumber,
      'startingBalance': startingBalance,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      icon: map['icon'],
      type: map['type'] != null
          ? PaymentMethodType.values.firstWhere(
              (e) => e.name == map['type'],
              orElse: () => PaymentMethodType.cash,
            )
          : PaymentMethodType.cash,
      cardNumber: map['cardNumber'],
      startingBalance: (map['startingBalance'] as num?)?.toDouble() ?? 0,
    );
  }
}
