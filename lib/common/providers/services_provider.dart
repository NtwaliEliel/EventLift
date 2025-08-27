import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

final servicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('services')
      .where('isAvailable', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList());
});

final userServicesProvider = StreamProvider.family<List<ServiceModel>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('services')
      .where('providerId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList());
});

final serviceProvider = StateNotifierProvider<ServiceNotifier, AsyncValue<void>>(
  (ref) => ServiceNotifier(),
);

class ServiceNotifier extends StateNotifier<AsyncValue<void>> {
  ServiceNotifier() : super(const AsyncValue.data(null));

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createService({
    required String providerId,
    required String title,
    required String description,
    required double price,
    required ServiceCategory category,
    required List<String> imageUrls,
  }) async {
    try {
      state = const AsyncValue.loading();

      final service = ServiceModel(
        id: '',
        providerId: providerId,
        title: title,
        description: description,
        price: price,
        category: category,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('services').add(service.toFirestore());
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateService({
    required String serviceId,
    String? title,
    String? description,
    double? price,
    ServiceCategory? category,
    List<String>? imageUrls,
    bool? isAvailable,
  }) async {
    try {
      state = const AsyncValue.loading();

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (category != null) updates['category'] = category.toString().split('.').last;
      if (imageUrls != null) updates['imageUrls'] = imageUrls;
      if (isAvailable != null) updates['isAvailable'] = isAvailable;

      await _firestore.collection('services').doc(serviceId).update(updates);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      state = const AsyncValue.loading();
      await _firestore.collection('services').doc(serviceId).delete();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
