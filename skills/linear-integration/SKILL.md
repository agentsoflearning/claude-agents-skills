---
name: linear-integration
description: Linear ticket management with MCP tools for status updates, progress tracking, and ticket lifecycle management. Handles get issue, update issue, add comments, and status transitions. Use when managing Linear tickets throughout development workflow.
version: 1.0.0
allowed-tools: Bash, Read, Write, MCP
---

# Linear Integration

Comprehensive Linear ticket management skill that guides agents through the complete ticket lifecycle using Linear MCP tools.

## Overview

This skill provides:
- **Linear MCP tool usage**: Standardized patterns for all Linear operations
- **Status transitions**: Proper workflow through ticket states
- **Progress tracking**: Regular updates and milestone documentation
- **Blocker handling**: Documenting and escalating blockers
- **Ticket linking**: Connecting related work across tickets

## When to Use This Skill

Use this skill when:
1. Starting work on a Linear ticket (transition to "In Progress")
2. Updating ticket progress after completing phases
3. Documenting blockers or issues encountered
4. Adding progress comments with technical details
5. Marking ticket ready for review or handoff
6. Completing work and closing tickets
7. Searching for related tickets
8. Linking dependencies between tickets

## Linear MCP Tools Available

You have access to these Linear MCP tools:

- `mcp__linear__get_issue` - Fetch ticket details
- `mcp__linear__update_issue` - Update ticket status, title, description
- `mcp__linear__add_comment` - Add progress updates and notes
- `mcp__linear__search_issues` - Find related tickets
- `mcp__linear__create_issue` - Create new tickets (when needed)
- `mcp__linear__get_team` - Get team information
- `mcp__linear__get_user` - Get user information

## Instructions

### 1. Starting Work on a Ticket

When you receive a Linear ticket to work on:

#### Step 1: Fetch Full Ticket Details

```bash
# Use MCP tool to get complete ticket information
mcp__linear__get_issue
  issue_id: "LINEAR-123"
```

This returns:
- Title and description
- Current status
- Assignee
- Priority
- Labels
- Comments and history
- Related tickets
- Acceptance criteria

#### Step 2: Review Context

Read the ticket details carefully:
- Understand the requirements
- Check acceptance criteria
- Review any linked PRDs or design docs
- Identify dependencies
- Note any special constraints

#### Step 3: Update Status to "In Progress"

```bash
# Update ticket status
mcp__linear__update_issue
  issue_id: "LINEAR-123"
  status: "In Progress"
```

#### Step 4: Add Initial Comment

Document your plan:

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "Starting work on LINEAR-123

## Implementation Plan
- Phase 1: [Brief description]
- Phase 2: [Brief description]
- Phase 3: [Brief description]

**Branch**: feature/LINEAR-123-brief-description
**Estimated Time**: [X hours/days]

Will provide progress updates as I complete each phase."
```

### 2. Providing Progress Updates

Update Linear ticket regularly throughout your work:

#### After Completing Each Phase

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**Phase 1 Complete** ✅

Completed tasks:
- ✅ Task 1.1: [Description]
- ✅ Task 1.2: [Description]
- ✅ Task 1.3: [Description]

**Commits**: [commit-sha-1, commit-sha-2, commit-sha-3]
**Progress**: 33% complete
**Files Changed**: src/api/users.ts, src/services/UserService.ts

Next: Starting Phase 2 - [Description]"
```

#### When Encountering Blockers

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "⚠️ **Blocker Encountered**

**Issue**: Unable to access [resource/service/API]
**Impact**: Blocks Phase 2 implementation
**Estimated Delay**: [X hours/days]

**Attempted Solutions**:
- [What you tried]
- [What didn't work]

**Need**: [What's required to unblock]
**Next Steps**: [What you'll do while blocked]"
```

Also update ticket status if needed:
```bash
mcp__linear__update_issue
  issue_id: "LINEAR-123"
  status: "Blocked"
```

#### After Making Technical Decisions

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**Technical Decision Made**

**Decision**: Using [Technology/Pattern/Approach]

**Rationale**:
- [Reason 1]
- [Reason 2]
- [Reason 3]

**Alternatives Considered**:
- [Alternative A]: Rejected because [reason]
- [Alternative B]: Rejected because [reason]

**Impact**: [Performance/Security/Maintainability implications]"
```

#### When Changing Scope

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**Scope Update**

**Added to Scope**:
- [Item added and why]

**Removed from Scope**:
- [Item removed and why]

**Justification**: [Explanation]
**Impact on Timeline**: [Estimate]"
```

### 3. Ticket Status Transitions

Follow this workflow for status transitions:

```
Todo → In Progress → In Review → Done
         ↓              ↓
      Blocked ←────────┘
```

#### Status: "Todo"
**When**: Ticket is created but work hasn't started
**Your action**: Fetch ticket details, plan work

#### Status: "In Progress"
**When**: You start working on the ticket
**Your action**: Update status, add initial comment with plan
```bash
mcp__linear__update_issue
  issue_id: "LINEAR-123"
  status: "In Progress"
```

#### Status: "Blocked"
**When**: You encounter a blocker that prevents progress
**Your action**: Update status, document blocker in comment
```bash
mcp__linear__update_issue
  issue_id: "LINEAR-123"
  status: "Blocked"

mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "[Blocker details as shown above]"
```

#### Status: "In Review"
**When**: Implementation complete, ready for code review/QA
**Your action**: Update status, provide comprehensive summary
```bash
mcp__linear__update_issue
  issue_id: "LINEAR-123"
  status: "In Review"

mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**Implementation Complete** ✅

Ready for review and QA testing.

**Summary**:
- All acceptance criteria met
- [X] tests written (Y% coverage)
- Security scan passed
- Documentation updated

**Branch**: feature/LINEAR-123-description
**Commits**: [Final count] commits

**How to Test**: [Brief testing instructions]

**Ready for**:
- Code review by engineering team
- Security review by @app-security-engineer
- QA testing by @senior-qa-engineer"
```

#### Status: "Done"
**When**: Work is merged, deployed, and verified
**Your action**: Final update with deployment details
```bash
mcp__linear__update_issue
  issue_id: "LINEAR-123"
  status: "Done"

mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**Completed and Deployed** 🚀

**Merged**: PR #[number] merged to main
**Deployed**: Production deployment on [date]
**Version**: v[version number]

**Final Metrics**:
- Commits: [count]
- Files changed: [count]
- Tests added: [count]
- Test coverage: [X%]

All acceptance criteria met ✅
No outstanding issues ✅"
```

### 4. Progress Update Patterns by Agent Role

#### Backend Developer

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**API Implementation Update**

✅ Completed:
- POST /api/users endpoint with validation
- UserService with business logic
- UserRepository with database operations
- Integration tests (23 tests passing)

**Commits**: 5 micro-commits
**Security**: Input validation, parameterized queries ✅
**Performance**: Added indexes for common queries ✅

Next: Adding authentication middleware"
```

#### Frontend Developer

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**UI Implementation Update**

✅ Completed:
- UserProfile component with responsive design
- Form validation with error handling
- API integration with loading/error states
- Component tests (15 tests passing)

**Accessibility**: WCAG 2.1 AA compliant ✅
**Responsive**: Tested mobile, tablet, desktop ✅

Next: Adding animations and polish"
```

#### DBA

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**Database Implementation Update**

✅ Completed:
- Users table migration with schema
- Composite indexes for query optimization
- RLS policies for data security
- Seed data for testing

**Migrations**: 4 migration files created
**Performance**: Queries optimized (2.5s → 45ms) ✅

Next: Testing migrations on staging"
```

#### DevOps Engineer

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**Infrastructure Deployment Update**

✅ Completed:
- Staging environment deployed
- CI/CD pipeline configured
- Monitoring and alerting active
- Smoke tests passing

**Environments**: Staging live at [URL]
**Health**: All health checks passing ✅
**Monitoring**: DataDog dashboard configured ✅

Next: Preparing production deployment plan"
```

### 5. Linking Related Tickets

When work relates to other tickets:

```bash
# Add comment mentioning related tickets
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**Related Work**

This implementation depends on:
- LINEAR-100: Database schema (✅ Complete)
- LINEAR-101: API contracts (✅ Complete)

This unblocks:
- LINEAR-150: Frontend integration (🔄 In Progress)
- LINEAR-151: Admin dashboard (⏳ Waiting)

See also:
- LINEAR-200: Similar feature for reference"
```

### 6. Searching for Related Tickets

Before starting work, search for related tickets:

```bash
# Search by keywords
mcp__linear__search_issues
  query: "user authentication"
  team: "engineering"

# Find tickets with specific labels
mcp__linear__search_issues
  query: "label:backend"
  state: "completed"
```

This helps:
- Avoid duplicate work
- Learn from similar implementations
- Identify dependencies
- Find reusable code

### 7. Creating New Tickets (When Needed)

If you discover new work during implementation:

```bash
mcp__linear__create_issue
  title: "Refactor user validation logic for reusability"
  description: "During LINEAR-123 implementation, discovered user validation logic is duplicated across 3 endpoints. Should extract to shared utility.

**Proposed Solution**: Create validateUser utility in src/utils/
**Impact**: Reduces code duplication by ~150 lines
**Priority**: Low (technical debt)
**Related**: LINEAR-123"
  priority: "low"
  labels: ["tech-debt", "refactoring"]
```

Then link it:
```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**New Ticket Created**

Created LINEAR-XXX for refactoring user validation logic discovered during this work. Not blocking current implementation but should be addressed."
```

### 8. Milestone Updates

For tickets with multiple phases, update after each major milestone:

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**Milestone: Phase 2 Complete** 🎯

**Progress**: 66% complete (2 of 3 phases done)

**Phase 1** ✅: API Setup
- Route handlers, middleware, validation

**Phase 2** ✅: Business Logic
- Service layer, repository, database integration

**Phase 3** 🔄: Testing & Polish (In Progress)
- Unit tests, integration tests, documentation

**Timeline**: On track for completion by [date]
**Blockers**: None
**Risks**: None identified"
```

### 9. Handling Pull Request Updates

When PR review feedback requires changes:

```bash
mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**PR Review Feedback Addressed**

**PR**: #45
**Reviewer**: @engineering-lead

**Changes Made**:
✅ Extracted magic numbers to constants
✅ Added JSDoc comments for public methods
✅ Improved error messages for validation
✅ Added missing edge case tests

**New Commits**: 3 additional commits
**Status**: Re-requested review"
```

### 10. Final Completion Update

When work is fully complete:

```bash
mcp__linear__update_issue
  issue_id: "LINEAR-123"
  status: "Done"

mcp__linear__add_comment
  issue_id: "LINEAR-123"
  comment: "**Work Complete** 🎉

**Delivered**:
- ✅ All acceptance criteria met
- ✅ Code reviewed and approved
- ✅ Security scan passed
- ✅ QA testing passed
- ✅ Deployed to production
- ✅ Documentation updated

**Final Stats**:
- **Branch**: feature/LINEAR-123-user-authentication
- **Commits**: 8 commits (squashed to 3)
- **PR**: #45 (merged)
- **Files Changed**: 12 files (+450, -80 lines)
- **Tests**: 28 tests (100% coverage for new code)
- **Deployed**: v1.2.0 on [date]

**Production Verification**:
- ✅ Health checks passing
- ✅ No errors in logs
- ✅ Performance metrics normal
- ✅ User testing successful

Thank you to reviewers and QA team!"
```

### 11. Best Practices

#### Do's ✅
- **Update ticket when you start work** (status: In Progress)
- **Provide regular progress updates** (after each phase)
- **Document all blockers immediately**
- **Include commit SHAs in updates** (for traceability)
- **Reference related tickets** (for context)
- **Mark complete only when deployed** (not just merged)
- **Use consistent formatting** (makes updates scannable)
- **Include metrics** (tests, coverage, performance)

#### Don'ts ❌
- **Don't leave tickets stale** (update at least daily if in progress)
- **Don't mark done prematurely** (wait for deployment verification)
- **Don't skip blocker documentation** (always explain what's blocking)
- **Don't forget to link related work** (helps team coordination)
- **Don't use vague updates** ("made progress" - be specific!)
- **Don't update ticket without context** (explain what changed)

### 12. Update Frequency Guidelines

| Work Stage | Update Frequency | What to Include |
|------------|------------------|-----------------|
| Starting work | Once | Plan, branch, estimated time |
| Active development | After each phase | Completed tasks, commits, progress % |
| Blocker encountered | Immediately | Issue, impact, attempted solutions |
| Technical decision | When made | Decision, rationale, alternatives |
| Phase complete | End of each phase | Summary, commits, next steps |
| Ready for review | Once | Complete summary, testing instructions |
| Review feedback | After addressing | Changes made, new commits |
| Deployment | Once | Deployment details, verification |
| Complete | Once | Final stats, verification, thanks |

### 13. Templates for Common Updates

#### Template: Starting Work
```
Starting work on LINEAR-XXX

## Plan
- Phase 1: [Description]
- Phase 2: [Description]
- Phase 3: [Description]

**Branch**: feature/LINEAR-XXX-description
**Estimated**: [X hours/days]
```

#### Template: Progress Update
```
**Phase [N] Complete** ✅

Completed:
- ✅ [Task 1]
- ✅ [Task 2]

**Commits**: [SHAs]
**Progress**: [X%]
Next: [Phase N+1 description]
```

#### Template: Blocker
```
⚠️ **Blocker**

**Issue**: [Description]
**Impact**: [What's blocked]
**Need**: [What's required]
```

#### Template: Ready for Review
```
**Implementation Complete** ✅

**Summary**: [Brief overview]
**Branch**: feature/LINEAR-XXX
**Tests**: [Count] tests, [X%] coverage

Ready for review and QA.
```

#### Template: Deployed
```
**Deployed** 🚀

**Version**: v[X.Y.Z]
**Environment**: [Staging/Production]
**Verified**: All checks passing ✅
```

---

## Quick Reference

### MCP Tools
- `mcp__linear__get_issue` - Fetch ticket
- `mcp__linear__update_issue` - Update status/description
- `mcp__linear__add_comment` - Add progress update
- `mcp__linear__search_issues` - Find related tickets

### Status Flow
`Todo → In Progress → In Review → Done`
(with optional `Blocked` state)

### Update Triggers
- Start work → Status: "In Progress"
- Complete phase → Add comment with progress
- Hit blocker → Status: "Blocked", add comment
- Ready for review → Status: "In Review"
- Deployed → Status: "Done"

---

**Remember**: Linear tickets are the source of truth for project status. Keep them updated to help your team stay coordinated and informed.
