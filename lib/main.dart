import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_usuario_screen.dart';
import 'screens/login_empresa_screen.dart';
import 'screens/registro_usuario_screen.dart';
import 'screens/registro_empresa_screen.dart';
import 'screens/dashboard_usuario.dart';
import 'screens/dashboard_empresa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para async en main
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oportunidades Inclusivas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal[50],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/loginUsuario': (context) => const LoginUsuarioScreen(),
        '/loginEmpresa': (context) => const LoginEmpresaScreen(),
        '/registroUsuario': (context) => const RegistroUsuarioScreen(),
        '/registroEmpresa': (context) => const RegistroEmpresaScreen(),
        '/dashboardUsuario': (context) => const DashboardUsuario(),
        '/dashboardEmpresa': (context) => const DashboardEmpresa(),
      },
    );
  }
}