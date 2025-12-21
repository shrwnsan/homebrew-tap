# brew-change Testing - Quick Start Guide

## 🚀 Super Simple Usage

### For Development (Recommended)
```bash
# Just run the menu - it detects your setup automatically
./tests/test-brew-change-local.sh
```

### For Docker Testing
```bash
# Just run the menu - it handles building automatically!
./tests/test-brew-change-docker.sh
```

### For Manual Docker Control (Optional)
```bash
# Build manually if you prefer full control
docker build -f tests/docker/Dockerfile.test-ubuntu -t brew-change-ubuntu .

# Then run the menu
./tests/test-brew-change-docker.sh
```

## 🎯 What You'll See

### Local Testing Menu
```
╔══════════════════════════════════════════════════╗
║           🧪 brew-change Local Testing Suite           ║
║              Easy Development Testing                ║
╚══════════════════════════════════════════════════╝

🚀 Quick Start - Choose an option:

  1) 🧪 Run All Tests                        Full validation
  2) 📋 Test Basic Functionality              Quick checks
  3) ⚡ Performance Benchmark                 Speed testing

Enter your choice [0-12]:
```

### Docker Testing Menu
```
╔══════════════════════════════════════════════════╗
║           🐳 brew-change Docker Testing Suite           ║
║              Easy Sandbox Testing                   ║
╚══════════════════════════════════════════════════╝

🚀 Quick Start - Choose an option:

  1) 🔨 Build Docker Image                One-time setup
  2) 🧪 Run All Tests                    Full automated testing
  3) 🎮 Interactive Menu                   Choose specific tests

Enter your choice [0-13]:
```

## ✨ Key Improvements Made

1. **🎯 Narrower Title Boxes** - Better terminal rendering
2. **🎨 Better Spacing** - No extra spaces in menu items
3. **🟢 Color Coding** - Green for primary actions, Yellow for info
4. **📝 Helpful Descriptions** - Each option shows what it does
5. **🔧 Fixed Exit Issues** - Both scripts exit properly now
6. **🧪 Beginner Friendly** - Clear categories and labels

## 🔧 What Each Option Does

### 🚀 Quick Start Options (Beginner-friendly)
- **1) Build/Run All Tests** - Just press 1 and it works!
- **2/3) Interactive Menu** - Choose specific tests

### 📊 Individual Tests
- **Performance** - See how fast brew-change runs
- **Network** - Test API connectivity
- **System** - Check resource usage

### 🔧 Management
- **Clean** - Remove Docker images if needed
- **Results** - View test logs and output
- **Debug** - Get shell access for troubleshooting

## 🎯 Recommended Workflow

### First Time Testing (Super Simple)
```bash
# 1. Test locally first (recommended)
./tests/test-brew-change-local.sh
# Choose option 1 to run all tests ✅

# 2. Try Docker testing (optional, for isolated environment)
./tests/test-brew-change-docker.sh
# Choose option 2 to run all tests ✅ (auto-builds if needed!)
```

### Docker Testing (Zero-Effort)
```bash
# The script handles everything automatically!
./tests/test-brew-change-docker.sh

# It will:
# - Check if Docker image exists
# - Auto-build if needed (no manual steps)
# - Show menu with all test options
# - Handle everything gracefully
```

### Daily Development (Fast)
```bash
# Quick local test - fastest
./tests/test-brew-change-local.sh
# Option 2 for quick tests, or option 8 for outdated packages
```

## 🔍 Troubleshooting

### Script Won't Run?
```bash
# Make sure it's executable
chmod +x tests/test-brew-change-*.sh

# Check if brew-change is in PATH
which brew-change
# If not found:
export PATH="$(pwd):$PATH"
```

### Docker Issues?
```bash
# Check Docker is running
docker info

# Clean and rebuild
./tests/test-brew-change-docker.sh
# Choose option 7 to clean, then option 1 to build
```

### Menu Navigation
- Use **1, 2, 3** for the main functions
- Use **0** to exit safely
- Use **Ctrl+C** to force quit if needed

## 🎉 Success Criteria

✅ **Local Testing Works**: `./tests/test-brew-change-local.sh` runs and shows menu
✅ **Docker Testing Works**: `./tests/test-brew-change-docker.sh` runs and shows menu
✅ **Clean Exit**: Both menus exit cleanly with option 0
✅ **No Errors**: Scripts complete without crashes
✅ **Helpful Output**: Clear feedback and success/failure messages

---

**That's it!** Just run either script and you'll get a user-friendly menu for testing brew-change. 🚀