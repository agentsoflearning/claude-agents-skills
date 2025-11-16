---
name: micro-commit-workflow
description: Git workflow management with micro-commits, conventional commit messages, and squash/rebase decisions. Guides developers through atomic commits, branch management, and git best practices. Use when committing code, managing branches, or deciding on commit history organization.
version: 1.0.0
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Micro-Commit Workflow

A comprehensive git workflow skill that guides developers through atomic commits, conventional commit messages, branch management, and squash/rebase decisions.

## Overview

This skill provides:
- **Micro-commit strategy**: Atomic, focused commits that tell a clear story
- **Conventional commits**: Standardized commit message format with LINEAR ticket references
- **Squash & rebase guidance**: Decision framework for organizing commit history
- **Git best practices**: Safe operations, force-push protection, and workflow patterns

## When to Use This Skill

Use this skill when:
1. Starting work on a new feature or bug fix (branch creation)
2. Making commits during development
3. Writing commit messages
4. Deciding whether to squash, keep, or interactively rebase commits
5. Preparing code for pull request or merge
6. Needing guidance on commit granularity
7. Managing git workflow and branch strategy

## Helper Scripts

This skill includes automated helper scripts in `.claude/skills/micro-commit-workflow/scripts/`:

### Available Scripts

1. **`validate-commit-msg.sh`** - Validates conventional commit format
   ```bash
   # Validate a commit message
   ./scripts/validate-commit-msg.sh --check "feat: add new feature"

   # Used automatically by git hook
   ```

2. **`generate-commit-template.sh`** - Generates commit message templates
   ```bash
   # Interactive mode
   ./scripts/generate-commit-template.sh

   # Direct mode
   ./scripts/generate-commit-template.sh feat api

   # With LINEAR ticket
   ./scripts/generate-commit-template.sh --linear LINEAR-123

   # Install as default template
   ./scripts/generate-commit-template.sh --install
   ```

3. **`setup-git-hooks.sh`** - Installs git hooks for automatic validation
   ```bash
   # Install hooks (commit-msg and prepare-commit-msg)
   ./scripts/setup-git-hooks.sh --install

   # Check installation status
   ./scripts/setup-git-hooks.sh --check

   # Uninstall hooks
   ./scripts/setup-git-hooks.sh --uninstall
   ```

4. **`squash-rebase-helper.sh`** - Analyzes commits and recommends strategy
   ```bash
   # Analyze current branch
   ./scripts/squash-rebase-helper.sh

   # Analyze specific branch
   ./scripts/squash-rebase-helper.sh --branch feature/login
   ```

### Quick Setup

For new projects, run:
```bash
cd .claude/skills/micro-commit-workflow

# Install git hooks for automatic validation
./scripts/setup-git-hooks.sh --install

# (Optional) Install commit message template
./scripts/generate-commit-template.sh --install
```

This will:
- ✅ Validate all commits against conventional format
- ✅ Auto-add LINEAR tickets from branch names
- ✅ Provide helpful commit message templates
- ✅ Block invalid commit messages

---

## Instructions

### 1. Understanding Micro-Commits

A **micro-commit** is a small, atomic commit that:
- **Accomplishes ONE specific task** - Single responsibility principle
- **Compiles and doesn't break existing functionality** - Always in working state
- **Has a clear, descriptive message** - Easy to understand what and why
- **Can be understood in isolation** - Self-contained change
- **Is independently revertible** - Can be undone without breaking other changes

**Philosophy**: Commit early, commit often. Small commits are easier to:
- Review in pull requests
- Revert if needed
- Cherry-pick to other branches
- Understand in git history
- Bisect when debugging

### 2. Conventional Commit Format

All commits should follow this format:

```
<type>(<scope>): <short description>

<optional: detailed explanation>

<optional: LINEAR-XXX ticket reference>
<optional: breaking changes, related tickets>
```

#### Commit Types

| Type | When to Use | Example |
|------|-------------|---------|
| `feat` | New feature or functionality | `feat(api): add user registration endpoint` |
| `fix` | Bug fix | `fix(auth): correct token expiration validation` |
| `refactor` | Code restructuring without changing behavior | `refactor(utils): extract helper functions` |
| `test` | Adding or updating tests | `test(api): add user authentication tests` |
| `docs` | Documentation only changes | `docs(readme): add API usage examples` |
| `style` | Code formatting, whitespace, etc. | `style(components): format with prettier` |
| `perf` | Performance improvements | `perf(query): add index for faster lookups` |
| `chore` | Build process, dependencies, tooling | `chore(deps): update lodash to 4.17.21` |
| `deploy` | Deployment-related changes | `deploy(prod): release v1.2.0 to production` |

#### Scopes (Examples)

Scope indicates the area of codebase affected:
- `api` - Backend API changes
- `ui` - Frontend UI changes
- `db` - Database changes
- `auth` - Authentication/authorization
- `infra` - Infrastructure changes
- `ci` - CI/CD pipeline changes
- `docs` - Documentation
- Component names: `button`, `navbar`, `userService`, etc.

#### LINEAR Ticket References

Always include LINEAR ticket reference in commit body:

```
feat(api): add user profile endpoint

LINEAR-123: Implement GET /api/users/:id endpoint with
authorization checks and response validation
```

### 3. Commit Granularity Guidelines

#### ✅ Just Right (DO commit)

- **Single endpoint implementation** - One route handler with validation
- **Single service method** - One business logic function
- **Single component** - One React/Vue component
- **Single test file** - Tests for one unit
- **Single bug fix** - Fix one specific issue
- **Single refactoring** - Extract one function or reorganize one module
- **Single migration** - One database schema change
- **Single configuration** - One config file or setting

#### ❌ Too Small (DON'T commit separately)

- Single line changes (unless critical hotfix)
- Formatting-only changes (combine with real changes)
- Temporary debug code (don't commit at all)
- Comment-only additions (combine with related code)

#### ❌ Too Large (SPLIT into multiple commits)

- Multiple unrelated features
- Feature + refactoring + bug fixes together
- Endpoint + service + repository + tests all at once
- Multiple API endpoints in one commit
- Changes affecting many different areas
- "Implement entire [feature]" commits

### 4. Good vs Bad Commit Examples

#### ✅ Good Examples

```
feat(auth): add JWT authentication middleware

LINEAR-456: Create middleware to verify JWT tokens and attach
user context to requests. Includes error handling for expired
and invalid tokens.
```

```
test(auth): add login flow integration tests

LINEAR-456: Test successful login, invalid credentials,
token generation, and token validation scenarios
```

```
refactor(db): extract common query methods to BaseRepository

LINEAR-789: Move shared pagination, filtering, and sorting logic
to BaseRepository class for reusability across all repositories
```

```
fix(api): correct email validation regex

LINEAR-234: Fix issue where valid emails with + symbols were
rejected. Updated regex to RFC 5322 compliant pattern.
```

```
perf(query): add composite index for user posts query

LINEAR-567: Create index on posts(user_id, created_at DESC)
reducing query time from 2.5s to 45ms (98% improvement)
```

#### ❌ Bad Examples

```
updates
```
*Too vague - what was updated?*

```
WIP: half-done feature

(Code doesn't compile, tests fail)
```
*Broken state - never commit broken code*

```
feat: implement entire user management system

- Add registration, login, password reset
- Add user profile endpoints
- Add admin panel
- Integrate email service
- Add all tests
```
*Too large - should be 10+ separate commits*

```
fix stuff
```
*Not descriptive - what was fixed?*

```
Final commit before deadline
```
*Not informative - doesn't describe changes*

### 5. Branch Naming Strategy

Create descriptive feature branches:

```bash
# Pattern: <type>/LINEAR-XXX-brief-description

# Examples:
feature/LINEAR-123-user-authentication
fix/LINEAR-456-email-validation
refactor/LINEAR-789-database-optimization
hotfix/LINEAR-234-security-patch
```

#### Branch Types
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `hotfix/` - Critical production fixes
- `chore/` - Maintenance tasks

### 6. Commit Workflow

#### Creating a Feature Branch

```bash
# Create and checkout feature branch
git checkout -b feature/LINEAR-XXX-brief-description

# Verify you're on the new branch
git branch --show-current
```

#### Making Commits

After completing each small task:

```bash
# Stage specific files
git add src/services/UserService.ts

# Commit with descriptive message
git commit -m "feat(service): implement user creation logic

LINEAR-123: Add createUser method with email validation,
password hashing, and duplicate email check"

# Continue with next task...
```

#### Commit Frequency

Commit after:
- Completing one function or method
- Adding one test file
- Implementing one component
- Fixing one bug
- Adding one migration
- Completing one logical unit of work

**Rule of thumb**: If you can describe the change in one sentence, it's ready to commit.

### 7. Squash & Rebase Decision Framework

After completing a feature, decide how to organize commits before merging.

#### When to SQUASH (Combine all commits into one)

**Use when**:
- 20+ micro-commits for a simple feature
- Many "WIP" or "fix typo" commits
- Commits don't tell a clear story individually
- Feature is simple and one commit makes sense
- Main branch prefers single commits per feature
- History noise outweighs history detail

**Example scenario**: Simple form component with 15 commits including "add input", "fix spacing", "update validation", "fix lint", etc.

**Command**:
```bash
git rebase -i main
# In editor, mark all commits as 'squash' except first
# Write comprehensive squash commit message
git push --force-with-lease origin feature/LINEAR-XXX
```

**Squash commit message template**:
```
feat(feature-name): implement [feature] for LINEAR-XXX

Summary of changes:
- Implemented [Component/Feature A] with full functionality
- Added [Feature B] with validation and error handling
- Integrated [Service C] with optimized queries
- Added comprehensive test coverage

Technical details:
- Framework/Library: [Technology used]
- Key patterns: [Architectural decisions]
- Testing: [X] unit tests, [Y] integration tests

Security/Performance notes:
- [Any important considerations]

LINEAR-XXX: [Full ticket title]
```

#### When to KEEP ALL (Preserve commit history)

**Use when**:
- 5-10 clean, atomic commits
- Each commit is meaningful and tells part of the story
- Commits may need to be cherry-picked later
- Team values detailed development history
- Each commit represents a significant step
- History is already clean and informative

**Example scenario**: Backend API with commits like "add route handler", "add validation", "add service logic", "add repository", "add tests" - each is a clear, distinct step.

**Command**:
```bash
# Just push - no squashing needed
git push -u origin feature/LINEAR-XXX
```

#### When to INTERACTIVE REBASE (Selectively organize)

**Use when**:
- Mix of good commits and noise ("WIP", "fix typo")
- Want to group related changes together
- Some commits need better messages
- Commits should be reordered for logical flow
- Complex feature that benefits from organized history
- Multiple logical units within the branch

**Example scenario**: 20 commits where some are substantial (implement feature) and some are fixes (fix lint, fix test, update docs) that should be squashed into related commits.

**Command**:
```bash
git rebase -i main

# In editor, use:
# - pick: Keep this commit
# - squash: Merge into previous commit
# - reword: Change commit message
# - drop: Remove commit
# - reorder: Move lines to reorder commits

git push --force-with-lease origin feature/LINEAR-XXX
```

**Interactive rebase example**:
```
# Before (12 commits):
pick 123abc feat(api): add user route structure
pick 456def feat(api): add validation schemas
pick 789ghi fix: fix lint error
pick abc123 feat(service): add user service
pick def456 feat(service): add business logic
pick ghi789 fix: typo in service
pick jkl012 feat(repo): add user repository
pick mno345 test(api): add route tests
pick pqr678 test(service): add service tests
pick stu901 fix: fix test
pick vwx234 docs: update API documentation
pick yz567 refactor: clean up code

# After interactive rebase (5 commits):
pick 123abc feat(api): add user routes with validation
# (squashed 456def and 789ghi into this)
pick abc123 feat(service): implement user service logic
# (squashed def456 and ghi789 into this)
pick jkl012 feat(repo): add user repository
pick mno345 test(api): add comprehensive test coverage
# (squashed pqr678 and stu901 into this)
pick vwx234 docs: update API documentation
# (squashed yz567 into this)
```

### 8. Squash & Rebase Decision Matrix

| Scenario | Commits | Quality | Recommendation | Reasoning |
|----------|---------|---------|----------------|-----------|
| Simple API endpoint | 5-8 | Clean, atomic | **Keep all** | Each step is valuable |
| Simple API endpoint | 20+ | Many WIP/fixes | **Squash all** | Noise outweighs value |
| Complex feature | 15-20 | Mix of good/noise | **Interactive rebase** | Keep structure, remove noise |
| Hotfix | 1-2 | Focused | **Keep all** | Clear, important change |
| UI component | 10-15 | Iterative tweaks | **Squash all** | Final result matters most |
| Database migrations | 5-8 | Sequential | **Keep all** | Track each migration |
| Refactoring | 10-12 | Mixed | **Interactive rebase** | Group by area refactored |
| Multi-endpoint API | 20+ | Good structure | **Interactive rebase** | Group by endpoint |

### 9. Git Best Practices

#### Safe Force Push

**Always use `--force-with-lease` instead of `--force`**:

```bash
# ✅ Good: Safe force push
git push --force-with-lease origin feature/LINEAR-XXX

# ❌ Bad: Dangerous force push
git push --force origin feature/LINEAR-XXX
```

`--force-with-lease` prevents overwriting others' work by checking if remote branch has changed.

#### Commit Message Guidelines

1. **First line (subject)**:
   - Keep under 72 characters
   - Use imperative mood ("add" not "added")
   - Don't end with period
   - Be specific and descriptive

2. **Body** (optional but recommended):
   - Wrap at 72 characters
   - Explain WHAT and WHY, not HOW
   - Include LINEAR ticket reference
   - Add context that isn't obvious from code

3. **Footer** (optional):
   - Breaking changes: `BREAKING CHANGE: description`
   - Related tickets: `Related: LINEAR-123, LINEAR-456`
   - Closes tickets: `Closes: LINEAR-789`

#### Common Patterns by Role

**Frontend Developer**:
```bash
# Commit 1: Component structure
git commit -m "feat(ui): add UserProfile component structure"

# Commit 2: Component logic
git commit -m "feat(ui): implement UserProfile state and handlers"

# Commit 3: Styling
git commit -m "style(ui): add responsive styles to UserProfile"

# Commit 4: Tests
git commit -m "test(ui): add UserProfile component tests"
```

**Backend Developer**:
```bash
# Commit 1: Route
git commit -m "feat(api): add POST /api/users route handler"

# Commit 2: Validation
git commit -m "feat(api): add user creation validation schemas"

# Commit 3: Service
git commit -m "feat(service): implement user creation logic"

# Commit 4: Repository
git commit -m "feat(repo): add user database operations"

# Commit 5: Tests
git commit -m "test(api): add user creation endpoint tests"
```

**DBA**:
```bash
# Commit 1: Schema doc
git commit -m "feat(db): document users table schema"

# Commit 2: Migration
git commit -m "feat(db): add users table migration"

# Commit 3: Indexes
git commit -m "feat(db): add users table indexes"

# Commit 4: Seed data
git commit -m "feat(db): add users seed data"
```

**DevOps**:
```bash
# Commit 1: Infrastructure
git commit -m "feat(infra): add VPC with multi-AZ subnets"

# Commit 2: Compute
git commit -m "feat(infra): configure auto-scaling group"

# Commit 3: Database
git commit -m "feat(infra): set up RDS instance"

# Commit 4: CI/CD
git commit -m "feat(ci): add automated deployment workflow"
```

### 10. Handling Common Scenarios

#### Scenario 1: Made too many small commits

**Solution**: Interactive rebase to squash
```bash
git rebase -i HEAD~10  # Last 10 commits
# Squash related commits together
git push --force-with-lease
```

#### Scenario 2: Forgot to add LINEAR ticket reference

**Solution**: Amend last commit or rebase to edit
```bash
# If it's the last commit:
git commit --amend
# Add LINEAR reference to message
git push --force-with-lease

# If it's an older commit:
git rebase -i HEAD~N
# Mark commit as 'reword'
# Add LINEAR reference
git push --force-with-lease
```

#### Scenario 3: Need to split a large commit

**Solution**: Interactive rebase with edit
```bash
git rebase -i HEAD~N
# Mark large commit as 'edit'
# When rebase stops:
git reset HEAD^
# Stage and commit files separately
git add file1.js
git commit -m "feat: add file1 functionality"
git add file2.js
git commit -m "feat: add file2 functionality"
# Continue rebase
git rebase --continue
git push --force-with-lease
```

#### Scenario 4: Commit messages are inconsistent

**Solution**: Interactive rebase to reword
```bash
git rebase -i HEAD~N
# Mark commits as 'reword'
# Update messages to follow conventional format
git push --force-with-lease
```

### 11. Pre-Merge Checklist

Before creating pull request or merging:

- [ ] All commits follow conventional commit format
- [ ] Each commit includes LINEAR ticket reference in body
- [ ] Commits are appropriately sized (atomic)
- [ ] Commit history is clean and logical
- [ ] Decided on squash/keep/interactive rebase strategy
- [ ] Branch is up to date with main/master
- [ ] No "WIP" or "fix typo" commits in final history
- [ ] Commit messages are descriptive and helpful
- [ ] Each commit compiles and passes tests
- [ ] No secrets or credentials in any commit

### 12. Review Your Commit History

Before finalizing, review your commits:

```bash
# View commit history for current branch
git log --oneline feature/LINEAR-XXX-description

# View detailed history
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'

# View what will be merged
git log main..HEAD --oneline

# View commit count
git rev-list --count main..HEAD
```

**Analysis questions**:
1. Is the story clear from reading the commits?
2. Are there any commits that should be squashed?
3. Do messages follow conventional format?
4. Are LINEAR tickets referenced?
5. Would this history help someone understand the changes?

### 13. Final Recommendation Process

When ready to finalize your branch:

1. **Count commits**: `git rev-list --count main..HEAD`
2. **Review quality**: `git log --oneline`
3. **Apply decision matrix**: Use table in section 8
4. **Make recommendation**: Propose squash/keep/interactive
5. **Get approval**: Ask user before proceeding
6. **Execute**: Perform chosen strategy
7. **Verify**: Check final history looks good
8. **Push**: Use `--force-with-lease` if rebased

### 14. Integration with Linear Tickets

All commits should support Linear ticket tracking:

```
feat(api): add user authentication endpoint

LINEAR-456: Implement POST /api/auth/login with email/password
validation, JWT token generation, and refresh token support.

Technical details:
- Uses bcrypt for password hashing
- JWT tokens expire in 24 hours
- Refresh tokens stored in httpOnly cookies
- Rate limiting: 5 attempts per minute per IP
```

This helps:
- Track all commits related to a ticket
- Understand work done for each story
- Audit development history
- Link code changes to requirements

---

## Quick Reference

### Commit Types
`feat` `fix` `refactor` `test` `docs` `style` `perf` `chore` `deploy`

### Commit Format
```
<type>(<scope>): <description>

LINEAR-XXX: <detailed explanation>
```

### Decision Framework
- **Squash**: 20+ commits, lots of noise, simple feature
- **Keep**: 5-10 clean commits, each meaningful
- **Interactive**: Mix of good/noise, complex feature

### Safe Commands
- `git push --force-with-lease` (not `--force`)
- `git rebase -i main` (organize commits)
- `git commit --amend` (fix last commit)

---

**Remember**: The goal is a clear, helpful commit history that tells the story of your changes. Commit often during development, then organize before merging.
