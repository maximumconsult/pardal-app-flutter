import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;

  Future<String?> get token async {
    _token ??= await _storage.read(key: 'auth_token');
    return _token;
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: 'auth_token');
  }

  Future<Map<String, String>> _headers() async {
    final t = await token;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem ligação à internet. Verifique a sua conexão.', 0);
    } on http.ClientException {
      throw ApiException('Não foi possível contactar o servidor.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de comunicação: ${e.toString()}', 0);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
        headers: await _headers(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem ligação à internet. Verifique a sua conexão.', 0);
    } on http.ClientException {
      throw ApiException('Não foi possível contactar o servidor.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de comunicação: ${e.toString()}', 0);
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
        headers: await _headers(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem ligação à internet. Verifique a sua conexão.', 0);
    } on http.ClientException {
      throw ApiException('Não foi possível contactar o servidor.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de comunicação: ${e.toString()}', 0);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    // Verificar se a resposta é JSON válido (não HTML)
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('text/html') || response.body.trimLeft().startsWith('<!')) {
      if (response.statusCode == 404) {
        throw ApiException('Recurso não encontrado (404).', 404);
      } else if (response.statusCode == 500) {
        throw ApiException('Erro interno do servidor (500). Tente novamente mais tarde.', 500);
      } else if (response.statusCode == 302 || response.statusCode == 301) {
        throw ApiException('Sessão expirada. Faça login novamente.', 401);
      }
      throw ApiException('O servidor retornou uma resposta inesperada. Verifique o URL da API.', response.statusCode);
    }

    // Tentar decodificar JSON
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Resposta inválida do servidor.', response.statusCode);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      throw ApiException('Sessão expirada. Faça login novamente.', 401);
    } else if (response.statusCode == 422) {
      final errors = body['errors'] as Map<String, dynamic>?;
      final message = body['message'] as String? ?? 'Erro de validação';
      throw ApiException(
        errors != null
            ? errors.values.expand((v) => v as List).join('\n')
            : message,
        422,
      );
    } else {
      throw ApiException(
        body['message'] as String? ?? 'Erro no servidor (${response.statusCode})',
        response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
