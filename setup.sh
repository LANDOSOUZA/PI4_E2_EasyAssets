#!/usr/bin/env bash
# ============================================================
#  Easy_Assets - PoC E2: preparação automática (Linux/macOS)
#  Uso: bash setup.sh   (na raiz do repositório)
#  Depois: cd src && flutter run
# ============================================================
set -e

cd "$(dirname "$0")/src"

if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERRO] Flutter não encontrado no PATH. Instale o Flutter SDK e tente de novo."
  exit 1
fi

if [ ! -d android ]; then
  echo "[1/4] Criando a base nativa Android com flutter create..."
  flutter create --project-name easy_assets_poc --org br.senai.easyassets --platforms android .
else
  echo "[1/4] Pasta android já existe — pulando flutter create."
fi

echo "[2/4] Garantindo que o código do app não foi sobrescrito..."
git checkout -- pubspec.yaml lib/ 2>/dev/null || true

echo "[3/4] Aplicando o AndroidManifest com permissão de câmera..."
cp android_config/AndroidManifest.xml android/app/src/main/AndroidManifest.xml

echo "[4/4] Baixando dependências..."
flutter pub get

echo
echo "Pronto! Conecte o celular Android (ou abra o emulador) e rode:"
echo "    cd src && flutter run"
