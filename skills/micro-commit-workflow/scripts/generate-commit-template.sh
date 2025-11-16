#!/bin/bash
#
# Commit Message Template Generator
#
# Generates a conventional commit message template with helpful comments
# and LINEAR ticket reference support.
#
# Usage:
#   ./generate-commit-template.sh                    # Interactive mode
#   ./generate-commit-template.sh feat api           # Direct mode
#   ./generate-commit-template.sh --linear LINEAR-123  # With LINEAR ticket
#   ./generate-commit-template.sh --install          # Install as git template
#
# Exit codes:
#   0 - Success
#   1 - Error

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Template file path
TEMPLATE_FILE=".gitmessage"

# Function to show usage
show_usage() {
    cat << EOF
Commit Message Template Generator

Usage:
  $0                              Interactive mode - prompts for input
  $0 <type> [scope]               Generate template with type and optional scope
  $0 --linear <ticket>            Generate with LINEAR ticket reference
  $0 --install                    Install as default git commit template
  $0 --help                       Show this help

Commit Types:
  feat      New feature
  fix       Bug fix
  docs      Documentation changes
  style     Code style changes (formatting)
  refactor  Code refactoring
  perf      Performance improvements
  test      Adding or updating tests
  build     Build system or dependencies
  ci        CI/CD configuration
  chore     Maintenance tasks
  revert    Revert previous commit

Examples:
  $0                              # Interactive mode
  $0 feat                         # feat:
  $0 fix api                      # fix(api):
  $0 --linear LINEAR-123          # With ticket reference
  $0 --install                    # Set as default template

EOF
}

# Function to generate template
generate_template() {
    local type="$1"
    local scope="$2"
    local linear_ticket="$3"

    # Build the subject line
    local subject=""
    if [[ -n "$type" ]]; then
        subject="$type"
        if [[ -n "$scope" ]]; then
            subject="${subject}(${scope})"
        fi
        subject="${subject}: "
    fi

    # Generate the template
    cat << EOF
${subject}
# Conventional Commit Format:
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>

# --- COMMIT GUIDELINES ---
#
# Type (required): feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert
#   feat:     New feature for the user
#   fix:      Bug fix for the user
#   docs:     Documentation only changes
#   style:    Formatting, missing semi colons, etc; no code change
#   refactor: Refactoring production code
#   perf:     Performance improvements
#   test:     Adding tests, refactoring test; no production code change
#   build:    Build system or external dependencies
#   ci:       CI configuration files and scripts
#   chore:    Updating grunt tasks etc; no production code change
#   revert:   Revert to a previous commit
#
# Scope (optional): Component, module, or area of change
#   Examples: api, auth, ui, database, docs
#
# Subject (required):
#   - Use imperative mood ("add" not "added")
#   - Start with lowercase
#   - No period at the end
#   - Max 72 characters
#
# Body (optional):
#   - Explain WHAT and WHY (not HOW)
#   - Wrap at 72 characters
#   - Separate from subject with blank line
#   - Can include multiple paragraphs
#
# Footer (optional):
#   - Breaking changes: BREAKING CHANGE: description
#   - Issue references: Closes #123, Fixes #456
#   - LINEAR tickets: LINEAR-123
#
# --- EXAMPLES ---
#
# feat(auth): add OAuth2 authentication
#
# Implement OAuth2 flow for third-party authentication providers.
# Users can now sign in using Google, GitHub, or Microsoft accounts.
#
# LINEAR-789
#
# ---
#
# fix(api): resolve null pointer in user service
#
# The UserService was throwing NullPointerException when accessing
# users with incomplete profiles. Added null checks and default values.
#
# Fixes #456
# LINEAR-790
#
# ---
#
# feat(ui)!: redesign navigation component
#
# BREAKING CHANGE: Navigation props API has changed. The 'items' prop
# is now required and must be an array of NavigationItem objects.
#
# Migration guide: See docs/migration/navigation-v2.md
#
# LINEAR-791
EOF

    # Add LINEAR ticket reference if provided
    if [[ -n "$linear_ticket" ]]; then
        echo ""
        echo "# LINEAR Ticket: $linear_ticket"
        echo "$linear_ticket"
    fi
}

# Function to install template as default
install_template() {
    local template_path="$PWD/$TEMPLATE_FILE"

    echo -e "${BLUE}Installing commit message template...${NC}"

    # Generate a basic template
    generate_template "" "" "" > "$TEMPLATE_FILE"

    # Set git config to use this template
    git config --local commit.template "$template_path"

    echo -e "${GREEN}✅ Template installed successfully!${NC}"
    echo ""
    echo "The template has been saved to: $template_path"
    echo "Git has been configured to use this template for commits."
    echo ""
    echo "Usage:"
    echo "  git commit          # Opens editor with template"
    echo "  git commit -m \"...\" # Bypasses template (still validated by hook)"
    echo ""
}

# Interactive mode
interactive_mode() {
    echo -e "${BLUE}=== Interactive Commit Template Generator ===${NC}"
    echo ""

    # Get commit type
    echo "Select commit type:"
    echo "  1) feat      - New feature"
    echo "  2) fix       - Bug fix"
    echo "  3) docs      - Documentation"
    echo "  4) style     - Code style"
    echo "  5) refactor  - Code refactoring"
    echo "  6) perf      - Performance"
    echo "  7) test      - Tests"
    echo "  8) build     - Build system"
    echo "  9) ci        - CI/CD"
    echo " 10) chore     - Maintenance"
    echo " 11) revert    - Revert commit"
    echo ""
    read -p "Enter number (1-11): " type_choice

    local type=""
    case "$type_choice" in
        1) type="feat" ;;
        2) type="fix" ;;
        3) type="docs" ;;
        4) type="style" ;;
        5) type="refactor" ;;
        6) type="perf" ;;
        7) type="test" ;;
        8) type="build" ;;
        9) type="ci" ;;
        10) type="chore" ;;
        11) type="revert" ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac

    # Get scope
    echo ""
    read -p "Enter scope (optional, e.g., api, auth, ui): " scope

    # Get LINEAR ticket
    echo ""
    read -p "Enter LINEAR ticket (optional, e.g., LINEAR-123): " linear_ticket

    # Generate template
    echo ""
    echo -e "${GREEN}=== Generated Template ===${NC}"
    echo ""
    generate_template "$type" "$scope" "$linear_ticket"
}

# Main script logic
main() {
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --install)
            install_template
            exit 0
            ;;
        --linear)
            if [ $# -lt 2 ]; then
                echo "Error: Missing LINEAR ticket number"
                echo "Usage: $0 --linear LINEAR-123"
                exit 1
            fi
            generate_template "" "" "$2"
            exit 0
            ;;
        "")
            interactive_mode
            exit 0
            ;;
        *)
            # Direct mode with type and optional scope
            generate_template "$1" "${2:-}" ""
            exit 0
            ;;
    esac
}

main "$@"
