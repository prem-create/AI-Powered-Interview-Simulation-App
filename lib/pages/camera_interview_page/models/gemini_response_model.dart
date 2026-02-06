import 'dart:convert';

Post postFromJson(String str) => Post.fromJson(json.decode(str));

String postToJson(Post data) => json.encode(data.toJson());

class Post {
  List<Candidate> candidates;

  Post({required this.candidates});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    candidates: List<Candidate>.from(
      json["candidates"].map((x) => Candidate.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "candidates": List<dynamic>.from(candidates.map((x) => x.toJson())),
  };
}

class Candidate {
  final Content content;

  Candidate({required this.content});

  factory Candidate.fromJson(Map<String, dynamic> json) =>
      Candidate(content: Content.fromJson(json["content"]));

  Map<String, dynamic> toJson() => {"content": content.toJson()};
}

class Content {
  final List parts;
  final String role;
  Content({required this.parts, required this.role});

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    parts: List<Part>.from(json["parts"].map((x) => Part.fromJson(x))),
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "parts": List<dynamic>.from(parts.map((x) => x.toJson())),
    "role": role,
  };
}

class Part {
  String text;

  Part({required this.text});

  factory Part.fromJson(Map<String, dynamic> json) => Part(text: json["text"]);

  Map<String, dynamic> toJson() => {"text": text};
}
