import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'detalle_postulante_screen.dart';

class DashboardEmpresa extends StatefulWidget {
  const DashboardEmpresa({super.key});

  @override
  State<DashboardEmpresa> createState() => _DashboardEmpresaState();
}

class _DashboardEmpresaState extends State<DashboardEmpresa> {
  int _selectedIndex = 0;
  late String empresaId;
  DocumentSnapshot? empresaDoc;

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  final _requisitosController = TextEditingController();
  final _modalidadController = TextEditingController();
  final _salarioController = TextEditingController();
  final _ubicacionController = TextEditingController();

  final _capTituloController = TextEditingController();
  final _capPlataformaController = TextEditingController();
  final _capLinkController = TextEditingController();
  final _capFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    empresaId = FirebaseAuth.instance.currentUser!.uid;
    _fetchEmpresaData();
  }

  Future<void> _fetchEmpresaData() async {
    final snapshot = await FirebaseFirestore.instance.collection('empresas').doc(empresaId).get();
    setState(() => empresaDoc = snapshot);
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

  Future<void> _publicarCapacitacion() async {
    if (_capFormKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('capacitaciones').add({
        'titulo': _capTituloController.text.trim(),
        'plataforma': _capPlataformaController.text.trim(),
        'link': _capLinkController.text.trim(),
        'fecha': Timestamp.now(),
      });
      _capTituloController.clear();
      _capPlataformaController.clear();
      _capLinkController.clear();
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

  Widget _buildCapacitaciones() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Publicar nueva capacitación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Form(
            key: _capFormKey,
            child: Column(
              children: [
                TextFormField(controller: _capTituloController, decoration: const InputDecoration(labelText: 'Título')),
                TextFormField(controller: _capPlataformaController, decoration: const InputDecoration(labelText: 'Plataforma')),
                TextFormField(controller: _capLinkController, decoration: const InputDecoration(labelText: 'Enlace')),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: _publicarCapacitacion, child: const Text('Publicar capacitación')),
              ],
            ),
          ),
          const Divider(height: 30),
          const Text('Capacitaciones publicadas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('capacitaciones').orderBy('fecha', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView(
                  children: docs.map((doc) => ListTile(
                    title: Text(doc['titulo'] ?? 'Sin título'),
                    subtitle: Text('Plataforma: ${doc['plataforma'] ?? 'No especificada'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => Clipboard.setData(ClipboardData(text: doc['link'] ?? '')),
                    ),
                  )).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfilEmpresa() {
    if (empresaDoc == null) return const Center(child: CircularProgressIndicator());

    if (!empresaDoc!.exists) {
      return const Center(child: Text('Perfil no encontrado.'));
    }

    final data = empresaDoc!.data() as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Center(
          child: CircleAvatar(
            radius: 50,
            child: Icon(Icons.business, size: 50),
          ),
        ),
        const SizedBox(height: 20),
        Text('Nombre Empresa: ${data['nombreEmpresa'] ?? 'No disponible'}'),
        Text('Correo Electrónico: ${data['email'] ?? 'No disponible'}'),
        Text('Gerente: ${data['gerente'] ?? 'No disponible'}'),
        Text('Rubro: ${data['rubro'] ?? 'No disponible'}'),
        Text('RUC: ${data['ruc'] ?? 'No disponible'}'),
        Text('Ubicación: ${data['ubicacion'] ?? 'No disponible'}'),
      ].map((widget) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: widget,
      )).toList(),
    );
  }

  List<Widget> get _pages => [
    _buildPostulantes(),
    _buildFormularioOferta(),
    _buildCapacitaciones(),
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