import 'package:flutter/material.dart';

class DashboardEmpresa extends StatefulWidget {
  const DashboardEmpresa({super.key});

  @override
  State<DashboardEmpresa> createState() => _DashboardEmpresaState();
}

class _DashboardEmpresaState extends State<DashboardEmpresa> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Postulantes Disponibles')),
    Center(child: Text('Publicar Nueva Oferta')),
    Center(child: Text('Perfil de Empresa')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empresa')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Postulantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Nueva Oferta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
