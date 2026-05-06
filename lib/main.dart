import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screen/login_screen.dart';
import 'screen/home_screen.dart';
import 'service/auth_service.dart';

void main() async {
  // Necesario para usar plugins antes de runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquea la orientación en vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // TEMPORALMENTE DESACTIVADO — para restaurar el auto-login, descomentar las
  // siguientes 2 líneas y cambiar MyApp(isLoggedIn: false) a MyApp(isLoggedIn: isLoggedIn)
  // final authService = AuthService();
  // final isLoggedIn = await authService.isLoggedIn();

  runApp(const MyApp(isLoggedIn: false));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Mezclas',
      debugShowCheckedModeBanner: false, // quita el banner de "debug"

      // Tema global de la app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF8DD2F), // amarillo Control Mezclas
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      // Si hay sesión activa va al home, si no va al login
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}