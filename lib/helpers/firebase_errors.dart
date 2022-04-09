import 'dart:developer' as devtools show log;

void firebaseError(String code) {
  switch (code) {
    case "user-not-found":
      devtools.log("User not found");
      break;

    case "wrong-password":
      devtools.log("Wrong password");
      break;

    case "weak-password-found":
      devtools.log("Weak Password");
      break;

    case "email-already-in-use":
      devtools.log("This email is already in use");
      break;

    case "invalid-email":
      devtools.log("This email is invalid");
      break;

    default:
      devtools.log("something else happen");
      devtools.log(code);
  }
}
