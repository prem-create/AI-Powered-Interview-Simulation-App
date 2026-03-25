class Message {
  final String role; // "user" or "model"
  final String text;

  Message({
    required this.role,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      "role": role,
      "parts": [
        {"text": text}
      ]
    };
  }
}