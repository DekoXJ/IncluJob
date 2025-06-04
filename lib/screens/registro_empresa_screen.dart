import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_empresa_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RegistroEmpresaScreen extends StatefulWidget {
  const RegistroEmpresaScreen({super.key});

  @override
  State<RegistroEmpresaScreen> createState() => _RegistroEmpresaScreenState();
}

class _RegistroEmpresaScreenState extends State<RegistroEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  final stt.SpeechToText _speech = stt.SpeechToText();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nombreEmpresa = TextEditingController();
  final _gerente = TextEditingController();
  final _rubro = TextEditingController();
  final _ruc = TextEditingController();
  final _ubicacion = TextEditingController();

  void _registrar() async {
    if (_formKey.currentState!.validate()) {
      final user = await authService.registerEmpresa(
        email: _email.text,
        password: _password.text,
        nombreEmpresa: _nombreEmpresa.text,
        gerente: _gerente.text,
        rubro: _rubro.text,
        ruc: _ruc.text,
        ubicacion: _ubicacion.text,
      );
      if (user != null && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginEmpresaScreen()));
      }
    }
  }

  void _listen(TextEditingController controller) async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(onResult: (val) {
          setState(() => controller.text = val.recognizedWords);
        });
      }
    } else {
      _speech.stop();
    }
  }

  Widget _buildVoiceField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(child: TextFormField(controller: controller, decoration: InputDecoration(labelText: label))),
        IconButton(onPressed: () => _listen(controller), icon: const Icon(Icons.mic))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Empresa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildVoiceField('Correo Electrónico', _email),
            TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
            _buildVoiceField('Nombre Empresa', _nombreEmpresa),
            _buildVoiceField('Gerente', _gerente),
            _buildVoiceField('Rubro', _rubro),
            _buildVoiceField('RUC', _ruc),
            _buildVoiceField('Ubicación', _ubicacion),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _registrar, child: const Text('Registrarse')),
          ],
        ),
      ),
    );
  }
}