#!/bin/bash
# Script to update Dockerfile.test-ubuntu with current package versions
# Ensures Docker testing environment stays synchronized with development environment

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔄 Updating Dockerfile with current package versions...${NC}"
echo ""

# Check if we're in the right directory
if [[ ! -f "Dockerfile.test-ubuntu" ]]; then
    echo -e "${RED}❌ Error: Dockerfile.test-ubuntu not found${NC}"
    echo "Please run this script from the tests/docker/ directory"
    exit 1
fi

# Generate current package versions
echo "📦 Generating current package versions..."
if ./package-versions.sh; then
    echo -e "${GREEN}✅ Package versions generated successfully${NC}"
else
    echo -e "${RED}❌ Failed to generate package versions${NC}"
    exit 1
fi

# Extract package installation commands from the generated file
echo ""
echo "🔧 Updating Dockerfile.test-ubuntu..."

# Create backup
cp Dockerfile.test-ubuntu Dockerfile.test-ubuntu.backup
echo -e "${YELLOW}💾 Created backup: Dockerfile.test-ubuntu.backup${NC}"

# Find the line numbers where packages section starts and ends
start_line=$(grep -n "# Install lightweight testing packages" Dockerfile.test-ubuntu | cut -d: -f1)
end_line=$(grep -n "# Copy brew-change files" Dockerfile.test-ubuntu | cut -d: -f1)

if [[ -n "$start_line" && -n "$end_line" ]]; then
    # Replace the packages section
    head -n $((start_line - 1)) Dockerfile.test-ubuntu > Dockerfile.test-ubuntu.new
    cat package-versions.txt >> Dockerfile.test-ubuntu.new
    tail -n +$((end_line - 1)) Dockerfile.test-ubuntu >> Dockerfile.test-ubuntu.new

    mv Dockerfile.test-ubuntu.new Dockerfile.test-ubuntu
    echo -e "${GREEN}✅ Dockerfile.test-ubuntu updated successfully${NC}"
else
    echo -e "${RED}❌ Could not find package section in Dockerfile${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📋 Summary of changes:${NC}"
echo "======================="
echo "Updated packages with specific versions:"
cat package-versions.txt | grep "RUN.*brew install" | sed 's/RUN \/home\/brewtest\/\.linuxbrew\/bin\/brew install /  - /'

echo ""
echo -e "${YELLOW}🔄 Next Steps:${NC}"
echo "1. Review the updated Dockerfile.test-ubuntu"
echo "2. Rebuild Docker image: docker build -f Dockerfile.test-ubuntu -t brew-change-ubuntu ."
echo "3. Test with: docker run --rm brew-change-ubuntu"
echo ""
echo -e "${GREEN}✅ Update completed successfully!${NC}"