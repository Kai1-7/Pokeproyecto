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
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3164D9), // Fondo azul Pokémon
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logotipo.png', height: 350),
            const SizedBox(height: 40),
            MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: AnimatedScale(
                scale: _isHovering ? 1.07 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/pokebola.png',
                    width: 35,
                    height: 35,
                  ),
                  label: const Text('Iniciar sesión con Google'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFFFBBD08),
                    ), // amarillo
                    foregroundColor: MaterialStateProperty.all(
                      const Color(0xFF3164D9),
                    ), // azul
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    ),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    elevation: MaterialStateProperty.all(6),
                    shadowColor: MaterialStateProperty.all(
                      const Color(0x1AE3350D),
                    ),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.pressed)) {
                        return const Color(0x30E3350D); // rojo con opacidad
                      }
                      return null;
                    }),
                  ),
                  onPressed: () async {
                    final userCredential = await signInWithGoogle();
                    if (userCredential != null && mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Home()),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<UserCredential?> signInWithGoogle() async {
  final googleProvider = GoogleAuthProvider();

  try {
    if (kIsWeb) {
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  } catch (e) {
    print("Error al iniciar sesión con Google: $e");
    return null;
  }
}
