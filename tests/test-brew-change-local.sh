#!/bin/bash
# Interactive menu for brew-change testing and operations

# Remove 'set -e' to prevent script from exiting on failures
# set -e  # Disabled - we'll handle errors manually

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Clear screen and show header
show_header() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           🧪 brew-change Local Testing Suite           ║${NC}"
    echo -e "${BLUE}║              Easy Development Testing                ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_main_menu() {
    show_header
    echo -e "${CYAN}🚀 Quick Start - Choose an option:${NC}"
    echo ""
    echo -e "${GREEN}  1) 🧪 Run All Tests${NC}                        ${YELLOW}Full validation${NC}"
    echo -e "${GREEN}  2) 📋 Test Basic Functionality${NC}              ${YELLOW}Quick checks${NC}"
    echo -e "${GREEN}  3) ⚡ Performance Benchmark${NC}                 ${YELLOW}Speed testing${NC}"
    echo ""
    echo -e "${CYAN}📦 Package Testing:${NC}"
    echo "  4) Test Individual Package"
    echo "  5) 🌐 Network Connectivity Test"
    echo "  6) 🖥️  System Resources Check"
    echo "  7) 🔍 Debug Mode Testing"
    echo ""
    echo -e "${CYAN}🔧 Real Operations:${NC}"
    echo "  8) 📊 Show Outdated Packages"
    echo "  9) 🔎 Test Specific Package"
    echo " 10) 📋 Verbose Package List"
    echo " 11) 🚀 Comprehensive Test Suite"
    echo ""
    echo -e "${CYAN}🏥 Environment:${NC}"
    echo " 12) Health Check"
    echo " 13) ⚙️  Show Configuration"
    echo ""
    echo -e "${RED}  0) 🚪 Exit${NC}"
    echo ""
    echo -e "${YELLOW}Enter your choice [0-13]:${NC} "
}

run_all_tests() {
    echo -e "${BLUE}🚀 Running comprehensive test suite...${NC}"
    echo ""

    # Check if we're in the right environment and run appropriate tests
    if [[ -f "/home/brewtest/test.sh" ]]; then
        # We're in Docker environment
        test_exit_code=0
        /home/brewtest/test.sh || test_exit_code=$?

        if [[ $test_exit_code -eq 0 ]]; then
            echo -e "\n${GREEN}✅ All automated tests passed!${NC}"
        else
            echo -e "\n${YELLOW}⚠️  Some tests had issues (exit code: $test_exit_code)${NC}"
            echo "This is normal if not all packages or dependencies are available."
        fi
    else
        # We're in local environment - run basic functionality tests
        echo "Running local environment tests..."

        test_exit_code=0

        # Test help command
        echo "Testing help command..."
        if ./brew-change --help >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Help command works${NC}"
        else
            echo -e "${RED}❌ Help command failed${NC}"
            test_exit_code=1
        fi

        # Test simple list
        echo "Testing basic functionality..."
        if ./brew-change >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Basic functionality works${NC}"
        else
            echo -e "${RED}❌ Basic functionality failed${NC}"
            test_exit_code=1
        fi

        if [[ $test_exit_code -eq 0 ]]; then
            echo -e "\n${GREEN}✅ Local tests completed successfully!${NC}"
        else
            echo -e "\n${YELLOW}⚠️  Some local tests had issues${NC}"
        fi
    fi

    echo ""
    read -p "Press Enter to continue..."
}

test_basic_functionality() {
    echo -e "${BLUE}📋 Testing basic functionality...${NC}"
    echo ""

    # Test help command
    echo "Testing help command..."
    if command -v brew-change >/dev/null 2>&1; then
        brew_change_cmd="brew-change"
    elif [[ -f "./brew-change" ]]; then
        brew_change_cmd="./brew-change"
    else
        echo -e "${RED}❌ brew-change command not found${NC}"
        echo "Try: export PATH=\"$(pwd):\$$PATH\""
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    if $brew_change_cmd --help >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Help command works${NC}"
    else
        echo -e "${RED}❌ Help command failed${NC}"
    fi

    # Test simple list
    echo "Testing simple outdated list..."
    if $brew_change_cmd >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Simple list works${NC}"
    else
        echo -e "${RED}❌ Simple list failed${NC}"
    fi

    # Test verbose mode
    echo "Testing verbose mode..."
    if $brew_change_cmd -v >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Verbose mode works${NC}"
    else
        echo -e "${RED}❌ Verbose mode failed${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

performance_benchmark() {
    echo -e "${BLUE}⚡ Running performance benchmark...${NC}"
    echo ""

    # Determine brew-change command
    if command -v brew-change >/dev/null 2>&1; then
        brew_change_cmd="brew-change"
    elif [[ -f "./brew-change" ]]; then
        brew_change_cmd="./brew-change"
    else
        echo -e "${RED}❌ brew-change command not found${NC}"
        echo "Try: export PATH=\"$(pwd):\$$PATH\""
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    echo "Timing basic operations..."
    echo "Running: $brew_change_cmd"
    time_output=$(time ($brew_change_cmd >/dev/null 2>&1) 2>&1)
    echo "Simple list time: $time_output"

    echo ""
    echo "System resources:"
    echo "Memory usage:"
    if command -v free >/dev/null 2>&1; then
        free -h | head -3
    elif [[ -f /proc/meminfo ]]; then
        cat /proc/meminfo | head -3
    else
        echo "Memory info not available"
    fi
    echo "System load:"
    uptime 2>/dev/null || echo "Load info unavailable"

    echo ""
    read -p "Press Enter to continue..."
}

test_individual_package() {
    echo -e "${BLUE}📦 Test Individual Package${NC}"
    echo ""

    # Show available packages
    echo "Available outdated packages:"
    if command -v brew-change >/dev/null 2>&1; then
        brew-change | head -10
    elif [[ -f "./brew-change" ]]; then
        ./brew-change | head -10
    else
        echo "brew-change not found"
        return
    fi
    echo ""

    read -p "Enter package name to test (or press Enter to skip): " package_name

    if [[ -n "$package_name" ]]; then
        echo ""
        echo "Testing package: $package_name"
        echo "----------------------------------------"
        if command -v brew-change >/dev/null 2>&1; then
            brew-change "$package_name"
        elif [[ -f "./brew-change" ]]; then
            ./brew-change "$package_name"
        fi
    else
        echo "Skipping individual package test."
    fi

    echo ""
    read -p "Press Enter to continue..."
}

network_test() {
    echo -e "${BLUE}🌐 Testing network connectivity...${NC}"
    echo ""

    # Test GitHub API
    echo "Testing GitHub API..."
    if curl -s --max-time 5 https://api.github.com >/dev/null 2>&1; then
        echo -e "${GREEN}✅ GitHub API accessible${NC}"
    else
        echo -e "${RED}❌ GitHub API not accessible${NC}"
    fi

    # Test npm registry
    echo "Testing npm registry..."
    if curl -s --max-time 5 https://registry.npmjs.org/ >/dev/null 2>&1; then
        echo -e "${GREEN}✅ npm registry accessible${NC}"
    else
        echo -e "${RED}❌ npm registry not accessible${NC}"
    fi

    # Test a generic HTTPS request
    echo "Testing general HTTPS..."
    if curl -s --max-time 5 https://httpbin.org/get >/dev/null 2>&1; then
        echo -e "${GREEN}✅ General HTTPS works${NC}"
    else
        echo -e "${YELLOW}⚠️  General HTTPS limited (may be expected)${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

system_resources_check() {
    echo -e "${BLUE}🖥️  System Resources Check${NC}"
    echo ""

    echo "System Information:"
    echo "-----------------"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"

    echo ""
    echo "Memory Usage:"
    echo "------------"
    if [[ -f /proc/meminfo ]]; then
        echo "Total: $(grep MemTotal /proc/meminfo | awk '{print $2" "$3}')"
        echo "Available: $(grep MemAvailable /proc/meminfo | awk '{print $2" "$3}')"
        echo "Free: $(grep MemFree /proc/meminfo | awk '{print $2" "$3}')"
    else
        echo "Memory info not available"
    fi

    echo ""
    echo "CPU Load:"
    echo "---------"
    if command -v uptime >/dev/null 2>&1; then
        uptime
    else
        echo "Load info not available"
    fi

    echo ""
    echo "Disk Usage:"
    echo "----------"
    df -h | head -5

    echo ""
    echo "Process Count:"
    echo "-------------"
    ps aux | wc -l

    echo ""
    read -p "Press Enter to continue..."
}

debug_mode_test() {
    echo -e "${BLUE}🔍 Debug Mode Testing${NC}"
    echo ""

    # Determine brew-change command
    if command -v brew-change >/dev/null 2>&1; then
        brew_change_cmd="brew-change"
    elif [[ -f "./brew-change" ]]; then
        brew_change_cmd="./brew-change"
    else
        echo -e "${RED}❌ brew-change command not found${NC}"
        echo "Try: export PATH=\"$(pwd):\$$PATH\""
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    echo "Enabling debug mode (BREW_CHANGE_DEBUG=1)..."
    export BREW_CHANGE_DEBUG=1

    echo ""
    echo "Testing with debug output..."
    echo "----------------------------------------"
    echo "Command: $brew_change_cmd --help"
    $brew_change_cmd --help 2>&1 | head -10

    echo ""
    echo "Testing invalid package with debug..."
    echo "----------------------------------------"
    echo "Command: $brew_change_cmd nonexistent-debug-test-123"
    $brew_change_cmd nonexistent-debug-test-123 2>&1 | head -10

    # Unset debug mode
    unset BREW_CHANGE_DEBUG
    echo ""
    echo "Debug mode tests completed."

    echo ""
    read -p "Press Enter to continue..."
}

show_outdated_packages() {
    echo -e "${BLUE}📊 Current Outdated Packages${NC}"
    echo ""

    # Determine brew-change command
    if command -v brew-change >/dev/null 2>&1; then
        brew_change_cmd="brew-change"
    elif [[ -f "./brew-change" ]]; then
        brew_change_cmd="./brew-change"
    else
        echo -e "${RED}❌ brew-change command not found${NC}"
        echo "Try: export PATH=\"$(pwd):\$$PATH\""
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    echo "Simple list:"
    echo "-----------"
    $brew_change_cmd

    echo ""
    echo "Verbose list:"
    echo "------------"
    $brew_change_cmd -v

    echo ""
    read -p "Press Enter to continue..."
}

test_specific_package() {
    echo -e "${BLUE}🔎 Test Specific Package${NC}"
    echo ""

    # Determine brew-change command
    if command -v brew-change >/dev/null 2>&1; then
        brew_change_cmd="brew-change"
    elif [[ -f "./brew-change" ]]; then
        brew_change_cmd="./brew-change"
    else
        echo -e "${RED}❌ brew-change command not found${NC}"
        echo "Try: export PATH=\"$(pwd):\$$PATH\""
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    read -p "Enter package name: " package_name

    if [[ -n "$package_name" ]]; then
        echo ""
        echo "Testing package: $package_name"
        echo "=========================================="
        echo "Command: $brew_change_cmd $package_name"
        $brew_change_cmd "$package_name"
    else
        echo "No package name provided."
    fi

    echo ""
    read -p "Press Enter to continue..."
}

show_verbose_list() {
    echo -e "${BLUE}📋 Verbose Package List${NC}"
    echo ""

    # Determine brew-change command
    if command -v brew-change >/dev/null 2>&1; then
        brew_change_cmd="brew-change"
    elif [[ -f "./brew-change" ]]; then
        brew_change_cmd="./brew-change"
    else
        echo -e "${RED}❌ brew-change command not found${NC}"
        echo "Try: export PATH=\"$(pwd):\$$PATH\""
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    echo "Command: $brew_change_cmd -v"
    $brew_change_cmd -v

    echo ""
    read -p "Press Enter to continue..."
}

comprehensive_test_suite() {
    echo -e "${BLUE}🚀 Comprehensive Test Suite${NC}"
    echo "============================="
    echo ""

    # Determine brew-change command
    if command -v brew-change >/dev/null 2>&1; then
        brew_change_cmd="brew-change"
    elif [[ -f "./brew-change" ]]; then
        brew_change_cmd="./brew-change"
    else
        echo -e "${RED}❌ brew-change command not found${NC}"
        echo "Try: export PATH=\"$(pwd):\$$PATH\""
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    local test_count=0
    local pass_count=0

    # Test 1: Help variations
    echo -e "${CYAN}Testing help commands...${NC}"
    for help_cmd in "--help" "-h" "help"; do
        ((test_count++))
        if $brew_change_cmd $help_cmd >/dev/null 2>&1; then
            echo -e "  ${GREEN}✅ brew-change $help_cmd${NC}"
            ((pass_count++))
        else
            echo -e "  ${RED}❌ brew-change $help_cmd${NC}"
        fi
    done

    # Test 2: Basic modes
    echo -e "\n${CYAN}Testing basic modes...${NC}"
    for mode in "" "-v" "-a"; do
        ((test_count++))
        if $brew_change_cmd $mode >/dev/null 2>&1; then
            echo -e "  ${GREEN}✅ brew-change $mode${NC}"
            ((pass_count++))
        else
            echo -e "  ${RED}❌ brew-change $mode${NC}"
        fi
    done

    # Test 3: Invalid inputs
    echo -e "\n${CYAN}Testing invalid inputs...${NC}"
    ((test_count++))
    if $brew_change_cmd --invalid-option 2>&1 | grep -q "Error: Unknown option"; then
        echo -e "  ${GREEN}✅ Invalid option handling${NC}"
        ((pass_count++))
    else
        echo -e "  ${RED}❌ Invalid option handling${NC}"
    fi

    ((test_count++))
    if $brew_change_cmd nonexistent-package-12345 2>&1 | grep -q "not found"; then
        echo -e "  ${GREEN}✅ Non-existent package handling${NC}"
        ((pass_count++))
    else
        echo -e "  ${RED}❌ Non-existent package handling${NC}"
    fi

    # Test 4: Environment variations
    echo -e "\n${CYAN}Testing environment variations...${NC}"
    ((test_count++))
    if TERM=vt100 $brew_change_cmd >/dev/null 2>&1; then
        echo -e "  ${GREEN}✅ Basic terminal mode${NC}"
        ((pass_count++))
    else
        echo -e "  ${RED}❌ Basic terminal mode${NC}"
    fi

    ((test_count++))
    if LC_ALL=C.UTF-8 $brew_change_cmd >/dev/null 2>&1; then
        echo -e "  ${GREEN}✅ UTF-8 locale${NC}"
        ((pass_count++))
    else
        echo -e "  ${RED}❌ UTF-8 locale${NC}"
    fi

    # Test 5: Performance check
    echo -e "\n${CYAN}Testing performance...${NC}"
    echo -e "  ${YELLOW}Timing simple list:${NC}"
    time_output=$(time ($brew_change_cmd >/dev/null) 2>&1)
    echo "    $time_output"

    # Summary
    echo -e "\n${BLUE}Test Summary${NC}"
    echo "============="
    echo -e "Total tests: $test_count"
    echo -e "Passed: ${GREEN}$pass_count${NC}"
    echo -e "Failed: ${RED}$((test_count - pass_count))${NC}"

    if [[ $pass_count -eq $test_count ]]; then
        echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    else
        echo -e "\n${YELLOW}⚠️  Some tests failed${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

health_check() {
    echo -e "${BLUE}🏥 Environment Health Check${NC}"
    echo ""

    # Check user
    echo "User: $(whoami)"

    # Check working directory
    echo "Working directory: $(pwd)"

    # Check PATH
    echo "PATH includes brew-change: $(echo $PATH | grep -q brew-change && echo 'Yes' || echo 'No')"

    # Check brew-change command
    if command -v brew-change >/dev/null 2>&1; then
        echo -e "${GREEN}✅ brew-change command available${NC}"
        echo "Location: $(which brew-change)"
    elif [[ -f "./brew-change" ]]; then
        echo -e "${YELLOW}⚠️  brew-change found in current directory - not in PATH${NC}"
        echo "Location: $(pwd)/brew-change"
    else
        echo -e "${RED}❌ brew-change command not found${NC}"
        echo "Try: export PATH=\"$(pwd):\$$PATH\""
    fi

    # Check dependencies
    echo ""
    echo "Dependency Check:"
    for dep in bash curl jq git; do
        if command -v "$dep" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✅ $dep${NC}"
        else
            echo -e "  ${RED}❌ $dep${NC}"
        fi
    done

    # Check Homebrew
    echo ""
    if /home/linuxbrew/.linuxbrew/bin/brew --version >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Homebrew working${NC}"
    else
        echo -e "${RED}❌ Homebrew not working${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

show_configuration() {
    echo -e "${BLUE}⚙️  Current Configuration${NC}"
    echo ""

    echo "Environment Variables:"
    echo "---------------------"
    env | grep BREW_CHANGE_ || echo "No BREW_CHANGE variables set"

    echo ""
    echo "Default Settings:"
    echo "-----------------"
    echo "BREW_CHANGE_JOBS: ${BREW_CHANGE_JOBS:-8 (default)}"
    echo "BREW_CHANGE_DEBUG: ${BREW_CHANGE_DEBUG:-0 (default)}"
    echo "BREW_CHANGE_MAX_RETRIES: ${BREW_CHANGE_MAX_RETRIES:-3 (default)}"

    echo ""
    echo "File Locations:"
    echo "--------------"
    echo "brew-change binary: $(which brew-change)"
    echo "Library directory: $(dirname $(dirname $(which brew-change)))/lib/brew-change"
    echo "Homebrew installation: /home/linuxbrew/.linuxbrew"

    echo ""
    read -p "Press Enter to continue..."
}

# Main menu loop
main() {
    while true; do
        show_main_menu
        read -r choice

        case $choice in
            1) run_all_tests ;;
            2) test_basic_functionality ;;
            3) performance_benchmark ;;
            4) test_individual_package ;;
            5) network_test ;;
            6) system_resources_check ;;
            7) debug_mode_test ;;
            8) show_outdated_packages ;;
            9) test_specific_package ;;
            10) show_verbose_list ;;
            11) comprehensive_test_suite ;;
            12) health_check ;;
            13) show_configuration ;;
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

# Check if we're running interactively
if [[ -t 0 ]]; then
    main
    echo -e "${GREEN}✅ Script completed successfully. Thank you for testing brew-change!${NC}"
else
    # Not interactive, run basic validation
    echo "Non-interactive mode detected. Running basic validation..."

    # Basic functionality tests
    echo "Running brew-change --help..."
    if command -v brew-change >/dev/null 2>&1; then
        brew-change --help >/dev/null 2>&1 && echo "✅ Help command works" || echo "❌ Help command failed"
        echo ""
        echo "Testing outdated list..."
        brew-change >/dev/null 2>&1 && echo "✅ Outdated list works" || echo "❌ Outdated list failed"
    else
        echo "❌ brew-change not found in PATH"
        echo "Try: export PATH=\"$(pwd):\$$PATH\""
        exit 1
    fi

    echo ""
    echo "Basic validation completed."
fi