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

  Widget _buildPostulantes() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final postulantes = snapshot.data!.docs;
        return ListView(
          children: postulantes.map((post) => Card(
            color: const Color(0xFFEAF2F8),
            child: ListTile(
              title: Text(post['nombre'], style: const TextStyle(fontFamily: 'Righteous')),
              subtitle: Text('${post['tipoDiscapacidad']} - ${post['especialidad']}', style: const TextStyle(fontFamily: 'Righteous')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetallePostulanteScreen(postulante: post.data() as Map<String, dynamic>),
                  ),
                );
              },
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildFormularioOferta() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          _customField('Título del puesto', _tituloController),
          _customField('Descripción', _descController),
          _customField('Requisitos', _requisitosController),
          _customField('Modalidad', _modalidadController),
          _customField('Salario', _salarioController),
          _customField('Ubicación', _ubicacionController),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _publicarOferta,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E86C1),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontFamily: 'Righteous', fontSize: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Publicar Oferta'),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacitaciones() {
    return Column(
      children: [
        const Text('Publicar nueva capacitación', style: TextStyle(fontSize: 20, fontFamily: 'Righteous', color: Color(0xFF2C3E50))),
        const SizedBox(height: 10),
        Form(
          key: _capFormKey,
          child: Column(
            children: [
              _customField('Título', _capTituloController),
              _customField('Plataforma', _capPlataformaController),
              _customField('Enlace', _capLinkController),
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
        const Text('Capacitaciones publicadas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Righteous')),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('capacitaciones').orderBy('fecha', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return ListView(
                children: docs.map((doc) => Card(
                  color: const Color(0xFFEAF2F8),
                  child: ListTile(
                    title: Text(doc['titulo'] ?? 'Sin título', style: const TextStyle(fontFamily: 'Righteous')),
                    subtitle: Text('Plataforma: ${doc['plataforma'] ?? 'No especificada'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => Clipboard.setData(ClipboardData(text: doc['link'] ?? '')),
                    ),
                  ),
                )).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPerfilEmpresa() {
    if (empresaDoc == null) return const Center(child: CircularProgressIndicator());
    if (!empresaDoc!.exists) return const Center(child: Text('Perfil no encontrado.'));
    final data = empresaDoc!.data() as Map<String, dynamic>;
    return ListView(
      children: [
        const SizedBox(height: 20),
        const Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF2C3E50),
            child: Icon(Icons.business, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        _perfilText('Nombre Empresa', data['nombreEmpresa']),
        _perfilText('Correo Electrónico', data['email']),
        _perfilText('Gerente', data['gerente']),
        _perfilText('Rubro', data['rubro']),
        _perfilText('RUC', data['ruc']),
        _perfilText('Ubicación', data['ubicacion']),
      ],
    );
  }

  Widget _perfilText(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text('$label: ${value ?? "No disponible"}', style: const TextStyle(fontSize: 16, fontFamily: 'Righteous')),
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
      backgroundColor: const Color(0xFFD4E6F1),
      appBar: AppBar(
        title: const Text('Panel Empresa', style: TextStyle(fontFamily: 'Righteous', color: Colors.white)),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF2C3E50),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontFamily: 'Righteous'),
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