import 'package:flutter/material.dart';

class DetalleEmpleoScreen extends StatelessWidget {
  final Map<String, dynamic> empleo;

  const DetalleEmpleoScreen({super.key, required this.empleo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6DDCC),
      appBar: AppBar(
        title: const Text('Detalle del Empleo', style: TextStyle(fontFamily: 'Righteous', color: Colors.white)),
        backgroundColor: const Color(0xFF2D1E33),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: const Color(0xFFEAF2F8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Título: ${empleo['titulo']}',
                    style: const TextStyle(fontSize: 22, fontFamily: 'Righteous', fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Empresa: ${empleo['empresa'] ?? 'No especificada'}',
                    style: const TextStyle(fontFamily: 'Righteous')),
                Text('Ubicación: ${empleo['ubicacion'] ?? 'No especificada'}',
                    style: const TextStyle(fontFamily: 'Righteous')),
                const SizedBox(height: 20),
                const Text('Descripción:',
                    style: TextStyle(fontFamily: 'Righteous', fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(empleo['descripcion'] ?? 'Sin descripción', style: const TextStyle(fontFamily: 'Righteous')),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23A393),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontFamily: 'Righteous', fontSize: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Volver a Ofertas'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}