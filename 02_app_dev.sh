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

# Accept Xcode license
echo "Accepting Xcode license..."
sudo xcodebuild -license accept

# Install CocoaPods for iOS development
echo "Installing CocoaPods for iOS development..."
brew install cocoapods

# Install watchman (used by React Native)
echo "Installing watchman..."
brew install watchman

# Install Java Development Kit (required for Android development)
echo "Installing JDK for Android development..."
brew install --cask zulu11

# Set JAVA_HOME environment variable
echo "Setting up JAVA_HOME environment variable..."
JAVA_PATH=$(/usr/libexec/java_home -v 11)
cat << EOF >> "$HOME/.zshrc"

# Java Home for Android development
export JAVA_HOME="$JAVA_PATH"
EOF

# Install Android Studio
echo "Installing Android Studio..."
brew install --cask android-studio

# Set up Android environment variables
echo "Setting up Android environment variables..."
cat << EOF >> "$HOME/.zshrc"

# Android SDK
export ANDROID_HOME="\$HOME/Library/Android/sdk"
export PATH="\$PATH:\$ANDROID_HOME/emulator"
export PATH="\$PATH:\$ANDROID_HOME/tools"
export PATH="\$PATH:\$ANDROID_HOME/tools/bin"
export PATH="\$PATH:\$ANDROID_HOME/platform-tools"
EOF

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

# Install fvm (Flutter Version Management) for project-specific Flutter versions
echo "Installing fvm (Flutter Version Management)..."
brew tap leoafarias/fvm
brew install fvm

# Install Fastlane for automating builds and deployments
echo "Installing Fastlane..."
brew install fastlane

# Install additional utilities for mobile development
echo "Installing additional development utilities..."
brew install scrcpy # For Android screen mirroring
brew install --cask figma # For UI design
brew install --cask android-file-transfer # For transferring files to Android devices

echo "=== Installation completed! ==="
echo "Please restart your terminal to apply all environment variables."
echo "Then run the following commands to complete the Android SDK setup:"
echo ""
echo "1. Open Android Studio and complete the setup wizard"
echo "2. In Android Studio, go to Preferences > Appearance & Behavior > System Settings > Android SDK"
echo "3. Select the 'SDK Platforms' tab, check the latest Android SDK and click 'Apply'"
echo ""
echo "To verify Flutter installation, run: flutter doctor"
echo "This will check your development environment and tell you if anything else needs to be configured."
echo ""
echo "For iOS development:"
echo "- Open Xcode and accept any additional prompts"
echo "- Install iOS Simulator by running: 'xcode-select --install'"
echo ""
echo "Enjoy your mobile development environment!"