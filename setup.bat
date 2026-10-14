@echo off
REM ============================================================
REM  Easy_Assets - PoC E2: preparacao automatica (Windows)
REM  Uso: de dois cliques neste arquivo, ou rode "setup.bat"
REM  na raiz do repositorio. Depois: cd src  e  flutter run
REM ============================================================

cd /d "%~dp0src"

where flutter >nul 2>nul
if errorlevel 1 (
    echo [ERRO] Flutter nao encontrado no PATH. Instale o Flutter SDK e tente de novo.
    pause
    exit /b 1
)

if not exist "android\" (
    echo [1/4] Criando a base nativa Android com flutter create...
    call flutter create --project-name easy_assets_poc --org br.senai.easyassets --platforms android .
    if errorlevel 1 (
        echo [ERRO] flutter create falhou.
        pause
        exit /b 1
    )
) else (
    echo [1/4] Pasta android ja existe - pulando flutter create.
)

echo [2/4] Garantindo que o codigo do app nao foi sobrescrito...
git checkout -- pubspec.yaml lib/ 2>nul

echo [3/4] Aplicando o AndroidManifest com permissao de camera...
copy /Y "android_config\AndroidManifest.xml" "android\app\src\main\AndroidManifest.xml" >nul
if errorlevel 1 (
    echo [ERRO] Nao foi possivel copiar o AndroidManifest.xml.
    pause
    exit /b 1
)

echo [4/4] Baixando dependencias...
call flutter pub get
if errorlevel 1 (
    echo [ERRO] flutter pub get falhou.
    pause
    exit /b 1
)

echo.
echo Pronto! Conecte o celular Android (ou abra o emulador) e rode:
echo     cd src
echo     flutter run
pause
