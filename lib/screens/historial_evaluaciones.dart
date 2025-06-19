import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cuestionario_screen.dart';

class HistorialEvaluaciones extends StatelessWidget {
  final String userId;
  const HistorialEvaluaciones({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6DDCC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1E33),
        title: const Text('Evaluaciones', style: TextStyle(fontFamily: 'Righteous', color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Selecciona un cuestionario:',
              style: TextStyle(fontFamily: 'Righteous', fontSize: 18)),
          const SizedBox(height: 10),
          ...['Motora', 'Psicosocial', 'Visual', 'Auditiva', 'Intelectual'].map((tipo) => Card(
                color: const Color(0xFFEAF2F8),
                child: ListTile(
                  leading: const Icon(Icons.assignment_turned_in, color: Color(0xFF23A393)),
                  title: Text('Evaluación para Discapacidad $tipo', style: const TextStyle(fontFamily: 'Righteous')),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF2D1E33)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CuestionarioScreen(titulo: 'Discapacidad $tipo'),
                    ),
                  ),
                ),
              )),
          const Divider(height: 30),
          const Text('Historial de evaluaciones:', style: TextStyle(fontFamily: 'Righteous', fontSize: 18)),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('evaluaciones')
                .where('userId', isEqualTo: userId)
                .orderBy('fecha', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Text('No hay evaluaciones registradas.');
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fecha = (data['fecha'] as Timestamp).toDate();
                  return Card(
                    color: const Color(0xFFFDEDEC),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(data['titulo'], style: const TextStyle(fontFamily: 'Righteous')),
                      subtitle: Text('Puntaje: ${data['puntaje']}/20\nResultado: ${data['evaluacion']}\nFecha: ${fecha.toLocal()}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.replay, color: Color(0xFFF28C57)),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CuestionarioScreen(titulo: data['titulo']),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}