# Agent System

A complete agent-based development team with 12 specialized agents that handle the entire software development lifecycle from product vision to production deployment.

## All Agents

All agent files are located in this directory (`.claude/agents/`):

### Product & Strategy
- `chief-product-officer.md` - Product vision, strategy, and roadmaps
- `senior-product-manager.md` - PRDs, user stories, acceptance criteria
- `marketer.md` - Brand identity, color palettes, design tokens

### Design
- `ux-designer.md` - Style guides, design systems, component libraries
- `product-designer.md` - High-fidelity UI designs and specifications

### Engineering
- `software-architect.md` - System architecture, tech stack, implementation plans
- `dba.md` - MongoDB/Supabase database design and management
- `frontend-developer.md` - UI implementation with React/Vue/etc.
- `backend-developer.md` - API implementation and business logic

### Quality & Operations
- `app-security-engineer.md` - Security scanning using secure-push skill
- `senior-qa-engineer.md` - Test plans and Playwright E2E testing
- `devops-engineer.md` - Infrastructure as code and CI/CD

## Quick Start

To start a new product development workflow:

```
1. @chief-product-officer      # Define product vision
2. @senior-product-manager      # Write PRD
3. @marketer + @ux-designer     # Create brand & design system (parallel)
4. @product-designer            # Create UI designs
5. @software-architect          # Design architecture
6. @dba + @frontend-developer + @backend-developer  # Build (parallel)
7. @app-security-engineer       # Security scan
8. @senior-qa-engineer          # Testing
9. @devops-engineer             # Deploy
```

## Key Features

- **User Confirmation Required**: Every agent asks for approval before making changes
- **Clear Handoffs**: Each agent explicitly passes work to the next agent
- **Skill Integration**: App Security Engineer uses the secure-push skill
- **MCP Integration**: DBA uses MongoDB/Supabase MCP, QA uses Playwright MCP
- **Standard Outputs**: All agents follow consistent directory structures

## Agent Format

Each agent follows the Claude Agent format:

```markdown
---
name: agent-name
description: Brief description of the agent's role and when to use it
tools: Read, Write, Edit, Grep, Glob, Bash, MCP, Skill
model: inherit
---

# Agent Name

[Agent instructions and workflow]
```

## Usage

Simply invoke any agent by name:

```
@chief-product-officer
@senior-product-manager
@software-architect
etc.
```

Each agent will:
1. Read relevant context
2. Propose changes
3. Ask for your approval
4. Execute after confirmation
5. Hand off to next agent

## Integration with Secure-Push Skill

The App Security Engineer (`@app-security-engineer`) integrates with the secure-push skill to provide comprehensive security scanning:
- Secret detection (Gitleaks)
- SAST code analysis (Semgrep)
- Dependency vulnerability scanning (Trivy)
- Blocks on Critical/High severity issues

## Total Agents: 12

All agents work together as a cohesive development team to take your product from concept to production.
