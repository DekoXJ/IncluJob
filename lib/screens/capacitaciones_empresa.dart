import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class CapacitacionesEmpresa extends StatefulWidget {
  const CapacitacionesEmpresa({super.key});

  @override
  State<CapacitacionesEmpresa> createState() => _CapacitacionesEmpresaState();
}

class _CapacitacionesEmpresaState extends State<CapacitacionesEmpresa> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _plataformaController = TextEditingController();
  final _linkController = TextEditingController();

  Future<void> _publicarCapacitacion() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('capacitaciones').add({
        'titulo': _tituloController.text.trim(),
        'plataforma': _plataformaController.text.trim(),
        'link': _linkController.text.trim(),
        'fecha': Timestamp.now(),
      });

      _tituloController.clear();
      _plataformaController.clear();
      _linkController.clear();
    }
  }

  void _abrirEnlace(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  Widget _buildListaCapacitaciones() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('capacitaciones')
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              color: const Color(0xFFEAF2F8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(data['titulo'] ?? 'Sin título', style: const TextStyle(fontFamily: 'Righteous')),
                subtitle: Text('Plataforma: ${data['plataforma'] ?? 'Sin plataforma'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_browser, color: Color(0xFF2C3E50)),
                  onPressed: () => _abrirEnlace(data['link']),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _customField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Righteous'),
          filled: true,
          fillColor: const Color(0xFFD6EAF8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4E6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text('Capacitaciones', style: TextStyle(fontFamily: 'Righteous', color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Publicar nueva capacitación',
              style: TextStyle(fontSize: 20, fontFamily: 'Righteous', color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _customField('Título del curso', _tituloController),
                  _customField('Plataforma (Udemy, Platzi, etc.)', _plataformaController),
                  _customField('URL del curso', _linkController),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _publicarCapacitacion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E86C1),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontFamily: 'Righteous', fontSize: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Publicar capacitación'),
                  ),
                ],
              ),
            ),
            const Divider(height: 30),
            const Text(
              'Capacitaciones publicadas:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Righteous'),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildListaCapacitaciones()),
          ],
        ),
      ),
    );
  }
}