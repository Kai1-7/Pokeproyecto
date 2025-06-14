import 'package:flutter/material.dart';
import '../services/pokeapi_service.dart';
import '../models/pokemon_model.dart';
import '../main.dart';

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
                //subtitle: Text(p.url),
              );
            },
          );
        },
      ),
    );
  }
}
