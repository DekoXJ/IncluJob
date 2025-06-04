import 'package:flutter/material.dart';

class DetallePostulanteScreen extends StatelessWidget {
  final Map<String, dynamic> postulante;

  const DetallePostulanteScreen({super.key, required this.postulante});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Postulante')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${postulante['nombre']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Especialidad: ${postulante['especialidad']}'),
            Text('Discapacidad: ${postulante['tipoDiscapacidad']}'),
            Text('Edad: ${postulante['edad']} años'),
            Text('Disponibilidad: ${postulante['disponibilidad']}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver a Postulantes'),
            ),
          ],
        ),
      ),
    );
  }
}