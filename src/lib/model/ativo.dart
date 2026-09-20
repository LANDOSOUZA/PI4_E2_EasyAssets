/// Modelo simplificado de Ativo para a PoC (Entrega E2).
///
/// Corresponde ao mesmo conceito do model `Ativo` do backend Django/DRF
/// (ver docs/modelo-dados.md), mas aqui os dados vêm de um arquivo JSON
/// local (assets/dados/ativos.json), sem depender da API estar no ar.
class Ativo {
  final String codigoQr;
  final String tipo;
  final String nome;
  final String numeroPatrimonio;
  final String sala;
  final String status;

  const Ativo({
    required this.codigoQr,
    required this.tipo,
    required this.nome,
    required this.numeroPatrimonio,
    required this.sala,
    required this.status,
  });

  factory Ativo.fromJson(Map<String, dynamic> json) {
    return Ativo(
      codigoQr: json['codigo_qr'] as String,
      tipo: json['tipo'] as String,
      nome: json['nome'] as String,
      numeroPatrimonio: json['numero_patrimonio'] as String,
      sala: json['sala'] as String,
      status: json['status'] as String,
    );
  }
}
