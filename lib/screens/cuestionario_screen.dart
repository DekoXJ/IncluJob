import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CuestionarioScreen extends StatefulWidget {
  final String titulo;
  const CuestionarioScreen({super.key, required this.titulo});

  @override
  State<CuestionarioScreen> createState() => _CuestionarioScreenState();
}

class _CuestionarioScreenState extends State<CuestionarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, int> _respuestas = {};

  Future<void> _guardarEvaluacionEnFirestore(int puntaje, String titulo) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    String evaluacion;

    if (puntaje <= 10) {
      evaluacion = 'Ineficiente';
    } else if (puntaje <= 15) {
      evaluacion = 'Aceptable';
    } else {
      evaluacion = 'Eficiente';
    }

    await FirebaseFirestore.instance.collection('evaluaciones').add({
      'userId': userId,
      'titulo': titulo,
      'puntaje': puntaje,
      'evaluacion': evaluacion,
      'fecha': Timestamp.now(),
    });
  }

  void _calcularResultado() async {
    int puntaje = _respuestas.values.fold(0, (a, b) => a + b);
    String resultado;
    if (puntaje <= 10) {
      resultado = 'Ineficiente';
    } else if (puntaje <= 15) {
      resultado = 'Aceptable';
    } else {
      resultado = 'Eficiente';
    }

    await _guardarEvaluacionEnFirestore(puntaje, widget.titulo);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resultado de la evaluación'),
        content: Text('Puntaje: $puntaje/20\nDesempeño: $resultado'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          )
        ],
      ),
    );
  }

  Widget _buildPregunta(int index, String texto) {
    return Card(
      color: const Color(0xFFEAF2F8),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pregunta ${index + 1}: $texto', style: const TextStyle(fontFamily: 'Righteous')),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text('Correcta'),
                    value: 1,
                    groupValue: _respuestas[index],
                    onChanged: (val) => setState(() => _respuestas[index] = val!),
                    activeColor: const Color(0xFF23A393),
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text('Incorrecta'),
                    value: 0,
                    groupValue: _respuestas[index],
                    onChanged: (val) => setState(() => _respuestas[index] = val!),
                    activeColor: const Color(0xFFF28C57),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _generarPreguntasPorTipo(String tipo) {
    return List.generate(20, (i) => 'Pregunta sobre $tipo número ${i + 1}');
  }

  @override
  Widget build(BuildContext context) {
    final preguntas = _generarPreguntasPorTipo(widget.titulo);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1E33),
        title: Text(widget.titulo, style: const TextStyle(color: Colors.white, fontFamily: 'Righteous')),
      ),
      backgroundColor: const Color(0xFFF6DDCC),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...List.generate(20, (index) => _buildPregunta(index, preguntas[index])),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _respuestas.length == 20 ? _calcularResultado : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23A393),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontFamily: 'Righteous', fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Finalizar Evaluación'),
            )
          ],
        ),
      ),
    );
  }
}