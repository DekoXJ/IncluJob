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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales inválidas')),
      );
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
      backgroundColor: const Color(0xFFF6DDCC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1E33),
        title: const Text(
          'Login Usuario',
          style: TextStyle(fontFamily: 'Righteous', color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF23A393),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _email,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      labelStyle: TextStyle(fontFamily: 'Righteous'),
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.mic, color: Color(0xFFF28C57)),
                  onPressed: _listenEmail,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(fontFamily: 'Righteous'),
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23A393),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 18, fontFamily: 'Righteous'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _goToRegister,
              child: const Text(
                '¿No tienes cuenta? Regístrate',
                style: TextStyle(fontFamily: 'Righteous', color: Color(0xFF2D1E33)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}