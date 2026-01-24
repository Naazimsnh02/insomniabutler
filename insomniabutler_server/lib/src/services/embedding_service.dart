import 'dart:math';

import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for generating embeddings using Gemini's text-embedding-004 model
class EmbeddingService {
  final GenerativeModel _embeddingModel;
  final String _apiKey;

  /// Recommended dimension for balance of quality and efficiency
  static const int defaultDimensions = 768;

  EmbeddingService(String apiKey)
      : _apiKey = apiKey,
        _embeddingModel = GenerativeModel(
          model: 'text-embedding-004',
          apiKey: apiKey,
        );

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Generate embedding for a single text
  /// Returns a 768-dimensional vector (normalized, ready for cosine similarity)
  Future<List<double>> generateEmbedding(String text) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Text cannot be empty');
    }

    final result = await _embeddingModel.embedContent(
      Content.text(text),
      taskType: TaskType.retrievalDocument,
      outputDimensionality: defaultDimensions,
    );

    return result.embedding.values;
  }

  /// Generate embeddings for multiple texts in a single batch
  /// More efficient for bulk operations
  Future<List<List<double>>> generateBatchEmbeddings(
    List<String> texts,
  ) async {
    if (texts.isEmpty) {
      return [];
    }

    // Filter out empty texts
    final validTexts = texts.where((t) => t.trim().isNotEmpty).toList();
    if (validTexts.isEmpty) {
      return [];
    }

    final requests = validTexts.map((text) => EmbedContentRequest(
      Content.text(text),
      taskType: TaskType.retrievalDocument,
      outputDimensionality: defaultDimensions,
    )).toList();

    final result = await _embeddingModel.batchEmbedContents(requests);
    return result.embeddings.map((e) => e.values).toList();
  }

  /// Generate embedding optimized for search queries
  Future<List<double>> generateQueryEmbedding(String query) async {
    if (query.trim().isEmpty) {
      throw ArgumentError('Query cannot be empty');
    }

    final result = await _embeddingModel.embedContent(
      Content.text(query),
      taskType: TaskType.retrievalQuery,
      outputDimensionality: defaultDimensions,
    );

    return result.embedding.values;
  }

  /// Calculate cosine similarity between two embeddings
  /// Returns a value between -1 and 1 (higher = more similar)
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have the same dimension');
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    // Since embeddings are normalized, we can simplify
    // But keeping full calculation for safety
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
