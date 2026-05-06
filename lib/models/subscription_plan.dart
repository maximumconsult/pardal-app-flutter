class SubscriptionPlan {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final double monthlyPrice;
  final double? annualPrice;
  final String currency;
  final int maxSpecies;
  final int maxBatches;
  final int maxUsers;
  final bool hasReports;
  final bool hasIncidents;
  final bool hasPriceCalculator;
  final bool hasExport;
  final bool hasNotifications;
  final bool hasApiAccess;
  final bool hasMultiFarm;
  final bool hasPrioritySupport;
  final bool isActive;
  final bool isDefault;
  final int sortOrder;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    required this.monthlyPrice,
    this.annualPrice,
    required this.currency,
    required this.maxSpecies,
    required this.maxBatches,
    required this.maxUsers,
    required this.hasReports,
    required this.hasIncidents,
    required this.hasPriceCalculator,
    required this.hasExport,
    required this.hasNotifications,
    required this.hasApiAccess,
    required this.hasMultiFarm,
    required this.hasPrioritySupport,
    required this.isActive,
    required this.isDefault,
    required this.sortOrder,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      monthlyPrice: double.tryParse(json['monthly_price']?.toString() ?? '0') ?? 0,
      annualPrice: json['annual_price'] != null
          ? double.tryParse(json['annual_price'].toString())
          : null,
      currency: json['currency'] as String? ?? 'MZN',
      maxSpecies: json['max_species'] as int? ?? 0,
      maxBatches: json['max_batches'] as int? ?? 0,
      maxUsers: json['max_users'] as int? ?? 0,
      hasReports: _parseBool(json['has_reports']),
      hasIncidents: _parseBool(json['has_incidents']),
      hasPriceCalculator: _parseBool(json['has_price_calculator']),
      hasExport: _parseBool(json['has_export']),
      hasNotifications: _parseBool(json['has_notifications']),
      hasApiAccess: _parseBool(json['has_api_access']),
      hasMultiFarm: _parseBool(json['has_multi_farm']),
      hasPrioritySupport: _parseBool(json['has_priority_support']),
      isActive: _parseBool(json['is_active']),
      isDefault: _parseBool(json['is_default']),
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  bool get isFree => monthlyPrice == 0;

  String get formattedMonthlyPrice {
    if (isFree) return 'Grátis';
    return '${monthlyPrice.toStringAsFixed(0)} $currency';
  }

  String get formattedAnnualPrice {
    if (isFree) return 'Grátis';
    if (annualPrice == null) return '-';
    return '${annualPrice!.toStringAsFixed(0)} $currency';
  }

  double? get annualSavings {
    if (annualPrice == null || monthlyPrice == 0) return null;
    final yearlyFromMonthly = monthlyPrice * 12;
    return yearlyFromMonthly - annualPrice!;
  }
}
