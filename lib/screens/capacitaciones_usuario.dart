import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class CapacitacionesUsuario extends StatelessWidget {
  const CapacitacionesUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4E6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text('Capacitaciones', style: TextStyle(fontFamily: 'Righteous', color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('capacitaciones')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay capacitaciones disponibles.',
                style: TextStyle(fontFamily: 'Righteous', fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                color: const Color(0xFFEAF2F8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    data['titulo'] ?? 'Sin título',
                    style: const TextStyle(fontFamily: 'Righteous'),
                  ),
                  subtitle: Text(
                    data['plataforma'] ?? 'Plataforma desconocida',
                    style: const TextStyle(fontFamily: 'Righteous'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, color: Color(0xFF2C3E50)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: data['link'] ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enlace copiado al portapapeles')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}