# Language-Specific Security Configurations

This directory contains optimized Semgrep security rules for specific programming languages.

## Available Configurations

### JavaScript/TypeScript (`javascript.yaml`)
Optimized for:
- Node.js applications
- React, Vue, Angular
- Express, Nest.js, Next.js
- Frontend and backend JavaScript/TypeScript

**Key security checks:**
- Command injection (child_process, eval)
- XSS vulnerabilities (dangerouslySetInnerHTML, href injection)
- SQL/NoSQL injection
- Path traversal
- Prototype pollution
- JWT security issues
- Weak cryptography
- CSRF protection
- Open redirects

### Python (`python.yaml`)
Optimized for:
- Flask applications
- Django projects
- FastAPI services
- General Python security

**Key security checks:**
- Command injection (os.system, subprocess)
- SQL injection (raw queries, string formatting)
- Insecure deserialization (pickle, yaml)
- Path traversal
- Template injection (Jinja2 SSTI)
- Weak cryptography
- SSL/TLS verification
- Hardcoded secrets
- XXE attacks

### Go/Golang (`go.yaml`)
Optimized for:
- Go web services and APIs
- gRPC applications
- Cloud-native applications
- Microservices architecture
- General Go security

**Key security checks:**
- SQL injection (database/sql with string concatenation)
- Command injection (exec.Command with shell)
- Path traversal (filepath operations)
- Weak cryptography (MD5, SHA1, math/rand)
- TLS certificate validation (InsecureSkipVerify)
- Hardcoded credentials
- Race conditions (unprotected map access)
- Resource leaks (unclosed rows, deferred in loops)
- Type assertion without checks
- Context misuse (Background in requests)
- Goroutine leaks (missing cancellation)
- Template injection
- JWT signature verification
- gRPC insecure connections
- Open redirects
- Integer overflows
- Panic handling in goroutines
- HTTP server timeouts
- Error wrapping best practices

## Adding New Language Configurations

To add support for additional languages:

1. **Create a new YAML file** named after the language (e.g., `java.yaml`, `go.yaml`, `ruby.yaml`)

2. **Follow the Semgrep rule format:**

```yaml
# Semgrep Rules for [Language]
# Brief description of what this covers

rules:
  - id: unique-rule-id
    patterns:
      - pattern: vulnerable_code_pattern(...)
    message: Description of the vulnerability and how to fix it
    languages: [language_name]
    severity: ERROR  # or WARNING, INFO
    metadata:
      cwe: "CWE-XXX: Vulnerability Name"
      owasp: "A0X:2021 - Category"
      references:
        - https://link-to-docs
```

3. **Focus on common vulnerabilities** for that language:
   - Injection flaws (SQL, Command, Code)
   - Authentication/authorization issues
   - Cryptography misuse
   - Insecure deserialization
   - Path traversal
   - XSS/CSRF (for web frameworks)
   - Framework-specific security issues

4. **Test your rules** with sample vulnerable code

5. **Document in this README** what the config covers

## Language-Specific Resources

### Java
- **Focus areas:** Spring Boot security, JDBC injection, XXE, deserialization
- **Reference:** https://semgrep.dev/explore?q=java

### Go
- **Focus areas:** SQL injection, command injection, path traversal, crypto
- **Reference:** https://semgrep.dev/explore?q=go

### Ruby
- **Focus areas:** Rails security, YAML deserialization, SQL injection
- **Reference:** https://semgrep.dev/explore?q=ruby

### PHP
- **Focus areas:** SQL injection, XSS, command injection, file inclusion
- **Reference:** https://semgrep.dev/explore?q=php

### Rust
- **Focus areas:** Unsafe blocks, FFI issues, panic in production
- **Reference:** https://semgrep.dev/explore?q=rust

### C#/.NET
- **Focus areas:** SQL injection, XSS, deserialization, auth issues
- **Reference:** https://semgrep.dev/explore?q=csharp

## Using Language-Specific Configs

The pre-push scan script automatically detects project languages and loads appropriate configs.

**Manual usage:**
```bash
semgrep --config=.claude/skills/secure-push/configs/languages/python.yaml .
```

**Combine multiple configs:**
```bash
semgrep \
  --config=.claude/skills/secure-push/configs/languages/javascript.yaml \
  --config=.claude/skills/secure-push/configs/languages/python.yaml \
  .
```

## Severity Levels

- **ERROR (Critical/High):** Security vulnerabilities that must be fixed before push
- **WARNING (Medium):** Security issues that should be reviewed
- **INFO (Low):** Best practice recommendations

## Contributing

To improve existing configs:

1. Add new rules following existing patterns
2. Include clear fix suggestions in messages
3. Add CWE and OWASP mappings
4. Test against real-world code
5. Document in rule metadata

## References

- [Semgrep Registry](https://semgrep.dev/explore)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [Semgrep Rule Syntax](https://semgrep.dev/docs/writing-rules/rule-syntax/)
