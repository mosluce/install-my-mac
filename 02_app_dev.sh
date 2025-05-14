#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Beginning installation of iOS / Android development environment and Flutter ==="

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew is required but not installed. Please run 01_basic.sh first."
    exit 1
fi

# Install Xcode Command Line Tools if not already installed
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    # Wait for installation to complete
    echo "Please complete the Xcode Command Line Tools installation dialog..."
    echo "Press Enter when the installation has completed."
    read -r
else
    echo "Xcode Command Line Tools already installed."
fi

# Check if Xcode is installed
if ! [ -d "/Applications/Xcode.app" ]; then
    echo "Xcode is required for iOS development but not installed."
    echo "Please install Xcode from the App Store, then run this script again."
    echo "Opening App Store..."
    open "macappstores://itunes.apple.com/app/id497799835"
    exit 1
fi

# Switch the active developer directory to Xcode
echo "Setting Xcode as the active developer directory..."
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# Accept Xcode license
echo "Accepting Xcode license..."
sudo xcodebuild -license accept

# Install CocoaPods for iOS development
echo "Installing CocoaPods for iOS development..."
brew install cocoapods

# Install Java Development Kit (required for Android development) using asdf
echo "Installing JDK for Android development using asdf..."
if asdf plugin list | grep -q "java"; then
    echo "Java plugin is already installed. Updating..."
    asdf plugin update java
else
    echo "Installing Java plugin..."
    asdf plugin add java https://github.com/halcyon/asdf-java.git
fi

# List available Java versions
echo "Available Java versions (OpenJDK 18):"
asdf list all java | grep "openjdk-18" | tail -5

echo "Installing Java JDK 18..."
asdf install java openjdk-18
asdf set --home java openjdk-18

# Set up JAVA_HOME in .zshrc
echo "Setting up JAVA_HOME in .zshrc..."
# Check if JAVA_HOME configuration already exists in .zshrc
if ! grep -q "# Java Home for asdf-java" "$HOME/.zshrc"; then
    cat << EOF >> "$HOME/.zshrc"

# Java Home for asdf-java
. "\$HOME/.asdf/plugins/java/set-java-home.zsh"

# Optional: macOS specific Java integration (for /usr/libexec/java_home)
export java_macos_integration_enable=yes
EOF
    echo "Added JAVA_HOME configuration to .zshrc"
else
    echo "JAVA_HOME configuration already exists in .zshrc, skipping"
fi

# Install Android Studio
echo "Installing Android Studio..."
brew install --cask android-studio

# Set up Android environment variables
echo "Setting up Android environment variables..."
# Check if Android SDK configuration already exists in .zshrc
if ! grep -q "# Android SDK" "$HOME/.zshrc"; then
    cat << EOF >> "$HOME/.zshrc"

# Android SDK
export ANDROID_HOME="\$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="\$HOME/Library/Android/sdk"
export PATH="\$PATH:\$ANDROID_HOME/emulator"
export PATH="\$PATH:\$ANDROID_HOME/tools"
export PATH="\$PATH:\$ANDROID_HOME/tools/bin"
export PATH="\$PATH:\$ANDROID_HOME/platform-tools"
EOF
    echo "Added Android SDK configuration to .zshrc"
else
    echo "Android SDK configuration already exists in .zshrc, skipping"
fi

# Create default Android SDK location in case it doesn't exist
echo "Creating default Android SDK directory structure..."
mkdir -p "$HOME/Library/Android/sdk"

# Install asdf if not already installed (required for Flutter installation)
if ! command -v asdf &>/dev/null; then
    echo "asdf is required but not installed. Please run 01_basic.sh first."
    exit 1
fi

# Install Flutter using asdf
echo "Installing Flutter using asdf..."
if asdf plugin list | grep -q "flutter"; then
    echo "Flutter plugin is already installed. Updating..."
    asdf plugin update flutter
else
    echo "Installing Flutter plugin..."
    asdf plugin add flutter
fi

echo "Installing latest Flutter version..."
asdf install flutter latest
asdf set --home flutter "$(asdf latest flutter)"

# Set FLUTTER_ROOT environment variable in .zshrc
echo "Setting up Flutter environment in .zshrc..."
if ! grep -q "# Flutter environment for asdf-flutter" "$HOME/.zshrc"; then
    cat << EOF >> "$HOME/.zshrc"

# Flutter environment for asdf-flutter
export FLUTTER_ROOT="\$(asdf where flutter)"
EOF
    echo "Added FLUTTER_ROOT configuration to .zshrc"
else
    echo "Flutter environment configuration already exists in .zshrc, skipping"
fi

# Check if on Apple Silicon and install Rosetta if needed
if [[ $(uname -m) == "arm64" ]]; then
    echo "Apple Silicon detected, making sure Rosetta is installed (needed for some Flutter components)..."
    softwareupdate --install-rosetta --agree-to-license || echo "Rosetta installation skipped, may already be installed"
fi

# Install Fastlane for automating builds and deployments
echo "Installing Fastlane..."
brew install fastlane

# Install additional utilities for mobile development
echo "Installing additional development utilities..."
brew install scrcpy # For Android screen mirroring
brew install --cask figma # For UI design
brew install --cask android-file-transfer # For transferring files to Android devices

# Configure Flutter to use the correct Android SDK path
echo "Configuring Flutter to use the correct Android SDK path..."
flutter config --android-sdk="$HOME/Library/Android/sdk"

echo "=== Installation completed! ==="
echo "Please restart your terminal to apply all environment variables."
echo "Then run the following commands to complete the Android SDK setup:"
echo ""
echo "1. Open Android Studio and complete the setup wizard"
echo "2. In Android Studio, go to Preferences > Appearance & Behavior > System Settings > Android SDK"
echo "3. Select the 'SDK Platforms' tab, check the latest Android SDK and click 'Apply'"
echo "4. After Android Studio completes the SDK installation, run 'flutter doctor' again to verify"
echo ""
echo "** IMPORTANT: Android SDK is initially set to $HOME/Library/Android/sdk **"
echo "If Android Studio installs the SDK to a different location, run:"
echo "flutter config --android-sdk=\"/path/to/your/android/sdk\""
echo ""
echo "To verify Flutter installation, run: flutter doctor"
echo "This will check your development environment and tell you if anything else needs to be configured."
echo ""
echo "For iOS development:"
echo "- Open Xcode and accept any additional prompts"
echo "- Install iOS Simulator by running: 'xcode-select --install'"
echo ""
echo "Java environment:"
echo "- JAVA_HOME is managed by asdf-java plugin through the set-java-home.zsh script"
echo "- If you need macOS specific Java integration (/usr/libexec/java_home), uncomment the relevant line in your .zshrc"
echo ""
echo "Flutter environment:"
echo "- FLUTTER_ROOT is set to point to your asdf Flutter installation"
echo "- This helps IDEs like VS Code to find your Flutter installation"
echo "- Run 'flutter doctor' after installation to verify everything is set up correctly"
echo ""
echo "Enjoy your mobile development environment!"