import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pokemon_model.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool showHeart = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(begin: 1.5, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onFavoritePressed() async {
    setState(() => showHeart = true);
    _animationController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        setState(() => showHeart = false);
      });
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final pokeId = _extractIdFromUrl(widget.pokemon.url);
      await FirebaseFirestore.instance
          .collection('favoritos')
          .doc(user.uid)
          .collection('pokemons')
          .doc(pokeId.toString())
          .set({
            'url': widget.pokemon.url,
            'name': widget.pokemon.name,
            'imageUrl':
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokeId.png',
            'types': widget.pokemon.types,
            'height': widget.pokemon.height,
            'weight': widget.pokemon.weight,
            'abilities': widget.pokemon.abilities,
            'stats': widget.pokemon.stats,
            'timestamp': FieldValue.serverTimestamp(),
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokeIndex = _extractIdFromUrl(widget.pokemon.url);
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokeIndex.png';

    final maxStatValue = 150.0;
    final statLabels = ['HP', 'ATK', 'DEF', 'SpA', 'SpD', 'SPD'];
    final statValues = _extractStatValues(widget.pokemon);
    final radarData = [
      statValues.map((v) => ((v / maxStatValue) * 100).toInt()).toList(),
    ];

    final mainTypeColor = _typeColor(widget.pokemon.types.first);

    return Scaffold(
      backgroundColor: mainTypeColor.withOpacity(0.3),
      appBar: AppBar(
        title: Text(widget.pokemon.name.toUpperCase()),
        backgroundColor: mainTypeColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: _onFavoritePressed,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: mainTypeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.network(
                              imageUrl,
                              height: 160,
                              width: 160,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (_, __, ___) =>
                                      const Icon(Icons.error, size: 100),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            children:
                                widget.pokemon.types
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
                      SizedBox(
                        height: 300,
                        width: 300,
                        child: RadarChart(
                          features: statLabels,
                          data: radarData,
                          ticks: const [20, 50, 80],
                          outlineColor: mainTypeColor,
                          graphColors: [mainTypeColor],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// CUADRO HABILIDADES
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: mainTypeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                        ...widget.pokemon.abilities.map(
                          (a) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(a),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// CUADRO INFO ADICIONAL + STATS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: mainTypeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.pokemon.stats.entries.map((entry) {
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
                        const SizedBox(height: 20),
                        const Text(
                          'Información Adicional',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _infoItem('ID', pokeIndex.toString()),
                            _infoItem(
                              'Altura',
                              '${widget.pokemon.height / 10} m',
                            ),
                            _infoItem(
                              'Peso',
                              '${widget.pokemon.weight / 10} kg',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showHeart)
            Positioned(
              top: 100,
              child: ScaleTransition(
                scale: _animation,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.pinkAccent,
                  size: 60,
                ),
              ),
            ),
        ],
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
  switch (type.toLowerCase()) {
    case 'normal':
      return Colors.brown.shade200;
    case 'fire':
      return Colors.redAccent;
    case 'water':
      return Colors.lightBlue;
    case 'electric':
      return Colors.amber.shade700;
    case 'grass':
      return Colors.green;
    case 'ice':
      return Colors.cyanAccent.shade100;
    case 'fighting':
      return Colors.orange.shade800;
    case 'poison':
      return Colors.purple;
    case 'ground':
      return Colors.brown;
    case 'flying':
      return Colors.indigoAccent.shade100;
    case 'psychic':
      return Colors.pinkAccent;
    case 'bug':
      return Colors.lightGreen;
    case 'rock':
      return Colors.grey.shade700;
    case 'ghost':
      return Colors.deepPurpleAccent;
    case 'dragon':
      return Colors.deepPurple;
    case 'dark':
      return Colors.black54;
    case 'steel':
      return Colors.blueGrey;
    case 'fairy':
      return Colors.pink.shade200;
    default:
      return Colors.grey.shade300;
  }
}
