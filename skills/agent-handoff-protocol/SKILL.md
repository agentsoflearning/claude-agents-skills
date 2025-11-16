---
name: agent-handoff-protocol
description: Standardized agent handoff procedures for seamless collaboration in multi-agent workflows. Creates comprehensive work summaries, identifies next agents, and passes critical context. Use when completing work and handing off to another agent.
version: 1.0.0
allowed-tools: Read, Write, Grep
---

# Agent Handoff Protocol

A comprehensive skill for standardizing agent-to-agent handoffs in multi-agent workflows, ensuring nothing gets lost in transitions.

## Overview

This skill provides:
- **Standardized handoff format**: Consistent "Work Complete ✓" summaries
- **Context preservation**: Ensures critical information passes between agents
- **Clear next steps**: Identifies which agent(s) to invoke next
- **Deliverables documentation**: Lists all artifacts created
- **Open questions tracking**: Surfaces issues needing attention

## When to Use This Skill

Use this skill when:
1. Your work is complete and ready for next agent
2. Handing off between design → development
3. Handing off between development → security → QA → DevOps
4. Passing partial work due to blocker
5. Completing a phase in multi-phase workflow
6. Coordinating between multiple parallel agents
7. Need to document what you've done for audit trail

## Agent Workflow Sequence

Understanding the typical flow helps you know who to hand off to:

```
Product Vision & Strategy Flow:
Chief Product Officer → Senior Product Manager → UX Designer → Product Designer

Technical Planning Flow:
Senior Product Manager → Software Architect → DBA

Development Flow:
Software Architect/DBA → Backend Developer
                      ↘ Frontend Developer

Quality & Deployment Flow:
Backend/Frontend Developer → App Security Engineer → Sr QA Engineer → DevOps Engineer
```

## Instructions

### 1. Standard Handoff Format

When your work is complete, create a handoff summary using this format:

```markdown
## Work Complete ✓

**[Your Role]**: [Brief summary of what you accomplished]

### Deliverables:
- Deliverable 1: [Description and location]
- Deliverable 2: [Description and location]
- Deliverable 3: [Description and location]

### Git Information (if applicable):
- **Branch**: [branch-name]
- **Commits**: [count] commits
- **Files Changed**: [+additions -deletions]
- **PR**: [PR number if created]

### Next Steps:
**Ready for handoff to**: [Agent name(s)]

To invoke:
- `@[agent-name]` for [specific work needed]
- `@[agent-name]` for [specific work needed]

### Context for Next Agent:
[Critical information the next agent needs to know]

**Important Notes**:
- [Any blockers, risks, or special considerations]
- [Decisions made that affect next steps]
- [Open questions that need resolution]

### Quality Checklist (if applicable):
- [x] Item 1
- [x] Item 2
- [ ] Item 3 (for next agent)
```

### 2. Handoff by Agent Type

#### Chief Product Officer → Senior Product Manager

```markdown
## Work Complete ✓

**Chief Product Officer**: Product vision and strategy defined

### Deliverables:
- Product Vision: `docs/product/vision/product-vision.md`
- Product Roadmap: `docs/product/roadmaps/2025-roadmap.md`
- Success Metrics: OKRs and KPIs documented
- Market Positioning: Competitive analysis complete

### Strategic Context:
- **Target Market**: [Description]
- **Key Differentiators**: [Unique value props]
- **Launch Timeline**: [Target dates]
- **Budget Constraints**: [Important constraints]

### Next Steps:
**Ready for handoff to**: Senior Product Manager

To invoke: `@senior-product-manager`

### Context for Senior Product Manager:
Please create detailed PRDs for the following initiatives from the roadmap:
1. **Priority 1**: [Initiative name] - Target Q1 2025
2. **Priority 2**: [Initiative name] - Target Q2 2025

**Key Requirements**:
- Focus on [specific user personas]
- Must integrate with [existing systems]
- Performance requirements: [specific metrics]

### Open Questions:
- [ ] Confirm budget allocation with finance team
- [ ] Validate market assumptions with customer interviews
```

#### Senior Product Manager → UX Designer + Software Architect

```markdown
## Work Complete ✓

**Senior Product Manager**: Comprehensive PRD created for [Feature]

### Deliverables:
- PRD: `docs/product/prds/user-authentication-prd.md`
- User Stories: 12 stories with acceptance criteria
- Success Metrics: Defined and measurable
- User Personas: 3 personas documented

### PRD Highlights:
- **Must-Have Features**: [List critical features]
- **User Flows**: 5 critical user journeys defined
- **Success Criteria**: [Key metrics]
- **Timeline**: [Target delivery date]

### Next Steps:
**Ready for handoff to**:
- UX Designer (for design system and style guide)
- Software Architect (for technical architecture)

To invoke:
- `@ux-designer` for style guide and UX patterns
- `@software-architect` for system architecture and tech stack decisions

### Context for UX Designer:
Focus on:
- Modern, clean aesthetic aligned with brand
- Mobile-first responsive design
- WCAG 2.1 AA accessibility compliance
- See user personas in PRD for design considerations

### Context for Software Architect:
Key technical considerations:
- Must handle 10K concurrent users
- Integrate with existing OAuth2 system
- Database choice: MongoDB or Supabase (your decision)
- Budget: $500/month infrastructure cost target

### Open Questions:
- [ ] Confirm OAuth2 provider (awaiting engineering decision)
- [ ] Validate success metrics with data team
```

#### UX Designer → Product Designer

```markdown
## Work Complete ✓

**UX Designer**: Style guide and design system complete

### Deliverables:
- Style Guide: `docs/design/ux/style-guide.md`
- Design System: `docs/design/ux/design-system.md`
- Component Specs: 24 components defined
- Accessibility Guidelines: WCAG 2.1 AA standards documented

### Design System Highlights:
- **Typography**: 6-level scale defined
- **Colors**: 12 color palette with tokens
- **Spacing**: 8px grid system
- **Components**: Buttons, forms, cards, navigation, modals
- **Breakpoints**: Mobile (320px), Tablet (768px), Desktop (1024px+)

### Next Steps:
**Ready for handoff to**: Product Designer

To invoke: `@product-designer`

### Context for Product Designer:
Please create high-fidelity UI designs for:
1. User authentication flow (login, signup, password reset)
2. User profile dashboard
3. Settings pages

**Design Constraints**:
- Use only colors and components from design system
- Follow spacing and typography scales
- Ensure all states are designed (default, hover, focus, disabled, error)
- Mobile-first approach

### Notes for Designer:
- Brand guidelines are in `docs/design/brand/`
- User flows from PRD: `docs/product/prds/user-authentication-prd.md`
- Focus on accessibility - all interactive elements need visible focus states
```

#### Software Architect → DBA + Backend Developer + Frontend Developer

```markdown
## Work Complete ✓

**Software Architect**: System architecture and implementation plan complete

### Deliverables:
- System Design: `docs/architecture/system-design.md`
- Tech Stack: Documented and approved
- Implementation Plan: `docs/architecture/implementation-plan.md`
- API Contracts: `docs/architecture/api-contracts/auth-api.yaml`
- Linear Tickets: 8 tickets created for development

### Architecture Decisions:
- **Frontend**: React 18 + TypeScript + Tailwind CSS
- **Backend**: Node.js + Express + TypeScript
- **Database**: Supabase (PostgreSQL) with RLS
- **Authentication**: JWT with refresh tokens
- **Hosting**: Vercel (frontend), Railway (backend)

### Next Steps:
**Ready for handoff to**:
- DBA (for database schema design)
- Backend Developer (for API implementation)
- Frontend Developer (for UI implementation)

To invoke:
- `@dba` for database schema and migrations (start first)
- `@backend-developer` for API development (after DBA completes)
- `@frontend-developer` for UI development (can start in parallel with backend)

### Context for DBA:
**Linear Ticket**: LINEAR-200
Focus on:
- Users table with authentication fields
- Sessions table for refresh tokens
- Proper indexes for email lookups and session queries
- RLS policies for user data protection
See `docs/architecture/system-design.md` for schema requirements

### Context for Backend Developer:
**Linear Ticket**: LINEAR-201
Wait for DBA to complete schema, then:
- Implement API contracts in `docs/architecture/api-contracts/auth-api.yaml`
- Use Supabase client for database operations
- Follow micro-commit workflow
- See implementation plan for detailed breakdown

### Context for Frontend Developer:
**Linear Ticket**: LINEAR-202
Can start in parallel:
- Use UI designs from `docs/design/ui/`
- Follow style guide in `docs/design/ux/style-guide.md`
- Mock API responses initially, integrate real API later
- See implementation plan for component breakdown

### Technical Notes:
- All agents: Use micro-commit workflow skill for git
- All agents: Update Linear tickets using linear-integration skill
- Backend: Ensure all API endpoints follow OpenAPI spec
- Frontend: Ensure WCAG 2.1 AA compliance
```

#### Backend Developer / Frontend Developer → App Security Engineer

```markdown
## Work Complete ✓

**Backend Developer**: API implementation complete and ready for security review

### Deliverables:
- API Endpoints: 8 endpoints implemented
- Services: 3 service classes with business logic
- Repositories: 2 repository classes for data access
- Tests: 45 tests (92% coverage)
- Documentation: API documentation updated

### Git Information:
- **Branch**: feature/LINEAR-201-auth-api
- **Commits**: 12 commits (squashed to 4)
- **Files Changed**: 18 files (+1,245 lines)
- **PR**: #47 (ready for review)

### Implementation Highlights:
- ✅ All API contracts implemented per OpenAPI spec
- ✅ Input validation on all endpoints (Joi schemas)
- ✅ Parameterized queries (no SQL injection risk)
- ✅ JWT authentication with secure secret management
- ✅ Rate limiting (100 req/min per user)
- ✅ Error messages don't leak sensitive data

### Next Steps:
**Ready for handoff to**: App Security Engineer

To invoke: `@app-security-engineer`

### Context for Security Engineer:
Please run security scans using secure-push skill:
- **Priority**: Check for secrets, SQL injection, auth bypasses
- **Focus Areas**: Authentication logic, password handling, token validation
- **Branch**: feature/LINEAR-201-auth-api
- **Linear Ticket**: LINEAR-201

### Security Checklist (Self-Review):
- [x] Input validation on all endpoints
- [x] Parameterized queries only (no string concatenation)
- [x] Authentication required on protected routes
- [x] Authorization checks for resource access
- [x] Rate limiting configured
- [x] CORS properly configured
- [x] Error messages sanitized
- [x] Secrets in environment variables
- [x] No hardcoded credentials
- [x] Password hashing with bcrypt

### Known Considerations:
- Using bcrypt with cost factor 10 (balance of security and performance)
- JWT tokens expire in 24 hours (refresh tokens in 30 days)
- Rate limiting may need adjustment based on real usage patterns
```

#### App Security Engineer → Senior QA Engineer

```markdown
## Work Complete ✓

**App Security Engineer**: Security scan complete - APPROVED ✅

### Security Scan Results:

**🔍 SECRET SCANNING (Gitleaks)**
- ✅ No secrets detected
- Scan coverage: 100% of changed files

**🔎 CODE ANALYSIS (Semgrep)**
- ✅ No Critical or High severity issues
- ⚠️ 2 Medium severity warnings (documented below)
- Scanned: 18 files, 1,245 lines of code

**🔬 DEPENDENCY SCANNING (Trivy)**
- ✅ No Critical or High CVEs
- ⚠️ 3 Low severity CVEs (accepted risk, documented)

### Medium Severity Warnings (Non-Blocking):
1. **JWT Secret Length**: Currently 32 chars, recommend 64+ for production
   - **File**: `src/config/auth.ts:12`
   - **Fix**: Increase JWT_SECRET length in production environment
   - **Risk**: Low - current length meets minimum requirements

2. **Session Timeout**: 24-hour session is long
   - **File**: `src/middleware/auth.ts:45`
   - **Recommendation**: Consider reducing to 8-12 hours
   - **Decision**: Accepted - product requirement for user convenience

### Overall Assessment:
**Status**: ✅ APPROVED FOR QA TESTING

All Critical and High severity issues resolved. Medium/Low findings documented and acceptable for this release. Code follows security best practices.

### Next Steps:
**Ready for handoff to**: Senior QA Engineer

To invoke: `@senior-qa-engineer`

### Context for QA Engineer:
Please perform comprehensive testing:
- **Branch**: feature/LINEAR-201-auth-api
- **Linear Ticket**: LINEAR-201
- **Focus Areas**: Authentication flows, edge cases, error handling

**Test Scenarios to Prioritize**:
1. User registration with various input combinations
2. Login with correct/incorrect credentials
3. Token expiration and refresh flows
4. Password reset flow
5. Rate limiting behavior
6. Error handling for all endpoints

**Security-Specific Tests**:
- Verify SQL injection prevention (try malicious inputs)
- Confirm authentication bypass attempts fail
- Test CORS configuration
- Verify rate limiting works

### Notes for QA:
- See `docs/product/prds/user-authentication-prd.md` for acceptance criteria
- Test data available in `tests/fixtures/`
- All unit tests passing (45 tests, 92% coverage)
```

#### Senior QA Engineer → DevOps Engineer

```markdown
## Work Complete ✓

**Senior QA Engineer**: Comprehensive testing complete - APPROVED ✅

### Test Execution Summary:

**Total Tests**: 78 tests
- Unit Tests: 45 tests ✅ (all passing)
- Integration Tests: 23 tests ✅ (all passing)
- E2E Tests (Playwright): 10 tests ✅ (all passing)

**Test Coverage**: 92% overall
- Services: 95% coverage
- Controllers: 90% coverage
- Repositories: 88% coverage

### Test Results by Category:

**Functional Testing**: ✅ PASS
- ✅ User registration with validation
- ✅ Login flow with JWT generation
- ✅ Token refresh mechanism
- ✅ Password reset flow
- ✅ All API endpoints respond correctly

**Edge Cases & Error Handling**: ✅ PASS
- ✅ Invalid email formats rejected
- ✅ Weak passwords rejected
- ✅ Duplicate email registration prevented
- ✅ Expired tokens handled correctly
- ✅ Invalid tokens rejected
- ✅ Rate limiting enforced (tested with 150 requests)

**Security Testing**: ✅ PASS
- ✅ SQL injection attempts blocked
- ✅ XSS attempts sanitized
- ✅ Authentication required on protected endpoints
- ✅ CORS configuration correct
- ✅ Password hashing verified

**Performance Testing**: ✅ PASS
- ✅ Login response time: 145ms avg (target: <200ms)
- ✅ Registration response time: 210ms avg (target: <300ms)
- ✅ Token validation: 8ms avg (target: <10ms)
- ✅ Concurrent users: Tested 100 users successfully

**Accessibility (Frontend)**: ✅ PASS
- ✅ WCAG 2.1 AA compliant (automated scan)
- ✅ Keyboard navigation works
- ✅ Screen reader tested (NVDA)
- ✅ Focus indicators visible

### Issues Found & Resolved:
1. ~~Minor: Error message typo~~ - Fixed in commit abc123
2. ~~Minor: Loading spinner alignment~~ - Fixed in commit def456

### Acceptance Criteria Status:
- [x] All 12 acceptance criteria from PRD met
- [x] No Critical or High severity bugs
- [x] Performance targets achieved
- [x] Security requirements validated
- [x] Accessibility standards met

### Overall Assessment:
**Status**: ✅ READY FOR PRODUCTION DEPLOYMENT

All testing complete. Code meets quality standards, acceptance criteria fulfilled, no blockers identified.

### Next Steps:
**Ready for handoff to**: DevOps Engineer

To invoke: `@devops-engineer`

### Context for DevOps:
Please deploy to production:
- **Branch**: feature/LINEAR-201-auth-api
- **Linear Ticket**: LINEAR-201
- **PR**: #47 (approved and ready to merge)

**Deployment Checklist**:
- [ ] Merge PR to main
- [ ] Run database migrations (2 new migrations)
- [ ] Deploy to staging first
- [ ] Run smoke tests on staging
- [ ] Deploy to production with monitoring
- [ ] Verify health checks
- [ ] Update Linear ticket to Done

**Environment Variables Required**:
- `JWT_SECRET` (64+ characters for production)
- `JWT_REFRESH_SECRET` (different from JWT_SECRET)
- `DATABASE_URL` (Supabase connection string)
- `CORS_ORIGINS` (production domain whitelist)

**Database Migrations**:
- `001_create_users_table.sql`
- `002_create_sessions_table.sql`

**Monitoring Alerts**:
- Watch error rates (should stay < 1%)
- Monitor response times (P95 < 200ms)
- Check auth success rate (should be > 95%)

### Rollback Plan (if needed):
1. Revert deployment to previous version
2. Roll back database migrations (down migrations provided)
3. Clear Redis cache
4. Estimated rollback time: < 5 minutes

### Notes:
- All tests available in PR for future regression testing
- Test plan documented in `tests/test-plan.md`
- Playwright tests can be added to CI/CD for continuous testing
```

### 3. Parallel Handoffs

When multiple agents can work in parallel:

```markdown
## Work Complete ✓

**Software Architect**: Architecture complete, ready for parallel development

### Next Steps:
**Ready for parallel handoff to**:
- DBA (can start immediately - no dependencies)
- Frontend Developer (can start immediately - use mocked APIs)
- Backend Developer (wait for DBA to complete schema)

### Execution Order:
1. **Start immediately** (parallel):
   - `@dba` - Create database schema
   - `@frontend-developer` - Build UI with mocked data

2. **Start after DBA completes**:
   - `@backend-developer` - Implement API with real database

3. **After all development complete**:
   - `@app-security-engineer` - Security scan
   - Then `@senior-qa-engineer` - QA testing
   - Finally `@devops-engineer` - Deployment

### Coordination:
- DBA and Frontend Developer: No dependencies, proceed in parallel
- Backend Developer: Wait for DBA completion notification
- All developers: Update shared Linear epic LINEAR-200 with progress
```

### 4. Partial Handoff (Blocker Scenario)

When you can't complete all work due to a blocker:

```markdown
## Partial Work Complete (Blocker)

**Backend Developer**: API implementation 70% complete - BLOCKED ⚠️

### Completed Work:
- ✅ User registration endpoint (fully implemented and tested)
- ✅ Login endpoint (fully implemented and tested)
- ✅ Service layer (UserService complete)
- ✅ Repository layer (UserRepository complete)

### Blocked Work:
- ❌ Password reset endpoint - BLOCKED
- ❌ Email verification - BLOCKED

### Blocker Details:
**Issue**: Email service integration not available
**Blocking**: Password reset and email verification features
**Impact**: 30% of API implementation blocked
**Attempted**: Tried using SendGrid, credentials not yet provisioned

**What's Needed**:
1. SendGrid API key provisioned by DevOps
2. Email templates approved by product
3. Sender email domain verified

**Estimated Time to Unblock**: 2-3 days

### Options for Next Steps:

**Option 1: Partial Handoff** (Recommended)
Hand off completed work for security scan and QA:
- Invoke `@app-security-engineer` to scan completed endpoints
- Invoke `@senior-qa-engineer` to test registration and login flows
- I'll complete email features once unblocked

**Option 2: Wait for Unblock**
- Wait for email service provisioning
- Complete all features
- Then hand off to security/QA once

**Option 3: Mock Email Service**
- Implement mock email service for testing
- Deploy with mock in staging
- Replace with real service later

### Recommendation:
Proceed with **Option 1** (partial handoff) to maintain velocity. Completed features can be tested and deployed while email service is being provisioned.

### Context if Proceeding with Option 1:
Invoke security and QA on:
- **Branch**: feature/LINEAR-201-auth-api-partial
- **Scope**: Registration and login only (skip password reset tests)
- **Linear Ticket**: LINEAR-201 (update description with partial scope)

I'll create a follow-up ticket LINEAR-XXX for email-dependent features once unblocked.
```

### 5. Best Practices for Effective Handoffs

#### Do's ✅
- **Be comprehensive**: Include all relevant context
- **Be specific**: Reference exact file paths, commit SHAs, ticket numbers
- **Highlight risks**: Call out anything the next agent should watch for
- **Provide testing instructions**: Make it easy for next agent to verify
- **Link documentation**: Reference all relevant docs
- **Update Linear**: Keep Linear ticket in sync with handoff
- **Thank collaborators**: Acknowledge help from other agents

#### Don'ts ❌
- **Don't assume context**: Next agent may not know background
- **Don't skip quality checks**: Verify work before handoff
- **Don't leave open questions unanswered**: Resolve or document them
- **Don't forget git info**: Always include branch, commits, PR
- **Don't handoff broken code**: Ensure tests pass
- **Don't skip documentation**: Update docs before handoff

### 6. Handoff Checklist Template

Before handing off, verify:

```markdown
## Pre-Handoff Checklist

### Quality Verification:
- [ ] All work completed per requirements
- [ ] Tests written and passing
- [ ] Code follows style guide
- [ ] Documentation updated
- [ ] No known bugs or issues
- [ ] Performance acceptable

### Git Hygiene:
- [ ] Branch up to date with main
- [ ] Commits follow micro-commit workflow
- [ ] Commit messages include LINEAR references
- [ ] No WIP or temp commits in history
- [ ] PR created (if applicable)

### Documentation:
- [ ] Code comments added where needed
- [ ] README updated
- [ ] API documentation current
- [ ] Architecture docs reflect changes
- [ ] Runbook updated (if infrastructure)

### Linear Ticket:
- [ ] Ticket status updated
- [ ] Progress comments added
- [ ] Blockers documented (if any)
- [ ] Related tickets linked
- [ ] Acceptance criteria checked

### Handoff Summary:
- [ ] Deliverables clearly listed
- [ ] Next agent(s) identified
- [ ] Context provided
- [ ] Open questions documented
- [ ] Quality checklist included
```

---

## Quick Reference

### Standard Handoff Sections:
1. **Work Complete ✓** header
2. **Deliverables** with file paths
3. **Git Information** (branch, commits, PR)
4. **Next Steps** (which agents to invoke)
5. **Context for Next Agent** (specific guidance)
6. **Open Questions** (unresolved items)
7. **Quality Checklist** (verification items)

### Common Handoff Flows:
- CPO → Sr PM → UX Designer → Product Designer
- Sr PM → Software Architect → DBA
- DBA → Backend Dev → Security → QA → DevOps
- Architect → Frontend Dev → Security → QA → DevOps

### Key Principles:
- **Completeness**: Include all relevant context
- **Clarity**: Be specific and unambiguous
- **Continuity**: Ensure smooth transition
- **Quality**: Verify work before handoff

---

**Remember**: A good handoff enables the next agent to start working immediately without confusion or missing information. Invest time in clear handoffs to maximize team velocity.
