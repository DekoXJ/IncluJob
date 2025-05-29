import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/auth_service.dart';

class LoginUsuarioScreen extends StatefulWidget {
  const LoginUsuarioScreen({super.key});

  @override
  State<LoginUsuarioScreen> createState() => _LoginUsuarioScreenState();
}

class _LoginUsuarioScreenState extends State<LoginUsuarioScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _speech = stt.SpeechToText();
  bool _isListening = false;
  String? _errorMessage;

  void _login() async {
    final error = await _authService.iniciarSesion(
      _emailController.text,
      _passwordController.text,
    );
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      Navigator.pushReplacementNamed(context, '/dashboardUsuario');
    }
  }

  void _listen() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          final result = val.recognizedWords.toLowerCase();
          if (result.contains('@')) {
            _emailController.text = result;
          } else if (result.contains('contraseña')) {
            _passwordController.text = '123456';
          }
          _speech.stop();
          setState(() => _isListening = false);
        },
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: true,
          partialResults: false,
        ),
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Iniciar Sesión')),
            ElevatedButton.icon(
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? 'Escuchando...' : 'Ingresar por voz'),
              onPressed: _isListening ? null : _listen,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/registroUsuario'),
              child: const Text('¿No tienes cuenta? Regístrate'),
            )
          ],
        ),
      ),
    );
  }
}