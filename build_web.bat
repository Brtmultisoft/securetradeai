@echo off
echo Building SecureTradeAI for Web...
echo.

REM Clean previous builds
echo Cleaning previous builds...
flutter clean
flutter pub get

REM Build for web with optimizations
echo Building optimized web version...
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true --source-maps --tree-shake-icons

REM Copy .htaccess to build directory
echo Copying .htaccess configuration...
copy web\.htaccess build\web\.htaccess

REM Create compressed version
echo Creating compressed assets...
cd build\web
powershell -Command "Get-ChildItem -Recurse -File | Where-Object {$_.Extension -match '\.(js|css|html|json)$'} | ForEach-Object { if (!(Test-Path ($_.FullName + '.gz'))) { $content = [System.IO.File]::ReadAllBytes($_.FullName); $compressed = [System.IO.Compression.GzipStream]::new([System.IO.MemoryStream]::new(), [System.IO.Compression.CompressionMode]::Compress); $compressed.Write($content, 0, $content.Length); $compressed.Close(); [System.IO.File]::WriteAllBytes(($_.FullName + '.gz'), $compressed.BaseStream.ToArray()) } }"
cd ..\..

echo.
echo Build completed! Files are in build\web\
echo You can now deploy the contents of build\web\ to your web server.
echo.
pause
