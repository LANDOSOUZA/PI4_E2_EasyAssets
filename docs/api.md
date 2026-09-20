# Contrato da API — PoC Easy_Assets (Entrega E2)

## O que está simulado nesta sprint

Nesta PoC, a consulta ao ativo **não faz uma chamada HTTP real** — ela é
resolvida por `AtivosRepository.buscarPorCodigo()` (`src/lib/data/ativos_repository.dart`),
que lê o arquivo local `dados/ativos.json` (copiado para
`assets/dados/ativos.json` dentro do app Flutter).

Essa função foi escrita **imitando exatamente o contrato do endpoint real**
que já existe no backend Django/DRF do projeto (repositório
`ProjetoIntegrador_Backend`), para que a troca de uma implementação pela
outra, na Sprint 3, seja só trocar a fonte de dados — a entrada e a saída
continuam as mesmas.

## Operação: consultar um ativo pelo código do marcador

| Item | Definição |
|---|---|
| Finalidade | Consultar um ativo pelo código lido no QR Code |
| Método (API real) | `GET` |
| Endereço (API real) | `/api/ativos/?codigo_qr={codigo}` |
| Equivalente nesta PoC | `AtivosRepository.buscarPorCodigo(String codigo)` |
| Entrada | Código do marcador, ex.: `EASY-GAB-01` |
| Resposta de sucesso (API real) | `200 OK` + JSON com os dados do ativo |
| Resposta de sucesso (PoC) | Um objeto `Ativo` (ver `src/lib/model/ativo.dart`) |
| Código inexistente (API real) | `404 Not Found` + mensagem explicativa |
| Código inexistente (PoC) | A função retorna `null`, e a tela exibe "Código não encontrado" |
| Autenticação (API real) | `Authorization: Bearer <token>` (JWT) — **não exigida nesta PoC** |

### Exemplo de requisição (API real, referência para a Sprint 3)

```
GET /api/ativos/?codigo_qr=EASY-GAB-01
Authorization: Bearer <token JWT>
```

### Exemplo de resposta de sucesso (API real)

```json
{
  "codigo_qr": "EASY-GAB-01",
  "tipo": "Gabinete",
  "nome": "Workstation Corporativo",
  "numero_patrimonio": "1253655",
  "sala": "B-111",
  "status": "Disponível"
}
```

### Exemplo de resposta de erro (API real)

```json
{
  "detail": "Nenhum ativo encontrado com o código informado."
}
```
(HTTP 404 Not Found)

### Exemplo equivalente na PoC (dados simulados)

Ver `dados/ativos.json` — mesmo formato de campos usado no JSON real,
com 4 ativos de teste (um de cada tipo do escopo do laboratório B-111):
`EASY-GAB-01`, `EASY-MON-01`, `EASY-TEC-01`, `EASY-MESA-01`.

## Por que a coerência importa

O mesmo campo `codigo_qr` aparece:
- No **marcador** físico (QR Code gerado em `marcador/`).
- No **modelo de dados** (`docs/modelo-dados.png`), como chave do Ativo.
- Na **arquitetura** (`docs/arquitetura.png`), como o dado que trafega
  entre "Câmera / Leitor" e "Repositório de Dados".
- No **código** (`ativos_repository.dart` e `ativo.dart`).
- Na **segurança** (`docs/seguranca.md`), como o principal ponto de
  validação de entrada.

Isso é intencional — é a regra de coerência exigida pelo modelo de entrega.
