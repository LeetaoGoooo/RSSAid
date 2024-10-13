class Rule {
  final String title;
  final String docs;
  final List<String> source;
  final String? target;
  Rule({required this.title, required this.docs, required this.source, required this.target});
}

class PositionItem {
  final int position;
  final bool optional;
  PositionItem({required this.position, required this.optional});

  Map<String, dynamic> toJson() => {
    "position": this.position,
    "optional": this.optional
  };
}

class Position {
  final String origin;
  final Map<String, PositionItem> replacePositions;
  final List<String> strings;
  Position({required this.origin, required this.replacePositions, required this.strings});
}