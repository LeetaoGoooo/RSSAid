import 'package:equatable/equatable.dart';

class Radar extends Equatable{
  final String? title;
  final String? path;
  final bool isRssHub;
  final String? docs;

  Radar({required this.title, this.path, this.isRssHub = true, this.docs});

  factory Radar.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return Radar(title: "");
    return Radar(
      title: json['title'],
      path: json['path'],
      isRssHub: json['isRssHub'] == null ? true : json['isRssHub'],
      docs: json['docs'],
    );
  }

  static List<Radar> listFromJson(List<dynamic> json) {
    return json.isEmpty
        ? []
        : json.map((value) => Radar.fromJson(value)).toList();
  }

  @override
  List<Object?> get props => [title, path];

}
