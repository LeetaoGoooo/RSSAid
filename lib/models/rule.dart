class Rule {
  final String title;
  final String docs;
  final List<String> source;
  final String? target;
  Rule({required this.title, required this.docs, required this.source, required this.target});
}

class Position {
  final String origin;
  final List<int> replacePositions;
  final List<String> strings;
  Position({required this.origin, required this.replacePositions, required this.strings});
}