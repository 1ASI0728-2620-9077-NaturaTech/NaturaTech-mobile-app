import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/secure_key_manager.dart';
import '../../../plants/domain/models/plant.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotPage extends StatefulWidget {
  final List<Plant> plants;

  const ChatbotPage({super.key, required this.plants});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final List<Map<String, String>> _chatHistory = [];
  late final Dio _dio;
  String? _apiKey;
  bool _isLoading = false;
  bool _initializing = true;

  String _buildSystemPrompt() {
    final buffer = StringBuffer();
    buffer.writeln(
        'Eres PlantBot, un asistente experto en plantas y jardineria. '
        'Respondes en español de forma amigable y concisa. '
        'Ayudas con consejos sobre riego, fertilizacion, plagas, '
        'iluminacion, tipos de suelo y cuidado general de plantas. '
        'Si te preguntan algo fuera del tema de plantas o jardineria, '
        'redirige amablemente la conversacion hacia las plantas. '
        'Usa emojis de plantas ocasionalmente para ser mas amigable.');

    if (widget.plants.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('El usuario tiene las siguientes plantas registradas:');
      for (int i = 0; i < widget.plants.length; i++) {
        final p = widget.plants[i];
        buffer.write('${i + 1}. "${p.name}" - Especie: ${p.species}');
        if (p.humidity.isNotEmpty) {
          final humLabel = switch (p.humidity) {
            'BAJA' => 'Baja',
            'MEDIA' => 'Media',
            'ALTA' => 'Alta',
            _ => p.humidity,
          };
          buffer.write(', Humedad: $humLabel');
        }
        if (p.acquisitionDate.isNotEmpty) {
          buffer.write(', Adquirida: ${p.acquisitionDate}');
        }
        if (p.nextWateringDate.isNotEmpty) {
          buffer.write(', Proximo riego: ${p.nextWateringDate}');
        }
        if (p.description.isNotEmpty) {
          buffer.write(', Descripcion: ${p.description}');
        }
        buffer.writeln();
      }
      buffer.writeln();
      buffer.writeln(
          'Usa esta informacion para dar recomendaciones personalizadas. '
          'Cuando el usuario pregunte sobre sus plantas, refierete a ellas por nombre. '
          'Si notas algo que podria mejorarse (riego, humedad, epoca del año), mencionalo proactivamente.');
    } else {
      buffer.writeln();
      buffer.writeln(
          'El usuario aun no tiene plantas registradas. '
          'Animalo a registrar sus plantas para recibir recomendaciones personalizadas.');
    }

    return buffer.toString();
  }

  @override
  void initState() {
    super.initState();

    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 15),
    ));

    _initChat();
  }

  Future<void> _initChat() async {
    try {
      _apiKey = await sl<SecureKeyManager>().getApiKey();

      _chatHistory.add({
        'role': 'system',
        'content': _buildSystemPrompt(),
      });

      final greeting = widget.plants.isNotEmpty
          ? 'Hola! Soy PlantBot, tu asistente de jardineria. '
              'Veo que tienes ${widget.plants.length} planta${widget.plants.length > 1 ? 's' : ''} registrada${widget.plants.length > 1 ? 's' : ''}. '
              'Preguntame lo que quieras sobre su cuidado!'
          : 'Hola! Soy PlantBot, tu asistente de jardineria. '
              'Preguntame lo que quieras sobre el cuidado de plantas.';

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: greeting, isUser: false));
          _initializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Error al inicializar: $e',
            isUser: false,
          ));
          _initializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _dio.close();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading || _apiKey == null) return;

    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    _chatHistory.add({'role': 'user', 'content': text});

    try {
      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        data: {
          'model': 'llama-3.3-70b-versatile',
          'messages': _chatHistory,
          'temperature': 0.7,
          'max_tokens': 1024,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          validateStatus: (status) => true,
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final reply =
            data['choices']?[0]?['message']?['content'] ?? 'Sin respuesta.';

        _chatHistory.add({'role': 'assistant', 'content': reply});

        setState(() {
          _messages.add(ChatMessage(text: reply, isUser: false));
          _isLoading = false;
        });
      } else {
        _chatHistory.removeLast();
        final errorBody = response.data;
        final errorMsg = errorBody is Map
            ? (errorBody['error']?['message'] ?? '${response.statusCode}')
            : '${response.statusCode}';

        setState(() {
          _messages.add(ChatMessage(
            text: 'Error: $errorMsg',
            isUser: false,
          ));
          _isLoading = false;
        });
      }
      _scrollToBottom();
    } on DioException catch (e) {
      debugPrint("Chatbot DioError: ${e.type} - ${e.message}");
      _chatHistory.removeLast();
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Error de conexion. Verifica tu internet e intenta de nuevo.',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Chatbot error: $e");
      _chatHistory.removeLast();
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Error inesperado: $e',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF2E7D32)
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.smart_toy,
                        size: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.green[300]
                            : Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      'PlantBot',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.green[300]
                            : Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            SelectableText(
              message.text,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, size: 24),
            SizedBox(width: 8),
            Text('PlantBot'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _initializing
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Iniciando PlantBot...'),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(right: 48),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Escribiendo...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Pregunta sobre tus plantas...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: const Color(0xFF2E7D32),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isLoading ? null : _sendMessage,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child:
                            Icon(Icons.send, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
