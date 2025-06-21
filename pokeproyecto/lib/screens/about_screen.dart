import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokeproyecto/widgets/custom_drawer.dart';
import '../models/pokemon_model.dart';
import 'PokemonDetailScreen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    final hasPhoto = user?.photoURL != null &&
        user!.photoURL!.isNotEmpty &&
        Uri.tryParse(user.photoURL!)?.hasAbsolutePath == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3B4CCA),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
                    child: Column(
                      children: [
                        hasPhoto
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(user!.photoURL!),
                              )
                            : CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey.shade300,
                                child: Text(
                                  (user?.email != null && user!.email!.isNotEmpty)
                                      ? user.email![0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 16),
                        Text(
                          user?.displayName ?? 'Entrenador sin nombre',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B4CCA),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.email ?? 'Sin correo',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1.5,
                          width: double.infinity,
                          color: const Color(0xFFFFCB05),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '¡Gracias ${user?.displayName ?? 'entrenador'} por usar la PokéApp!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Tus Pokémon Favoritos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B4CCA),
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('favoritos')
                    .doc(userId)
                    .collection('pokemons')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text("Aún no has agregado favoritos."),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3 / 3.8,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      // Previene errores si faltan campos
                      if (data['url'] == null || data['name'] == null) {
                        return const SizedBox.shrink();
                      }

                      final pokemon = Pokemon(
                        name: data['name'],
                        url: data['url'],
                        types: List<String>.from(data['types'] ?? []),
                        height: data['height'] ?? 0,
                        weight: data['weight'] ?? 0,
                        abilities: List<String>.from(data['abilities'] ?? []),
                        stats: Map<String, int>.from(data['stats'] ?? {}),
                        imageUrl: '',
                      );

                      final imageUrl =
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${_extractIdFromUrl(pokemon.url)}.png';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PokemonDetailScreen(pokemon: pokemon),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  imageUrl,
                                  height: 70,
                                  width: 70,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.error),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pokemon.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B4CCA),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: pokemon.types
                                      .map(
                                        (type) => Chip(
                                          label: Text(type),
                                          backgroundColor: Colors.grey.shade400,
                                          labelStyle: const TextStyle(
                                              color: Colors.white),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _extractIdFromUrl(String? url) {
    if (url == null || url.isEmpty) return 1;
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      return int.tryParse(segments[segments.length - 2]) ?? 1;
    } catch (_) {
      return 1;
    }
  }
}