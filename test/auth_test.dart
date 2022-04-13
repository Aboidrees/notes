import 'package:flutter_test/flutter_test.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_user.dart';

void main() {
  group("Mock Authentication", () {
    //
    final provider = MockAuthProvidr();
    test("Should not be initialized to brgin with", () {
      expect(provider._isIntialized, false);
    });
    test("Can not log out if not initialized", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test("Should be able to be initialized", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test("User should be null after initialized", () {
      expect(provider.currentUser, null);
    });
    test("Test should be able to initialized in less than 2 seconds", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test("Create user should delegate to login function", () async {
      final badEmailUser = provider.createUser(email: "foo@bar.com", password: "password");
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      final badPasswordUser = provider.createUser(email: "email", password: "foobar");
      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      final user = await provider.createUser(email: "wmail", password: "password");
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test("Logged in user should br sble to get verified", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test("Should be able to login and logout again", () async {
      await provider.logOut();
      await provider.logIn(email: "email", password: "password");

      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvidr implements AuthProvider {
  AuthUser? _user;
  var _isIntialized = false;
  bool get isInitialized => _isIntialized;

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    if (!_isIntialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isIntialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) async {
    if (!_isIntialized) throw NotInitializedException();
    if (email == "foo@bar.com") throw UserNotFoundAuthException();
    if (password == "foobar") throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(_user);
  }

  @override
  Future<void> logOut() async {
    if (!_isIntialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isIntialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
