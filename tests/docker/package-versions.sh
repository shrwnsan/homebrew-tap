#!/bin/bash
# Script to generate Homebrew package installation commands with specific versions
# This ensures Docker testing environment matches the development environment

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 Generating package installation commands for Docker...${NC}"
echo ""

# Get current outdated packages with versions
echo "# Current Package Versions (Generated: $(date))" > package-versions.txt
echo "# These commands install the exact versions from your development environment" >> package-versions.txt
echo "" >> package-versions.txt

# Extract installed versions (current versions)
echo "# INSTALL CURRENT VERSIONS (these will become 'outdated' in Docker)" >> package-versions.txt

# Get package information
brew_info=$(brew info --json=v2 $(brew-change) 2>/dev/null)

# Parse and generate installation commands
echo "$brew_info" | jq -r '.formulae[]? | select(.name) | "\(.name)@\(.installed[0].version // .versions.stable)"' 2>/dev/null | while read -r package_version; do
    if [[ -n "$package_version" && "$package_version" != "null" ]]; then
        echo "RUN /home/brewtest/.linuxbrew/bin/brew install $package_version" >> package-versions.txt
        echo -e "  ${GREEN}✅${NC} Added: $package_version"
    fi
done

echo "$brew_info" | jq -r '.casks[]? | select(.token) | "\(.token)@\(.installed[0].version // .version)"' 2>/dev/null | while read -r package_version; do
    if [[ -n "$package_version" && "$package_version" != "null" ]]; then
        echo "RUN /home/brewtest/.linuxbrew/bin/brew install $package_version" >> package-versions.txt
        echo -e "  ${GREEN}✅${NC} Added: $package_version"
    fi
done

echo ""
echo -e "${BLUE}📋 Generated package installation commands:${NC}"
echo "========================================="
cat package-versions.txt

echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo "1. Copy the commands from package-versions.txt"
echo "2. Update tests/docker/Dockerfile.test-ubuntu"
echo "3. Rebuild the Docker image for consistent testing"

echo ""
echo -e "${YELLOW}⚠️  Note:${NC} Package versions change frequently."
echo "Consider regenerating this file periodically or using automation."