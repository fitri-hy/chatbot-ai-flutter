class ChatResponse {
  final String text;

  ChatResponse({required this.text});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      text: json['text'],
    );
  }
}
