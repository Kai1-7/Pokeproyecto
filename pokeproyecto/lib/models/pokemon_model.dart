class Pokemon {
  final String name;
  final String url;
  final String imageUrl;
  final List<String> types;

  Pokemon({
    required this.name,
    required this.url,
    required this.imageUrl,
    required this.types,
  });

  factory Pokemon.fromBasicJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      url: json['url'],
      imageUrl: '', // Se llena después al hacer el fetch individual
      types: [],
    );
  }

  /// A partir del JSON completo de detalle
  factory Pokemon.fromDetailJson(
    Map<String, dynamic> json, {
    required String url,
  }) {
    final typesList =
        (json['types'] as List)
            .map<String>((t) => t['type']['name'] as String)
            .toList();

    return Pokemon(
      name: json['name'],
      url: url, // <- conservamos la URL original
      imageUrl: json['sprites']['front_default'] ?? '',
      types: typesList,
    );
  }
}
