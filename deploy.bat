@echo off
echo Building Flutter web app...
flutter build web --release
echo Build complete! Upload the 'build/web' folder contents to your cPanel public_html directory.
pause