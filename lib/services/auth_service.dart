import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Singleton que gerencia autenticação na API real do NextInventory.
class AuthService {
  AuthService._();

  static final AuthService _instance = AuthService._();

  static AuthService get instance => _instance;

  /// Token de acesso em memória. Null quando não autenticado.
  static String? _token;

  static String? get token => _token;

  final http.Client _client = http.Client();

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Realiza login na API real e armazena o token em memória.
  /// Retorna [true] em caso de sucesso; lança [Exception] em caso de erro.
  Future<bool> login(String username, String password) async {
    final uri = Uri.parse('${AppConstants.authBaseUrl}/api/auth/login');

    final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'password': password,
          'sistemaId': AppConstants.sistemaId,
        }),
      );
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }

    debugPrint('[AuthService] login status=${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken =
          data['accessToken'] ?? data['access_token'] ?? data['token'];

      if (accessToken == null) {
        throw Exception('Token não encontrado na resposta do servidor.');
      }

      _token = accessToken.toString();
      debugPrint('[AuthService] Token salvo: $_token');
      return true;
    }

    if (response.statusCode == 400 || response.statusCode == 401) {
      throw Exception('Usuário ou senha inválidos.');
    }

    throw Exception(
      'Falha no login: ${response.statusCode} — ${response.body}',
    );
  }

  // ─── Registro ─────────────────────────────────────────────────────────────

  /// Registra um novo usuário na API.
  /// Retorna [true] em caso de sucesso; lança [Exception] em caso de erro.
  Future<bool> register({
    required String name,
    required String surname,
    required String login,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConstants.authBaseUrl}/api/register');

    final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'surname': surname,
          'login': login,
          'email': email,
          'password': password,
          'sistemaId': AppConstants.sistemaId,
        }),
      );
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }

    debugPrint('[AuthService] register status=${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception(
      'Falha no registro: ${response.statusCode} — ${response.body}',
    );
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  void logout() {
    _token = null;
    debugPrint('[AuthService] Token removido.');
  }
}
