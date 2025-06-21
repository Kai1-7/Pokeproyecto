import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text("Menú", style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Lista"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/list');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Perfil"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/about');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar sesión"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
