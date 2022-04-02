// ignore_for_file: avoid_print

void firebaseError(String code) {
  switch (code) {
    case "user-not-found":
      print("User not found");
      break;

    case "wrong-password":
      print("Wrong password");
      break;

    case "weak-password-found":
      print("Weak Password");
      break;

    case "email-already-in-use":
      print("This email is already in use");
      break;

    case "invalid-email":
      print("This email is invalid");
      break;

    default:
      print("something else happen");
      print(code);
  }
}
