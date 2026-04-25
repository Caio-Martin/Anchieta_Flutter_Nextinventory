import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class IAuthService {
  Future<Map<String, dynamic>> login(String username, String password);
}

class AuthConfig {
  const AuthConfig._();

  static const bool useMock = bool.fromEnvironment(
    'NEXTINVENTORY_AUTH_MOCK',
    defaultValue: false,
  );

  static const String loginUrl = String.fromEnvironment(
    'NEXTINVENTORY_AUTH_URL',
    defaultValue: 'https://dummyjson.com/auth/login',
    // usar esse usuario para logar na api - emilys / emilyspass
  );

  static IAuthService createService() {
    if (useMock) {
      return AuthServiceMock();
    }

    return AuthService(baseUrl: loginUrl);
  }
}

class AuthService implements IAuthService {
  AuthService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _client.post(
        Uri.parse(baseUrl),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username.trim(), 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken =
            data['access_token'] ?? data['accessToken'] ?? data['token'];
        final refreshToken = data['refresh_token'] ?? data['refreshToken'];

        return {
          ...data,
          if (accessToken != null) 'access_token': accessToken,
          if (refreshToken != null) 'refresh_token': refreshToken,
          if (accessToken != null && data['token_type'] == null)
            'token_type': 'Bearer',
        };
      }

      debugPrint(
        'Login rejeitado: status=${response.statusCode}, body=${response.body}',
      );

      if (response.statusCode == 400 || response.statusCode == 401) {
        throw Exception('Usuario ou senha invalidos.');
      }

      throw Exception(
        'Falha no login: ${response.statusCode} - ${response.body}',
      );
    } catch (error) {
      throw Exception('Erro de conexao: $error');
    }
  }
}

class AuthServiceMock implements IAuthService {
  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username.trim() == 'caio' && password == '123456') {
      return {
        'access_token': 'mock-nextinventory-access-token',
        'expires_in': 299,
        'refresh_expires_in': 1799,
        'refresh_token': 'mock-nextinventory-refresh-token',
        'token_type': 'Bearer',
        'session_state': '7da70210-f7c6-49fa-87ca-cfe03f78d885',
        'scope': 'profile email',
      };
    }

    throw Exception('Usuario ou senha invalidos (Mock)');
  }
}
