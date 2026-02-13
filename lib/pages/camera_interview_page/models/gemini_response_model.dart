// ============================================================================
// GEMINI RESPONSE MODEL - Data Models for API Response
// ============================================================================
// Defines data structures for parsing Gemini AI API responses
// 
// STRUCTURE:
// Post → Candidates[] → Candidate → Content → Parts[] → Part → text
// 
// USAGE:
// - Parses JSON response from Gemini API
// - Extracts AI-generated text from nested structure
// - Provides type-safe access to response data
// 
// NOTE: Currently not actively used in the codebase
// The repository manually parses JSON instead of using these models
// TODO: Refactor GeminiRepository to use these models for type safety
// ============================================================================

import 'dart:convert';

/// Helper function to parse JSON string into Post object
Post postFromJson(String str) => Post.fromJson(json.decode(str));

/// Helper function to convert Post object to JSON string
String postToJson(Post data) => json.encode(data.toJson());

/// Root response object from Gemini API
class Post {
  List<Candidate> candidates; // Array of response candidates

  Post({required this.candidates});

  /// Creates Post from JSON map
  factory Post.fromJson(Map<String, dynamic> json) => Post(
    candidates: List<Candidate>.from(
      json["candidates"].map((x) => Candidate.fromJson(x)),
    ),
  );

  /// Converts Post to JSON map
  Map<String, dynamic> toJson() => {
    "candidates": List<dynamic>.from(candidates.map((x) => x.toJson())),
  };
}

/// Represents a single candidate response from AI
class Candidate {
  final Content content; // The actual content of the response

  Candidate({required this.content});

  /// Creates Candidate from JSON map
  factory Candidate.fromJson(Map<String, dynamic> json) =>
      Candidate(content: Content.fromJson(json["content"]));

  /// Converts Candidate to JSON map
  Map<String, dynamic> toJson() => {"content": content.toJson()};
}

/// Contains the parts and role of the response
class Content {
  final List parts; // Array of text parts
  final String role; // Role: "model" or "user"
  
  Content({required this.parts, required this.role});

  /// Creates Content from JSON map
  factory Content.fromJson(Map<String, dynamic> json) => Content(
    parts: List<Part>.from(json["parts"].map((x) => Part.fromJson(x))),
    role: json["role"],
  );

  /// Converts Content to JSON map
  Map<String, dynamic> toJson() => {
    "parts": List<dynamic>.from(parts.map((x) => x.toJson())),
    "role": role,
  };
}

/// Represents a single text part of the response
class Part {
  String text; // The actual text content

  Part({required this.text});

  /// Creates Part from JSON map
  factory Part.fromJson(Map<String, dynamic> json) => Part(text: json["text"]);

  /// Converts Part to JSON map
  Map<String, dynamic> toJson() => {"text": text};
}
