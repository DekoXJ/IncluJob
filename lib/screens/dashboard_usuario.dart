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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado correctamente')));
    }
  }

  Widget _buildListaEmpleos() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('ofertas').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView(
          children: docs.map((doc) => ListTile(
            title: Text(doc['titulo']),
            subtitle: Text(doc['ubicacion']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleEmpleoScreen(empleo: doc.data() as Map<String, dynamic>),
                ),
              );
            },
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
          const SizedBox(height: 20),
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 20),
          ..._controllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: entry.value,
                decoration: InputDecoration(
                  labelText: entry.key[0].toUpperCase() + entry.key.substring(1),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _guardarPerfil, child: const Text('Guardar')),
        ],
      ),
    );
  }

  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildListaEmpleos(),
      const CapacitacionesUsuario(),
      _buildPerfilUsuario(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Ofertas'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Capacitaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}