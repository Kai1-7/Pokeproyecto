class Pokemon {
  final String name;
  final String url;
  final String imageUrl;
  final List<String> types;
  final List<String> abilities;
  final Map<String, int> stats;
  final int height;
  final int weight;

  Pokemon({
    required this.name,
    required this.url,
    required this.imageUrl,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.height,
    required this.weight,
  });

  factory Pokemon.fromBasicJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      url: json['url'],
      imageUrl: '',
      types: [],
      abilities: [],
      stats: {},
      height: 0,
      weight: 0,
    );
  }

  factory Pokemon.fromDetailJson(
    Map<String, dynamic> json, {
    required String url,
  }) {
    final typesList =
        (json['types'] as List)
            .map<String>((t) => t['type']['name'] as String)
            .toList();

    final abilitiesList =
        (json['abilities'] as List)
            .map<String>((a) => a['ability']['name'] as String)
            .toList();

    final statsMap = <String, int>{};
    for (var s in json['stats']) {
      final name = s['stat']['name'] as String;
      final value = s['base_stat'] as int;
      statsMap[name] = value;
    }

    return Pokemon(
      name: json['name'],
      url: url,
      imageUrl: json['sprites']['front_default'] ?? '',
      types: typesList,
      abilities: abilitiesList,
      stats: statsMap,
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
    );
  }
}
