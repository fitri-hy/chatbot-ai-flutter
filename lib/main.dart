import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'chat_response.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.purple,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: MyHomePage(
        title: 'Chatbot App',
        toggleTheme: _toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.toggleTheme});
  final String title;
  final VoidCallback toggleTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String prompt = 'Anda Harus berpura-pura menjadi BotAI yang di kembangkan oleh seorang developer dari I-As.Dev. jawab pertanyaan: ';
  bool _isLoading = false;

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': message});
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://i-as.dev/api/gemini/$prompt$message'),
    );

    if (response.statusCode == 200) {
      final chatResponse = ChatResponse.fromJson(json.decode(response.body));
      setState(() {
        _messages.add({'sender': 'bot', 'text': chatResponse.text});
        _isLoading = false;
      });
    } else {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'Failed to get response from API'});
        _isLoading = false;
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            color: Colors.white,
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['sender'] == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message['sender'] == 'user'
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: message['sender'] == 'user'
                          ? Text(
                        message['text']!,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      )
                          : MarkdownBody(
                        data: message['text']!,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
