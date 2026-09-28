import 'package:medtoks_notifications/medtoks_notifications.dart';
import 'package:test/test.dart';

void main() {
  test('exports notification message contract without a provider', () {
    const message = NotificationMessage(id: 'notification-id', title: 'Placeholder', body: '');
    expect(message.title, 'Placeholder');
  });
}
