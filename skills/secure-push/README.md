# Secure-Push: Pre-Push Security Scanning Skill

A comprehensive Claude Code skill that provides multi-layer security scanning to prevent secrets, vulnerabilities, and CVEs from reaching your remote repository.

## Overview

Secure-Push integrates three industry-leading open-source security tools into your development workflow:

- **Gitleaks** - Fast secret detection (API keys, tokens, passwords)
- **Semgrep** - Static application security testing (SAST)
- **Trivy** - Software composition analysis (dependency CVEs)

**Severity Policy:**
- 🚫 **BLOCK**: Critical and High severity findings prevent git push
- ⚠️ **WARN**: Medium and Low severity findings show warnings but allow push
- ℹ️ **INFO**: Informational findings are logged

## Quick Start

### 1. Install Security Tools

```bash
bash .claude/skills/secure-push/scripts/install-tools.sh
```

This auto-detects your OS and installs Gitleaks, Semgrep, and Trivy.

### 2. Set Up Git Hook (Automatic Scanning)

```bash
bash .claude/skills/secure-push/scripts/setup-git-hook.sh --install
```

Now security scans run automatically before every `git push`.

### 3. Manual Scan (On-Demand)

```bash
bash .claude/skills/secure-push/scripts/pre-push-scan.sh
```

## Features

### Multi-Layer Security

1. **Secret Detection** (< 10 seconds)
   - 200+ patterns for API keys, tokens, credentials
   - Custom regex support
   - False positive filtering

2. **SAST Code Analysis** (< 30 seconds)
   - OWASP Top 10 coverage
   - CWE Top 25 rules
   - Language-specific optimizations
   - Framework-aware (React, Flask, Django, Express, etc.)

3. **Dependency Scanning** (< 2 minutes)
   - CVE database with severity ratings
   - Multi-language package manager support
   - License compliance checking
   - Container image scanning

### Language Support

**Optimized configurations for:**
- JavaScript/TypeScript (Node.js, React, Vue, Angular, Express, Next.js)
- Python (Flask, Django, FastAPI)
- Go/Golang (web services, gRPC, cloud-native applications)

**Generic support for:**
- Java, Ruby, PHP, Rust, C#, and more

See `configs/languages/README.md` for adding custom language rules.

### Performance Optimized

- **Fast Mode**: Secrets only (~10s)
- **Standard Mode**: Secrets + SAST (~30s) [Default]
- **Deep Mode**: Full scan with dependencies (~2m)

Scans only changed files (git diff) for speed.

### CI/CD Integration

Ready-to-use examples for:
- GitHub Actions (`.github/workflows/`)
- GitLab CI (`.gitlab-ci.yml`)
- Jenkins (Jenkinsfile)
- Pre-commit framework (`.pre-commit-config.yaml`)

## Installation

### Prerequisites

- Git repository
- Bash shell (Linux/macOS)
- One of: curl or wget
- One of: pip3, brew (for Semgrep)

### Step-by-Step

1. **Clone or add this skill to your project:**

   ```bash
   # Skill is already at .claude/skills/secure-push/
   ```

2. **Install security scanning tools:**

   ```bash
   bash .claude/skills/secure-push/scripts/install-tools.sh
   ```

   Tools are installed to `.claude/skills/secure-push/bin/`

3. **Add to PATH (optional but recommended):**

   ```bash
   export PATH=".claude/skills/secure-push/bin:$PATH"
   ```

   Add this to your `~/.bashrc` or `~/.zshrc` for persistence.

4. **Install pre-push hook:**

   ```bash
   # Interactive installation (recommended)
   bash .claude/skills/secure-push/scripts/setup-git-hook.sh

   # Or direct installation
   bash .claude/skills/secure-push/scripts/setup-git-hook.sh --install
   ```

5. **Verify installation:**

   ```bash
   bash .claude/skills/secure-push/scripts/install-tools.sh --check
   bash .claude/skills/secure-push/scripts/setup-git-hook.sh --status
   ```

## Usage

### Automatic Scanning (Pre-Push Hook)

Once the hook is installed, it runs automatically:

```bash
git add .
git commit -m "Add new feature"
git push  # Security scan runs here automatically
```

**Bypass hook (when needed):**
```bash
git push --no-verify
```

⚠️ Only use `--no-verify` after confirming findings are false positives.

### Manual Scanning

**Standard scan** (secrets + SAST):
```bash
bash .claude/skills/secure-push/scripts/pre-push-scan.sh
```

**Fast scan** (secrets only):
```bash
bash .claude/skills/secure-push/scripts/pre-push-scan.sh --fast
```

**Deep scan** (full security check):
```bash
bash .claude/skills/secure-push/scripts/pre-push-scan.sh --deep
```

### Scan Reports

**Generate JSON report:**
```bash
bash .claude/skills/secure-push/scripts/pre-push-scan.sh \
  --report-format=json \
  --output=security-report.json
```

**Generate SARIF report (for GitHub):**
```bash
bash .claude/skills/secure-push/scripts/pre-push-scan.sh \
  --report-format=sarif \
  --output=security-report.sarif
```

## Understanding Results

### Example Output

```
🔒 SECURE-PUSH SECURITY SCAN
════════════════════════════════════════
Mode: standard
Time: 2025-11-09 18:00:00
════════════════════════════════════════

🔍 SECRET SCANNING (Gitleaks)
✓ No secrets detected

🔎 CODE ANALYSIS (Semgrep)
✗ Found 2 code issue(s)

  [ERROR] SQL Injection vulnerability
  → src/db/query.js:42
  Rule: javascript.sql-injection-raw-query

  [WARNING] Weak cryptography (MD5)
  → src/utils/hash.js:15
  Rule: javascript.weak-crypto-md5

════════════════════════════════════════
📊 SCAN SUMMARY
════════════════════════════════════════

Total Findings: 2
  Critical: 0
  High: 1
  Medium: 1
  Low: 0

════════════════════════════════════════
🚫 PUSH BLOCKED: Critical or High severity findings detected
════════════════════════════════════════

Please fix the issues above before pushing.

To bypass this check (not recommended):
  git push --no-verify
```

### Severity Levels

| Severity | Icon | Action | Examples |
|----------|------|--------|----------|
| CRITICAL | ❌ | Block | Hardcoded AWS keys, SQL injection |
| HIGH | ❌ | Block | Command injection, XSS, insecure deserialization |
| MEDIUM | ⚠️ | Warn | Weak crypto, missing CSRF protection |
| LOW | ℹ️ | Info | Missing security headers, code smells |

## Configuration

### Customizing Rules

**Gitleaks (Secrets):**
Edit `.claude/skills/secure-push/configs/gitleaks.toml`
- Add custom regex patterns
- Configure allowlists
- Adjust severity

**Semgrep (Code Analysis):**
Edit `.claude/skills/secure-push/configs/semgrep.yaml`
- Add custom SAST rules
- Modify severity thresholds
- Include/exclude paths

**Trivy (Dependencies):**
Edit `.claude/skills/secure-push/configs/trivy.yaml`
- Configure CVE policies
- Set license restrictions
- Adjust scanning scope

### Language-Specific Tuning

For JavaScript/TypeScript projects:
```bash
# Edit language-specific rules
vim .claude/skills/secure-push/configs/languages/javascript.yaml
```

For Python projects:
```bash
# Edit language-specific rules
vim .claude/skills/secure-push/configs/languages/python.yaml
```

### Allowlisting False Positives

**Secrets (.gitleaksignore):**
```
# Create in project root
echo "path/to/false/positive.js:12" >> .gitleaksignore
```

**Code issues (.semgrepignore):**
```
# Create in project root
echo "tests/" >> .semgrepignore
```

**Or inline:**
```javascript
// nosemgrep: javascript.sql-injection-raw-query
db.query(dynamicQuery);
```

**Dependencies (.trivyignore.rego or trivy.yaml):**
```yaml
# In trivy.yaml
ignore:
  - CVE-2021-1234  # False positive, doesn't affect our use case
```

## CI/CD Integration

### GitHub Actions

1. Copy the example workflow:
   ```bash
   mkdir -p .github/workflows
   cp .claude/skills/secure-push/examples/github-actions.yml \
      .github/workflows/security-scan.yml
   ```

2. Commit and push:
   ```bash
   git add .github/workflows/security-scan.yml
   git commit -m "Add security scanning workflow"
   git push
   ```

3. Configure branch protection (Settings → Branches → Add rule):
   - Require status checks to pass
   - Select: "Secret Detection", "Code Security Analysis", "Dependency Vulnerability Scan"

### GitLab CI

1. Merge with existing `.gitlab-ci.yml`:
   ```bash
   cat .claude/skills/secure-push/examples/gitlab-ci.yml >> .gitlab-ci.yml
   ```

2. Or use as standalone config

3. View security reports: Security & Compliance → Security Dashboard

### Jenkins

1. Create a new Pipeline job

2. Use the Groovy script:
   ```bash
   cat .claude/skills/secure-push/examples/jenkins.groovy
   ```

3. Configure webhooks for automatic builds on push

### Pre-commit Framework

Alternative to git hooks:

1. Install pre-commit:
   ```bash
   pip install pre-commit
   ```

2. Copy config:
   ```bash
   cp .claude/skills/secure-push/examples/pre-commit-config.yaml \
      .pre-commit-config.yaml
   ```

3. Install hooks:
   ```bash
   pre-commit install
   pre-commit install --hook-type pre-push
   ```

## Troubleshooting

### Tools Not Found

**Error:** `gitleaks: command not found`

**Solution:**
```bash
# Reinstall tools
bash .claude/skills/secure-push/scripts/install-tools.sh

# Add to PATH
export PATH=".claude/skills/secure-push/bin:$PATH"
```

### Scan Takes Too Long

**Problem:** Scans taking > 2 minutes

**Solutions:**
1. Use fast mode for quick checks:
   ```bash
   bash .claude/skills/secure-push/scripts/pre-push-scan.sh --fast
   ```

2. Reduce Semgrep rules (edit `configs/semgrep.yaml`)

3. Skip Trivy in local scans (only run in CI/CD)

4. Ensure scanning only changed files, not entire repo

### Too Many False Positives

**Solutions:**
1. Add to allowlists (`.gitleaksignore`, `.semgrepignore`)

2. Adjust severity thresholds in configs

3. Use inline suppressions with justification:
   ```python
   # nosemgrep: python-sql-injection
   # Safe: input is validated by middleware
   cursor.execute(query)
   ```

### Git Hook Not Triggering

**Check:**
```bash
# Verify hook exists and is executable
ls -la .git/hooks/pre-push

# Test manually
bash .git/hooks/pre-push
```

**Fix:**
```bash
# Reinstall hook
bash .claude/skills/secure-push/scripts/setup-git-hook.sh --install
```

### CI/CD Pipeline Failing

**Common issues:**
- Tools not installed in CI environment (check install steps)
- Network issues downloading vulnerability databases
- Insufficient permissions for artifact uploads
- Timeout on large repositories (increase timeout values)

## Best Practices

### Development Workflow

1. **Local Development:**
   - Use fast mode for quick iteration
   - Run standard mode before committing
   - Deep scan before major releases

2. **Code Review:**
   - Address all Critical and High findings
   - Document false positives
   - Update allowlists with team approval

3. **CI/CD Pipeline:**
   - Always run full scans in CI (not just changed files)
   - Generate and store reports for compliance
   - Set up notifications for security failures
   - Schedule weekly comprehensive scans

### Security Hygiene

1. **Secret Management:**
   - Never hardcode secrets
   - Use environment variables or secret managers
   - Rotate exposed secrets immediately
   - Even if caught pre-push, assume compromise

2. **Dependency Updates:**
   - Update dependencies monthly
   - Subscribe to security advisories
   - Pin major versions, allow patch updates
   - Test updates in staging before production

3. **Team Collaboration:**
   - Document all exceptions and allowlists
   - Regular security training
   - Share findings in retrospectives
   - Celebrate catching vulnerabilities early

## Maintenance

### Update Tools

```bash
# Update all tools to latest versions
bash .claude/skills/secure-push/scripts/install-tools.sh --update
```

### Update Semgrep Rules

Semgrep rules auto-update, but you can force update:
```bash
semgrep --config=auto --update-rules
```

### Quarterly Review

Every 3 months:
- Review and prune allowlists
- Update tool versions
- Review new vulnerability types
- Measure security posture improvement

## Advanced Usage

### Custom Hooks

Add custom pre/post scan logic:

1. Create hook script:
   ```bash
   mkdir -p .claude/skills/secure-push/hooks
   vim .claude/skills/secure-push/hooks/post-scan.sh
   ```

2. Example: Send notification to Slack
   ```bash
   #!/bin/bash
   # Post-scan hook - notify team
   curl -X POST https://hooks.slack.com/... \
     -d '{"text":"Security scan completed: '$SCAN_RESULT'"}'
   ```

### Integration with Security Platforms

Export scan results to:
- GitHub Advanced Security (SARIF format)
- SonarQube (JSON format)
- Snyk, WhiteSource, etc.

### Custom Severity Mapping

Override default severity in configs:
```yaml
# In semgrep.yaml
rules:
  - id: my-custom-rule
    severity: ERROR  # Treat as blocking
```

## Contributing

To improve this skill:

1. Add new language configurations in `configs/languages/`
2. Enhance existing rules with better patterns
3. Share common false positives for allowlists
4. Document edge cases and solutions

## Support & Resources

### Documentation
- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [Semgrep Documentation](https://semgrep.dev/docs/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)

### Security Resources
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST NVD](https://nvd.nist.gov/)

### Claude Code Skills
- [Skills Documentation](https://docs.claude.com/en/docs/claude-code/skills)
- [Skills Repository](https://github.com/anthropics/skills)

## License

This skill uses open-source tools:
- Gitleaks: MIT License
- Semgrep: LGPL 2.1
- Trivy: Apache 2.0

## Version History

- **v1.0.0** (2025-11-09): Initial release
  - Gitleaks 8.18.4 integration
  - Semgrep SAST with 200+ rules
  - Trivy dependency scanning
  - JavaScript/TypeScript optimization
  - Python optimization
  - CI/CD examples (GitHub Actions, GitLab, Jenkins)

---

**Built with ❤️ for secure development workflows**
