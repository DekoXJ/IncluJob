import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegistroEmpresaScreen extends StatefulWidget {
  const RegistroEmpresaScreen({super.key});

  @override
  State<RegistroEmpresaScreen> createState() => _RegistroEmpresaScreenState();
}

class _RegistroEmpresaScreenState extends State<RegistroEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nombreEmpresaController = TextEditingController();
  final _gerenteController = TextEditingController();
  final _rubroController = TextEditingController();
  final _rucController = TextEditingController();
  final _escalaController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _registrar() async {
    if (_formKey.currentState!.validate()) {
      final error = await _authService.registrarEmpresa(
        nombreEmpresa: _nombreEmpresaController.text,
        gerente: _gerenteController.text,
        rubro: _rubroController.text,
        ruc: _rucController.text,
        escala: _escalaController.text,
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
      appBar: AppBar(title: const Text('Registro de Empresa')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              TextFormField(controller: _nombreEmpresaController, decoration: const InputDecoration(labelText: 'Nombre de la Empresa')),
              TextFormField(controller: _gerenteController, decoration: const InputDecoration(labelText: 'Nombre del Gerente')),
              TextFormField(controller: _rubroController, decoration: const InputDecoration(labelText: 'Rubro')),
              TextFormField(controller: _rucController, decoration: const InputDecoration(labelText: 'RUC')),
              TextFormField(controller: _escalaController, decoration: const InputDecoration(labelText: 'Escala')),
              TextFormField(controller: _ubicacionController, decoration: const InputDecoration(labelText: 'Ubicación')),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo Electrónico')),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrar,
                child: const Text('Registrar Empresa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}