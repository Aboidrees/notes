import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;

  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(
      email: user.email,
      isEmailVerified: user.emailVerified,
    );
  }
}
