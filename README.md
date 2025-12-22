# shrwnsan's Homebrew Tap 🍺

Personal Homebrew tap for useful development tools and utilities.

## 🚀 Installation

### Add the Tap
```bash
brew tap shrwnsan/homebrew-tap
```

### Install Tools
```bash
# Install brew-change
brew install brew-change

# Or install directly without tapping first
brew install shrwnsan/tap/brew-change
```

## 📦 Available Tools

### [brew-change](https://github.com/shrwnsan/brew-change)
Make informed updates - see what changed in your Homebrew packages before updating.

```bash
# Show detailed changelog for specific package
brew-change node

# Show detailed changelogs for all outdated packages in parallel
brew-change -a

# Show verbose output with version information
brew-change -v
```

## 🔧 Usage

### Update Tap
```bash
brew update
```

### Upgrade Tools
```bash
brew upgrade brew-change
```

### Remove Tap
```bash
brew untap shrwnsan/homebrew-tap
```

## 📋 Requirements

- **macOS** or **Linux** with [Homebrew](https://brew.sh/) installed
- **jq** and **curl** dependencies are automatically installed

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch
3. Add your formula to the `Formula/` directory
4. Submit a pull request

## 📄 License

This tap follows the licenses of the individual tools it distributes.

---

**Looking for more tools?** Check out the individual tool repositories for detailed documentation.