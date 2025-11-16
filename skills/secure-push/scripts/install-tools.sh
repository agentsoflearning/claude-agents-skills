#!/bin/bash
set -e

#######################################
# Secure-Push Tool Installer
# Installs Gitleaks, Semgrep, and Trivy
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
BIN_DIR="$SKILL_DIR/bin"
VERSION_FILE="$SKILL_DIR/.tool-versions"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Tool versions (update these periodically)
GITLEAKS_VERSION="8.18.4"
TRIVY_VERSION="0.67.2"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS and architecture
detect_os() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
  Linux*) OS_TYPE="linux" ;;
  Darwin*) OS_TYPE="macOS" ;;
  *)
    log_error "Unsupported OS: $OS"
    exit 1
    ;;
  esac

  case "$ARCH" in
  x86_64 | amd64) ARCH_TYPE="amd64" ;;
  arm64 | aarch64) ARCH_TYPE="arm64" ;;
  *)
    log_error "Unsupported architecture: $ARCH"
    exit 1
    ;;
  esac

  log_info "Detected OS: $OS_TYPE, Architecture: $ARCH_TYPE"
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if Docker is available (fallback option)
check_docker() {
  if command_exists docker; then
    log_info "Docker is available as a fallback"
    return 0
  fi
  return 1
}

# Install Gitleaks
install_gitleaks() {
  log_info "Installing Gitleaks v${GITLEAKS_VERSION}..."

  if command_exists gitleaks; then
    CURRENT_VERSION=$(gitleaks version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    if [[ "$CURRENT_VERSION" == "$GITLEAKS_VERSION" ]]; then
      log_success "Gitleaks v${GITLEAKS_VERSION} already installed"
      return 0
    fi
    log_warning "Gitleaks v${CURRENT_VERSION} found, upgrading to v${GITLEAKS_VERSION}"
  fi

  # Create bin directory if it doesn't exist
  mkdir -p "$BIN_DIR"

  # Download binary
  DOWNLOAD_URL="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_${OS_TYPE}_${ARCH_TYPE}.tar.gz"
  TEMP_FILE=$(mktemp)

  log_info "Downloading from $DOWNLOAD_URL"

  if command_exists curl; then
    curl -sL "$DOWNLOAD_URL" -o "$TEMP_FILE"
  elif command_exists wget; then
    wget -q "$DOWNLOAD_URL" -O "$TEMP_FILE"
  else
    log_error "Neither curl nor wget found. Please install one of them."
    exit 1
  fi

  # Extract binary
  tar -xzf "$TEMP_FILE" -C "$BIN_DIR" gitleaks
  chmod +x "$BIN_DIR/gitleaks"
  rm "$TEMP_FILE"

  # Add to PATH if not already
  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    export PATH="$BIN_DIR:$PATH"
  fi

  if command_exists gitleaks || [ -x "$BIN_DIR/gitleaks" ]; then
    log_success "Gitleaks installed successfully at $BIN_DIR/gitleaks"
    echo "gitleaks=$GITLEAKS_VERSION" >>"$VERSION_FILE"
  else
    log_error "Gitleaks installation failed"
    return 1
  fi
}

# Install Semgrep
install_semgrep() {
  log_info "Installing Semgrep..."

  if command_exists semgrep; then
    log_success "Semgrep already installed"
    semgrep --version | head -1
    return 0
  fi

  # Try pip/pip3 first (most reliable)
  if command_exists pip3; then
    log_info "Installing via pip3..."
    pip3 install --user semgrep >/dev/null 2>&1 || {
      log_warning "pip3 install failed, trying alternative methods..."
    }
  elif command_exists pip; then
    log_info "Installing via pip..."
    pip install --user semgrep >/dev/null 2>&1 || {
      log_warning "pip install failed, trying alternative methods..."
    }
  fi

  # Check if installed via pip
  if command_exists semgrep; then
    log_success "Semgrep installed successfully via pip"
    return 0
  fi

  # Try Homebrew on macOS
  if [[ "$OS_TYPE" == "darwin" ]] && command_exists brew; then
    log_info "Installing via Homebrew..."
    brew install semgrep
    log_success "Semgrep installed successfully via Homebrew"
    return 0
  fi

  # Binary installation as fallback
  log_info "Installing Semgrep binary..."
  mkdir -p "$BIN_DIR"

  DOWNLOAD_URL="https://github.com/semgrep/semgrep/releases/latest/download/semgrep-${OS_TYPE}-${ARCH_TYPE}"

  if command_exists curl; then
    curl -sL "$DOWNLOAD_URL" -o "$BIN_DIR/semgrep"
  elif command_exists wget; then
    wget -q "$DOWNLOAD_URL" -O "$BIN_DIR/semgrep"
  fi

  chmod +x "$BIN_DIR/semgrep"

  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    export PATH="$BIN_DIR:$PATH"
  fi

  if command_exists semgrep || [ -x "$BIN_DIR/semgrep" ]; then
    log_success "Semgrep installed successfully"
    return 0
  else
    log_error "Semgrep installation failed"
    return 1
  fi
}

# Install Trivy
install_trivy() {
  log_info "Installing Trivy v${TRIVY_VERSION}..."

  if command_exists trivy; then
    CURRENT_VERSION=$(trivy version 2>/dev/null | grep -oE 'Version: [0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    if [[ "$CURRENT_VERSION" == "$TRIVY_VERSION" ]]; then
      log_success "Trivy v${TRIVY_VERSION} already installed"
      return 0
    fi
    log_warning "Trivy v${CURRENT_VERSION} found, upgrading to v${TRIVY_VERSION}"
  fi

  mkdir -p "$BIN_DIR"

  # Download and install
  DOWNLOAD_URL="https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_${OS_TYPE}-${ARCH_TYPE}.tar.gz"
  TEMP_FILE=$(mktemp)

  log_info "Downloading from $DOWNLOAD_URL"

  if command_exists curl; then
    curl -sL "$DOWNLOAD_URL" -o "$TEMP_FILE"
  elif command_exists wget; then
    wget -q "$DOWNLOAD_URL" -O "$TEMP_FILE"
  else
    log_error "Neither curl nor wget found"
    exit 1
  fi

  # Extract binary
  mkdir -p bin
  tar -xzvf "$TEMP_FILE" -C "$BIN_DIR" trivy
  chmod +x "$BIN_DIR/trivy"
  rm "$TEMP_FILE"

  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    export PATH="$BIN_DIR:$PATH"
  fi

  if command_exists trivy || [ -x "$BIN_DIR/trivy" ]; then
    log_success "Trivy installed successfully at $BIN_DIR/trivy"
    echo "trivy=$TRIVY_VERSION" >>"$VERSION_FILE"
  else
    log_error "Trivy installation failed"
    return 1
  fi
}

# Check if all tools are installed
check_tools() {
  log_info "Checking tool installations..."

  ALL_INSTALLED=true

  # Check Gitleaks
  if command_exists gitleaks || [ -x "$BIN_DIR/gitleaks" ]; then
    VERSION=$(gitleaks version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    log_success "Gitleaks: ✓ (v${VERSION})"
  else
    log_error "Gitleaks: ✗ (not installed)"
    ALL_INSTALLED=false
  fi

  # Check Semgrep
  if command_exists semgrep || [ -x "$BIN_DIR/semgrep" ]; then
    VERSION=$(semgrep --version 2>/dev/null | head -1 || echo "unknown")
    log_success "Semgrep: ✓ ($VERSION)"
  else
    log_error "Semgrep: ✗ (not installed)"
    ALL_INSTALLED=false
  fi

  # Check Trivy
  if command_exists trivy || [ -x "$BIN_DIR/trivy" ]; then
    VERSION=$(trivy version 2>/dev/null | grep -oE 'Version: [0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    log_success "Trivy: ✓ (v${VERSION})"
  else
    log_error "Trivy: ✗ (not installed)"
    ALL_INSTALLED=false
  fi

  if $ALL_INSTALLED; then
    echo ""
    log_success "All security scanning tools are installed!"
    echo ""
    echo "Add this to your PATH to use the tools:"
    echo "  export PATH=\"$BIN_DIR:\$PATH\""
    return 0
  else
    echo ""
    log_warning "Some tools are missing. Run without --check to install."
    return 1
  fi
}

# Update all tools
update_tools() {
  log_info "Updating all security scanning tools..."
  rm -f "$VERSION_FILE"
  install_gitleaks
  install_semgrep
  install_trivy
  log_success "All tools updated!"
}

# Show usage
show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Install security scanning tools for the secure-push skill.

OPTIONS:
    --check     Check if tools are installed (don't install)
    --update    Update all tools to latest versions
    --help      Show this help message

TOOLS INSTALLED:
    - Gitleaks v${GITLEAKS_VERSION}  (Secret detection)
    - Semgrep (latest)               (SAST code analysis)
    - Trivy v${TRIVY_VERSION}        (Dependency scanning)

INSTALLATION:
    Tools are installed to: $BIN_DIR
    Add to PATH: export PATH="$BIN_DIR:\$PATH"

EXAMPLES:
    $0                  # Install all tools
    $0 --check          # Check installation status
    $0 --update         # Update all tools

EOF
}

# Main installation flow
main() {
  # Parse arguments
  case "${1:-}" in
  --check)
    detect_os
    check_tools
    exit $?
    ;;
  --update)
    detect_os
    update_tools
    exit 0
    ;;
  --help | -h)
    show_usage
    exit 0
    ;;
  "")
    # Install all tools
    ;;
  *)
    log_error "Unknown option: $1"
    show_usage
    exit 1
    ;;
  esac

  echo "════════════════════════════════════════════════════════"
  echo "  Secure-Push Security Tools Installer"
  echo "════════════════════════════════════════════════════════"
  echo ""

  detect_os

  # Create version file
  >"$VERSION_FILE"

  # Install tools
  install_gitleaks || log_warning "Gitleaks installation had issues"
  echo ""
  install_semgrep || log_warning "Semgrep installation had issues"
  echo ""
  install_trivy || log_warning "Trivy installation had issues"
  echo ""

  # Final check
  echo "════════════════════════════════════════════════════════"
  check_tools
  echo "════════════════════════════════════════════════════════"
  echo ""
  log_info "Installation complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Add $BIN_DIR to your PATH"
  echo "  2. Run: bash $SCRIPT_DIR/setup-git-hook.sh --install"
  echo "  3. Test: bash $SCRIPT_DIR/pre-push-scan.sh"
}

main "$@"
