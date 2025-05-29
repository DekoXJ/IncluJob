import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registrarUsuario({
    required String nombre,
    required String apellidos,
    required int edad,
    required String tipoDiscapacidad,
    required String idConadis,
    required String ubicacion,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nombre': nombre,
        'apellidos': apellidos,
        'edad': edad,
        'tipoDiscapacidad': tipoDiscapacidad,
        'idConadis': idConadis,
        'ubicacion': ubicacion,
        'email': email,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> registrarEmpresa({
    required String nombreEmpresa,
    required String gerente,
    required String rubro,
    required String ruc,
    required String escala,
    required String ubicacion,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('empresas').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nombreEmpresa': nombreEmpresa,
        'gerente': gerente,
        'rubro': rubro,
        'ruc': ruc,
        'escala': escala,
        'ubicacion': ubicacion,
        'email': email,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> iniciarSesion(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}