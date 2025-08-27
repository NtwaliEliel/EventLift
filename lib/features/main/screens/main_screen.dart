import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/providers/auth_provider.dart';
import '../../../common/models/user_model.dart';
import '../../services/screens/service_marketplace_screen.dart';
import '../../services/screens/my_services_screen.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../widgets/profile_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _MainScreenContent(user: user);
  }
}

class _MainScreenContent extends ConsumerStatefulWidget {
  final UserModel user;
  
  const _MainScreenContent({required this.user});

  @override
  ConsumerState<_MainScreenContent> createState() => _MainScreenContentState();
}

class _MainScreenContentState extends ConsumerState<_MainScreenContent> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens;
  late final List<BottomNavigationBarItem> _bottomNavItems;

  @override
  void initState() {
    super.initState();
    
    if (widget.user.role == UserRole.provider) {
      _screens = [
        const MyServicesScreen(),
        const BookingsScreen(),
        const ChatListScreen(),
        const ProfileScreen(),
      ];
      
      _bottomNavItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'My Services',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_online),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      _screens = [
        const ServiceMarketplaceScreen(),
        const BookingsScreen(),
        const ChatListScreen(),
        const ProfileScreen(),
      ];
      
      _bottomNavItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_online),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        items: _bottomNavItems,
      ),
    );
  }
}
