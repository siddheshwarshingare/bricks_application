import 'package:bricks_application/login_screen.dart';
import 'package:bricks_application/screens/factory/factory/factory_list_screen.dart';
import 'package:bricks_application/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const FactoryListScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
