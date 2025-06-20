import 'package:flutter/material.dart';
import '../services/pokeapi_service.dart';
import '../models/pokemon_model.dart';
import '../main.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<Pokemon> _pokemons = [];
  int _offset = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMorePokemons(); // Cargar los primeros 20
  }

  Future<void> _loadMorePokemons() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newPokemons = await PokeApiService().fetchPokemons(offset: _offset);
      setState(() {
        _pokemons.addAll(newPokemons);
        _offset += 20;
      });
    } catch (e) {
      print("Error al cargar más Pokémon: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokémon"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
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
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemCount: _pokemons.length,
              itemBuilder: (context, index) {
                return PokemonCard(pokemon: _pokemons[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child:
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _loadMorePokemons,
                      child: const Text("Cargar más"),
                    ),
          ),
        ],
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final pokeIndex = _extractIdFromUrl(pokemon.url);
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokeIndex.png';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Image.network(
            imageUrl,
            height: 80,
            width: 80,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.error),
          ),
          const SizedBox(height: 10),
          Text(
            pokemon.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children:
                pokemon.types.map((type) {
                  return Chip(
                    label: Text(type),
                    backgroundColor: _typeColor(type),
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  int _extractIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    return int.tryParse(segments[segments.length - 2]) ?? 1;
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow.shade700;
      case 'psychic':
        return Colors.pink;
      // ...otros tipos
      default:
        return Colors.grey;
    }
  }
}
