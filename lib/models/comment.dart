class Comment {
  final String id;
  final String celebType;
  final String text;
  final String type; // "toxic" | "positive"
  final int difficulty;
  final int likesMin;
  final int likesMax;
  final double damageWeight;
  final List<String> tags;
  final String language;
  final bool eventOnly;

  const Comment({
    required this.id,
    required this.celebType,
    required this.text,
    required this.type,
    required this.difficulty,
    required this.likesMin,
    required this.likesMax,
    required this.damageWeight,
    required this.tags,
    required this.language,
    this.eventOnly = false,
  });

  bool get isToxic => type == 'toxic';

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      celebType: json['celeb_type'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
      difficulty: json['difficulty'] as int,
      likesMin: json['likes_min'] as int,
      likesMax: json['likes_max'] as int,
      damageWeight: (json['damage_weight'] as num).toDouble(),
      tags: List<String>.from(json['tags'] as List),
      language: json['language'] as String,
      eventOnly: json['event_only'] as bool? ?? false,
    );
  }
}
