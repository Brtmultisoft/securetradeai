@echo off
echo ========================================
echo SecureTradeAI - Deployment Verification
echo ========================================
echo.

set BUILD_DIR=build\web
set ERROR_COUNT=0

echo [1/4] Checking core Flutter files...
if not exist "%BUILD_DIR%\index.html" (
    echo ❌ Missing: index.html
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: index.html
)

if not exist "%BUILD_DIR%\main.dart.js" (
    echo ❌ Missing: main.dart.js
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: main.dart.js
)

if not exist "%BUILD_DIR%\flutter.js" (
    echo ❌ Missing: flutter.js
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: flutter.js
)

if not exist "%BUILD_DIR%\flutter_service_worker.js" (
    echo ❌ Missing: flutter_service_worker.js
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: flutter_service_worker.js
)

echo.
echo [2/4] Checking configuration files...
if not exist "%BUILD_DIR%\manifest.json" (
    echo ❌ Missing: manifest.json
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: manifest.json
)

if not exist "%BUILD_DIR%\version.json" (
    echo ❌ Missing: version.json
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: version.json
)

if not exist "%BUILD_DIR%\.htaccess" (
    echo ❌ Missing: .htaccess
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: .htaccess
)

echo.
echo [3/4] Checking asset folders...
if not exist "%BUILD_DIR%\assets" (
    echo ❌ Missing: assets folder
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: assets folder
)

if not exist "%BUILD_DIR%\canvaskit" (
    echo ❌ Missing: canvaskit folder
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: canvaskit folder
)

if not exist "%BUILD_DIR%\icons" (
    echo ❌ Missing: icons folder
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: icons folder
)

echo.
echo [4/4] Checking critical assets...
if not exist "%BUILD_DIR%\assets\packages" (
    echo ❌ Missing: assets\packages folder
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: assets\packages folder
)

if not exist "%BUILD_DIR%\assets\AssetManifest.json" (
    echo ❌ Missing: AssetManifest.json
    set /a ERROR_COUNT+=1
) else (
    echo ✅ Found: AssetManifest.json
)

echo.
echo ========================================
if %ERROR_COUNT%==0 (
    echo ✅ ALL FILES PRESENT - READY FOR DEPLOYMENT!
    echo.
    echo 📦 Creating deployment package...
    powershell -Command "Compress-Archive -Path 'build/web/*' -DestinationPath 'securetradeai-web-FIXED.zip' -Force"
    echo ✅ Created: securetradeai-web-FIXED.zip
) else (
    echo ❌ FOUND %ERROR_COUNT% MISSING FILES!
    echo.
    echo 🔧 Run the following command to rebuild:
    echo flutter build web --no-sound-null-safety --web-renderer canvaskit
)
echo ========================================
echo.
pause
