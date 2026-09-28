class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.body,
    required this.sentAt,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String body;
  final DateTime sentAt;
}
