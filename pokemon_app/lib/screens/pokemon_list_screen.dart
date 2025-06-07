import 'package:flutter/material.dart';
import '../services/pokeapi_service.dart';
import '../models/pokemon_model.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  late Future<List<Pokemon>> _pokemonList;

  @override
  void initState() {
    super.initState();
    _pokemonList = PokeApiService().fetchPokemons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pokémon')),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final pokemons = snapshot.data!;
          return ListView.builder(
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final p = pokemons[index];
              return ListTile(
                title: Text(p.name.toUpperCase()),
                subtitle: Text(p.url),
              );
            },
          );
        },
      ),
    );
  }
}
    