import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}


class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _edadController = TextEditingController();
  final _discapacidadController = TextEditingController();
  final _conadisController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _especialidadController = TextEditingController();
  final _disponibilidadController = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance.collection('usuarios').doc(cred.user!.uid).set({
          'email': _emailController.text,
          'nombre': _nombreController.text,
          'apellidos': _apellidosController.text,
          'edad': _edadController.text,
          'tipoDiscapacidad': _discapacidadController.text,
          'idConadis': _conadisController.text,
          'ubicacion': _ubicacionController.text,
          'especialidad': _especialidadController.text,
          'disponibilidad': _disponibilidadController.text,
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _listen(TextEditingController controller) async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(onResult: (result) {
        setState(() {
          controller.text = result.recognizedWords;
        });
      });
    }
  }

  Widget _buildField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(labelText: label),
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
          ),
        ),
        if (!isPassword)
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () => _listen(controller),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('Correo Electrónico', _emailController),
              _buildField('Contraseña', _passwordController, isPassword: true),
              _buildField('Nombre', _nombreController),
              _buildField('Apellidos', _apellidosController),
              _buildField('Edad', _edadController),
              _buildField('Tipo de Discapacidad', _discapacidadController),
              _buildField('ID Conadis', _conadisController),
              _buildField('Ubicación', _ubicacionController),
              _buildField('Especialidad', _especialidadController),
              _buildField('Disponibilidad', _disponibilidadController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrarUsuario,
                child: const Text('Registrarse'),
              )
            ],
          ),
        ),
      ),
    );
  }
}