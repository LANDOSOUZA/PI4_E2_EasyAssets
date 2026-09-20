import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/ativos_repository.dart';
import '../model/ativo.dart';
import 'manual_query_screen.dart';

/// Tela central da PoC (fluxo mínimo obrigatório da Entrega E2).
///
/// Diferente de "somente leitura" (câmera lê o código e abre uma tela
/// comum com os dados), aqui as informações do ativo são exibidas
/// SOBREPOSTAS à imagem da câmera, que continua ativa e visível ao
/// fundo — é isso que caracteriza a Realidade Aumentada exigida
/// (ver docs/README, seção "O que caracteriza a realidade aumentada").
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final AtivosRepository _repositorio = AtivosRepository();

  Ativo? _ativoEncontrado;
  String? _mensagemErro;
  bool _processando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _aoDetectarCodigo(BarcodeCapture capture) async {
    if (_processando) return; // evita múltiplas leituras do mesmo frame
    final codigos = capture.barcodes;
    if (codigos.isEmpty) return;

    final valor = codigos.first.rawValue;
    if (valor == null || valor.isEmpty) return;

    setState(() => _processando = true);

    final ativo = await _repositorio.buscarPorCodigo(valor);

    if (!mounted) return;
    setState(() {
      _processando = false;
      if (ativo != null) {
        _ativoEncontrado = ativo;
        _mensagemErro = null;
      } else {
        _ativoEncontrado = null;
        _mensagemErro = 'Código "$valor" não corresponde a nenhum ativo cadastrado.';
      }
    });
  }

  void _novaConsulta() {
    setState(() {
      _ativoEncontrado = null;
      _mensagemErro = null;
    });
  }

  Future<void> _abrirConsultaManual() async {
    final ativo = await Navigator.of(context).push<Ativo?>(
      MaterialPageRoute(builder: (_) => const ManualQueryScreen()),
    );
    if (ativo != null && mounted) {
      setState(() {
        _ativoEncontrado = ativo;
        _mensagemErro = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Easy_Assets — Leitura + RA (PoC)'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Câmera ao fundo, sempre ativa — item 2 do fluxo mínimo obrigatório.
          MobileScanner(
            controller: _controller,
            onDetect: _aoDetectarCodigo,
          ),

          // Moldura de mira, só para orientar o usuário onde apontar.
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Overlay com o resultado, SOBRE a imagem da câmera (RA).
          if (_ativoEncontrado != null)
            _OverlayResultado(
              ativo: _ativoEncontrado!,
              onNovaConsulta: _novaConsulta,
            ),

          // Overlay de erro (código não encontrado).
          if (_mensagemErro != null)
            _OverlayErro(
              mensagem: _mensagemErro!,
              onFechar: _novaConsulta,
            ),

          // Indicador de processamento.
          if (_processando)
            const Positioned(
              top: 16,
              right: 16,
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Botão de consulta manual — alternativa exigida quando a
          // leitura ou a RA não estiver disponível (item 6 do fluxo).
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: ElevatedButton.icon(
              onPressed: _abrirConsultaManual,
              icon: const Icon(Icons.keyboard),
              label: const Text('Digitar código manualmente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card semitransparente com os dados do ativo, desenhado por cima da
/// imagem da câmera (que continua visível atrás dele).
class _OverlayResultado extends StatelessWidget {
  final Ativo ativo;
  final VoidCallback onNovaConsulta;

  const _OverlayResultado({required this.ativo, required this.onNovaConsulta});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 90,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.greenAccent, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ativo.nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _linhaInfo('Tipo', ativo.tipo),
            _linhaInfo('Patrimônio', ativo.numeroPatrimonio),
            _linhaInfo('Sala', ativo.sala),
            _linhaInfo('Status', ativo.status),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onNovaConsulta,
                child: const Text('Nova consulta'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaInfo(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 14),
          children: [
            TextSpan(text: '$rotulo: ', style: const TextStyle(color: Colors.white70)),
            TextSpan(text: valor, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _OverlayErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback onFechar;

  const _OverlayErro({required this.mensagem, required this.onFechar});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 90,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(mensagem, style: const TextStyle(color: Colors.white)),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: onFechar,
            ),
          ],
        ),
      ),
    );
  }
}
