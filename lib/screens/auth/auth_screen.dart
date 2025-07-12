import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../welcome_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showWelcome = true;
  bool isLogin = true;

    void startApp() {
    setState(() => showWelcome = false);
  }

  void toggleForm() {
    setState(() => isLogin = !isLogin);
  }

  @override
  Widget build(BuildContext context) {
    if (showWelcome) {
      return WelcomeScreen(onStart: startApp);
    }

    return isLogin
        ? LoginScreen(onToggle: toggleForm)
        : RegisterScreen(onToggle: toggleForm);
  }
}
