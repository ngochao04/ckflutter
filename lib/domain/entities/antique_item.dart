class AntiqueItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final double estimatedValue;
  final String currency;
  final DateTime acquisitionDate;
  final String origin;
  final String period;
  final String condition;
  final List<String> imageUrls;
  final String provenance;
  final Map<String, dynamic> historicalData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const AntiqueItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.estimatedValue,
    required this.currency,
    required this.acquisitionDate,
    required this.origin,
    required this.period,
    required this.condition,
    required this.imageUrls,
    required this.provenance,
    required this.historicalData,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  AntiqueItem copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? estimatedValue,
    String? currency,
    DateTime? acquisitionDate,
    String? origin,
    String? period,
    String? condition,
    List<String>? imageUrls,
    String? provenance,
    Map<String, dynamic>? historicalData,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return AntiqueItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      currency: currency ?? this.currency,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      origin: origin ?? this.origin,
      period: period ?? this.period,
      condition: condition ?? this.condition,
      imageUrls: imageUrls ?? this.imageUrls,
      provenance: provenance ?? this.provenance,
      historicalData: historicalData ?? this.historicalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}