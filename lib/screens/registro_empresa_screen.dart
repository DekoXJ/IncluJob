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

  Widget _buildVoiceField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(fontFamily: 'Righteous'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            ),
          ),
          if (!isPassword)
            const SizedBox(width: 8),
          if (!isPassword)
            IconButton(
              icon: const Icon(Icons.mic, color: Color(0xFFF5B041)),
              onPressed: () => _listen(controller),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4E6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text('Registro Empresa', style: TextStyle(fontFamily: 'Righteous', color: Colors.white)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            const Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFF2C3E50),
                child: Icon(Icons.business, color: Colors.white, size: 50),
              ),
            ),
            const SizedBox(height: 20),
            _buildVoiceField('Correo Electrónico', _email),
            _buildVoiceField('Contraseña', _password, isPassword: true),
            _buildVoiceField('Nombre Empresa', _nombreEmpresa),
            _buildVoiceField('Gerente', _gerente),
            _buildVoiceField('Rubro', _rubro),
            _buildVoiceField('RUC', _ruc),
            _buildVoiceField('Ubicación', _ubicacion),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registrar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 18, fontFamily: 'Righteous'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}