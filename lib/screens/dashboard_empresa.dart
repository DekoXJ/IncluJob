import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detalle_postulante_screen.dart';
import 'capacitaciones_empresa.dart';

class DashboardEmpresa extends StatefulWidget {
  const DashboardEmpresa({super.key});

  @override
  State<DashboardEmpresa> createState() => _DashboardEmpresaState();
}

class _DashboardEmpresaState extends State<DashboardEmpresa> {
  int _selectedIndex = 0;
  late String empresaId;
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  final _requisitosController = TextEditingController();
  final _modalidadController = TextEditingController();
  final _salarioController = TextEditingController();
  final _ubicacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    empresaId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _publicarOferta() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('ofertas').add({
        'titulo': _tituloController.text,
        'descripcion': _descController.text,
        'requisitos': _requisitosController.text,
        'modalidad': _modalidadController.text,
        'salario': _salarioController.text,
        'ubicacion': _ubicacionController.text,
        'empresaId': empresaId,
        'fechaPublicacion': Timestamp.now(),
      });
      _tituloController.clear();
      _descController.clear();
      _requisitosController.clear();
      _modalidadController.clear();
      _salarioController.clear();
      _ubicacionController.clear();
    }
  }

  Widget _buildPostulantes() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final postulantes = snapshot.data!.docs;
        return ListView(
          children: postulantes.map((post) => ListTile(
            title: Text(post['nombre']),
            subtitle: Text('${post['tipoDiscapacidad']} - ${post['especialidad']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetallePostulanteScreen(postulante: post.data() as Map<String, dynamic>),
                ),
              );
            },
          )).toList(),
        );
      },
    );
  }

  Widget _buildFormularioOferta() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(controller: _tituloController, decoration: const InputDecoration(labelText: 'Título del puesto')),
          TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Descripción')),
          TextFormField(controller: _requisitosController, decoration: const InputDecoration(labelText: 'Requisitos')),
          TextFormField(controller: _modalidadController, decoration: const InputDecoration(labelText: 'Modalidad')),
          TextFormField(controller: _salarioController, decoration: const InputDecoration(labelText: 'Salario')),
          TextFormField(controller: _ubicacionController, decoration: const InputDecoration(labelText: 'Ubicación')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _publicarOferta, child: const Text('Publicar Oferta')),
        ],
      ),
    );
  }

  Widget _buildPerfilEmpresa() {
    return const Center(child: Text('Perfil editable en desarrollo'));
  }

  List<Widget> get _pages => [
        _buildPostulantes(),
        _buildFormularioOferta(),
        const CapacitacionesEmpresa(),
        _buildPerfilEmpresa(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empresa')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Postulantes'),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Nueva Oferta'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Capacitaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Perfil'),
        ],
      ),
    );
  }
}