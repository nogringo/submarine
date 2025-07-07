#!/bin/bash

# Build script for Submarine Password Manager - all platforms

set -e

APP_NAME="Submarine"
APP_VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
DESCRIPTION="A Nostr-based password manager for secure, decentralized credential storage"
MAINTAINER="Submarine Team"
ARCHITECTURE="amd64"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Building Submarine Password Manager for all platforms...${NC}"

# Create output directory structure
mkdir -p build/outputs

# Clean first
echo -e "${YELLOW}🧹 Cleaning...${NC}"
flutter clean
flutter pub get

# Run code quality checks
echo -e "${YELLOW}🔍 Running code analysis...${NC}"
flutter analyze
echo -e "${GREEN}✅ Code analysis passed${NC}"

# Build Web (for GitHub Pages)
echo -e "${YELLOW}🌐 Building Web...${NC}"
flutter build web --release --base-href /submarine/
mkdir -p build/temp/web
mkdir -p build/outputs
cp -r build/web/* build/temp/web/
cd build/temp && zip -r ../outputs/Submarine-${APP_VERSION}-web.zip web/ && cd ../..
echo -e "${GREEN}✅ Web build completed -> build/outputs/Submarine-${APP_VERSION}-web.zip${NC}"

# Build Linux
echo -e "${YELLOW}🐧 Building Linux...${NC}"
flutter build linux --release
mkdir -p build/temp/linux
cp -r build/linux/x64/release/bundle/. build/temp/linux/

# Create desktop file for Linux package
cat > "build/temp/linux/submarine.desktop" << EOF
[Desktop Entry]
Name=Submarine
Comment=$DESCRIPTION
Exec=./submarine
Icon=submarine
Terminal=false
Type=Application
Categories=Utility;Security;Office;
StartupWMClass=submarine
Path=%k
EOF

# Copy icon to Linux package if available
if [ -f "assets/icons/icon-512.png" ]; then
    cp "assets/icons/icon-512.png" "build/temp/linux/submarine.png"
elif [ -f "icon-512.png" ]; then
    cp "icon-512.png" "build/temp/linux/submarine.png"
fi

cd build/temp && zip -r ../outputs/Submarine-${APP_VERSION}-linux.zip linux/ && cd ../..
echo -e "${GREEN}✅ Linux build completed -> build/outputs/Submarine-${APP_VERSION}-linux.zip${NC}"

# Build macOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}🍎 Building macOS...${NC}"
    flutter build macos --release
    mkdir -p build/temp/macos
    cp -r build/macos/Build/Products/Release/submarine.app build/temp/macos/
    cd build/temp && zip -r ../outputs/Submarine-${APP_VERSION}-macos.zip macos/ && cd ../..
    echo -e "${GREEN}✅ macOS build completed -> build/outputs/Submarine-${APP_VERSION}-macos.zip${NC}"
else
    echo -e "${YELLOW}⏭️  Skipping macOS build (not on macOS)${NC}"
fi

# Build Windows (if on Windows or with cross-compilation)
if command -v flutter &> /dev/null && flutter doctor | grep -q "Windows"; then
    echo -e "${YELLOW}🪟 Building Windows...${NC}"
    flutter build windows --release
    mkdir -p build/temp/windows
    cp -r build/windows/x64/runner/Release/* build/temp/windows/
    cd build/temp && zip -r ../outputs/Submarine-${APP_VERSION}-windows.zip windows/ && cd ../..
    echo -e "${GREEN}✅ Windows build completed -> build/outputs/Submarine-${APP_VERSION}-windows.zip${NC}"
else
    echo -e "${YELLOW}⏭️  Skipping Windows build (not available)${NC}"
fi

# Build Android APK
echo -e "${YELLOW}🤖 Building Android APK...${NC}"
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk build/outputs/Submarine-${APP_VERSION}.apk
echo -e "${GREEN}✅ APK build completed -> build/outputs/Submarine-${APP_VERSION}.apk${NC}"

# Build Android AAB
echo -e "${YELLOW}🤖 Building Android AAB...${NC}"
flutter build appbundle --release
cp build/app/outputs/bundle/release/app-release.aab build/outputs/Submarine-${APP_VERSION}.aab
echo -e "${GREEN}✅ AAB build completed -> build/outputs/Submarine-${APP_VERSION}.aab${NC}"

# Build iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}📱 Building iOS...${NC}"
    flutter build ios --release --no-codesign
    echo -e "${GREEN}✅ iOS build completed (no code signing)${NC}"
    echo -e "${YELLOW}📝 Note: iOS build requires Xcode for final packaging and signing${NC}"
else
    echo -e "${YELLOW}⏭️  Skipping iOS build (requires macOS)${NC}"
fi

# Build DEB package (Linux only)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${YELLOW}📦 Building DEB package...${NC}"
    DEB_DIR="build/debian"
    rm -rf "$DEB_DIR"
    mkdir -p "$DEB_DIR/DEBIAN"
    mkdir -p "$DEB_DIR/usr/bin"
    mkdir -p "$DEB_DIR/usr/share/applications"
    mkdir -p "$DEB_DIR/usr/share/pixmaps"

    # Copy Linux bundle for DEB
    cp -r build/linux/x64/release/bundle/* "$DEB_DIR/usr/bin/"

    # Create control file
    cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: submarine
Version: $APP_VERSION
Section: utils
Priority: optional
Architecture: $ARCHITECTURE
Maintainer: $MAINTAINER
Description: $DESCRIPTION
 A Flutter application for secure password management using the Nostr protocol.
 Store and sync your credentials across devices with end-to-end encryption.
 Features include password storage, 2FA support, and decentralized backup.
EOF

    # Create desktop file
    cat > "$DEB_DIR/usr/share/applications/submarine.desktop" << EOF
[Desktop Entry]
Name=Submarine
Comment=$DESCRIPTION
Exec=/usr/bin/submarine
Icon=/usr/share/pixmaps/submarine.png
Terminal=false
Type=Application
Categories=Utility;Security;Office;
StartupWMClass=submarine
EOF

    # Copy icon
    if [ -f "assets/icons/icon-512.png" ]; then
        cp "assets/icons/icon-512.png" "$DEB_DIR/usr/share/pixmaps/submarine.png"
    elif [ -f "icon-512.png" ]; then
        cp "icon-512.png" "$DEB_DIR/usr/share/pixmaps/submarine.png"
    fi

    # Build DEB
    dpkg-deb --build "$DEB_DIR" "build/outputs/Submarine_${APP_VERSION}_${ARCHITECTURE}.deb"
    echo -e "${GREEN}✅ DEB package completed -> build/outputs/Submarine_${APP_VERSION}_${ARCHITECTURE}.deb${NC}"
else
    echo -e "${YELLOW}⏭️  Skipping DEB package (Linux only)${NC}"
fi

# Build AppImage (Linux only)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${YELLOW}📱 Building AppImage...${NC}"
    APPDIR="build/AppDir"
    rm -rf "$APPDIR"
    mkdir -p "$APPDIR/usr/bin"
    mkdir -p "$APPDIR/usr/share/applications"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/512x512/apps"

    # Copy Linux bundle for AppImage
    cp -r build/linux/x64/release/bundle/* "$APPDIR/usr/bin/"

    # Create desktop file
    cat > "$APPDIR/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Name=$APP_NAME
Comment=$DESCRIPTION
Exec=$APP_NAME
Icon=$APP_NAME
Terminal=false
Type=Application
Categories=Utility;Security;Office;
StartupWMClass=submarine
EOF

    # Copy desktop file to AppDir root
    cp "$APPDIR/usr/share/applications/$APP_NAME.desktop" "$APPDIR/"

    # Copy icon
    if [ -f "assets/icons/icon-512.png" ]; then
        cp "assets/icons/icon-512.png" "$APPDIR/usr/share/icons/hicolor/512x512/apps/$APP_NAME.png"
        cp "assets/icons/icon-512.png" "$APPDIR/$APP_NAME.png"
    elif [ -f "icon-512.png" ]; then
        cp "icon-512.png" "$APPDIR/usr/share/icons/hicolor/512x512/apps/$APP_NAME.png"
        cp "icon-512.png" "$APPDIR/$APP_NAME.png"
    fi

    # Create AppRun script
    cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
DIR="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="$DIR/usr/bin/lib:$LD_LIBRARY_PATH"
exec "$DIR/usr/bin/submarine" "$@"
EOF

    chmod +x "$APPDIR/AppRun"

    # Download appimagetool if not present
    if [ ! -f "appimagetool-x86_64.AppImage" ]; then
        echo "Downloading appimagetool..."
        wget -q "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
        chmod +x appimagetool-x86_64.AppImage
    fi

    # Build AppImage
    ARCH=x86_64 ./appimagetool-x86_64.AppImage "$APPDIR" "build/outputs/${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
    echo -e "${GREEN}✅ AppImage completed -> build/outputs/${APP_NAME}-${APP_VERSION}-x86_64.AppImage${NC}"
else
    echo -e "${YELLOW}⏭️  Skipping AppImage (Linux only)${NC}"
fi

# Summary
echo -e "\n${GREEN}🎉 All builds completed successfully!${NC}"
echo -e "${GREEN}📁 Outputs available in build/outputs/:${NC}"
echo -e "  🌐 Web: build/outputs/Submarine-${APP_VERSION}-web.zip"
echo -e "  🐧 Linux: build/outputs/Submarine-${APP_VERSION}-linux.zip"
echo -e "  🤖 Android APK: build/outputs/Submarine-${APP_VERSION}.apk"
echo -e "  🤖 Android AAB: build/outputs/Submarine-${APP_VERSION}.aab"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "  🍎 macOS: build/outputs/Submarine-${APP_VERSION}-macos.zip"
fi

if command -v flutter &> /dev/null && flutter doctor | grep -q "Windows"; then
    echo -e "  🪟 Windows: build/outputs/Submarine-${APP_VERSION}-windows.zip"
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "  📦 DEB: build/outputs/Submarine_${APP_VERSION}_${ARCHITECTURE}.deb"
    echo -e "  📱 AppImage: build/outputs/${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
fi

echo -e "\n${YELLOW}📋 Installation instructions:${NC}"
echo -e "  DEB: sudo dpkg -i build/outputs/Submarine_${APP_VERSION}_${ARCHITECTURE}.deb"
echo -e "  AppImage: chmod +x build/outputs/${APP_NAME}-${APP_VERSION}-x86_64.AppImage && ./build/outputs/${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
echo -e "  APK: adb install build/outputs/Submarine-${APP_VERSION}.apk"
echo -e "  Web: Extract and serve build/outputs/Submarine-${APP_VERSION}-web.zip"

echo -e "\n${GREEN}🔐 Submarine Password Manager - Secure, Decentralized, Open Source${NC}"