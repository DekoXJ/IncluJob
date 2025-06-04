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
            return ListTile(
              title: Text(data['titulo'] ?? 'Sin título'),
              subtitle: Text('${data['plataforma'] ?? 'Sin plataforma'}'),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_browser),
                onPressed: () => _abrirEnlace(data['link']),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _abrirEnlace(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Publicar nueva capacitación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título del curso'),
                  validator: (value) => value!.isEmpty ? 'Ingrese un título' : null,
                ),
                TextFormField(
                  controller: _plataformaController,
                  decoration: const InputDecoration(labelText: 'Plataforma (Udemy, Platzi, etc.)'),
                  validator: (value) => value!.isEmpty ? 'Ingrese una plataforma' : null,
                ),
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(labelText: 'URL del curso'),
                  validator: (value) => value!.isEmpty ? 'Ingrese un enlace válido' : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _publicarCapacitacion,
                  child: const Text('Publicar'),
                ),
              ],
            ),
          ),
          const Divider(height: 30),
          const Text('Capacitaciones publicadas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(child: _buildListaCapacitaciones()),
        ],
      ),
    );
  }
}