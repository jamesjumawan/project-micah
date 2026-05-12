import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

/// Response shape that mirrors what a real API endpoint would return.
/// When the backend is ready, swap [_fetchLocal] with a Dio/Retrofit call
/// and delete the asset reference — callers stay untouched.
class MotorcycleApiResponse {
  final List<Map<String, dynamic>> motorcycles;
  const MotorcycleApiResponse({required this.motorcycles});

  factory MotorcycleApiResponse.fromJson(Map<String, dynamic> json) {
    return MotorcycleApiResponse(
      motorcycles: (json['motorcycles'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}

class MotorcycleService {
  MotorcycleService();

  // ── Public API ────────────────────────────────────────────────────────────

  /// Fetch the full motorcycles catalogue.
  ///
  /// TODO: Replace [_fetchLocal] with a Retrofit client call once the API
  /// endpoint `GET /api/motorcycles` is available:
  ///
  /// ```dart
  /// return await _client.getMotorcycles();
  /// ```
  Future<MotorcycleApiResponse> getMotorcycles() async {
    try {
      return await _fetchLocal();
    } catch (e) {
      log('[MotorcycleService] getMotorcycles error: $e');
      rethrow;
    }
  }

  /// Returns OBJ paths for the given motorcycle's explosion models, sorted
  /// alphabetically.
  ///
  /// Looks in `assets/models/{modelKey}/` first (the preferred layout for new
  /// motorcycles). Falls back to the flat `assets/models/` folder so that
  /// existing BLT150 exports (which were added before subfolders were
  /// introduced) are still discovered without moving any files.
  Future<List<String>> getLocalExplosionModels(String modelKey) async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allKeys = manifest.listAssets();

      // ── Preferred: per-motorcycle subfolder ──────────────────────────────
      final subfolderPrefix = 'assets/models/$modelKey/';
      var matches = allKeys
          .where((k) =>
              k.startsWith(subfolderPrefix) && k.endsWith('_assembled.obj'))
          .toList();

      // ── Fallback: flat assets/models/ (legacy / BLT150) ──────────────────
      if (matches.isEmpty) {
        const flatPrefix = 'assets/models/';
        matches = allKeys
            .where((k) =>
                k.startsWith(flatPrefix) &&
                !k.substring(flatPrefix.length).contains('/') &&
                k.endsWith('_assembled.obj'))
            .toList();
      }

      return matches..sort();
    } catch (e) {
      log('[MotorcycleService] getLocalExplosionModels error: $e');
      return [];
    }
  }

  /// Returns the matching MTL path for an OBJ path, or null if absent.
  Future<String?> mtlForObj(String objPath) async {
    final mtlPath = objPath.replaceAll('.obj', '.mtl');
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final exists = manifest.listAssets().contains(mtlPath);
      return exists ? mtlPath : null;
    } catch (_) {
      return null;
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────

  /// Loads from bundled JSON asset — stands in for the real API call.
  Future<MotorcycleApiResponse> _fetchLocal() async {
    // TODO: swap this body for a Dio/Retrofit HTTP call.
    // Expected response shape: { "motorcycles": [ { "name": ..., ... } ] }
    const assetPath = 'assets/data/motorcycles_data.json';
    final raw = await rootBundle.loadString(assetPath);
    return MotorcycleApiResponse.fromJson(
        json.decode(raw) as Map<String, dynamic>);
  }
}
