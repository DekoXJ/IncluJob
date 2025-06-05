import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'detalle_empleo_screen.dart';
import 'capacitaciones_usuario.dart';

class DashboardUsuario extends StatefulWidget {
  const DashboardUsuario({super.key});

  @override
  State<DashboardUsuario> createState() => _DashboardUsuarioState();
}

class _DashboardUsuarioState extends State<DashboardUsuario> {
  int _selectedIndex = 0;
  late String userId;
  DocumentSnapshot? userDoc;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'nombre': TextEditingController(),
    'apellidos': TextEditingController(),
    'edad': TextEditingController(),
    'tipoDiscapacidad': TextEditingController(),
    'idConadis': TextEditingController(),
    'ubicacion': TextEditingController(),
    'email': TextEditingController(),
    'especialidad': TextEditingController(),
    'disponibilidad': TextEditingController(),
    'foto': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final snapshot = await FirebaseFirestore.instance.collection('usuarios').doc(userId).get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      _controllers.forEach((key, controller) {
        controller.text = data[key] ?? '';
      });
      setState(() => userDoc = snapshot);
    } else {
      setState(() => userDoc = null);
    }
  }

  Future<void> _guardarPerfil() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        for (var entry in _controllers.entries) entry.key: entry.value.text.trim()
      };
      await FirebaseFirestore.instance.collection('usuarios').doc(userId).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    }
  }

  Widget _buildListaEmpleos() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('ofertas').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView(
          children: docs.map((doc) => Card(
            color: const Color(0xFFEAF2F8),
            child: ListTile(
              title: Text(doc['titulo'], style: const TextStyle(fontFamily: 'Righteous')),
              subtitle: Text(doc['ubicacion'], style: const TextStyle(fontFamily: 'Righteous')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleEmpleoScreen(empleo: doc.data() as Map<String, dynamic>),
                  ),
                );
              },
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildPerfilUsuario() {
    if (userDoc == null) return const Center(child: CircularProgressIndicator());

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const SizedBox(height: 10),
          const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF2C3E50),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          const SizedBox(height: 20),
          ..._controllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextFormField(
                controller: entry.value,
                decoration: InputDecoration(
                  labelText: entry.key[0].toUpperCase() + entry.key.substring(1),
                  labelStyle: const TextStyle(fontFamily: 'Righteous'),
                  filled: true,
                  fillColor: const Color(0xFFD6EAF8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _guardarPerfil,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E86C1),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontFamily: 'Righteous', fontSize: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildListaEmpleos(),
      const CapacitacionesUsuario(),
      _buildPerfilUsuario(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFD4E6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text('Panel Usuario', style: TextStyle(fontFamily: 'Righteous', color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF2C3E50),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontFamily: 'Righteous'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Ofertas'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Capacitaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}