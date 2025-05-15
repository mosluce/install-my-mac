#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Beginning installation of Homebrew, iTerm2, VS Code, Chrome, Slack, Oh My Zsh, and Powerlevel10k ==="

# Check if Homebrew is already installed
if command -v brew &>/dev/null; then
    echo "Homebrew is already installed. Updating..."
    brew update
else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    echo "Adding Homebrew to PATH..."
    if [[ $(uname -m) == "arm64" ]]; then
        # For Apple Silicon Macs
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # For Intel Macs
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Install iTerm2 using Homebrew
echo "Installing iTerm2..."
brew install --cask iterm2

# Install Visual Studio Code using Homebrew
echo "Installing Visual Studio Code..."
brew install --cask visual-studio-code

# Install Chrome using Homebrew
echo "Installing Google Chrome..."
brew install --cask google-chrome

# Install Slack using Homebrew
echo "Installing Slack..."
brew install --cask slack

# Check if zsh is installed
if ! command -v zsh &>/dev/null; then
    echo "Installing zsh..."
    brew install zsh
fi

# Check if Oh My Zsh is already installed
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed. Updating..."
    cd "$HOME/.oh-my-zsh"
    git pull
else
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k theme for Oh My Zsh
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
    echo "Powerlevel10k theme is already installed. Updating..."
    cd "$P10K_DIR"
    git pull
else
    echo "Installing Powerlevel10k theme for Oh My Zsh..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# Set Powerlevel10k as the default theme in .zshrc
echo "Setting Powerlevel10k as the default theme..."
if grep -q 'ZSH_THEME="robbyrussell"' "$HOME/.zshrc"; then
    sed -i '' 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    echo "Updated ZSH_THEME to powerlevel10k in .zshrc"
elif grep -q 'ZSH_THEME="powerlevel10k\/powerlevel10k"' "$HOME/.zshrc"; then
    echo "Powerlevel10k theme is already set in .zshrc, skipping"
else
    echo "Warning: Could not find default ZSH_THEME setting in .zshrc"
    echo "You may need to manually set ZSH_THEME=\"powerlevel10k/powerlevel10k\" in your .zshrc file"
fi

# Set zsh as the default shell if it's not already
if [[ $SHELL != *"zsh"* ]]; then
    echo "Setting zsh as the default shell..."
    chsh -s "$(which zsh)"
fi

# Add VS Code to PATH
echo "Adding VS Code to PATH..."
if ! grep -q "# Add Visual Studio Code (code)" "$HOME/.zshrc"; then
    cat << EOF >> "$HOME/.zshrc"

# Add Visual Studio Code (code)
export PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
EOF
    echo "Added VS Code to PATH in .zshrc"
else
    echo "VS Code PATH configuration already exists in .zshrc, skipping"
fi

# Install asdf version manager
echo "Installing asdf version manager..."
if command -v asdf &>/dev/null; then
    echo "asdf is already installed. Updating..."
    # asdf update
else
    echo "Installing asdf..."
    brew install asdf
    
    # Add asdf to .zshrc
    echo "Adding asdf to .zshrc..."
    if ! grep -q "# asdf version manager" "$HOME/.zshrc"; then
        cat << EOF >> "$HOME/.zshrc"

# asdf version manager
. "$(brew --prefix asdf)/libexec/asdf.sh"

# Node.js legacy file dynamic strategy
export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_installed
EOF
        echo "Added asdf configuration to .zshrc"
    else
        echo "asdf configuration already exists in .zshrc, skipping"
    fi
fi

# Install asdf plugins and latest versions
echo "Installing asdf plugins for Ruby, Python, and Node.js..."

# Install Ruby plugin
if asdf plugin list | grep -q "ruby"; then
    echo "Ruby plugin is already installed. Updating..."
    asdf plugin update ruby
else
    echo "Installing Ruby plugin..."
    asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
fi
echo "Installing latest Ruby version..."
asdf install ruby latest
asdf set --home ruby "$(asdf latest ruby)"

# Install Python plugin
if asdf plugin list | grep -q "python"; then
    echo "Python plugin is already installed. Updating..."
    asdf plugin update python
else
    echo "Installing Python plugin..."
    asdf plugin add python
fi
echo "Installing latest Python version..."
asdf install python latest
asdf set --home python "$(asdf latest python)"

# Install Node.js plugin
if asdf plugin list | grep -q "nodejs"; then
    echo "Node.js plugin is already installed. Updating..."
    asdf plugin update nodejs
else
    echo "Installing Node.js plugin..."
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    # Import Node.js release team OpenPGP keys to main keyring
    # bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
fi
echo "Installing latest Node.js version..."
asdf install nodejs latest
asdf set --home nodejs "$(asdf latest nodejs)"

# Install Docker
echo "Installing Docker Desktop for Mac..."
if [ -d "/Applications/Docker.app" ]; then
    echo "Docker Desktop is already installed."
else
    echo "Downloading and installing Docker Desktop..."
    brew install --cask docker
fi

# Install Postman
echo "Installing Postman..."
if [ -d "/Applications/Postman.app" ]; then
    echo "Postman is already installed."
else
    echo "Downloading and installing Postman..."
    brew install --cask postman
fi

# Check if Docker CLI is available and Docker Desktop is running
echo "Setting up Docker..."
if ! command -v docker &>/dev/null; then
    echo "Docker CLI not found. Please start Docker Desktop after installation."
else
    # Check if Docker is running
    if ! docker info &>/dev/null; then
        echo "Docker Desktop is installed but not running."
        echo "Please start Docker Desktop manually after installation."
        open -a Docker
    else
        echo "Docker is installed and running."
    fi
fi

echo "=== Installation completed! ==="
echo "Please restart your terminal or run 'zsh' to start using Oh My Zsh with Powerlevel10k theme."
echo "When you first start your terminal with Powerlevel10k, it will guide you through the setup process."
echo "You can find iTerm2, VS Code, Chrome, Slack, Docker, and Postman in your Applications folder."
echo "To use VS Code from the terminal, restart your terminal and use the 'code' command."
echo "The following development tools have been installed via asdf:"
echo "- Ruby: $(asdf current ruby | awk '{print $2}')"
echo "- Python: $(asdf current python | awk '{print $2}')"
echo "- Node.js: $(asdf current nodejs | awk '{print $2}')"
echo ""
echo "Docker Desktop has been installed. If it's not running, please start it manually."
echo "You may need to accept the Docker license agreement on first launch."
echo ""
echo "Postman has been installed for API development and testing."
