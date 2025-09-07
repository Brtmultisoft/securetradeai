@echo off
echo ========================================
echo SecureTradeAI - cPanel Deployment Script
echo ========================================
echo.

echo [1/4] Cleaning previous build...
flutter clean

echo.
echo [2/4] Building Flutter web app...
flutter build web --no-sound-null-safety --web-renderer canvaskit

echo.
echo [3/4] Copying .htaccess file...
copy .htaccess build\web\.htaccess

echo.
echo [4/4] Creating deployment ZIP file...
powershell -Command "Compress-Archive -Path 'build/web/*' -DestinationPath 'securetradeai-web-deployment.zip' -Force"

echo.
echo ========================================
echo ✅ DEPLOYMENT PACKAGE READY!
echo ========================================
echo.
echo 📦 File: securetradeai-web-deployment.zip
echo 📁 Size: 
dir securetradeai-web-deployment.zip | findstr "securetradeai-web-deployment.zip"
echo.
echo 🚀 Next Steps:
echo 1. Upload securetradeai-web-deployment.zip to your cPanel
echo 2. Extract it in public_html folder
echo 3. Set proper file permissions (644 for files, 755 for folders)
echo 4. Test your website!
echo.
echo 📖 For detailed instructions, see: CPANEL_DEPLOYMENT_GUIDE.md
echo.
pause
