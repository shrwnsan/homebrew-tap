#!/bin/bash
# Docker testing script for brew-change
# Provides easy interface to run Docker-based tests

# Remove 'set -e' to prevent script from exiting on failures
# set -e  # Disabled - we'll handle errors manually

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"

# Docker environment options
DOCKERFILE_TEST_UBUNTU="$SCRIPT_DIR/docker/Dockerfile.test-ubuntu"

# Default configuration (Ubuntu-only setup)
ENVIRONMENT_TYPE="ubuntu"
IMAGE_NAME="brew-change-ubuntu"
DOCKERFILE="$DOCKERFILE_TEST_UBUNTU"
GITHUB_AUTH_ENABLED=""  # Set to "with GitHub Auth" when enabled
GITHUB_AUTH_TOGGLE=false  # Toggle state for all Docker operations

# Create results directory
mkdir -p "$RESULTS_DIR"

# Helper function to get Docker volume mounts based on GitHub auth toggle
get_docker_volumes() {
    if [[ "$GITHUB_AUTH_TOGGLE" == true ]]; then
        echo "-v $HOME/.config/gh:/home/brewtest/.config/gh:ro"
    else
        echo ""
    fi
}

# Clear screen and show header
show_header() {
    clear
    echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}           🐳 brew-change Docker Testing Suite${NC}"
    echo -e "${BLUE}              Easy Sandbox Testing${NC}"
    echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"
    echo ""
    # Build environment display string
    env_display="${YELLOW}$ENVIRONMENT_TYPE${NC} (${GREEN}$IMAGE_NAME${NC})"

    # Show GitHub auth status (either temporary or toggle)
    if [[ "$GITHUB_AUTH_TOGGLE" == true ]]; then
        env_display="$env_display ${BLUE}🔐${YELLOW} GitHub Auth: ON${NC}"
    elif [[ -n "$GITHUB_AUTH_ENABLED" ]]; then
        env_display="$env_display ${BLUE}🔐${YELLOW} $GITHUB_AUTH_ENABLED${NC}"
    fi

    echo -e "${CYAN}Current Environment: $env_display${NC}"
    echo -e "${CYAN}Dockerfile: ${YELLOW}$(basename "$DOCKERFILE")${NC}"
    echo ""
}

show_main_menu() {
    show_header
    echo -e "${CYAN}🚀 Quick Start - Choose an option:${NC}"
    echo -e "${GREEN}  1) 🔨 Build Docker Image${NC}              ${YELLOW}One-time setup${NC}"
    echo -e "${GREEN}  2) 🧪 Run All Tests${NC}                   ${YELLOW}Full automated testing${NC}"
    echo -e "${GREEN}  3) 🎮 Quick brew-change Tests${NC}          ${YELLOW}Help and basic list${NC}"
    echo ""
    echo -e "${CYAN}🔧 Docker Management:${NC}"
    echo "  7) 🔐 Toggle GitHub Auth (On/Off)"
    echo "  8) 🏗️ Build Docker Image"
    echo "  9) 🏗️ Rebuild Image (No Cache)"
    echo " 10) 🧹 Clean Docker Environment"
    echo " 11) 🗂️ List Docker Images"
    echo " 12) 📜 View Docker Logs"
    echo ""
    echo -e "${CYAN}🧪 Container Testing:${NC}"
    echo " 13) ⚡ Performance Benchmark"
    echo " 14) 🌐 Network Connectivity Test"
    echo " 15) 🖥️ System Resources Check"
    echo " 16) 📦 Test Specific Package"
    echo ""
    echo -e "${CYAN}🐚 Container Access:${NC}"
    echo " 17) 🐚 Shell Access"
    echo " 18) 🐚 Shell Access (Debug Mode)"
    echo ""
    echo -e "${CYAN}⚙️ Configuration & Results:${NC}"
    echo " 20) 📋 View Test Results"
    echo ""
    echo -e "${RED}  0) 🚪 Exit${NC}"
    echo ""
    echo -e "${YELLOW}Enter your choice [0-19]:${NC} "
}

build_docker_image() {
    echo -e "${BLUE}🔨 Building Docker image...${NC}"
    echo ""

    # Capture docker build exit code to prevent script failure
    build_exit_code=0
    docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" . || build_exit_code=$?

    if [[ $build_exit_code -eq 0 ]]; then
        echo -e "${GREEN}✅ Docker image built successfully!${NC}"
        echo ""
        echo "Image details:"
        docker images | grep "$IMAGE_NAME" | head -1
    else
        echo -e "${RED}❌ Failed to build Docker image (exit code: $build_exit_code)!${NC}"
        echo "Please check the Dockerfile and try again."
        echo "Common issues:"
        echo "  - Docker daemon not running"
        echo "  - Insufficient disk space"
        echo "  - Network connectivity issues"
        echo "  - Dockerfile syntax errors"
        echo ""
        echo "You can try building manually with:"
        echo "  docker build -f $DOCKERFILE -t $IMAGE_NAME ."
    fi

    echo ""
    read -p "Press Enter to continue..."
}

run_automated_tests() {
    # Create a debug file to track execution
    echo "=== DEBUG START: $(date) ===" >> /tmp/docker_test_debug.log
    echo "Function run_automated_tests called" >> /tmp/docker_test_debug.log
    echo "Current user: $(whoami)" >> /tmp/docker_test_debug.log
    echo "Current directory: $(pwd)" >> /tmp/docker_test_debug.log
    echo "DOCKERFILE: $DOCKERFILE" >> /tmp/docker_test_debug.log
    echo "IMAGE_NAME: $IMAGE_NAME" >> /tmp/docker_test_debug.log

    echo -e "${BLUE}🧪 Running automated Docker tests...${NC}" | tee -a /tmp/docker_test_debug.log
    echo "" | tee -a /tmp/docker_test_debug.log

    # Check if image exists
    echo "Checking for Docker image..." | tee -a /tmp/docker_test_debug.log
    if docker images | grep -q "$IMAGE_NAME"; then
        echo -e "${GREEN}✅ Docker image found${NC}" | tee -a /tmp/docker_test_debug.log
        image_exists=true
    else
        echo -e "${YELLOW}⚠️  Docker image not found. Building first...${NC}" | tee -a /tmp/docker_test_debug.log
        echo "" | tee -a /tmp/docker_test_debug.log

        echo "DEBUG: Starting Docker build..." | tee -a /tmp/docker_test_debug.log

        # Simple build command
        if docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" . >> /tmp/docker_test_debug.log 2>&1; then
            echo -e "${GREEN}✅ Docker image built successfully${NC}" | tee -a /tmp/docker_test_debug.log
            image_exists=true
        else
            echo -e "${RED}❌ Docker build failed${NC}" | tee -a /tmp/docker_test_debug.log
            echo "Check /tmp/docker_test_debug.log for details" | tee -a /tmp/docker_test_debug.log
            echo "" | tee -a /tmp/docker_test_debug.log
            echo "DEBUG: Returning from function due to build failure" >> /tmp/docker_test_debug.log
            return
        fi
    fi

    echo "" | tee -a /tmp/docker_test_debug.log
    echo "Running test suite..." | tee -a /tmp/docker_test_debug.log
    echo "====================" | tee -a /tmp/docker_test_debug.log

    echo "DEBUG: About to run Docker container..." >> /tmp/docker_test_debug.log

    # Run the container with output to both screen and log
    echo "Container output:" | tee -a /tmp/docker_test_debug.log

    # Run comprehensive brew-change test suite
    local github_volumes=$(get_docker_volumes)

    echo "Running comprehensive brew-change test suite..." | tee -a /tmp/docker_test_debug.log

    # Test 1: Help command
    echo "" | tee -a /tmp/docker_test_debug.log
    echo "=== Test 1: brew-change --help ===" | tee -a /tmp/docker_test_debug.log
    if [[ -n "$github_volumes" ]]; then
        eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change --help" 2>&1 | tee -a /tmp/docker_test_debug.log
    else
        docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change --help 2>&1 | tee -a /tmp/docker_test_debug.log
    fi

    # Test 2: Simple list (no arguments)
    echo "" | tee -a /tmp/docker_test_debug.log
    echo "=== Test 2: brew-change (simple list) ===" | tee -a /tmp/docker_test_debug.log
    if [[ -n "$github_volumes" ]]; then
        eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change" 2>&1 | tee -a /tmp/docker_test_debug.log
    else
        docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change 2>&1 | tee -a /tmp/docker_test_debug.log
    fi

    # Test 3: Verbose mode
    echo "" | tee -a /tmp/docker_test_debug.log
    echo "=== Test 3: brew-change -v (verbose) ===" | tee -a /tmp/docker_test_debug.log
    if [[ -n "$github_volumes" ]]; then
        eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change -v" 2>&1 | tee -a /tmp/docker_test_debug.log
    else
        docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change -v 2>&1 | tee -a /tmp/docker_test_debug.log
    fi

    # Test 4: All packages (detailed)
    echo "" | tee -a /tmp/docker_test_debug.log
    echo "=== Test 4: brew-change -a (all packages detailed) ===" | tee -a /tmp/docker_test_debug.log
    if [[ -n "$github_volumes" ]]; then
        eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change -a" 2>&1 | tee -a /tmp/docker_test_debug.log
    else
        docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change -a 2>&1 | tee -a /tmp/docker_test_debug.log
    fi

    # Test 5: Invalid package (error handling)
    echo "" | tee -a /tmp/docker_test_debug.log
    echo "=== Test 5: brew-change nonexistent-package-12345 (error handling) ===" | tee -a /tmp/docker_test_debug.log
    if [[ -n "$github_volumes" ]]; then
        eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change nonexistent-package-12345" 2>&1 | tee -a /tmp/docker_test_debug.log
    else
        docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change nonexistent-package-12345 2>&1 | tee -a /tmp/docker_test_debug.log
    fi

    # Test 6: Test with first available outdated package (dynamic)
    echo "" | tee -a /tmp/docker_test_debug.log
    echo "=== Test 6: brew-change <first_available_package> (dynamic test) ===" | tee -a /tmp/docker_test_debug.log
    echo "Checking for available outdated packages..." | tee -a /tmp/docker_test_debug.log

    # Get first available outdated package
    if [[ -n "$github_volumes" ]]; then
        first_package=$(eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change" 2>/dev/null | head -1 | awk '{print $1}' | tr -d '[:space:]')
    else
        first_package=$(docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change 2>/dev/null | head -1 | awk '{print $1}' | tr -d '[:space:]')
    fi

    if [[ -n "$first_package" && "$first_package" != "No" ]]; then
        echo "Testing with package: $first_package" | tee -a /tmp/docker_test_debug.log
        if [[ -n "$github_volumes" ]]; then
            eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change \"$first_package\"" 2>&1 | tee -a /tmp/docker_test_debug.log
        else
            docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change "$first_package" 2>&1 | tee -a /tmp/docker_test_debug.log
        fi
    else
        echo "No outdated packages found for dynamic testing" | tee -a /tmp/docker_test_debug.log
        echo "This is normal if all packages are up to date" | tee -a /tmp/docker_test_debug.log
    fi

    # Test 7: Test with common package if available (fallback)
    echo "" | tee -a /tmp/docker_test_debug.log
    echo "=== Test 7: brew-change node (common package fallback test) ===" | tee -a /tmp/docker_test_debug.log
    if [[ -n "$github_volumes" ]]; then
        eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change node" 2>&1 | tee -a /tmp/docker_test_debug.log
    else
        docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change node 2>&1 | tee -a /tmp/docker_test_debug.log
    fi

    echo "" | tee -a /tmp/docker_test_debug.log
    echo -e "${GREEN}✅ Docker test completed!${NC}" | tee -a /tmp/docker_test_debug.log
    echo "" | tee -a /tmp/docker_test_debug.log

    echo "DEBUG: Function completed successfully" >> /tmp/docker_test_debug.log
    echo "=== DEBUG END: $(date) ===" >> /tmp/docker_test_debug.log

    # Ask user what they want to do next
    echo "" | tee -a /tmp/docker_test_debug.log
    echo -e "${CYAN}📋 What would you like to do next?${NC}" | tee -a /tmp/docker_test_debug.log
    echo "1) Run tests again" | tee -a /tmp/docker_test_debug.log
    echo "2) View debug log" | tee -a /tmp/docker_test_debug.log
    echo "3) Return to menu" | tee -a /tmp/docker_test_debug.log
    echo "" | tee -a /tmp/docker_test_debug.log

    while true; do
        read -p "Enter your choice [1-3]: " choice
        echo "User entered choice: '$choice'" >> /tmp/docker_test_debug.log

        case $choice in
            1)
                echo "DEBUG: User chose to run tests again" >> /tmp/docker_test_debug.log
                echo "" | tee -a /tmp/docker_test_debug.log
                echo -e "${BLUE}🔄 Running tests again...${NC}" | tee -a /tmp/docker_test_debug.log
                echo "" | tee -a /tmp/docker_test_debug.log
                # Clean up debug file and restart the function
                rm -f /tmp/docker_test_debug.log
                run_automated_tests
                return
                ;;
            2)
                echo ""
                echo -e "${YELLOW}📄 Debug log contents:${NC}"
                echo "======================================"
                cat /tmp/docker_test_debug.log
                echo "======================================"
                echo ""
                ;;
            3)
                echo "DEBUG: User chose to return to menu" >> /tmp/docker_test_debug.log
                echo -e "${GREEN}✅ Returning to main menu${NC}" | tee -a /tmp/docker_test_debug.log
                rm -f /tmp/docker_test_debug.log  # Clean up debug file
                return
                ;;
            *)
                echo -e "${RED}Invalid choice. Please enter 1, 2, or 3.${NC}" | tee -a /tmp/docker_test_debug.log
                ;;
        esac
    done
}

run_interactive_menu() {
    echo -e "${BLUE}🎮 Starting interactive Docker menu...${NC}"
    echo ""

    # Set up trap to handle Ctrl+C gracefully
    trap 'echo -e "\n${YELLOW}⚠️  Interrupted by user (Ctrl+C)${NC}"; echo ""; return 2' INT

    # Check if image exists
    if ! docker images | grep -q "$IMAGE_NAME"; then
        echo -e "${YELLOW}⚠️  Docker image not found. Building first...${NC}"
        echo ""

        # Try to build the image
        build_exit_code=0
        docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" . || build_exit_code=$?

        if [[ $build_exit_code -ne 0 ]]; then
            echo -e "${RED}❌ Docker build failed with exit code: $build_exit_code${NC}"
            echo "Cannot start interactive menu without Docker image."
            echo ""
            echo "Common issues:"
            echo "  - Docker daemon not running"
            echo "  - Insufficient disk space"
            echo "  - Network connectivity issues"
            echo "  - Dockerfile syntax errors"
            echo ""
            echo "You can try building manually:"
            echo "  docker build -f $DOCKERFILE -t $IMAGE_NAME ."
            echo ""
            read -p "Press Enter to continue..."
            return
        fi

        echo -e "${GREEN}✅ Docker image built successfully${NC}"
        echo ""
    fi

    echo -e "${CYAN}🎮 Interactive Docker Options:${NC}"
    echo "================================"
    echo "1) Run test script in container"
    echo "2) Get shell access to container"
    echo "3) Run brew-change help (will show error - expected)"
    echo "4) Return to main menu"
    echo ""

    while true; do
        echo ""
        echo "Enter your choice [1-4] (or press Enter for main menu): "

        # Simple read without timeout
        choice=""
        if read -r choice 2>/dev/null; then
            # Got input successfully
            if [[ -n "$choice" ]]; then
                echo "You entered: $choice"
            else
                # User pressed Enter without input
                echo -e "${YELLOW}🏠 Returning to main menu...${NC}"
                break
            fi
        else
            # Read failed
            echo -e "${YELLOW}⚠️  Unable to read input. Returning to main menu.${NC}"
            break
        fi

        # Validate input
        if [[ ! "$choice" =~ ^[1-4]$ ]]; then
            echo -e "${RED}Invalid choice '$choice'. Please enter 1, 2, 3, or 4.${NC}"
            echo ""
            continue
        fi

        case $choice in
            1)
                echo ""
                echo "🧪 Running test script in container..."
                echo "===================================="
                echo ""

                # First check if Docker image exists
                if ! docker images | grep -q "$IMAGE_NAME"; then
                    echo -e "${RED}❌ Docker image '$IMAGE_NAME' not found!${NC}"
                    echo ""
                    echo "🔨 You need to build the Docker image first."
                    echo "   Go to main menu and choose Option 1: Build Docker Image"
                    echo ""
                    echo -e "${CYAN}What would you like to do?${NC}"
                    echo "  1) Build the image now"
                    echo "  2) Return to main menu"
                    echo "  3) Continue in interactive menu"
                    echo ""
                    read -p "Enter your choice [1-3]: " build_choice
                    case $build_choice in
                        1)
                            echo ""
                            echo "🏗️  Building Docker image..."
                            echo "This may take a few minutes..."
                            echo ""
                            if docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" .; then
                                echo ""
                                echo -e "${GREEN}✅ Docker image built successfully!${NC}"
                                echo ""
                                echo "🧪 Running test script now..."
                                echo "============================="
                                if docker run --rm "$IMAGE_NAME"; then
                                    echo ""
                                    echo -e "${GREEN}✅ Test script completed successfully${NC}"
                                else
                                    exit_code=$?
                                    echo ""
                                    echo -e "${YELLOW}⚠️  Test script completed with exit code: $exit_code${NC}"
                                fi
                            else
                                echo ""
                                echo -e "${RED}❌ Failed to build Docker image${NC}"
                            fi
                            ;;
                        2)
                            echo -e "${GREEN}🏠 Returning to main menu...${NC}"
                            break
                            ;;
                        3)
                            echo "Continuing in interactive menu..."
                            ;;
                    esac
                else
                    echo "✅ Docker image found: $IMAGE_NAME"
                    echo ""
                    echo "🚀 Starting test script inside container..."
                    echo "======================================"

                    # Run with visible output and clear indication it's running
                    docker run --rm "$IMAGE_NAME" && docker_exit_code=0 || docker_exit_code=$?

                    echo ""
                    echo "========================================"
                    if [[ $docker_exit_code -eq 0 ]]; then
                        echo -e "${GREEN}✅ Test script completed successfully${NC}"
                    else
                        echo -e "${YELLOW}⚠️  Test script completed with exit code: $docker_exit_code${NC}"
                        echo "Some tests may have failed - this can be normal in this environment."
                    fi
                    echo "========================================"
                fi

                echo ""
                echo -e "${CYAN}✅ Test script completed! Review the output above.${NC}"
                echo ""
                read -p "Press ENTER to show options, or type 'menu' to return to main menu: " continue_choice
                if [[ "$continue_choice" == "menu" ]]; then
                    echo -e "${GREEN}🏠 Returning to main menu...${NC}"
                    break
                fi
                echo ""
                echo -e "${CYAN}🎮 Interactive Docker Options:${NC}"
                echo "================================"
                echo "1) Run test script in container"
                echo "2) Get shell access to container"
                echo "3) Run brew-change help (will show error - expected)"
                echo "4) Return to main menu"
                echo ""
                ;;
            2)
                echo ""
                echo "🐚 Getting shell access to container..."
                echo "======================================"

                if ! docker images | grep -q "$IMAGE_NAME"; then
                    echo -e "${RED}❌ Docker image '$IMAGE_NAME' not found!${NC}"
                    echo "You need to build the image first (Option 1)."
                    echo ""
                    continue
                fi

                echo "✅ Docker image found: $IMAGE_NAME"
                echo ""
                echo "🚀 Opening shell in container..."
                echo "Type 'exit' to return to this menu when done."
                echo ""
                docker run --rm -it --entrypoint /bin/bash "$IMAGE_NAME"

                echo ""
                echo "===================================="
                echo "✅ Shell session ended"
                echo "===================================="
                echo ""
                read -p "Press ENTER to show options, or type 'menu' to return to main menu: " continue_choice
                if [[ "$continue_choice" == "menu" ]]; then
                    echo -e "${GREEN}🏠 Returning to main menu...${NC}"
                    break
                fi
                echo ""
                echo -e "${CYAN}🎮 Interactive Docker Options:${NC}"
                echo "================================"
                echo "1) Run test script in container"
                echo "2) Get shell access to container"
                echo "3) Run brew-change help (will show error - expected)"
                echo "4) Return to main menu"
                echo ""
                ;;
            3)
                echo ""
                echo "🔍 Testing brew-change command in container..."
                echo "============================================="

                if ! docker images | grep -q "$IMAGE_NAME"; then
                    echo -e "${RED}❌ Docker image '$IMAGE_NAME' not found!${NC}"
                    echo "You need to build the image first (Option 1)."
                    echo ""
                    continue
                fi

                echo "✅ Docker image found: $IMAGE_NAME"
                echo ""
                echo "🚀 Running: brew-change --help"
                echo "(Expected to show error due to missing Homebrew)"
                echo ""

                echo "========================================"
                docker run --rm --entrypoint /bin/bash "$IMAGE_NAME" -c "/home/brewtest/brew-change/bin/brew-change --help" || echo "Expected: brew command not found in container"
                echo "========================================"

                echo ""
                echo -e "${CYAN}✅ Command completed! Review the output above.${NC}"
                echo ""
                read -p "Press ENTER to show options, or type 'menu' to return to main menu: " continue_choice
                if [[ "$continue_choice" == "menu" ]]; then
                    echo -e "${GREEN}🏠 Returning to main menu...${NC}"
                    break
                fi
                echo ""
                echo -e "${CYAN}🎮 Interactive Docker Options:${NC}"
                echo "================================"
                echo "1) Run test script in container"
                echo "2) Get shell access to container"
                echo "3) Run brew-change help (will show error - expected)"
                echo "4) Return to main menu"
                echo ""
                ;;
            4)
                echo -e "${GREEN}✅ Returning to main menu${NC}"
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Please enter 1, 2, 3, or 4.${NC}"
                ;;
        esac
    done

    # Restore default signal handling
    trap - INT
}

performance_benchmark() {
    echo -e "${BLUE}⚡ Running Docker performance benchmark...${NC}"
    echo ""

    # Check if image exists
    if ! docker images | grep -q "$IMAGE_NAME"; then
        echo -e "${YELLOW}⚠️  Docker image not found. Building first...${NC}"
        echo ""

        # Try to build the image
        build_exit_code=0
        docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" . || build_exit_code=$?

        if [[ $build_exit_code -ne 0 ]]; then
            echo -e "${RED}❌ Docker build failed with exit code: $build_exit_code${NC}"
            echo "Cannot run performance benchmark without Docker image."
            echo ""
            read -p "Press Enter to continue..."
            return
        fi

        echo -e "${GREEN}✅ Docker image built successfully${NC}"
        echo ""
    fi

    echo "Running performance tests..."
    echo "============================"

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local results_file="$RESULTS_DIR/performance_${timestamp}.log"

    docker run --rm "$IMAGE_NAME" bash -c "
        echo '=== Docker Performance Test ===' &&
        echo 'Timestamp: $(date)' &&
        echo '=== System Resources ===' &&
        cat /proc/meminfo | head -5 &&
        uptime &&
        echo '=== brew-change Performance ===' &&
        time /home/brewtest/brew-change/bin/brew-change -a > /tmp/output.log 2>&1 &&
        echo '=== Output Analysis ===' &&
        echo 'Total lines:' \$(wc -l < /tmp/output.log) &&
        echo 'Package separators:' \$(grep -c '---' /tmp/output.log || echo '0') &&
        echo 'First few lines:' &&
        head -10 /tmp/output.log
    " | tee "$results_file"

    echo ""
    echo -e "${GREEN}✅ Performance test completed!${NC}"
    echo "Results saved to: $results_file"

    echo ""
    read -p "Press Enter to continue..."
}

network_test() {
    echo -e "${BLUE}🌐 Testing Docker network connectivity...${NC}"
    echo ""

    # Check if image exists
    if ! docker images | grep -q "$IMAGE_NAME"; then
        echo -e "${YELLOW}⚠️  Docker image not found. Building first...${NC}"
        echo ""

        # Try to build the image
        build_exit_code=0
        docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" . || build_exit_code=$?

        if [[ $build_exit_code -ne 0 ]]; then
            echo -e "${RED}❌ Docker build failed with exit code: $build_exit_code${NC}"
            echo "Cannot test network connectivity without Docker image."
            echo ""
            read -p "Press Enter to continue..."
            return
        fi

        echo -e "${GREEN}✅ Docker image built successfully${NC}"
        echo ""
    fi

    echo "Testing network from Docker container..."
    echo "======================================="

    docker run --rm "$IMAGE_NAME" bash -c "
        echo '=== Network Connectivity Tests ===' &&
        echo 'Testing GitHub API...' &&
        if curl -s --max-time 5 https://api.github.com >/dev/null; then
            echo '✅ GitHub API: SUCCESS'
        else
            echo '❌ GitHub API: FAILED'
        fi &&
        echo '' &&
        echo 'Testing npm registry...' &&
        if curl -s --max-time 5 https://registry.npmjs.org/ >/dev/null; then
            echo '✅ npm registry: SUCCESS'
        else
            echo '❌ npm registry: FAILED'
        fi &&
        echo '' &&
        echo 'Testing general HTTPS...' &&
        if curl -s --max-time 5 https://httpbin.org/get >/dev/null; then
            echo '✅ General HTTPS: SUCCESS'
        else
            echo '⚠️  General HTTPS: LIMITED (may be expected)'
        fi
    "

    echo ""
    read -p "Press Enter to continue..."
}

system_resources_check() {
    echo -e "${BLUE}🖥️  Docker system resources check...${NC}"
    echo ""

    # Check if image exists
    if ! docker images | grep -q "$IMAGE_NAME"; then
        echo -e "${YELLOW}⚠️  Docker image not found. Building first...${NC}"
        echo ""

        # Try to build the image
        build_exit_code=0
        docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" . || build_exit_code=$?

        if [[ $build_exit_code -ne 0 ]]; then
            echo -e "${RED}❌ Docker build failed with exit code: $build_exit_code${NC}"
            echo "Cannot check system resources without Docker image."
            echo ""
            read -p "Press Enter to continue..."
            return
        fi

        echo -e "${GREEN}✅ Docker image built successfully${NC}"
        echo ""
    fi

    echo "Checking Docker container resources..."
    echo "====================================="

    docker run --rm "$IMAGE_NAME" bash -c "
        echo '=== Docker Container Information ===' &&
        echo 'Container ID:' \$(hostname) &&
        echo 'User:' \$(whoami) &&
        echo 'Working directory:' \$(pwd) &&
        echo '' &&
        echo '=== System Information ===' &&
        uname -a &&
        echo '' &&
        echo '=== Memory Information ===' &&
        cat /proc/meminfo | head -5 &&
        echo '' &&
        echo '=== CPU Information ===' &&
        cat /proc/cpuinfo | head -10 &&
        echo '' &&
        echo '=== Disk Usage ===' &&
        df -h | head -5 &&
        echo '' &&
        echo '=== Process Information ===' &&
        echo 'Total processes:' \$(ps aux | wc -l) &&
        echo 'Brew processes:' \$(ps aux | grep brew | wc -l || echo '0')
    "

    echo ""
    read -p "Press Enter to continue..."
}

clean_docker_environment() {
    echo -e "${BLUE}🧹 Cleaning Docker environment...${NC}"
    echo ""

    echo "Removing Docker images (if exist)..."
    if docker images | grep -q "$IMAGE_NAME"; then
        docker rmi "$IMAGE_NAME" 2>/dev/null || true
        echo -e "${GREEN}✅ Removed $IMAGE_NAME${NC}"
    else
        echo -e "${YELLOW}⚠️  No $IMAGE_NAME found${NC}"
    fi

    echo ""
    echo "Cleaning up any dangling images..."
    docker image prune -f 2>/dev/null || true

    echo ""
    echo "Cleaning up test results..."
    if [[ -d "$RESULTS_DIR" ]]; then
        rm -rf "$RESULTS_DIR"/*
        echo -e "${GREEN}✅ Cleared test results${NC}"
    fi

    echo ""
    echo -e "${GREEN}✅ Docker environment cleaned!${NC}"

    echo ""
    read -p "Press Enter to continue..."
}

view_test_results() {
    echo -e "${BLUE}📋 Viewing test results...${NC}"
    echo ""

    if [[ ! -d "$RESULTS_DIR" ]] || [[ -z "$(ls -A "$RESULTS_DIR" 2>/dev/null)" ]]; then
        echo -e "${YELLOW}⚠️  No test results found.${NC}"
        echo "Run some tests first to generate results."
    else
        echo "Available test results:"
        echo "======================="
        ls -la "$RESULTS_DIR/"
        echo ""

        read -p "Enter filename to view (or press Enter to skip): " results_file

        if [[ -n "$results_file" ]] && [[ -f "$RESULTS_DIR/$results_file" ]]; then
            echo ""
            echo "Contents of $results_file:"
            echo "========================="
            cat "$RESULTS_DIR/$results_file"
        elif [[ -n "$results_file" ]]; then
            echo -e "${RED}❌ File not found: $results_file${NC}"
        fi
    fi

    echo ""
    read -p "Press Enter to continue..."
}

view_docker_logs() {
    echo -e "${BLUE}📜 Viewing Docker logs...${NC}"
    echo ""

    echo "Recent Docker activity:"
    echo "======================="
    docker logs --tail 50 2>/dev/null || echo "No recent container logs available."

    echo ""
    echo "Docker system information:"
    echo "=========================="
    docker system df 2>/dev/null || echo "Docker system info not available."

    echo ""
    read -p "Press Enter to continue..."
}

list_docker_images() {
    echo -e "${BLUE}🗂️  Listing Docker images...${NC}"
    echo ""

    echo "All Docker images:"
    echo "=================="
    docker images

    echo ""
    echo "brew-change related images:"
    echo "=========================="
    docker images | grep -E "(brew-change|alpine)" || echo "No brew-change images found."

    echo ""
    read -p "Press Enter to continue..."
}


rebuild_image_no_cache() {
    echo -e "${BLUE}🏗️  Rebuilding Docker image (no cache)...${NC}"
    echo ""

    echo "Removing existing image..."
    docker rmi "$IMAGE_NAME" 2>/dev/null || true

    echo "Building fresh image (no cache)..."
    if docker build --no-cache -f "$DOCKERFILE" -t "$IMAGE_NAME" .; then
        echo -e "${GREEN}✅ Image rebuilt successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to rebuild image!${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

debug_mode() {
    echo -e "${BLUE}🧪 Debug mode - Shell access to container...${NC}"
    echo ""

    # Check if image exists
    if ! docker images | grep -q "$IMAGE_NAME"; then
        echo -e "${YELLOW}⚠️  Docker image not found. Building first...${NC}"
        echo ""

        # Try to build the image
        build_exit_code=0
        docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" . || build_exit_code=$?

        if [[ $build_exit_code -ne 0 ]]; then
            echo -e "${RED}❌ Docker build failed with exit code: $build_exit_code${NC}"
            echo "Cannot start debug mode without Docker image."
            echo ""
            read -p "Press Enter to continue..."
            return
        fi

        echo -e "${GREEN}✅ Docker image built successfully${NC}"
        echo ""
    fi

    echo "🔍 Debug mode - Container shell access"
    echo "=================================="
    echo ""
    echo "Available commands in container:"
    echo "- ls -la /home/brewtest/brew-change/bin/    # See brew-change files"
    echo "- ls -la /home/brewtest/brew-change/lib/   # See library files"
    echo "- cat /home/brewtest/brew-change/bin/brew-change  # View brew-change script"
    echo "- /home/brewtest/brew-change/bin/brew-change --help  # Test brew-change"
    echo "- /home/brewtest/test.sh                    # Run test script"
    echo ""
    echo "💡 Useful debug commands:"
    echo "- env | grep -E '(PATH|BREW)'              # Check environment"
    echo "- which brew                                # Check if brew exists"
    echo "- ps aux                                    # See running processes"
    echo "- df -h                                     # Check disk usage"
    echo ""
    echo "Type 'exit' to return to menu when you're done."
    echo ""

    docker run --rm -it --entrypoint /bin/bash "$IMAGE_NAME"

    echo ""
    echo -e "${GREEN}✅ Exited debug shell successfully${NC}"

    echo ""
    read -p "Press Enter to continue..."
}

test_specific_package() {
    echo -e "${BLUE}📦 Testing specific package in Docker...${NC}"
    echo ""

    # Check if image exists
    if ! docker images | grep -q "$IMAGE_NAME"; then
        echo -e "${YELLOW}⚠️  Docker image not found. Building first...${NC}"
        echo ""

        # Try to build the image
        build_exit_code=0
        docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" . || build_exit_code=$?

        if [[ $build_exit_code -ne 0 ]]; then
            echo -e "${RED}❌ Docker build failed with exit code: $build_exit_code${NC}"
            echo "Cannot test specific package without Docker image."
            echo ""
            read -p "Press Enter to continue..."
            return
        fi

        echo -e "${GREEN}✅ Docker image built successfully${NC}"
        echo ""
    fi

    read -p "Enter package name to test: " package_name

    if [[ -n "$package_name" ]]; then
        echo ""
        echo "Testing package '$package_name' in Docker container..."
        echo "======================================================="
        echo "Note: This will likely fail due to missing Homebrew (expected behavior)"
        echo ""

        local github_volumes=$(get_docker_volumes)
        if [[ -n "$github_volumes" ]]; then
            eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change \"$package_name\"" || echo "Expected failure: brew command not found in container"
        else
            docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change "$package_name" || echo "Expected failure: brew command not found in container"
        fi

        echo ""
        echo "💡 Tip: To test brew-change properly, you would need to:"
        echo "   1. Install Homebrew in the container"
        echo "   2. Install some packages"
        echo "   3. Then run brew-change on those packages"
    else
        echo "No package name provided."
    fi

    echo ""
    read -p "Press Enter to continue..."
}

run_with_github_auth() {
    echo -e "${BLUE}🚀 Running Simple brew-change Test${NC}"
    echo ""

    # Check if image exists
    if ! docker images | grep -q "$IMAGE_NAME"; then
        echo -e "${YELLOW}⚠️  Docker image not found. Building first...${NC}"
        echo ""

        # Try to build the image
        build_exit_code=0
        docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" . || build_exit_code=$?

        if [[ $build_exit_code -ne 0 ]]; then
            echo -e "${RED}❌ Docker build failed with exit code: $build_exit_code${NC}"
            echo "Cannot run with GitHub auth without Docker image."
            echo ""
            read -p "Press Enter to continue..."
            return
        fi

        echo -e "${GREEN}✅ Docker image built successfully${NC}"
        echo ""
    fi

    echo "📋 Simple brew-change Test Options:"
    echo "======================================"
    echo ""
    echo "This runs a single brew-change execution (no parameters, no -v)."
    echo "Perfect for quick validation that brew-change works in the container."
    echo ""
    echo -e "${CYAN}What it tests:${NC}"
    echo "- ✅ brew-change script execution"
    echo "- ✅ Docker container connectivity"
    echo "- ✅ GitHub credential mounting (if you have gh auth set up)"
    echo ""
    echo -e "${CYAN}What it does NOT test:${NC}"
    echo "- ❌ Verbose mode (-v)"
    echo "- ❌ Parallel processing (-a)"
    echo "- ❌ Specific package changelogs"
    echo ""

    # Check if user has gh config
    if [[ ! -f "$HOME/.config/gh/hosts.yml" ]]; then
        echo -e "${YELLOW}⚠️  No GitHub CLI config found.${NC}"
        echo ""
        echo "Please run 'gh auth login' first on your host system:"
        echo "  gh auth login"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    # Show environment status with GitHub auth
    echo -e "${CYAN}Environment: ${YELLOW}$ENVIRONMENT_TYPE${NC} (${GREEN}$IMAGE_NAME${NC}) ${BLUE}🔐${YELLOW} with GitHub Auth${NC}"
    echo ""
    echo "🏃‍♂️ Running brew-change with GitHub authentication..."
    echo "======================================================"
    echo ""

    # Run with GitHub config mounted
    docker run --rm \
        -v "$HOME/.config/gh:/home/brewtest/.config/gh:ro" \
        "$IMAGE_NAME" \
        /home/brewtest/brew-change/bin/brew-change

    echo ""
    echo -e "${GREEN}✅ Completed with GitHub authentication!${NC}"
    echo -e "${CYAN}Note: This used your local GitHub credentials mounted in the container.${NC}"
    echo -e "${CYAN}Benefits: Higher API limits, private repo access, enhanced GitHub CLI features.${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

toggle_github_auth() {
    echo -e "${BLUE}🔐 GitHub Authentication Toggle${NC}"
    echo "=================================="
    echo ""

    if [[ "$GITHUB_AUTH_TOGGLE" == true ]]; then
        echo -e "${YELLOW}Current status: GitHub Auth ${GREEN}ON${NC}"
        echo ""
        echo "This means ALL Docker test operations will use your local GitHub credentials."
        echo "Volume mount: -v \"\$HOME/.config/gh:/home/brewtest/.config/gh:ro\""
        echo ""
        echo -e "${CYAN}Benefits when enabled:${NC}"
        echo "• Higher GitHub API rate limits"
        echo "• Access to private repositories"
        echo "• Full GitHub CLI integration"
        echo "• Eliminates 'Missing optional dependencies: gh' warnings"
        echo ""
        printf "Would you like to " && printf "${RED}disable${NC}" && printf " GitHub authentication?\n"
        echo "1) Yes, disable GitHub Auth"
        echo "2) No, keep it enabled"
        echo ""
        read -p "Enter your choice [1-2]: " disable_choice

        case $disable_choice in
            1)
                GITHUB_AUTH_TOGGLE=false
                echo ""
                echo -e "${GREEN}✅ GitHub authentication DISABLED${NC}"
                echo -e "${CYAN}All Docker operations will now run without GitHub credentials.${NC}"
                ;;
            2)
                echo ""
                echo -e "${GREEN}✅ GitHub authentication remains ENABLED${NC}"
                ;;
            *)
                echo ""
                echo -e "${YELLOW}Invalid choice. GitHub authentication remains ENABLED.${NC}"
                ;;
        esac
    else
        echo -e "${YELLOW}Current status: GitHub Auth ${RED}OFF${NC}"
        echo ""
        echo "This means Docker test operations run without GitHub credentials."
        echo "You may see 'Missing optional dependencies: gh' warnings."
        echo ""
        echo -e "${CYAN}Requirements to enable:${NC}"
        echo "• You must be logged into GitHub CLI (gh) on your host system"
        echo "• Run 'gh auth login' first if you haven't already"
        echo ""
        echo -e "${CYAN}Benefits when enabled:${NC}"
        echo "• Higher GitHub API rate limits"
        echo "• Access to private repositories"
        echo "• Full GitHub CLI integration"
        echo "• Eliminates 'Missing optional dependencies: gh' warnings"
        echo ""

        # Check if user has gh config
        if [[ ! -f "$HOME/.config/gh/hosts.yml" ]]; then
            echo -e "${RED}⚠️  No GitHub CLI config found.${NC}"
            echo ""
            echo "Please run 'gh auth login' first on your host system:"
            echo "  gh auth login"
            echo ""
            echo -e "${YELLOW}GitHub authentication will remain disabled until you set up gh credentials.${NC}"
        else
            printf "Would you like to " && printf "${GREEN}enable${NC}" && printf " GitHub authentication?\n"
            echo "1) Yes, enable GitHub Auth"
            echo "2) No, keep it disabled"
            echo ""
            read -p "Enter your choice [1-2]: " enable_choice

            case $enable_choice in
                1)
                    GITHUB_AUTH_TOGGLE=true
                    echo ""
                    echo -e "${GREEN}✅ GitHub authentication ENABLED${NC}"
                    echo -e "${CYAN}All Docker operations will now use your GitHub credentials.${NC}"
                    ;;
                2)
                    echo ""
                    echo -e "${GREEN}✅ GitHub authentication remains DISABLED${NC}"
                    ;;
                *)
                    echo ""
                    echo -e "${YELLOW}Invalid choice. GitHub authentication remains DISABLED.${NC}"
                    ;;
            esac
        fi
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# New Option 3: Quick brew-change Tests (help and basic list)
quick_brew_change_tests() {
    echo -e "${BLUE}🎮 Running Quick brew-change Tests...${NC}"
    echo ""

    # Check if Docker image exists
    if ! docker images | grep -q "$IMAGE_NAME"; then
        echo -e "${RED}❌ Docker image '$IMAGE_NAME' not found!${NC}"
        echo ""
        echo "🔨 You need to build the Docker image first."
        echo "   Go to main menu and choose Option 1: Build Docker Image"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    echo "✅ Docker image found: $IMAGE_NAME"
    echo ""

    local github_volumes=$(get_docker_volumes)

    # Test 1: Help command
    echo "=== Test 1: brew-change --help ==="
    if [[ -n "$github_volumes" ]]; then
        eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change --help"
    else
        docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change --help
    fi

    echo ""
    read -p "Press Enter to continue to basic list test..."

    # Test 2: Basic list
    echo ""
    echo "=== Test 2: brew-change (basic outdated list) ==="
    if [[ -n "$github_volumes" ]]; then
        eval "docker run --rm $github_volumes \"$IMAGE_NAME\" /home/brewtest/brew-change/bin/brew-change"
    else
        docker run --rm "$IMAGE_NAME" /home/brewtest/brew-change/bin/brew-change
    fi

    echo ""
    echo -e "${GREEN}✅ Quick brew-change tests completed!${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

# New Option 12: Shell Access to Container (moved from Option 3 submenu)
shell_access_container() {
    echo -e "${BLUE}🐚 Getting shell access to container...${NC}"
    echo ""

    if ! docker images | grep -q "$IMAGE_NAME"; then
        echo -e "${RED}❌ Docker image '$IMAGE_NAME' not found!${NC}"
        echo "You need to build the image first (Option 1)."
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    echo "✅ Docker image found: $IMAGE_NAME"
    echo ""
    echo "🚀 Opening shell in container..."
    echo "Type 'exit' to return to menu when done."
    echo ""

    local github_volumes=$(get_docker_volumes)
    if [[ -n "$github_volumes" ]]; then
        eval "docker run --rm -it $github_volumes --entrypoint /bin/bash \"$IMAGE_NAME\""
    else
        docker run --rm -it --entrypoint /bin/bash "$IMAGE_NAME"
    fi

    echo ""
    echo -e "${GREEN}✅ Shell session ended${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

# Main menu loop
main() {
    while true; do
        show_main_menu
        read -r choice

        case $choice in
            1) build_docker_image ;;
            2) run_automated_tests ;;
            3) quick_brew_change_tests ;;
            7) toggle_github_auth ;;
            8) build_docker_image ;;
            9) rebuild_image_no_cache ;;
            10) clean_docker_environment ;;
            11) list_docker_images ;;
            12) view_docker_logs ;;
            13) performance_benchmark ;;
            14) network_test ;;
            15) system_resources_check ;;
            16) test_specific_package ;;
            17) shell_access_container ;;
            18) debug_mode ;;
            19) view_test_results ;;
            0)
                echo -e "${GREEN}👋 Goodbye!${NC}"
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Parse command line arguments (Ubuntu-only setup)
case "${1:-}" in
    "build")
        build_docker_image
        exit $?
        ;;
    "test")
        run_docker_tests
        exit $?
        ;;
    "clean")
        clean_docker_environment
        exit $?
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command] [environment]"
        echo ""
        echo "Commands:"
        echo "  build [environment]  Build Docker image"
        echo "  test [environment]   Run tests in Docker"
        echo "  clean                Clean Docker environment"
        echo "  help                 Show this help"
        echo ""
        echo "Environments:"
        echo "  full                Full environment with Homebrew (default)"
        echo "  error-handling      Minimal environment for error testing"
        echo ""
        echo "Examples:"
        echo "  $0 build full           # Build full test environment"
        echo "  $0 build error-handling # Build error-handling environment"
        echo "  $0                     # Interactive menu"
        exit 0
        ;;
esac

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker not found!${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker daemon not running!${NC}"
    echo "Please start Docker and try again."
    exit 1
fi

# Start menu if running interactively
if [[ -t 0 ]]; then
    main
    echo -e "${GREEN}✅ Script completed successfully. Thank you for testing brew-change!${NC}"
else
    # Non-interactive mode
    echo "Non-interactive mode detected. Use specific commands:"
    echo "  Build: $0 build"
    echo "  Test:  $0 test"
    echo "  Clean: $0 clean"
fi