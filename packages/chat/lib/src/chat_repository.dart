import 'chat_message.dart';

abstract interface class ChatRepository {
  Stream<ChatMessage> watchMessages(String roomId);
}
