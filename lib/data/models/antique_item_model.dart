import 'package:hive/hive.dart';
import '../../domain/entities/antique_item.dart';

part 'antique_item_model.g.dart';

@HiveType(typeId: 0)
class AntiqueItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final double estimatedValue;

  @HiveField(5)
  final String currency;

  @HiveField(6)
  final DateTime acquisitionDate;

  @HiveField(7)
  final String origin;

  @HiveField(8)
  final String period;

  @HiveField(9)
  final String condition;

  @HiveField(10)
  final List<String> imageUrls;

  @HiveField(11)
  final String provenance;

  @HiveField(12)
  final Map<dynamic, dynamic> historicalData;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  @HiveField(15)
  final String userId;

  AntiqueItemModel({
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

  // From Entity
  factory AntiqueItemModel.fromEntity(AntiqueItem entity) {
    return AntiqueItemModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      description: entity.description,
      estimatedValue: entity.estimatedValue,
      currency: entity.currency,
      acquisitionDate: entity.acquisitionDate,
      origin: entity.origin,
      period: entity.period,
      condition: entity.condition,
      imageUrls: entity.imageUrls,
      provenance: entity.provenance,
      historicalData: entity.historicalData,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      userId: entity.userId,
    );
  }

  // To Entity
  AntiqueItem toEntity() {
    return AntiqueItem(
      id: id,
      name: name,
      category: category,
      description: description,
      estimatedValue: estimatedValue,
      currency: currency,
      acquisitionDate: acquisitionDate,
      origin: origin,
      period: period,
      condition: condition,
      imageUrls: imageUrls,
      provenance: provenance,
      historicalData: Map<String, dynamic>.from(historicalData),
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
    );
  }

  // From Firebase
  factory AntiqueItemModel.fromFirestore(Map<String, dynamic> json) {
    return AntiqueItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      estimatedValue: (json['estimatedValue'] as num).toDouble(),
      currency: json['currency'] as String,
      acquisitionDate: DateTime.parse(json['acquisitionDate'] as String),
      origin: json['origin'] as String,
      period: json['period'] as String,
      condition: json['condition'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      provenance: json['provenance'] as String,
      historicalData: json['historicalData'] as Map<dynamic, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
    );
  }

  // To Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'estimatedValue': estimatedValue,
      'currency': currency,
      'acquisitionDate': acquisitionDate.toIso8601String(),
      'origin': origin,
      'period': period,
      'condition': condition,
      'imageUrls': imageUrls,
      'provenance': provenance,
      'historicalData': historicalData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
    };
  }
}