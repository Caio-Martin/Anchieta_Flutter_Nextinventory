import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../utils/constants.dart';

/// Serviço responsável por enviar mensagens ao endpoint de IA.
class AiService {
  AiService._();

  static final AiService _instance = AiService._();

  static AiService get instance => AiService._instance;

  final http.Client _client = http.Client();

  /// Envia [prompt] ao endpoint de IA e retorna o texto da resposta.
  /// Lança [Exception] se o token estiver ausente ou a requisição falhar.
  Future<String> sendMessage(String prompt) async {
    final token = AuthService.token;
    if (token == null || token.isEmpty) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }

    final uri = Uri.parse('${AppConstants.aiBaseUrl}/api/ai/chat');

    final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'prompt': prompt}),
      );
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }

    debugPrint('[AiService] chat status=${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Aceita qualquer um dos campos possíveis
      if (data is Map<String, dynamic>) {
        final text =
            data['response'] ??
            data['message'] ??
            data['answer'] ??
            data['content'];
        if (text != null) {
          return text.toString();
        }
      }

      // Fallback: retorna o body cru como string
      return response.body;
    }

    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    throw Exception(
      'Erro na IA: ${response.statusCode} — ${response.body}',
    );
  }
}
