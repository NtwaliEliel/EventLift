import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

final userBookingsProvider = StreamProvider.family<List<BookingModel>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .where('customerId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList());
});

final providerBookingsProvider = StreamProvider.family<List<BookingModel>, String>((ref, providerId) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .where('providerId', isEqualTo: providerId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList());
});

final bookingProvider = StateNotifierProvider<BookingNotifier, AsyncValue<void>>(
  (ref) => BookingNotifier(),
);

class BookingNotifier extends StateNotifier<AsyncValue<void>> {
  BookingNotifier() : super(const AsyncValue.data(null));

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBooking({
    required String customerId,
    required String providerId,
    required String serviceId,
    required DateTime requestedDate,
    String? specialRequirements,
  }) async {
    try {
      state = const AsyncValue.loading();

      final booking = BookingModel(
        id: '',
        customerId: customerId,
        providerId: providerId,
        serviceId: serviceId,
        requestedDate: requestedDate,
        specialRequirements: specialRequirements,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('bookings').add(booking.toFirestore());
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    try {
      state = const AsyncValue.loading();

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      state = const AsyncValue.loading();
      await updateBookingStatus(
        bookingId: bookingId,
        status: BookingStatus.cancelled,
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
