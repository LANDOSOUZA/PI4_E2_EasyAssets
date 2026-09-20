import 'package:flutter/material.dart';

import '../data/ativos_repository.dart';
import '../model/ativo.dart';

/// Alternativa de consulta manual, exigida pelo item 6 do fluxo mínimo
/// obrigatório da Entrega E2: "Permitir consulta manual como alternativa
/// quando a leitura ou a RA não estiver disponível."
class ManualQueryScreen extends StatefulWidget {
  const ManualQueryScreen({super.key});

  @override
  State<ManualQueryScreen> createState() => _ManualQueryScreenState();
}

class _ManualQueryScreenState extends State<ManualQueryScreen> {
  final _controller = TextEditingController();
  final _repositorio = AtivosRepository();
  String? _erro;
  bool _buscando = false;

  Future<void> _buscar() async {
    final codigo = _controller.text.trim();
    if (codigo.isEmpty) {
      setState(() => _erro = 'Digite um código para consultar.');
      return;
    }

    setState(() {
      _buscando = true;
      _erro = null;
    });

    final ativo = await _repositorio.buscarPorCodigo(codigo);

    if (!mounted) return;
    setState(() => _buscando = false);

    if (ativo != null) {
      Navigator.of(context).pop<Ativo>(ativo);
    } else {
      setState(() => _erro = 'Código "$codigo" não encontrado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta manual')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Digite o código do ativo (mesmo valor codificado no QR Code). '
              'Exemplos disponíveis nesta PoC: EASY-GAB-01, EASY-MON-01, '
              'EASY-TEC-01, EASY-MESA-01.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Código do ativo',
                border: const OutlineInputBorder(),
                errorText: _erro,
              ),
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buscando ? null : _buscar,
              child: _buscando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Consultar'),
            ),
          ],
        ),
      ),
    );
  }
}
