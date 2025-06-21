import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokeproyecto/screens/pokemon_list_screen.dart';
import 'firebase_options.dart';
import 'auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pokeproyecto/screens/about_screen.dart';
import 'package:pokeproyecto/widgets/custom_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokeproyecto',
      initialRoute: '/landing',
      routes: {
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
        '/landing': (context) => const Landing(),
        '/list': (context) => PokemonListScreen(),
        '/about': (context) => const AboutScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B4CCA)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3B4CCA),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
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
        title: const Text("Pokémon"),
        centerTitle: true,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/banner.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "¿Estás listo para atrapar a los Pokémon más épicos? 🌟 ¡Explora la Pokédex y encuentra a tus favoritos ahora mismo!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF3B4CCA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/list');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B4CCA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("Ver Pokédex"),
            ),
          ],
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
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const Home(); // redirige a Home si ya está logueado
        } else {
          return const Login();
        }
      },
    );
  }
}
