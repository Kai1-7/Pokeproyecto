// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'PokemonDetailScreen.dart';
import '../models/pokemon_model.dart';
import '../services/pokeapi_service.dart';
import '../main.dart';

//LOS CHIPS DENTRO DEL WRAP (LOS QUE MUESTRAN LOS TIPOS) NO SON RESPONSIVE Y ESO DEBE CORREGIRSE

class PokemonListScreen extends StatefulWidget {
  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Pokemon> _allBasicPokemons = []; // Solo nombre + url
  List<Pokemon> _visiblePokemons = []; // Lista con detalles
  Map<String, Pokemon> _cache = {}; // Evita recargar detalles repetidos

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
      final newList = await PokeApiService().fetchPokemons(
        offset: _offset,
        limit: limit,
      );
      _offset += limit;
      setState(() => _visiblePokemons.addAll(newList));
    } catch (e) {
      print('Error al cargar pokémones: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchAndDisplayDetails(String query) async {
    final matches =
        _allBasicPokemons
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
        backgroundColor: Colors.deepPurple,
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
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text("Menú"),
            ),
            ListTile(
              title: const Text("Home"),
              onTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading && _visiblePokemons.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3 / 4,
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
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow.shade700;
      case 'psychic':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokeIndex = _extractIdFromUrl(pokemon.url);
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokeIndex.png';

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
      ),
    );
  }
}
