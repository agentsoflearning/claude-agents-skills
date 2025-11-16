# Claude Agents & Skills

A comprehensive collection of specialized Claude Agents and workflow Skills for managing the complete software development lifecycle—from product vision to production deployment.

## Overview

This repository provides:

- **12 Specialized Agents**: A complete development team covering product, design, engineering, and operations
- **4 Workflow Skills**: Best-practice workflows for security, ticket management, git commits, and agent handoffs

Together, these agents and skills enable a coordinated, efficient workflow for building and shipping software products.

---

## Quick Start

### Using Agents

Agents are specialized roles that handle specific parts of the development lifecycle. Simply invoke any agent by name:

```
@chief-product-officer
@senior-product-manager
@software-architect
@backend-developer
@app-security-engineer
@senior-qa-engineer
@devops-engineer
```

Each agent will:
1. Read relevant context
2. Propose changes
3. Ask for your approval
4. Execute after confirmation
5. Hand off to the next agent

**See detailed documentation**: [agents/README.md](agents/README.md)

### Using Skills

Skills provide standardized workflows that agents (and you) can invoke for common development tasks:

- **secure-push**: Security scanning before git push
- **linear-integration**: Linear ticket management
- **agent-handoff-protocol**: Standardized handoffs between agents
- **micro-commit-workflow**: Git workflow with atomic commits

Skills enhance agent capabilities and ensure consistency across the development process.

---

## Agents

### Complete Development Team (12 Agents)

#### Product & Strategy
- **[chief-product-officer](agents/chief-product-officer.md)** - Product vision, strategy, and roadmaps
- **[senior-product-manager](agents/senior-product-manager.md)** - PRDs, user stories, acceptance criteria
- **[marketer](agents/marketer.md)** - Brand identity, color palettes, design tokens

#### Design
- **[ux-designer](agents/ux-designer.md)** - Style guides, design systems, component libraries
- **[product-designer](agents/product-designer.md)** - High-fidelity UI designs and specifications

#### Engineering
- **[software-architect](agents/software-architect.md)** - System architecture, tech stack, implementation plans
- **[dba](agents/dba.md)** - MongoDB/Supabase database design and management
- **[frontend-developer](agents/frontend-developer.md)** - UI implementation with React/Vue/etc.
- **[backend-developer](agents/backend-developer.md)** - API implementation and business logic

#### Quality & Operations
- **[app-security-engineer](agents/app-security-engineer.md)** - Security scanning using secure-push skill
- **[senior-qa-engineer](agents/senior-qa-engineer.md)** - Test plans and Playwright E2E testing
- **[devops-engineer](agents/devops-engineer.md)** - Infrastructure as code and CI/CD

**See detailed documentation**: [agents/README.md](agents/README.md)

---

## Skills

### Workflow Skills (4 Skills)

#### 1. Secure Push
**Pre-push security scanning with secret detection, SAST, and vulnerability scanning**

- **Layer 1**: Secret Detection (Gitleaks) - API keys, tokens, passwords
- **Layer 2**: SAST Code Analysis (Semgrep) - Code vulnerabilities
- **Layer 3**: Dependency Scanning (Trivy) - CVE detection

**When to use**: Setting up security scanning, preventing secrets from being committed, pre-push security checks

**Documentation**: [skills/secure-push/SKILL.md](skills/secure-push/SKILL.md)

#### 2. Linear Integration
**Linear ticket management with MCP tools for status updates and progress tracking**

- Get issue, update issue, add comments, status transitions
- Progress tracking throughout development workflow
- Ticket lifecycle management from Todo → In Progress → In Review → Done

**When to use**: Managing Linear tickets, updating progress, documenting blockers, linking dependencies

**Documentation**: [skills/linear-integration/SKILL.md](skills/linear-integration/SKILL.md)

#### 3. Agent Handoff Protocol
**Standardized agent handoff procedures for seamless collaboration**

- Comprehensive work summaries
- Context preservation between agents
- Clear next steps and deliverables documentation
- Open questions tracking

**When to use**: Completing work and handing off to another agent, coordinating multi-agent workflows

**Documentation**: [skills/agent-handoff-protocol/SKILL.md](skills/agent-handoff-protocol/SKILL.md)

#### 4. Micro-Commit Workflow
**Git workflow management with micro-commits and conventional commit messages**

- Atomic, focused commits that tell a clear story
- Conventional commit format with LINEAR ticket references
- Squash/rebase decision framework
- Git best practices and safe operations

**When to use**: Committing code, writing commit messages, managing branches, organizing commit history

**Documentation**: [skills/micro-commit-workflow/SKILL.md](skills/micro-commit-workflow/SKILL.md)

---

## Typical Workflow

Here's how agents and skills work together in a complete product development cycle:

### 1. Product Vision & Planning
```
@chief-product-officer      # Define product vision and strategy
@senior-product-manager      # Write comprehensive PRD
```

### 2. Design & Architecture
```
@marketer                    # Create brand identity (parallel)
@ux-designer                 # Create style guide and design system (parallel)
@product-designer            # Create high-fidelity UI designs
@software-architect          # Design system architecture
```

### 3. Development
```
@dba                         # Create database schema (start first)
@backend-developer           # Implement API (after DBA)
@frontend-developer          # Build UI (can start parallel with backend)
```

**Skills used during development:**
- **micro-commit-workflow**: Making atomic commits with conventional messages
- **linear-integration**: Updating ticket progress and status

### 4. Quality & Security
```
@app-security-engineer       # Security scan with secure-push skill
@senior-qa-engineer          # Comprehensive testing
```

**Skills used:**
- **secure-push**: Pre-push security scanning (secrets, SAST, CVEs)
- **linear-integration**: Documenting test results

### 5. Deployment
```
@devops-engineer             # Infrastructure and CI/CD deployment
```

**Skills used:**
- **agent-handoff-protocol**: Final handoff documentation
- **linear-integration**: Mark ticket as Done

---

## Key Features

### Agent Features
- **User Confirmation Required**: Every agent asks for approval before making changes
- **Clear Handoffs**: Each agent explicitly passes work to the next agent using handoff protocol
- **Skill Integration**: Agents leverage skills for standardized workflows
- **MCP Integration**: DBA uses MongoDB/Supabase MCP, QA uses Playwright MCP
- **Standard Outputs**: All agents follow consistent directory structures

### Skill Features
- **Security First**: Prevent secrets and vulnerabilities from reaching repositories
- **Ticket Tracking**: Keep Linear tickets updated throughout development
- **Clean Git History**: Organized, conventional commits with proper references
- **Seamless Handoffs**: No context lost between agent transitions

---

## Integration Examples

### Example 1: Backend Developer using Skills
```
@backend-developer

During implementation:
1. Uses micro-commit-workflow for atomic commits
2. Updates Linear ticket using linear-integration
3. Pre-push security scan with secure-push
4. Hands off to @app-security-engineer using agent-handoff-protocol
```

### Example 2: Security Engineer Workflow
```
@app-security-engineer

1. Receives handoff from @backend-developer
2. Runs secure-push skill for comprehensive security scan
3. Documents findings in Linear using linear-integration
4. Hands off to @senior-qa-engineer with agent-handoff-protocol
```

### Example 3: Full Feature Development
```
Product: @chief-product-officer → @senior-product-manager
Design: @ux-designer → @product-designer
Arch: @software-architect → @dba
Dev: @backend-developer + @frontend-developer (parallel)
  ↓ (micro-commit-workflow, linear-integration skills used)
Security: @app-security-engineer (secure-push skill)
  ↓
QA: @senior-qa-engineer
  ↓
Deploy: @devops-engineer
  ↓ (agent-handoff-protocol for final documentation)
Done ✅
```

---

## Getting Started

### 1. Set Up Security Scanning (Recommended First Step)

```bash
# Install security scanning tools
bash .claude/skills/secure-push/scripts/install-tools.sh

# Set up git hook for automatic scanning
bash .claude/skills/secure-push/scripts/setup-git-hook.sh --install
```

### 2. Configure Git Workflow

```bash
# Install commit message validation
cd .claude/skills/micro-commit-workflow
./scripts/setup-git-hooks.sh --install
```

### 3. Start Your First Feature

```bash
# Create feature branch
git checkout -b feature/LINEAR-XXX-description

# Invoke product agents
@chief-product-officer
@senior-product-manager
```

### 4. Follow the Workflow

Each agent will guide you through their phase and hand off to the next agent when complete.

---

## Documentation

### Detailed Documentation
- **Agents**: [agents/README.md](agents/README.md) - Complete agent system documentation
- **Secure Push**: [skills/secure-push/SKILL.md](skills/secure-push/SKILL.md) - Security scanning guide
- **Linear Integration**: [skills/linear-integration/SKILL.md](skills/linear-integration/SKILL.md) - Ticket management guide
- **Agent Handoff Protocol**: [skills/agent-handoff-protocol/SKILL.md](skills/agent-handoff-protocol/SKILL.md) - Handoff procedures
- **Micro-Commit Workflow**: [skills/micro-commit-workflow/SKILL.md](skills/micro-commit-workflow/SKILL.md) - Git workflow guide

### Additional Resources
- **Secure Push Configs**: [skills/secure-push/configs/](skills/secure-push/configs/) - Security scanning configurations
- **Language-Specific Configs**: [skills/secure-push/configs/languages/](skills/secure-push/configs/languages/) - JS/Python/Go optimizations

---

## Best Practices

1. **Always start with product vision**: Begin with @chief-product-officer for proper foundation
2. **Use skills consistently**: Leverage skills for standardized workflows
3. **Keep Linear updated**: Use linear-integration skill for progress tracking
4. **Commit frequently**: Use micro-commit-workflow for clean git history
5. **Security scan before push**: Enable secure-push git hook
6. **Document handoffs**: Use agent-handoff-protocol when passing work
7. **Follow the sequence**: Respect agent dependencies (e.g., DBA before Backend)

---

## Requirements

### For Agents
- Claude Code or Claude API access
- Git installed
- Project workspace

### For Skills
- **secure-push**: Gitleaks, Semgrep, Trivy (auto-installed by setup script)
- **linear-integration**: Linear MCP tools configured
- **micro-commit-workflow**: Git installed
- **agent-handoff-protocol**: No special requirements

---

## Contributing

Contributions welcome! Please ensure:
- New agents follow the existing agent format
- New skills include comprehensive SKILL.md documentation
- All changes are tested in real workflows
- Documentation is updated

---

## License

MIT License - see LICENSE file for details

---

## Support

For questions or issues:
- Review agent documentation in [agents/](agents/)
- Review skill documentation in [skills/](skills/)
- Check troubleshooting sections in individual SKILL.md files

---

**Built for efficient, coordinated software development from concept to production.**
