# shrwnsan's Homebrew Tap 🍺

Personal Homebrew tap for useful development tools and utilities.

## 🚀 Installation

```bash
# Add the tap
brew tap shrwnsan/homebrew-tap

# Install a tool
brew install tailroute-cli
```

## 📦 Available Tools

### [tailroute-cli](https://github.com/shrwnsan/tailroute-cli)

Automatic MagicDNS toggle for Tailscale + VPN coexistence on macOS.

```bash
# Install
brew install tailroute-cli

# Setup
sudo tailroute install

# Check status
tailroute status
```

### [brew-change](https://github.com/shrwnsan/brew-change)

See what changed in your Homebrew packages before updating.

```bash
brew install brew-change
brew-change node      # Changelog for specific package
brew-change -a        # All outdated packages
```

### [brew-usage](https://github.com/shrwnsan/brew-usage)

Analyze Homebrew package usage patterns.

```bash
brew install brew-usage
```

### [glow](https://github.com/shrwnsan/glow)

Markdown renderer with subscript/superscript support (fork with patches).

```bash
brew install glow
```

## 🔧 Usage

```bash
brew update              # Update tap
brew upgrade <formula>   # Upgrade a tool
brew untap shrwnsan/homebrew-tap  # Remove tap
```

## 📋 Requirements

- macOS or Linux with [Homebrew](https://brew.sh/) installed

## 🤝 Contributing

1. Fork this repository
2. Add your formula to `Formula/`
3. Submit a pull request

## 📄 License

This tap follows the licenses of the individual tools it distributes.
