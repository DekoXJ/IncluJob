import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  Future<User?> registerUsuario({
    required String email,
    required String password,
    required String nombre,
    required String apellidos,
    required int edad,
    required String tipoDiscapacidad,
    required String idConadis,
    required String ubicacion,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = userCredential.user!.uid;

      await _firestore.collection('usuarios').doc(uid).set({
        'nombre': nombre,
        'apellidos': apellidos,
        'edad': edad,
        'tipoDiscapacidad': tipoDiscapacidad,
        'idConadis': idConadis,
        'ubicacion': ubicacion,
      });

      return userCredential.user;
    } catch (e) {
      print('Error en registro usuario: $e');
      return null;
    }
  }

  Future<User?> registerEmpresa({
    required String email,
    required String password,
    required String nombreEmpresa,
    required String gerente,
    required String rubro,
    required String ruc,
    required String ubicacion,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = userCredential.user!.uid;

      await _firestore.collection('empresas').doc(uid).set({
        'nombreEmpresa': nombreEmpresa,
        'gerente': gerente,
        'rubro': rubro,
        'ruc': ruc,
        'ubicacion': ubicacion,
      });

      return userCredential.user;
    } catch (e) {
      print('Error en registro empresa: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}