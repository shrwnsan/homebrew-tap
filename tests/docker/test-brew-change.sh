#!/bin/bash
# Comprehensive test script for brew-change in Docker environment

# Remove 'set -e' to handle failures gracefully
# set -e  # Disabled - we'll handle exit codes manually

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  INFO: $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ SUCCESS: $1${NC}"
    ((TESTS_PASSED++))
}

log_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

log_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ((TESTS_FAILED++))
}

run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"

    ((TESTS_TOTAL++))
    echo -e "\n${BLUE}Testing: $test_name${NC}"
    echo "Command: $test_command"

    if output=$(eval "$test_command" 2>&1); then
        if [[ -n "$expected_pattern" ]]; then
            if echo "$output" | grep -q "$expected_pattern"; then
                log_success "$test_name"
                echo "Output preview:"
                echo "$output" | head -5
            else
                log_error "$test_name - Expected pattern not found: $expected_pattern"
                echo "Actual output:"
                echo "$output"
            fi
        else
            log_success "$test_name"
            echo "Output preview:"
            echo "$output" | head -5
        fi
    else
        log_error "$test_name - Command failed"
        echo "Error output:"
        echo "$output"
    fi
}

# Start testing
echo -e "${BLUE}🧪 brew-change Docker Test Suite${NC}"
echo "======================================"

# Check environment
log_info "Checking test environment..."
echo "User: $(whoami)"
echo "Working directory: $(pwd)"
echo "PATH: $PATH"

# Check brew-change installation
if command -v brew-change >/dev/null 2>&1; then
    log_success "brew-change command found"
    echo "Location: $(which brew-change)"
else
    log_error "brew-change command not found"
    exit 1
fi

# Check dependencies
log_info "Checking dependencies..."
dependencies=("bash" "curl" "jq" "git")
for dep in "${dependencies[@]}"; do
    if command -v "$dep" >/dev/null 2>&1; then
        log_success "$dep is available"
    else
        log_error "$dep is missing"
    fi
done

# Check Homebrew
log_info "Checking Homebrew..."
if /home/linuxbrew/.linuxbrew/bin/brew --version >/dev/null 2>&1; then
    log_success "Homebrew is working"
    echo "Homebrew version: $(/home/linuxbrew/.linuxbrew/bin/brew --version | head -1)"
else
    log_error "Homebrew is not working"
fi

# Basic functionality tests
echo -e "\n${BLUE}📋 Basic Functionality Tests${NC}"
echo "================================"

# Test help command
run_test "Help command" "brew-change --help" "Usage: brew-change"

# Test version/invalid package
run_test "Invalid package handling" "brew-change nonexistent-package-12345" "not found"

# Test simple list
run_test "Simple outdated list" "brew-change" ""

# Test verbose mode
run_test "Verbose mode" "brew-change -v" ""

# Performance tests
echo -e "\n${BLUE}⚡ Performance Tests${NC}"
echo "========================"

# Time the basic operations
echo "Timing basic operations..."
time_output=$(time (brew-change >/dev/null 2>&1) 2>&1)
echo "Simple list time: $time_output"

# Test individual package types if available
echo -e "\n${BLUE}📦 Package Type Tests${NC}"
echo "==========================="

# Check what packages are available for testing
outdated_packages=$(brew-change 2>/dev/null | head -5)

if [[ -n "$outdated_packages" ]]; then
    echo "Available test packages:"
    echo "$outdated_packages"

    # Test first available package
    first_package=$(echo "$outdated_packages" | head -1 | awk '{print $1}')
    if [[ -n "$first_package" ]]; then
        run_test "Single package test" "brew-change $first_package" "📦"
    fi
else
    log_warning "No outdated packages available for testing"
fi

# System resource tests
echo -e "\n${BLUE}🖥️  System Resource Tests${NC}"
echo "==============================="

# Check system load
if command -v uptime >/dev/null 2>&1; then
    echo "System load:"
    uptime
    log_success "System load information available"
else
    log_warning "uptime command not available"
fi

# Memory usage check
if command -v free >/dev/null 2>&1; then
    echo "Memory usage:"
    free -h
    log_success "Memory usage information available"
elif [[ -f /proc/meminfo ]]; then
    echo "Memory info:"
    cat /proc/meminfo | head -5
    log_success "Memory information available"
else
    log_warning "Memory usage information not available"
fi

# Additional command-line options tests
echo -e "\n${BLUE}🚀 Additional Command-line Options Tests${NC}"
echo "==============================================="

# Test -a/--all flag (parallel processing)
run_test "All packages flag (-a)" "brew-change -a" ""

# Test invalid flags
run_test "Invalid flag handling" "brew-change --invalid-flag" "Error: Unknown option"

# Test help variations
run_test "Help command (help)" "brew-change help" "Usage: brew-change"
run_test "Help command (-h)" "brew-change -h" "Usage: brew-change"

# Edge case tests
echo -e "\n${BLUE}🎯 Edge Case Tests${NC}"
echo "==================="

# Test with a package that doesn't exist
run_test "Non-existent package" "brew-change absolutely-nonexistent-package-12345" "not found"

# Test with empty argument
run_test "Empty package name" "brew-change ''" ""

# Performance and parallel processing tests
echo -e "\n${BLUE}⚡ Performance Tests${NC}"
echo "======================"

# Time the execution of a simple list
echo -e "\n${YELLOW}Timing simple outdated list:${NC}"
time_output=$(time (brew-change > /dev/null) 2>&1)
echo "$time_output"

# Time the execution with -a flag (parallel processing)
echo -e "\n${YELLOW}Timing -a flag (parallel processing):${NC}"
time_output=$(time (brew-change -a > /dev/null) 2>&1)
echo "$time_output"

# Display formatting tests
echo -e "\n${BLUE}🎨 Display Formatting Tests${NC}"
echo "==========================="

# Test with different TERM settings
echo -e "\n${YELLOW}Testing with basic TERM (no colors):${NC}"
TERM=vt100 run_test "Basic terminal mode" "brew-change" ""

# Test with UTF-8 locale
echo -e "\n${YELLOW}Testing with UTF-8 locale:${NC}"
LC_ALL=C.UTF-8 run_test "UTF-8 locale" "brew-change" ""

# Network connectivity tests
echo -e "\n${BLUE}🌐 Network Connectivity Tests${NC}"
echo "=================================="

# Test GitHub API
run_test "GitHub API connectivity" "curl -s --max-time 5 https://api.github.com" "GitHub"

# Test npm registry
run_test "npm registry connectivity" "curl -s --max-time 5 https://registry.npmjs.org/" "registry"

# Comprehensive test summary
echo -e "\n${BLUE}📊 Test Results Summary${NC}"
echo "========================="
echo -e "Total tests: ${BLUE}$TESTS_TOTAL${NC}"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}💥 Some tests failed!${NC}"
    exit 1
fi