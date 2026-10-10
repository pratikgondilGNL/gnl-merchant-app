enum PlanType { basic, professional, enterprise }

class SubscriptionPlan {
  final PlanType type;
  final String title;
  final String price;
  final List<String> features;
  final bool isHighlighted;

  const SubscriptionPlan({
    required this.type,
    required this.title,
    required this.price,
    required this.features,
    this.isHighlighted = false,
  });

  SubscriptionPlan copyWith({
    PlanType? type,
    String? title,
    String? price,
    List<String>? features,
    bool? isHighlighted,
  }) {
    return SubscriptionPlan(
      type: type ?? this.type,
      title: title ?? this.title,
      price: price ?? this.price,
      features: features ?? this.features,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      type: PlanType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PlanType.basic,
      ),
      title: json['title'] as String,
      price: json['price'] as String,
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      isHighlighted: json['isHighlighted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'title': title,
    'price': price,
    'features': features,
    'isHighlighted': isHighlighted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionPlan &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          title == other.title &&
          price == other.price;

  @override
  int get hashCode => Object.hash(type, title, price);

  @override
  String toString() =>
      'SubscriptionPlan(type: $type, title: $title, price: $price)';
}

extension SubscriptionPlanX on SubscriptionPlan {
  String get displayPrice => price;

  static const basic = SubscriptionPlan(
    type: PlanType.basic,
    title: 'Basic',
    price: '₹3,999',
    features: [
      'Up to 100 bookings/month',
      'Basic analytics',
      'Email support',
      'QR code scanner',
      'Easy access',
    ],
  );

  static const professional = SubscriptionPlan(
    type: PlanType.professional,
    title: 'Professional',
    price: '₹7,999',
    features: [
      'Unlimited bookings',
      'Advanced analytics',
      'Priority support 24/7',
      'QR code scanner',
      'Up to 3 venues',
      'Custom branding',
    ],
    isHighlighted: true,
  );

  static const enterprise = SubscriptionPlan(
    type: PlanType.enterprise,
    title: 'Enterprise',
    price: '₹15,999',
    features: [
      'Everything in Pro',
      'Unlimited venues',
      'Dedicated account manager',
      'API access',
      'White-label solution',
      'Custom integrations',
      'Advanced reporting',
    ],
  );

  static List<SubscriptionPlan> get all => [basic, professional, enterprise];
}
