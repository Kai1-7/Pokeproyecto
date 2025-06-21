import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'PokemonDetailScreen.dart';
import '../models/pokemon_model.dart';
import '../services/pokeapi_service.dart';
import '../widgets/custom_drawer.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Pokemon> _allBasicPokemons = [];
  List<Pokemon> _visiblePokemons = [];
  Map<String, Pokemon> _cache = {};

  bool _isLoading = false;
  bool _isSearching = false;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _loadAllBasicNames();
    _loadMorePokemons();
  }

  Future<void> _loadAllBasicNames() async {
    try {
      final list = await PokeApiService().fetchAllBasicPokemon();
      setState(() => _allBasicPokemons = list);
    } catch (e) {
      print('Error al cargar nombres básicos: $e');
    }
  }

  Future<void> _loadMorePokemons({int limit = 20}) async {
    setState(() => _isLoading = true);
    try {
      final newList = await PokeApiService().fetchPokemons(offset: _offset, limit: limit);
      _offset += limit;
      setState(() => _visiblePokemons.addAll(newList));
    } catch (e) {
      print('Error al cargar pokémones: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchAndDisplayDetails(String query) async {
    final matches = _allBasicPokemons
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    List<Pokemon> detailed = [];
    for (final basic in matches) {
      if (_cache.containsKey(basic.name)) {
        detailed.add(_cache[basic.name]!);
        continue;
      }

      try {
        final resp = await http.get(Uri.parse(basic.url));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          final poke = Pokemon.fromDetailJson(data, url: basic.url);
          detailed.add(poke);
          _cache[basic.name] = poke;
        }
      } catch (e) {
        print('Error al obtener detalles de ${basic.name}: $e');
      }
    }

    setState(() {
      _visiblePokemons = detailed;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _visiblePokemons.clear();
        _offset = 0;
      });
      _loadMorePokemons();
    } else {
      _searchAndDisplayDetails(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B4CCA),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar Pokémon...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.catching_pokemon, color: Color(0xFF3B4CCA)),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "¡Atrapa a tus Pokémon favoritos y crea tu colección! 🧢⚡",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B4CCA),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading && _visiblePokemons.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3 / 3.8,
                    ),
                    itemCount: _visiblePokemons.length,
                    itemBuilder: (context, index) {
                      return PokemonCard(pokemon: _visiblePokemons[index]);
                    },
                  ),
          ),
          if (!_isSearching && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton(
                onPressed: _loadMorePokemons,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC0000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
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

  int _extractIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    return int.tryParse(segments[segments.length - 2]) ?? 1;
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'fire':
        return Colors.redAccent;
      case 'water':
        return Colors.lightBlue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.amber.shade700;
      case 'psychic':
        return Colors.pinkAccent;
      case 'ground':
        return Colors.brown;
      case 'rock':
        return Colors.grey.shade700;
      case 'bug':
        return Colors.lightGreen;
      case 'ice':
        return Colors.cyan;
      case 'dragon':
        return Colors.deepPurple;
      case 'dark':
        return Colors.black54;
      case 'fairy':
        return Colors.pink.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokeIndex = _extractIdFromUrl(pokemon.url);
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokeIndex.png';
    final mainType = pokemon.types.isNotEmpty ? pokemon.types[0] : 'normal';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PokemonDetailScreen(pokemon: pokemon),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _typeColor(mainType),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                pokemon.name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF3B4CCA),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: pokemon.types.map((type) {
                  return Chip(
                    label: Text(type),
                    backgroundColor: _typeColor(type),
                    labelStyle: const TextStyle(color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
