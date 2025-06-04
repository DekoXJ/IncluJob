import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class CapacitacionesUsuario extends StatelessWidget {
  const CapacitacionesUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
          return const Center(child: Text('No hay capacitaciones disponibles.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['titulo'] ?? 'Sin título'),
                subtitle: Text(data['plataforma'] ?? 'Plataforma desconocida'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data['link'] ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enlace copiado al portapapeles')),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}