import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/dashboard_usuario.dart';
import 'registro_usuario_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LoginUsuarioScreen extends StatefulWidget {
  const LoginUsuarioScreen({super.key});

  @override
  State<LoginUsuarioScreen> createState() => _LoginUsuarioScreenState();
}

class _LoginUsuarioScreenState extends State<LoginUsuarioScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final authService = AuthService();
  final stt.SpeechToText _speech = stt.SpeechToText();

  void _login() async {
    final user = await authService.login(_email.text, _password.text);
    if (user != null && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardUsuario()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credenciales inválidas')));
    }
  }

  void _goToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroUsuarioScreen())).then((_) {
      setState(() {});
    });
  }

  void _listenEmail() async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(onResult: (val) {
          setState(() => _email.text = val.recognizedWords);
        });
      }
    } else {
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _email, decoration: const InputDecoration(labelText: 'Correo'))),
                IconButton(onPressed: _listenEmail, icon: const Icon(Icons.mic))
              ],
            ),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Iniciar sesión')),
            TextButton(onPressed: _goToRegister, child: const Text('¿No tienes cuenta? Regístrate')),
          ],
        ),
      ),
    );
  }
}