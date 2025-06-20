import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokeApiService {
  final String baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  Future<List<Pokemon>> fetchPokemons({int offset = 0, int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$baseUrl?offset=$offset&limit=$limit'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cargar la lista de Pokémon');
    }

    final data = jsonDecode(response.body);
    final results = data['results'] as List;

    List<Pokemon> pokemons = [];

    for (var item in results) {
      final name = item['name'];
      final url = item['url'];

      try {
        final detailResponse = await http.get(Uri.parse(url));
        if (detailResponse.statusCode != 200) continue;

        final detailData = jsonDecode(detailResponse.body);
        final pokemon = Pokemon.fromDetailJson(detailData, url: url);
        pokemons.add(pokemon);
      } catch (e) {
        print('Error al cargar detalles de $name: $e');
        continue;
      }
    }
    return pokemons;
  }
}
