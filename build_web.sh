#!/bin/bash

echo "Building SecureTradeAI for Web..."
echo

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean
flutter pub get

# Build for web with optimizations
echo "Building optimized web version..."
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --source-maps \
  --tree-shake-icons \
  --dart-define=FLUTTER_WEB_AUTO_DETECT=true

# Create compressed version
echo "Creating compressed assets..."
cd build/web

# Compress JS, CSS, HTML, and JSON files
find . -type f \( -name "*.js" -o -name "*.css" -o -name "*.html" -o -name "*.json" \) -exec gzip -k {} \;

cd ../..

echo
echo "Build completed! Files are in build/web/"
echo "You can now deploy the contents of build/web/ to your web server."
echo

# Make the script executable
chmod +x build_web.sh
