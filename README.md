# PI4_E2_EasyAssets — PoC de Leitura de QR Code + Realidade Aumentada

**Projeto:** Projeto Integrador IV — Easy_Assets (Sistema de Gestão de
Ativos, laboratório de informática B-111, SENAI "Roberto Mange")
**Equipe:** Lucilando Celestino de Souza (backend, segurança, mobile e RA),
Miguel Freitas Santos (frontend web), Guilherme Bibiano Taglioni de Oliveira
(documentação, apoio em testes e segurança)
**Turma:** CTADS125N4
**Etapa:** Entrega E2 — Projeto técnico (marco: PoC executável de leitura + RA)
**Prazo:** 24/09/2026
**Versão revisada:** tag `entrega-e2-v2` (ajustes após a tentativa de execução em aula de 08/10/2026; a versão original segue na tag `entrega-e2`)

## Objetivo desta PoC

Demonstrar, com código executável, que é possível ler o QR Code de um
ativo do laboratório B-111 e exibir seus dados **sobrepostos à imagem da
câmera** (Realidade Aumentada), em vez de apenas abrir uma tela comum com
os dados — resolvendo o problema real do projeto: hoje um chamado de
defeito não indica de forma confiável qual máquina física está com
problema.

Esta PoC usa **dados simulados** (arquivo `dados/ativos.json`), mas o
contrato de entrada/saída é o mesmo já usado pelo backend real do projeto
(Django + DRF), documentado em [`docs/api.md`](docs/api.md).

## Tecnologias e versões

| Camada | Tecnologia |
|---|---|
| App | Flutter (SDK `>=3.0.0 <4.0.0`) / Dart |
| Leitura de QR Code | [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) `^5.2.3` |
| Dados desta PoC | Arquivo JSON local (`assets/dados/ativos.json`) |
| Referência real (Sprint 3) | Python 3 + Django + Django REST Framework + JWT |

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (canal stable).
- Um dispositivo Android físico conectado por USB (depuração ativada) **ou** um emulador Android configurado.
  - `mobile_scanner` não funciona no emulador iOS/Simulator sem câmera real; recomenda-se testar em um celular Android real.
- Ambiente já testado com `flutter doctor` sem erros bloqueantes.

## Instalação passo a passo

O repositório traz o código Dart do app (`src/lib/`), o `pubspec.yaml`, os
assets e um manifesto Android pronto (`src/android_config/`). A base nativa
`android/` é criada automaticamente pelo script de preparação — **nenhum
arquivo precisa ser editado à mão**.

```bash
# 1. Baixar o repositório
git clone https://github.com/LANDOSOUZA/PI4_E2_EasyAssets.git
cd PI4_E2_EasyAssets

# 2. Preparar o projeto (um comando só)
#    Windows:
setup.bat
#    Linux/macOS:
bash setup.sh

# 3. Conectar o celular Android (ou abrir um emulador) e executar
cd src
flutter run
```

O script de preparação faz, em ordem: `flutter create` (gera `android/`),
restaura `pubspec.yaml` e `lib/` caso tenham sido alterados, copia o
`AndroidManifest.xml` com a permissão de câmera e roda `flutter pub get`.
Pode ser executado de novo sem problema (se `android/` já existir, ele pula
essa etapa).

## Como executar e reproduzir o teste

1. Rode `flutter run` com o app instalado no celular.
2. A tela abre direto na câmera (tela "1. Leitura" — ver [`docs/wireframes/fluxo-leitura.png`](docs/wireframes/fluxo-leitura.png)).
3. Aponte a câmera para um dos QR Codes de teste, disponíveis em [`marcador/`](marcador/):
   - `EASY-GAB-01.png` (Workstation Corporativo)
   - `EASY-MON-01.png` (Monitor de Vídeo 24" Dell)
   - `EASY-TEC-01.png` (Teclado USB Padrão)
   - `EASY-MESA-01.png` (Mesa de Informática 1200 Cinza)
   - `INVALIDO-OUTRO-SISTEMA.png` (QR Code de outro sistema, conteúdo `OUTRO-SISTEMA-123` — usado só para testar o erro)
   - Dica: abra o PNG em outro celular/monitor e aponte a câmera para a tela, ou imprima o marcador.
4. **Resultado esperado:** em até 2 segundos, um card verde aparece **sobre a imagem da câmera** (que continua visível ao fundo), mostrando nome, tipo, número de patrimônio, sala e status do ativo — mais de três informações, portanto.
5. Toque em "Nova consulta" para escanear outro marcador, ou em "Digitar código manualmente" para testar a alternativa sem câmera (digite, por exemplo, `EASY-GAB-01`).
6. Para testar os casos de erro: aponte para o marcador `INVALIDO-OUTRO-SISTEMA.png` (ou qualquer QR Code de outro sistema) — deve aparecer o card vermelho "QR Code inválido: não pertence ao Easy_Assets"; na consulta manual, digite `EASY-XYZ-99` (formato válido, mas inexistente) — deve aparecer "Código não encontrado".

## Indicação do que usa dados simulados

- **Simulado nesta PoC:** todo o conteúdo de [`dados/ativos.json`](dados/ativos.json) — os 4 ativos de teste, seus números de patrimônio e status. Não há chamada de rede nem backend real envolvido na execução desta PoC.
- **Real (referência):** os códigos `codigo_qr` usados (`EASY-GAB-01`, etc.) seguem o mesmo padrão de nomenclatura do `seed_ativos` do backend Django real do projeto, e os campos (`tipo`, `nome`, `numero_patrimonio`, `sala`, `status`) são exatamente os mesmos expostos pela API real (ver [`docs/api.md`](docs/api.md)).

## Documentação técnica mínima

- [Arquitetura](docs/arquitetura.md) ([diagrama](docs/arquitetura.png))
- [Modelo de dados](docs/modelo-dados.png)
- [Contrato da API](docs/api.md)
- [Wireframes do fluxo](docs/wireframes/fluxo-leitura.png)
- [Ameaças e controles de segurança](docs/seguranca.md)

## Evidências de execução

Capturas de tela da PoC rodando de ponta a ponta, em execução real (dispositivo: Motorola Edge 40 Neo, Android 15), disponíveis em [`evidencias/`](evidencias/):

| Arquivo | O que mostra |
|---|---|
| `01_sucesso_EASY-GAB-01.png` | Leitura por câmera + RA — Workstation Corporativo (status Disponível) |
| `02_sucesso_EASY-MON-01.png` | Leitura por câmera + RA — Monitor de Vídeo 24" Dell |
| `03_sucesso_EASY-TEC-01.png` | Leitura por câmera + RA — Teclado USB Padrão (patrimônio "S/N", fora do inventário) |
| `04_sucesso_EASY-MESA-01.png` | Leitura por câmera + RA — Mesa de Informática (status "Em manutenção", caso não-padrão) |
| `05_erro_codigo_nao_encontrado.png` | Consulta manual com código inexistente — mensagem de erro tratada, sem travar o app |

O que funciona: leitura de QR Code pela câmera com overlay de RA para os 4 ativos de teste; consulta manual como alternativa; tratamento de erro para código não cadastrado.
O que não foi testado nesta sprint: leitura em ambientes com pouca luz e em iOS (ver Limitações conhecidas).

## Limitações conhecidas

- A PoC não se conecta à API real do backend (decisão deliberada, para não depender de o backend estar no ar durante a apresentação — ver `docs/api.md`).
- Testado apenas em Android; suporte a iOS não foi verificado nesta sprint.
- A leitura por câmera exige boa iluminação; em ambientes escuros, recomenda-se usar a consulta manual.
- O overlay de RA é 2D (card de texto sobreposto), não há reconhecimento de profundidade/posição 3D do objeto — está fora do escopo desta sprint (ver seção "Não é exigido nesta sprint" do modelo de entrega).
- Apenas 4 ativos de teste estão cadastrados nesta PoC (um de cada tipo do escopo do laboratório B-111); o inventário completo (16 ativos) está no backend real.

## Participação dos integrantes nesta entrega

| Integrante | Contribuição na E2 |
|---|---|
| Lucilando Celestino de Souza | App Flutter completo (scanner, overlay de RA, consulta manual), dados simulados, QR Codes de teste, documentação técnica (arquitetura, modelo de dados, API, segurança) |
| Miguel Freitas Santos | Revisão do README e alinhamento com a stack do frontend web (Vue + Django) para consistência entre os repositórios do projeto |
| Guilherme Bibiano Taglioni de Oliveira | Apoio na definição das ameaças de segurança e na revisão dos wireframes |

## Estrutura do repositório

```text
PI4_E2_EasyAssets/
├── README.md
├── setup.bat / setup.sh # Preparação automática (flutter create + manifesto + dependências)
├── src/                     # Código-fonte do app Flutter
│   ├── pubspec.yaml
│   ├── android_config/AndroidManifest.xml  # Manifesto com permissão de câmera
│   ├── lib/
│   │   ├── main.dart
│   │   ├── model/ativo.dart
│   │   ├── data/ativos_repository.dart
│   │   └── ui/
│   │       ├── scanner_screen.dart
│   │       └── manual_query_screen.dart
│   └── assets/dados/ativos.json
├── dados/                   # Dados simulados (cópia de referência)
│   └── ativos.json
├── marcador/                # QR Codes de teste (PNG)
│   ├── EASY-GAB-01.png
│   ├── EASY-MON-01.png
│   ├── EASY-TEC-01.png
│   ├── EASY-MESA-01.png
│   └── INVALIDO-OUTRO-SISTEMA.png  # QR Code inválido, para o teste de erro
├── docs/
│   ├── arquitetura.png / arquitetura.md
│   ├── modelo-dados.png
│   ├── api.md
│   ├── wireframes/fluxo-leitura.png
│   └── seguranca.md
└── evidencias/              # Capturas de tela da execução (ver "Evidências de execução" acima)
```
