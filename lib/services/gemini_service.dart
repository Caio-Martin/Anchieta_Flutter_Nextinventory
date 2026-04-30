import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServiceException implements Exception {
  GeminiServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

class GeminiItemDetails {
  final String name;
  final String description;

  GeminiItemDetails({required this.name, required this.description});
}

class GeminiService {
  GeminiService._();

  static final GeminiService instance = GeminiService._();

  Future<GeminiItemDetails> generateItemDetailsFromImage(
    Uint8List imageBytes,
    String mimeType,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw GeminiServiceException(
        'Chave de API do Gemini nao configurada. Por favor, adicione GEMINI_API_KEY no arquivo .env',
      );
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

      final prompt = TextPart(
        'Voce e um assistente de cadastro de inventario de TI e equipamentos. '
        'Por favor, analise esta imagem e identifique o objeto. '
        'Retorne o resultado estritamente no seguinte formato: '
        'Nome: <um nome curto para o item>\n'
        'Descricao: <uma descricao curta sobre o item, marca ou caracteristica visivel, maximo 2 frases>',
      );

      final imagePart = DataPart(mimeType, imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw GeminiServiceException('A IA nao retornou nenhuma informacao.');
      }

      String name = 'Item Desconhecido';
      String description = 'Descricao nao disponivel.';

      final lines = text.split('\n');
      for (final line in lines) {
        if (line.toLowerCase().startsWith('nome:')) {
          name = line.substring(5).trim();
        } else if (line.toLowerCase().startsWith('descricao:')) {
          description = line.substring(10).trim();
        } else if (line.toLowerCase().startsWith('descrição:')) {
          description = line.substring(10).trim();
        }
      }

      return GeminiItemDetails(name: name, description: description);
    } catch (e) {
      throw GeminiServiceException(
        'Erro ao processar imagem na API do Gemini: $e',
      );
    }
  }
}
