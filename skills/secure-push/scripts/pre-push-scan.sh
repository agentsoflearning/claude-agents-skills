#!/bin/bash

#######################################
# Secure-Push Pre-Push Scanner
# Multi-layer security scanning orchestrator
#######################################

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$SKILL_DIR/configs"
BIN_DIR="$SKILL_DIR/bin"

# Add bin directory to PATH
export PATH="$BIN_DIR:$PATH"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Scan modes
SCAN_MODE="${SCAN_MODE:-standard}"  # fast, standard, deep
SEVERITY_BLOCK="${SEVERITY_BLOCK:-CRITICAL,HIGH}"
SEVERITY_WARN="${SEVERITY_WARN:-MEDIUM,LOW}"

# Tracking variables
CRITICAL_FOUND=0
HIGH_FOUND=0
MEDIUM_FOUND=0
LOW_FOUND=0
TOTAL_FINDINGS=0
EXIT_CODE=0

# Output options
REPORT_FORMAT="${REPORT_FORMAT:-terminal}"  # terminal, json, sarif
OUTPUT_FILE="${OUTPUT_FILE:-}"

# Logging functions
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_section() { echo -e "\n${BOLD}$1${NC}"; }

# Print separator
print_separator() {
    echo "════════════════════════════════════════════════════════"
}

# Check if tools are installed
check_prerequisites() {
    local MISSING_TOOLS=()

    if ! command -v gitleaks >/dev/null 2>&1 && [ ! -x "$BIN_DIR/gitleaks" ]; then
        MISSING_TOOLS+=("gitleaks")
    fi

    if ! command -v semgrep >/dev/null 2>&1 && [ ! -x "$BIN_DIR/semgrep" ]; then
        MISSING_TOOLS+=("semgrep")
    fi

    if ! command -v trivy >/dev/null 2>&1 && [ ! -x "$BIN_DIR/trivy" ]; then
        MISSING_TOOLS+=("trivy")
    fi

    if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
        log_error "Missing tools: ${MISSING_TOOLS[*]}"
        log_info "Install them with: bash $SCRIPT_DIR/install-tools.sh"
        exit 1
    fi
}

# Get list of changed files
get_changed_files() {
    local FILES=()

    # Check if in git repo
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not in a git repository"
        exit 1
    fi

    # Get staged files (for pre-commit) or all tracked files
    if git diff --cached --name-only --diff-filter=d 2>/dev/null | grep -q .; then
        # Staged files exist
        FILES=($(git diff --cached --name-only --diff-filter=d))
    elif git diff --name-only --diff-filter=d HEAD 2>/dev/null | grep -q .; then
        # Changed but unstaged files
        FILES=($(git diff --name-only --diff-filter=d HEAD))
    else
        # No changes, scan all tracked files
        FILES=($(git ls-files))
    fi

    echo "${FILES[@]}"
}

# Run Gitleaks secret scanning
run_gitleaks() {
    log_section "🔍 SECRET SCANNING (Gitleaks)"

    local CONFIG_FILE="$CONFIG_DIR/gitleaks.toml"
    local TEMP_REPORT=$(mktemp)

    # Use custom config if exists, otherwise use default
    local CONFIG_ARG=""
    if [ -f "$CONFIG_FILE" ]; then
        CONFIG_ARG="--config=$CONFIG_FILE"
    fi

    # Run gitleaks on git repository
    if gitleaks detect \
        $CONFIG_ARG \
        --report-path="$TEMP_REPORT" \
        --report-format=json \
        --no-banner \
        --redact 2>/dev/null; then
        log_success "No secrets detected"
        rm -f "$TEMP_REPORT"
        return 0
    else
        # Gitleaks found secrets (exit code 1)
        if [ -f "$TEMP_REPORT" ]; then
            local SECRET_COUNT=$(jq 'length' "$TEMP_REPORT" 2>/dev/null || echo 0)

            if [ "$SECRET_COUNT" -gt 0 ]; then
                log_error "Found $SECRET_COUNT secret(s)"
                echo ""

                # Parse and display findings
                jq -r '.[] | "  → \(.File):\(.StartLine) - \(.Description)\n    Secret: \(.Secret // "REDACTED")\n    Rule: \(.RuleID)"' "$TEMP_REPORT" 2>/dev/null || cat "$TEMP_REPORT"

                CRITICAL_FOUND=$((CRITICAL_FOUND + SECRET_COUNT))
                TOTAL_FINDINGS=$((TOTAL_FINDINGS + SECRET_COUNT))
            fi
            rm -f "$TEMP_REPORT"
        fi
        return 1
    fi
}

# Run Semgrep SAST scanning
run_semgrep() {
    log_section "🔎 CODE ANALYSIS (Semgrep)"

    local CONFIG_FILE="$CONFIG_DIR/semgrep.yaml"
    local LANG_JS_CONFIG="$CONFIG_DIR/languages/javascript.yaml"
    local LANG_PY_CONFIG="$CONFIG_DIR/languages/python.yaml"
    local TEMP_REPORT=$(mktemp)

    # Determine which rulesets to use
    local RULESETS=("auto")

    # Check for language-specific configs
    if [ -f "$LANG_JS_CONFIG" ]; then
        RULESETS+=("$LANG_JS_CONFIG")
    fi
    if [ -f "$LANG_PY_CONFIG" ]; then
        RULESETS+=("$LANG_PY_CONFIG")
    fi
    if [ -f "$CONFIG_FILE" ]; then
        RULESETS+=("$CONFIG_FILE")
    fi

    # Build config arguments
    local CONFIG_ARGS=""
    for ruleset in "${RULESETS[@]}"; do
        CONFIG_ARGS="$CONFIG_ARGS --config=$ruleset"
    done

    # Run Semgrep
    if semgrep scan \
        $CONFIG_ARGS \
        --json \
        --quiet \
        --metrics=off \
        --output="$TEMP_REPORT" \
        . 2>/dev/null; then

        # Check if there are results
        local FINDING_COUNT=$(jq '.results | length' "$TEMP_REPORT" 2>/dev/null || echo 0)

        if [ "$FINDING_COUNT" -eq 0 ]; then
            log_success "No code vulnerabilities detected"
            rm -f "$TEMP_REPORT"
            return 0
        fi
    fi

    # Parse findings by severity
    if [ -f "$TEMP_REPORT" ]; then
        local CRIT=$(jq '[.results[] | select(.extra.severity == "ERROR")] | length' "$TEMP_REPORT" 2>/dev/null || echo 0)
        local HIGH=$(jq '[.results[] | select(.extra.severity == "WARNING")] | length' "$TEMP_REPORT" 2>/dev/null || echo 0)
        local MED=$(jq '[.results[] | select(.extra.severity == "INFO")] | length' "$TEMP_REPORT" 2>/dev/null || echo 0)

        # Adjust severity mapping (Semgrep uses ERROR/WARNING/INFO)
        # We'll treat ERROR as HIGH, WARNING as MEDIUM
        HIGH_FOUND=$((HIGH_FOUND + CRIT + HIGH))
        MEDIUM_FOUND=$((MEDIUM_FOUND + MED))
        TOTAL_FINDINGS=$((TOTAL_FINDINGS + CRIT + HIGH + MED))

        if [ $((CRIT + HIGH + MED)) -gt 0 ]; then
            log_warning "Found $((CRIT + HIGH + MED)) code issue(s)"
            echo ""

            # Display findings
            jq -r '.results[] | "  [\(.extra.severity)] \(.extra.message)\n  → \(.path):\(.start.line)\n  Rule: \(.check_id)\n"' "$TEMP_REPORT" 2>/dev/null | head -20

            if [ $((CRIT + HIGH + MED)) -gt 10 ]; then
                echo "  ... and more (showing first 10)"
            fi
        else
            log_success "No code vulnerabilities detected"
        fi

        rm -f "$TEMP_REPORT"
    fi

    return 0
}

# Run Trivy dependency scanning
run_trivy() {
    log_section "🔬 DEPENDENCY SCANNING (Trivy)"

    # Skip in fast mode
    if [ "$SCAN_MODE" == "fast" ]; then
        log_info "Skipped (fast mode)"
        return 0
    fi

    local TEMP_REPORT=$(mktemp)
    local TRIVY_CONFIG="$CONFIG_DIR/trivy.yaml"

    # Detect dependency files
    local DEP_FILES=()
    [ -f "package.json" ] && DEP_FILES+=("package.json")
    [ -f "package-lock.json" ] && DEP_FILES+=("package-lock.json")
    [ -f "requirements.txt" ] && DEP_FILES+=("requirements.txt")
    [ -f "Pipfile.lock" ] && DEP_FILES+=("Pipfile.lock")
    [ -f "go.mod" ] && DEP_FILES+=("go.mod")
    [ -f "pom.xml" ] && DEP_FILES+=("pom.xml")
    [ -f "Gemfile.lock" ] && DEP_FILES+=("Gemfile.lock")
    [ -f "composer.lock" ] && DEP_FILES+=("composer.lock")

    if [ ${#DEP_FILES[@]} -eq 0 ]; then
        log_info "No dependency files found"
        return 0
    fi

    # Scan filesystem for dependencies
    local SEVERITY_ARG="CRITICAL,HIGH,MEDIUM,LOW"
    if [ "$SCAN_MODE" == "standard" ]; then
        SEVERITY_ARG="CRITICAL,HIGH"
    fi

    if trivy fs \
        --severity "$SEVERITY_ARG" \
        --format json \
        --output "$TEMP_REPORT" \
        --quiet \
        . 2>/dev/null; then

        # Parse results
        local CRIT=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$TEMP_REPORT" 2>/dev/null || echo 0)
        local HIGH=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' "$TEMP_REPORT" 2>/dev/null || echo 0)
        local MED=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "MEDIUM")] | length' "$TEMP_REPORT" 2>/dev/null || echo 0)
        local LOW=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "LOW")] | length' "$TEMP_REPORT" 2>/dev/null || echo 0)

        CRITICAL_FOUND=$((CRITICAL_FOUND + CRIT))
        HIGH_FOUND=$((HIGH_FOUND + HIGH))
        MEDIUM_FOUND=$((MEDIUM_FOUND + MED))
        LOW_FOUND=$((LOW_FOUND + LOW))
        TOTAL_FINDINGS=$((TOTAL_FINDINGS + CRIT + HIGH + MED + LOW))

        if [ $((CRIT + HIGH + MED + LOW)) -gt 0 ]; then
            log_warning "Found $((CRIT + HIGH + MED + LOW)) vulnerabilities (CRIT: $CRIT, HIGH: $HIGH, MED: $MED, LOW: $LOW)"
            echo ""

            # Display top findings
            jq -r '.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL" or .Severity == "HIGH") | "  [\(.Severity)] \(.VulnerabilityID): \(.Title // .Description)\n  → Package: \(.PkgName)@\(.InstalledVersion)\n  Fixed in: \(.FixedVersion // "No fix available")\n"' "$TEMP_REPORT" 2>/dev/null | head -30

            if [ $((CRIT + HIGH)) -gt 5 ]; then
                echo "  ... (showing first 5 critical/high)"
            fi
        else
            log_success "No vulnerabilities detected in dependencies"
        fi

        rm -f "$TEMP_REPORT"
    else
        log_warning "Trivy scan failed or returned errors"
    fi

    return 0
}

# Generate summary report
generate_summary() {
    print_separator
    log_section "📊 SCAN SUMMARY"
    print_separator

    echo ""
    echo "Total Findings: $TOTAL_FINDINGS"
    echo "  Critical: $CRITICAL_FOUND"
    echo "  High:     $HIGH_FOUND"
    echo "  Medium:   $MEDIUM_FOUND"
    echo "  Low:      $LOW_FOUND"
    echo ""

    # Determine if we should block
    if [ $CRITICAL_FOUND -gt 0 ] || [ $HIGH_FOUND -gt 0 ]; then
        print_separator
        log_error "PUSH BLOCKED: Critical or High severity findings detected"
        print_separator
        echo ""
        echo "Please fix the issues above before pushing."
        echo ""
        echo "To bypass this check (not recommended):"
        echo "  git push --no-verify"
        echo ""
        EXIT_CODE=1
    elif [ $MEDIUM_FOUND -gt 0 ] || [ $LOW_FOUND -gt 0 ]; then
        print_separator
        log_warning "WARNINGS DETECTED: Medium or Low severity findings"
        print_separator
        echo ""
        echo "Consider fixing these issues, but push is allowed."
        echo ""
        EXIT_CODE=0
    else
        print_separator
        log_success "ALL CHECKS PASSED - Safe to push! 🎉"
        print_separator
        echo ""
        EXIT_CODE=0
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --fast)
                SCAN_MODE="fast"
                shift
                ;;
            --deep)
                SCAN_MODE="deep"
                shift
                ;;
            --report-format=*)
                REPORT_FORMAT="${1#*=}"
                shift
                ;;
            --output=*)
                OUTPUT_FILE="${1#*=}"
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Run security scans on code changes before pushing.

OPTIONS:
    --fast              Fast mode (secrets only, ~10s)
    --deep              Deep mode (secrets + SAST + SCA, ~2m)
    --report-format=FMT Output format: terminal, json, sarif
    --output=FILE       Save report to file
    --help              Show this help

SCAN MODES:
    fast:     Secrets only (Gitleaks)
    standard: Secrets + Code analysis (Gitleaks + Semgrep) [DEFAULT]
    deep:     Full scan (Gitleaks + Semgrep + Trivy)

EXAMPLES:
    $0                      # Standard scan
    $0 --fast               # Quick secret scan
    $0 --deep               # Comprehensive scan

SEVERITY BLOCKING:
    BLOCK: Critical, High
    WARN:  Medium, Low

EOF
}

# Main execution
main() {
    parse_args "$@"

    print_separator
    echo "🔒 SECURE-PUSH SECURITY SCAN"
    print_separator
    echo "Mode: $SCAN_MODE"
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    print_separator

    # Check prerequisites
    check_prerequisites

    # Run scans based on mode
    run_gitleaks
    echo ""

    if [ "$SCAN_MODE" != "fast" ]; then
        run_semgrep
        echo ""
    fi

    if [ "$SCAN_MODE" == "deep" ]; then
        run_trivy
        echo ""
    fi

    # Generate summary
    generate_summary

    exit $EXIT_CODE
}

main "$@"
