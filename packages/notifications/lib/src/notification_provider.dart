import 'notification_message.dart';

abstract interface class NotificationProvider {
  Future<void> requestPermission();

  Stream<NotificationMessage> get messages;
}
