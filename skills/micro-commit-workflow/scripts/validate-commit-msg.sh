#!/bin/bash
#
# Conventional Commit Message Validator
#
# Validates commit messages against the Conventional Commits specification
# with support for LINEAR ticket references.
#
# Usage:
#   ./validate-commit-msg.sh <commit-message-file>
#   ./validate-commit-msg.sh --check "feat: add new feature"
#
# Exit codes:
#   0 - Valid commit message
#   1 - Invalid commit message

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Conventional commit types
VALID_TYPES="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"

# Function to print colored output
print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to show usage
show_usage() {
    cat << EOF
Conventional Commit Message Validator

Usage:
  $0 <commit-message-file>        Validate commit message from file (git hook mode)
  $0 --check "message"             Validate a specific commit message
  $0 --help                        Show this help

Conventional Commit Format:
  <type>(<scope>): <description>

  [optional body]

  [optional footer(s)]

Valid Types:
  feat:     New feature
  fix:      Bug fix
  docs:     Documentation changes
  style:    Code style changes (formatting, no logic change)
  refactor: Code refactoring
  perf:     Performance improvements
  test:     Adding or updating tests
  build:    Build system or dependencies
  ci:       CI/CD configuration
  chore:    Maintenance tasks
  revert:   Revert previous commit

Scope (optional):
  Component, module, or area affected (e.g., api, auth, ui)

Description:
  - Must be lowercase
  - Must start immediately after ': '
  - Should be imperative mood ("add" not "added")
  - No period at the end
  - Max 72 characters recommended

LINEAR Ticket References:
  - Body can include: "LINEAR-123" or "Refs LINEAR-123"
  - Footer can include: "LINEAR: LINEAR-123"

Examples:
  feat(auth): add OAuth2 authentication
  fix(api): resolve null pointer in user service
  docs: update API documentation
  feat(ui): add dark mode toggle

  LINEAR-123

Breaking Changes:
  feat(api)!: remove deprecated endpoints

  BREAKING CHANGE: The /api/v1/old endpoint has been removed

EOF
}

# Function to validate commit message format
validate_commit_message() {
    local message="$1"
    local errors=0
    local warnings=0

    # Skip merge commits
    if [[ "$message" =~ ^Merge\ (branch|pull\ request) ]]; then
        print_info "Merge commit detected - skipping validation"
        return 0
    fi

    # Skip revert commits (they have standard format)
    if [[ "$message" =~ ^Revert\ \" ]]; then
        print_info "Revert commit detected - skipping validation"
        return 0
    fi

    # Extract the first line (subject)
    local subject=$(echo "$message" | head -n 1)

    # Check if subject is empty
    if [[ -z "$subject" ]]; then
        print_error "Commit message cannot be empty"
        return 1
    fi

    # Check basic format: type(scope): description or type: description
    if ! [[ "$subject" =~ ^($VALID_TYPES)(\(.+\))?!?:\ .+ ]]; then
        print_error "Invalid conventional commit format"
        echo ""
        echo "Expected format:"
        echo "  <type>(<scope>): <description>"
        echo "  or"
        echo "  <type>: <description>"
        echo ""
        echo "Your commit: $subject"
        echo ""
        echo "Valid types: ${VALID_TYPES//|/, }"
        echo ""
        echo "Run '$0 --help' for more information"
        ((errors++))
    fi

    # Extract components
    local type=$(echo "$subject" | grep -oP "^($VALID_TYPES)" || echo "")
    local has_breaking=$(echo "$subject" | grep -oP '!(?=:)' || echo "")
    local description=$(echo "$subject" | sed -E "s/^($VALID_TYPES)(\(.+\))?!?:\ //")

    # Validate description
    if [[ -n "$description" ]]; then
        # Check if description starts with uppercase
        if [[ "$description" =~ ^[A-Z] ]]; then
            print_warning "Description should start with lowercase"
            echo "  Found: $description"
            echo "  Should be: ${description,}"
            ((warnings++))
        fi

        # Check if description ends with period
        if [[ "$description" =~ \.$ ]]; then
            print_warning "Description should not end with a period"
            ((warnings++))
        fi

        # Check description length
        local desc_length=${#subject}
        if [ $desc_length -gt 72 ]; then
            print_warning "Subject line is $desc_length characters (recommended max: 72)"
            ((warnings++))
        fi

        # Check for imperative mood (common violations)
        if [[ "$description" =~ ^(added|updated|removed|fixed|changed) ]]; then
            print_warning "Use imperative mood (e.g., 'add' not 'added')"
            ((warnings++))
        fi
    fi

    # Check for LINEAR ticket reference
    if [[ "$message" =~ LINEAR-[0-9]+ ]]; then
        local ticket=$(echo "$message" | grep -oP 'LINEAR-[0-9]+' | head -1)
        print_info "LINEAR ticket reference found: $ticket"
    fi

    # Check for breaking change indicators
    if [[ -n "$has_breaking" ]] || [[ "$message" =~ BREAKING\ CHANGE: ]]; then
        print_info "Breaking change detected"
        if [[ -n "$has_breaking" ]] && ! [[ "$message" =~ BREAKING\ CHANGE: ]]; then
            print_warning "Breaking change indicator '!' found but no 'BREAKING CHANGE:' in body"
            ((warnings++))
        fi
    fi

    # Print summary
    echo ""
    if [ $errors -eq 0 ]; then
        print_success "Commit message is valid!"
        if [ $warnings -gt 0 ]; then
            echo -e "${YELLOW}  Note: $warnings warning(s) found${NC}"
        fi
        return 0
    else
        print_error "Commit message validation failed with $errors error(s)"
        return 1
    fi
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi

    case "$1" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --check)
            if [ $# -lt 2 ]; then
                print_error "Missing commit message argument"
                echo "Usage: $0 --check \"commit message\""
                exit 1
            fi
            validate_commit_message "$2"
            exit $?
            ;;
        *)
            # Assume it's a file path (git hook mode)
            if [ ! -f "$1" ]; then
                print_error "File not found: $1"
                exit 1
            fi

            commit_msg=$(cat "$1")
            validate_commit_message "$commit_msg"
            exit $?
            ;;
    esac
}

main "$@"
