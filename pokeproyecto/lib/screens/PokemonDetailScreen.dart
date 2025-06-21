import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import '../models/pokemon_model.dart';
//NOTA: HAY QUE IMPEDIR QUE LA IMAGEN Y EL RADAR CHART HAGAN OVERFLOW AL CAMBIAR EL TAMAÑO DE LA PANTALLA

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final pokeIndex = _extractIdFromUrl(pokemon.url);
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokeIndex.png';

    final maxStatValue = 150.0; // Para normalizar los valores en radar chart
    final statLabels = ['HP', 'ATK', 'DEF', 'SpA', 'SpD', 'SPD'];
    final statValues = _extractStatValues(pokemon);
    final radarData = [
      statValues.map((v) => ((v / maxStatValue) * 100).toInt()).toList(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name.toUpperCase()),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) => const Icon(Icons.error, size: 100),
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children:
                          pokemon.types
                              .map(
                                (type) => Chip(
                                  label: Text(type),
                                  backgroundColor: _typeColor(type),
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                SizedBox(
                  height: 300,
                  width: 300,
                  child: RadarChart(
                    features: statLabels,
                    data: radarData,
                    ticks: const [20, 50, 80],
                    outlineColor: Colors.deepPurple,
                    graphColors: const [Colors.deepPurple],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Habilidades',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children:
                            pokemon.abilities
                                .map(
                                  (a) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(a),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        pokemon.stats.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(entry.value.toString()),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Información Adicional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoItem('ID', pokeIndex.toString()),
                _infoItem('Altura', '${pokemon.height / 10} m'),
                _infoItem('Peso', '${pokemon.weight / 10} kg'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

int _extractIdFromUrl(String url) {
  final uri = Uri.parse(url);
  final segments = uri.pathSegments;
  return int.tryParse(segments[segments.length - 2]) ?? 1;
}

List<double> _extractStatValues(Pokemon p) {
  return [
    p.stats['hp'] ?? 0,
    p.stats['attack'] ?? 0,
    p.stats['defense'] ?? 0,
    p.stats['special-attack'] ?? 0,
    p.stats['special-defense'] ?? 0,
    p.stats['speed'] ?? 0,
  ].map((e) => e.toDouble()).toList();
}

Widget _infoItem(String label, String value) {
  return Column(
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(value),
    ],
  );
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
