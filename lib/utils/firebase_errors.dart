// lib/utils/firebase_errors.dart
import 'package:firebase_auth/firebase_auth.dart';

String getFirebaseAuthErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'El correo electrónico tiene un formato inválido.';
    case 'user-not-found':
      return 'No se encontró una cuenta con ese correo.';
    case 'wrong-password':
      return 'La contraseña es incorrecta.';
    case 'email-already-in-use':
      return 'Este correo ya está en uso.';
    case 'weak-password':
      return 'La contraseña es muy débil.';
    case 'invalid-credential':
      return 'Las credenciales son incorrectas o han expirado.';
    case 'user-disabled':
      return 'La cuenta ha sido deshabilitada.';
    case 'too-many-requests':
      return 'Demasiados intentos. Intenta más tarde.';
    default:
      return e.message ?? 'Ocurrió un error inesperado.';
  }
}
