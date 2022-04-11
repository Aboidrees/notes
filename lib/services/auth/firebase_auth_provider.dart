import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/services/auth/auth_user.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_exceptions.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotFoundAuthException();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          throw EmailAlreadyInUseAuthException();
        case "invalid-email":
          throw InvalidEmailAuthException();
        case "weak-password-found":
          throw WeakPasswordAuthException();
        default:
          throw GenaricAuthException();
      }
    } catch (_) {
      throw GenaricAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotFoundAuthException();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          throw UserNotFoundAuthException();
        case "wrong-password":
          throw WrongPasswordAuthException();
        case "invalid-email":
          throw InvalidEmailAuthException();
        default:
          throw GenaricAuthException();
      }
    } catch (_) {
      throw GenaricAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
