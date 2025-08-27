import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceCategory {
  photography,
  catering,
  decoration,
  entertainment,
  transportation,
  other;

  String get categoryDisplayName {
    switch (this) {
      case ServiceCategory.photography:
        return 'Photography';
      case ServiceCategory.catering:
        return 'Catering';
      case ServiceCategory.decoration:
        return 'Decoration';
      case ServiceCategory.entertainment:
        return 'Entertainment';
      case ServiceCategory.transportation:
        return 'Transportation';
      case ServiceCategory.other:
        return 'Other';
    }
  }
}

class ServiceModel {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final double price;
  final ServiceCategory category;
  final List<String> imageUrls;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrls,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      providerId: data['providerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: ServiceCategory.values.firstWhere(
        (e) => e.toString() == 'ServiceCategory.${data['category']}',
        orElse: () => ServiceCategory.other,
      ),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'providerId': providerId,
      'title': title,
      'description': description,
      'price': price,
      'category': category.toString().split('.').last,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ServiceModel copyWith({
    String? id,
    String? providerId,
    String? title,
    String? description,
    double? price,
    ServiceCategory? category,
    List<String>? imageUrls,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
