import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pokeproyecto/main.dart';

//Stateful para poder ejecutar initState()
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

//Como al regresar de la página de login se recargará nuestra pantalla, revisamos en el constructor si hay sesión
class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    _checkRedirect(); //
  }

  Future<void> _checkRedirect() async {
    if (kIsWeb) {
      try {
        final userCredential =
            await FirebaseAuth.instance
                .getRedirectResult(); //getRedirectResult() nos permite obtener la información después del signInWithGoogle()
        if (userCredential.user != null) {
          //validamos el userCredential
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ), //Redirige a home
          );
        }
      } catch (e) {
        print('Error al obtener el redirect: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.login),
          label: Text("Google"),
          onPressed: () async {
            if (kIsWeb) {
              await signInWithGoogle(); //ejecutamos el signInWithGoogle(), pero no recuperamos los datos
            } else {
              final userCredential = await signInWithGoogle();
              if (userCredential != null) {
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
  // Create a new provider
  GoogleAuthProvider googleProvider = GoogleAuthProvider();

  if (kIsWeb) {
    await FirebaseAuth.instance.signInWithRedirect(googleProvider);
    return null;
  } else {
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
}
