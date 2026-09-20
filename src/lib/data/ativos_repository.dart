import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../model/ativo.dart';

/// Repositório que simula o contrato da API (ver docs/api.md):
/// GET /api/ativos/?codigo_qr={codigo}
///
/// Nesta PoC, os "dados simulados" ficam em assets/dados/ativos.json
/// (cópia de dados/ativos.json na raiz do repositório) em vez de uma
/// chamada HTTP de verdade — o backend real (Django/DRF) já expõe esse
/// mesmo contrato, documentado em docs/api.md.
class AtivosRepository {
  List<Ativo>? _cache;

  Future<List<Ativo>> _carregarTodos() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/dados/ativos.json');
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    final lista = (data['ativos'] as List<dynamic>)
        .map((e) => Ativo.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache = lista;
    return lista;
  }

  /// Equivalente a GET /api/ativos/?codigo_qr={codigo}
  /// Retorna null quando o código não é encontrado (equivalente ao
  /// 404 Not Found descrito em docs/api.md).
  Future<Ativo?> buscarPorCodigo(String codigo) async {
    final todos = await _carregarTodos();
    final codigoNormalizado = codigo.trim().toUpperCase();
    for (final ativo in todos) {
      if (ativo.codigoQr.toUpperCase() == codigoNormalizado) {
        return ativo;
      }
    }
    return null;
  }

  /// Usado pela tela de consulta manual, para sugerir códigos válidos.
  Future<List<Ativo>> listarTodos() => _carregarTodos();
}
