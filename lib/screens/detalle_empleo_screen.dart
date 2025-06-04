import 'package:flutter/material.dart';

class DetalleEmpleoScreen extends StatelessWidget {
  final Map<String, dynamic> empleo;

  const DetalleEmpleoScreen({super.key, required this.empleo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Empleo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título: ${empleo['titulo']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Empresa: ${empleo['empresa']}'),
            Text('Ubicación: ${empleo['ubicacion']}'),
            const SizedBox(height: 8),
            Text('Descripción:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(empleo['descripcion'] ?? 'Sin descripción'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver a Ofertas'),
            ),
          ],
        ),
      ),
    );
  }
}