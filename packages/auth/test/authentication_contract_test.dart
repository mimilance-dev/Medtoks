import 'package:medtoks_auth/medtoks_auth.dart';
import 'package:test/test.dart';

void main() {
  test('exports the identity contract', () {
    const identity = UserIdentity(id: 'user-id', email: 'mentee@example.test');
    expect(identity.id, 'user-id');
  });
}
