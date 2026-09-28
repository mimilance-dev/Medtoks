import 'user_identity.dart';

abstract interface class AuthenticationRepository {
  Stream<UserIdentity?> identityChanges();

  Future<void> signOut();
}
