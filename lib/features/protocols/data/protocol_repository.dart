import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models/protocol_models.dart';

/// Repository for loading and accessing protocol definitions
class ProtocolRepository {
  List<ProtocolDefinition>? _cachedProtocols;

  /// Load all protocol definitions from assets
  Future<List<ProtocolDefinition>> loadProtocols() async {
    if (_cachedProtocols != null) {
      return _cachedProtocols!;
    }

    final jsonString = await rootBundle.loadString('assets/data/protocols.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final protocolsList = jsonData['protocols'] as List<dynamic>;

    _cachedProtocols = protocolsList
        .map((e) => ProtocolDefinition.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cachedProtocols!;
  }

  /// Get protocol by ID
  Future<ProtocolDefinition?> getProtocol(String id) async {
    final protocols = await loadProtocols();
    return protocols.where((p) => p.id == id).firstOrNull;
  }

  /// Get protocols filtered by type
  Future<List<ProtocolDefinition>> getProtocolsByType(String type) async {
    final protocols = await loadProtocols();
    return protocols.where((p) => p.type == type).toList();
  }

  /// Get all unique protocol types
  Future<List<String>> getProtocolTypes() async {
    final protocols = await loadProtocols();
    return protocols.map((p) => p.type).toSet().toList()..sort();
  }
}
