---
name: secure-push
description: Pre-push security scanning with secret detection, SAST, and vulnerability scanning. Automatically scans code before git push to prevent secrets, vulnerabilities, and CVEs from reaching remote repositories. Blocks on Critical/High severity. Use when setting up secure development workflows or before pushing code.
version: 1.0.0
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Secure Push - Pre-Push Security Scanning

A comprehensive security scanning skill that prevents secrets, vulnerabilities, and CVEs from being pushed to remote repositories. Integrates seamlessly with git workflows using pre-push hooks and supports CI/CD pipelines.

## Overview

This skill provides multi-layer security scanning:
- **Layer 1: Secret Detection** (Gitleaks) - Fast detection of API keys, tokens, passwords
- **Layer 2: SAST Code Analysis** (Semgrep) - Static analysis for code vulnerabilities
- **Layer 3: Dependency Scanning** (Trivy) - CVE detection in dependencies

**Severity Policy:**
- **BLOCK**: Critical and High severity findings prevent push
- **WARN**: Medium and Low severity findings show warnings but allow push
- **INFO**: Informational findings are logged

## Instructions

### When to Use This Skill

Use this skill when:
1. Setting up security scanning for a new or existing project
2. User wants to prevent secrets/credentials from being committed
3. User asks about pre-commit or pre-push security checks
4. User wants to scan code for vulnerabilities before pushing
5. User mentions security, secrets, CVEs, or vulnerability scanning
6. Installing git hooks for automated security checks

### Initial Setup

When a user first invokes this skill or asks to set up security scanning:

1. **Check if tools are installed** by running:
   ```bash
   bash .claude/skills/secure-push/scripts/install-tools.sh --check
   ```

2. **If tools are missing**, install them:
   ```bash
   bash .claude/skills/secure-push/scripts/install-tools.sh
   ```
   This auto-detects the OS and installs Gitleaks, Semgrep, and Trivy.

3. **Detect project language** using Glob to find:
   - `package.json` or `*.js`/`*.ts` files → JavaScript/TypeScript
   - `requirements.txt`, `pyproject.toml`, or `*.py` files → Python
   - `pom.xml` or `*.java` files → Java
   - `go.mod` or `*.go` files → Go

4. **Configure for detected language(s)**:
   - Copy language-specific configs from `.claude/skills/secure-push/configs/languages/`
   - Merge with base configs in `.claude/skills/secure-push/configs/`

5. **Offer git hook installation**:
   Ask the user: "Would you like me to install the pre-push hook to automatically scan before every push? (Y/n)"

   - If yes: Run `bash .claude/skills/secure-push/scripts/setup-git-hook.sh --install`
   - If no: Inform them they can install it later with the same command

### Running Security Scans

#### Manual Scan (on-demand)

To scan current changes before pushing:
```bash
bash .claude/skills/secure-push/scripts/pre-push-scan.sh
```

This scans only files in `git diff` for efficiency.

#### Automated Scan (via git hook)

Once the pre-push hook is installed, scans run automatically before every `git push`.

To bypass the hook (e.g., for false positives):
```bash
git push --no-verify
```
**Important**: Only use `--no-verify` when you've confirmed findings are false positives.

### Understanding Scan Results

When a scan completes, you'll see results in this format:

```
🔍 SECURE-PUSH SCAN RESULTS
════════════════════════════════════════

✅ SECRET SCANNING (Gitleaks)
   No secrets detected

❌ CODE ANALYSIS (Semgrep)
   CRITICAL: SQL Injection vulnerability
   → src/db/query.js:42
   → Use parameterized queries instead

⚠️  DEPENDENCY SCANNING (Trivy)
   HIGH: CVE-2024-1234 in lodash@4.17.20
   → Update to lodash@4.17.21+

════════════════════════════════════════
🚫 PUSH BLOCKED: Critical/High findings detected
Fix issues above or use --no-verify to bypass
```

**Interpreting results:**
- ✅ Green check = No issues found
- ⚠️ Warning = Medium/Low severity (push allowed)
- ❌ Red X = Critical/High severity (push blocked)

### Handling Findings

**For Secrets Detected:**
1. Remove the secret from code
2. Add to `.gitleaksignore` if it's a false positive
3. Rotate the exposed secret (API key, token, etc.)

**For Code Vulnerabilities:**
1. Review the finding at the specified file:line
2. Apply the suggested fix
3. Re-run the scan to verify

**For Dependency CVEs:**
1. Update the vulnerable dependency to the suggested version
2. Run `npm install`/`pip install` to update lockfiles
3. Re-run the scan to verify

**For False Positives:**
1. Add to appropriate allowlist:
   - Secrets: `.gitleaksignore`
   - SAST: `.semgrepignore` or inline `// nosemgrep` comment
   - Dependencies: `trivy.yaml` exceptions
2. Document why it's a false positive

### Configuration Customization

**Adjust severity blocking:**
Edit `.claude/skills/secure-push/configs/semgrep.yaml` or `trivy.yaml` to change severity thresholds.

**Add custom rules:**
- **Gitleaks**: Add regex patterns to `.claude/skills/secure-push/configs/gitleaks.toml`
- **Semgrep**: Add YAML rules to `.claude/skills/secure-push/configs/semgrep.yaml`
- **Trivy**: Configure policies in `.claude/skills/secure-push/configs/trivy.yaml`

**Language-specific optimizations:**
Use configs in `.claude/skills/secure-push/configs/languages/` for:
- JavaScript/TypeScript: `javascript.yaml`
- Python: `python.yaml`
- Go/Golang: `go.yaml`

### CI/CD Integration

After the pre-push hook is working locally, help users set up CI/CD scanning:

1. **GitHub Actions**: Copy `.claude/skills/secure-push/examples/github-actions.yml` to `.github/workflows/security-scan.yml`

2. **GitLab CI**: Copy `.claude/skills/secure-push/examples/gitlab-ci.yml` to `.gitlab-ci.yml` (merge if exists)

3. **Jenkins**: Use `.claude/skills/secure-push/examples/jenkins.groovy` as a pipeline template

4. **Generic/Other**: Use the Docker-based examples for platform-agnostic scanning

**Key differences between local and CI/CD:**
- Local (pre-push): Scans only changed files for speed
- CI/CD (post-push): Scans entire codebase for comprehensive coverage
- CI/CD generates reports and artifacts for compliance

### Troubleshooting

**"Tool not found" errors:**
- Run `bash .claude/skills/secure-push/scripts/install-tools.sh` again
- Check if tools are in PATH: `which gitleaks semgrep trivy`
- Use Docker fallback: Set `SECURE_PUSH_USE_DOCKER=1` environment variable

**Scan takes too long:**
- Ensure scanning only changed files: `git diff --name-only --cached`
- Reduce Semgrep rules for faster scans (remove rules from config)
- Skip Trivy in local scans if dependencies rarely change

**Too many false positives:**
- Review and tune `.gitleaksignore`, `.semgrepignore`
- Adjust rule severity in configs
- Consider using `--severity=high` flag to only show high+ findings

**Git hook not triggering:**
- Check `.git/hooks/pre-push` exists and is executable
- Verify shebang line: `#!/bin/bash`
- Test manually: `bash .git/hooks/pre-push`

## Best Practices

1. **Incremental Adoption**: Start with secret scanning only, then add SAST and SCA
2. **Team Communication**: Document exceptions and false positives in the project
3. **Regular Updates**: Keep scanning tools updated monthly
4. **CI/CD Redundancy**: Even with pre-push hooks, run scans in CI/CD
5. **Secret Rotation**: Always rotate secrets even if caught pre-push
6. **Performance**: For large repos, configure scanning to focus on critical paths

## Language-Specific Notes

### JavaScript/TypeScript
- Optimized Semgrep rules for Node.js security patterns
- Scans for: XSS, prototype pollution, command injection, path traversal
- NPM/Yarn/PNPM dependency scanning via Trivy
- React-specific rules for common vulnerabilities

### Python
- Optimized for Flask/Django/FastAPI security patterns
- Scans for: SQL injection, command injection, insecure deserialization
- Pip/Poetry/Pipenv dependency scanning via Trivy
- Python-specific Bandit rules integrated via Semgrep

### Go/Golang
- Optimized for Go web services, gRPC, and cloud-native applications
- Scans for: SQL injection, command injection, weak cryptography, race conditions
- Go module dependency scanning via Trivy
- Go-specific patterns for goroutine leaks, context misuse, and unsafe operations
- Checks for TLS certificate validation, JWT verification, and HTTP server timeouts

## Examples

### Example 1: First-time setup for a Python project

```
User: "Set up security scanning for my Flask app"

1. Check for Python files: Glob "**/*.py"
2. Install tools: bash .claude/skills/secure-push/scripts/install-tools.sh
3. Copy Python configs: cp configs/languages/python.yaml configs/
4. Ask about git hook installation
5. Run initial scan: bash scripts/pre-push-scan.sh
6. Explain results and next steps
```

### Example 2: Handling a blocked push

```
User: "My git push is blocked by the security scan"

1. Read the scan output to identify findings
2. Explain each finding with file:line references
3. For secrets: Guide removal and rotation
4. For vulnerabilities: Suggest fixes
5. For dependencies: Show update commands
6. Re-run scan after fixes
7. Confirm push is unblocked
```

### Example 3: CI/CD integration

```
User: "Add this security scanning to GitHub Actions"

1. Detect GitHub repo: Check for .github/ directory
2. Copy example workflow: cp examples/github-actions.yml .github/workflows/security-scan.yml
3. Customize for detected languages
4. Explain workflow triggers (push, PR, schedule)
5. Show how to view results in GitHub UI
6. Suggest branch protection rules
```

## Advanced Features

### Scanning Modes

- **Fast Mode**: Secrets only (< 10s)
  ```bash
  bash scripts/pre-push-scan.sh --fast
  ```

- **Standard Mode**: Secrets + SAST (< 30s)
  ```bash
  bash scripts/pre-push-scan.sh
  ```

- **Deep Mode**: Secrets + SAST + SCA (< 2m)
  ```bash
  bash scripts/pre-push-scan.sh --deep
  ```

### Reporting

Generate compliance reports:
```bash
bash scripts/pre-push-scan.sh --report-format=sarif --output=security-report.sarif
```

Supported formats: JSON, SARIF, HTML, Markdown

### Customization Hooks

Users can add custom pre/post scan hooks:
- `.claude/skills/secure-push/hooks/pre-scan.sh` - Runs before scanning
- `.claude/skills/secure-push/hooks/post-scan.sh` - Runs after scanning

Use cases: Notify team chat, update dashboards, custom logging

## Maintenance

1. **Monthly Tool Updates**:
   ```bash
   bash scripts/install-tools.sh --update
   ```

2. **Rule Updates**: Semgrep rules auto-update, but review changes in release notes

3. **Config Review**: Quarterly review of exceptions and allowlists

4. **Metrics**: Track findings over time to measure security posture improvement

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review tool documentation:
   - Gitleaks: https://github.com/gitleaks/gitleaks
   - Semgrep: https://semgrep.dev/docs
   - Trivy: https://aquasecurity.github.io/trivy/
3. Review `.claude/skills/secure-push/README.md` for detailed docs

---

**Remember**: Security scanning is a layer of defense, not a silver bullet. Combine with:
- Code reviews
- Dependency updates
- Security training
- Penetration testing
- Runtime monitoring
