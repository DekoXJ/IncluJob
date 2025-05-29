import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _edadController = TextEditingController();
  final _tipoDiscapacidadController = TextEditingController();
  final _idConadisController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _registrar() async {
    if (_formKey.currentState!.validate()) {
      final error = await _authService.registrarUsuario(
        nombre: _nombreController.text,
        apellidos: _apellidosController.text,
        edad: int.parse(_edadController.text),
        tipoDiscapacidad: _tipoDiscapacidadController.text,
        idConadis: _idConadisController.text,
        ubicacion: _ubicacionController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (error != null) {
        setState(() => _errorMessage = error);
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextFormField(controller: _apellidosController, decoration: const InputDecoration(labelText: 'Apellidos')),
              TextFormField(controller: _edadController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad')),
              TextFormField(controller: _tipoDiscapacidadController, decoration: const InputDecoration(labelText: 'Tipo de Discapacidad')),
              TextFormField(controller: _idConadisController, decoration: const InputDecoration(labelText: 'ID Conadis')),
              TextFormField(controller: _ubicacionController, decoration: const InputDecoration(labelText: 'Ubicación')),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo Electrónico')),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrar,
                child: const Text('Registrar Usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}