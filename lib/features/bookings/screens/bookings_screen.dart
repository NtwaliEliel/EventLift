import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/providers/auth_provider.dart';
import '../../../common/providers/bookings_provider.dart';
import '../../../common/models/booking_model.dart';
import '../../../common/models/user_model.dart';
import '../widgets/booking_card.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Bookings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'My Bookings'),
              Tab(text: 'Received'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Bookings Tab (for customers)
            if (currentUser.role == UserRole.customer)
              _buildBookingsList(
                ref.watch(userBookingsProvider(currentUser.id)),
                'bookings',
              )
            else
              _buildBookingsList(
                ref.watch(providerBookingsProvider(currentUser.id)),
                'bookings',
              ),
            
            // Received Bookings Tab (for providers)
            if (currentUser.role == UserRole.provider)
              _buildBookingsList(
                ref.watch(providerBookingsProvider(currentUser.id)),
                'received',
              )
            else
              const Center(
                child: Text('No received bookings for customers'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(AsyncValue<List<BookingModel>> bookingsAsync, String type) {
    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'bookings' ? Icons.book_online : Icons.inbox,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  type == 'bookings' ? 'No bookings yet' : 'No received bookings',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  type == 'bookings' 
                      ? 'Your bookings will appear here'
                      : 'Incoming booking requests will appear here',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: BookingCard(
                booking: booking,
                type: type,
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading bookings',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                color: Colors.red[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
