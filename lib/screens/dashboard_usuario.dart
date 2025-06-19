import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'detalle_empleo_screen.dart';
import 'capacitaciones_usuario.dart';
import 'cuestionario_screen.dart';
import 'historial_evaluaciones.dart';

class DashboardUsuario extends StatefulWidget {
  const DashboardUsuario({super.key});

  @override
  State<DashboardUsuario> createState() => _DashboardUsuarioState();
}

class _DashboardUsuarioState extends State<DashboardUsuario> {
  int _selectedIndex = 0;
  late String userId;
  DocumentSnapshot? userDoc;
  String _filtro = '';
  final _searchController = TextEditingController();
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
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _filtro = value.toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Buscar empleo...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFF6DDCC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('ofertas').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              final resultados = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final titulo = data['titulo']?.toString().toLowerCase() ?? '';
                final descripcion = data['descripcion']?.toString().toLowerCase() ?? '';
                return titulo.contains(_filtro) || descripcion.contains(_filtro);
              }).toList();

              if (resultados.isEmpty) {
                return const Center(child: Text('No se encontraron empleos relacionados.'));
              }

              return ListView(
                children: resultados.map((doc) => Card(
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
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluaciones() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: HistorialEvaluaciones(userId: userId),
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
              backgroundColor: Color(0xFF23A393),
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
                  fillColor: const Color(0xFFF6DDCC),
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
              backgroundColor: const Color(0xFF23A393),
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
      _buildEvaluaciones(),
      _buildPerfilUsuario(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6DDCC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1E33),
        title: const Text('Panel Usuario', style: TextStyle(fontFamily: 'Righteous', color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF23A393),
        unselectedItemColor: Color(0xFFF28C57),
        selectedLabelStyle: const TextStyle(fontFamily: 'Righteous'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Righteous'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Ofertas'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Capacitaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Evaluación'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}