import 'package:medtoks_chat/medtoks_chat.dart';
import 'package:test/test.dart';

void main() {
  test('exports a chat message contract', () {
    final message = ChatMessage(
      id: 'message-id',
      roomId: 'room-id',
      senderId: 'sender-id',
      body: 'Placeholder',
      sentAt: DateTime.utc(2026),
    );
    expect(message.roomId, 'room-id');
  });
}
