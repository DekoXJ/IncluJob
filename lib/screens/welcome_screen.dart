import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  void _speakAndNavigate(String userType) async {
    await _tts.speak('Has seleccionado iniciar sesión como $userType');
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    if (userType == 'usuario') {
      Navigator.pushNamed(context, '/loginUsuario');
    } else {
      Navigator.pushNamed(context, '/loginEmpresa');
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          final result = val.recognizedWords.toLowerCase();
          if (result.contains('usuario')) {
            _speech.stop();
            _speakAndNavigate('usuario');
          } else if (result.contains('empresa')) {
            _speech.stop();
            _speakAndNavigate('empresa');
          } else {
            _speech.stop();
            setState(() => _isListening = false);
          }
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
      backgroundColor: Colors.teal[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido a IncluJob',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Iniciar sesión como Usuario'),
              onPressed: () => Navigator.pushNamed(context, '/loginUsuario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.business),
              label: const Text('Iniciar sesión como Empresa'),
              onPressed: () => Navigator.pushNamed(context, '/loginEmpresa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? 'Escuchando...' : 'Usar Voz'),
              onPressed: _isListening ? null : _startListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'También puedes decir "USUARIO" o "EMPRESA" para continuar',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}