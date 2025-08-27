import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String customerId;
  final String providerId;
  final String serviceId;
  final DateTime lastMessageTime;
  final String lastMessage;
  final DateTime createdAt;

  ConversationModel({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.createdAt,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      providerId: data['providerId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'providerId': providerId,
      'serviceId': serviceId,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessage': lastMessage,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ConversationModel copyWith({
    String? id,
    String? customerId,
    String? providerId,
    String? serviceId,
    DateTime? lastMessageTime,
    String? lastMessage,
    DateTime? createdAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
