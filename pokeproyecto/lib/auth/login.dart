// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pokeproyecto/main.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login), //falta ICON
          label: const Text("Iniciar sesión con Google"),
          onPressed: () async {
            //lo que se ejecuta al darle al botón
            final userCredential = await signInWithGoogle();
            if (userCredential != null) {
              //Si la función devuelve un user válido, navega a home
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

Future<UserCredential?> signInWithGoogle() async {
  final googleProvider = GoogleAuthProvider();

  try {
    if (kIsWeb) {
      // Si estamos en web, abre el popup y retorna el user
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      // Este es el inicio de sesión para android. Fue extraído de la documentación de firebase
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  } catch (e) {
    print("Error al iniciar sesión con Google: $e");
    return null;
  }
}
