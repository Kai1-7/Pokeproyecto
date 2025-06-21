import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokeproyecto/screens/pokemon_list_screen.dart';
import 'firebase_options.dart';
import 'auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokeproyecto',
      initialRoute: '/landing',
      routes: {
        '/login': (context) => Login(), //Pantalla de login
        '/home': (context) => Home(), //Esta pantalla
        '/landing': (context) => Landing(),
        '/list': (context) => PokemonListScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  final String title = "Home";

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokemon"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          //botones
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text("Menú"),
            ),
            ListTile(
              title: Text("Home"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
            ListTile(
              title: Text("Lista"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PokemonListScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PokemonListScreen()),
            );
          },
          child: const Text("Lista"),
        ),
      ),
    );
  }
}

class Landing extends StatelessWidget {
  const Landing({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      //StreamBuilder porque lo que construyamos depende de un stream
      stream:
          FirebaseAuth.instance
              .authStateChanges(), //Depende de esto (el estado de autentificación)
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          //Si lo que devuelve el stream no es nulo
          return PokemonListScreen();
        } else {
          //si es nulo vuelve a login
          return const Login();
        }
      },
    );
  }
}
