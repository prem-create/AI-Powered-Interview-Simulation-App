import 'dart:convert';

Post postFromJson(String str) => Post.fromJson(json.decode(str));

class Post {
  final List<Candidate> candidates;

  Post({required this.candidates});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        candidates: List<Candidate>.from(
          json["candidates"].map((x) => Candidate.fromJson(x)),
        ),
      );
}

class Candidate {
  final Content content;

  Candidate({required this.content});

  factory Candidate.fromJson(Map<String, dynamic> json) =>
      Candidate(content: Content.fromJson(json["content"]));
}

class Content {
  final List<Part> parts;
  final String role;

  Content({required this.parts, required this.role});

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        parts: List<Part>.from(
          json["parts"].map((x) => Part.fromJson(x)),
        ),
        role: json["role"],
      );
}

class Part {
  final String text;

  Part({required this.text});

  factory Part.fromJson(Map<String, dynamic> json) =>
      Part(text: json["text"]);
}