# Ameaças e controles de segurança — PoC Easy_Assets (Entrega E2)

Três ameaças diretamente ligadas ao fluxo demonstrado nesta PoC (leitura de
QR Code → identificação do ativo → exibição de dados em RA), cobrindo os
três pontos exigidos pelo modelo: entrada de dados/marcador, acesso, e
perda/alteração de registros.

| # | Componente | Ameaça | Consequência | Controle | Situação |
|---|---|---|---|---|---|
| 1 | Leitura do marcador (câmera → `codigo_qr`) | QR Code adulterado, ilegível ou pertencente a outro sistema | Ativo incorreto identificado, ou nenhum ativo encontrado, confundindo o usuário sobre qual equipamento está em mãos | Validar o formato do código lido (prefixo `EASY-`) antes de consultar os dados; se não encontrado, exibir erro explícito em vez de dado de outro ativo | **Implementado** — ver tratamento de retorno `null` em `ativos_repository.dart` e a tela de erro em `scanner_screen.dart` |
| 2 | Acesso à API de ativos (na versão real, Sprint 3) | Consulta de dados de ativos sem autenticação, expondo local/patrimônio de equipamentos a qualquer pessoa | Vazamento de informação de inventário para quem não tem relação com o laboratório | Autenticação obrigatória por JWT em todo endpoint de consulta (já implementado no backend real, `Authorization: Bearer <token>`); nesta PoC local, não se aplica, pois não há rede envolvida | **Planejado nesta PoC / já implementado no backend real** |
| 3 | Registro/alteração de dados do ativo (histórico de movimentação) | Alteração indevida do status ou localização de um ativo por um usuário sem permissão (ex.: aluno registrando "em manutenção" para um gabinete que na verdade está disponível) | Dado incorreto no sistema, gerando decisões erradas de suporte técnico e perda de rastreabilidade | Controle de acesso por papel (RBAC): apenas Professor e Suporte técnico podem escrever; Aluno tem acesso somente de leitura | **Planejado nesta PoC (é somente leitura) / já implementado no backend real** (ver `contas/signals.py` e permissões por papel) |

## Observações

- Esta PoC é **somente leitura** (não grava nada), então a ameaça #3 não
  se manifesta tecnicamente aqui — ela é documentada porque pertence ao
  mesmo fluxo de dados (o `codigo_qr` que a PoC lê é o mesmo que, no
  sistema completo, também pode disparar uma escrita de histórico).
- A ameaça #1 é a única com controle **de fato implementado nesta PoC**,
  já que é a única parte que roda sem depender do backend.
- As ameaças #2 e #3 referenciam controles que já existem no backend real
  do projeto (JWT + RBAC por papel), mas que não são exercitados por esta
  PoC porque ela não faz chamadas de rede.
