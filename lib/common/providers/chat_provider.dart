import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

final conversationsProvider = StreamProvider.family<List<ConversationModel>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('conversations')
      .where('customerId', isEqualTo: userId)
      .orderBy('lastMessageTime', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList());
});

final providerConversationsProvider = StreamProvider.family<List<ConversationModel>, String>((ref, providerId) {
  return FirebaseFirestore.instance
      .collection('conversations')
      .where('providerId', isEqualTo: providerId)
      .orderBy('lastMessageTime', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList());
});

final messagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList());
});

final chatProvider = StateNotifierProvider<ChatNotifier, AsyncValue<void>>(
  (ref) => ChatNotifier(),
);

class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  ChatNotifier() : super(const AsyncValue.data(null));

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createConversation({
    required String customerId,
    required String providerId,
    required String serviceId,
  }) async {
    try {
      state = const AsyncValue.loading();

      final conversation = ConversationModel(
        id: '',
        customerId: customerId,
        providerId: providerId,
        serviceId: serviceId,
        lastMessageTime: DateTime.now(),
        lastMessage: 'Conversation started',
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('conversations').add(conversation.toFirestore());
      state = const AsyncValue.data(null);
      return docRef.id;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      state = const AsyncValue.loading();

      final message = MessageModel(
        id: '',
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
      );

      // Add message to conversation
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(message.toFirestore());

      // Update conversation last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      });

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<String?> getConversationId({
    required String customerId,
    required String providerId,
    required String serviceId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .where('customerId', isEqualTo: customerId)
          .where('providerId', isEqualTo: providerId)
          .where('serviceId', isEqualTo: serviceId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
