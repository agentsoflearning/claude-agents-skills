#!/bin/bash
#
# Squash vs Rebase Decision Helper
#
# Analyzes your branch commits and recommends whether to squash or rebase
# based on commit quality, history, and best practices.
#
# Usage:
#   ./squash-rebase-helper.sh                    # Analyze current branch
#   ./squash-rebase-helper.sh --branch <name>    # Analyze specific branch
#   ./squash-rebase-helper.sh --help             # Show help
#
# Exit codes:
#   0 - Success
#   1 - Error

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Scoring thresholds
SQUASH_THRESHOLD=5  # If score >= 5, recommend squash
REBASE_THRESHOLD=-5 # If score <= -5, recommend rebase

print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  $1${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

show_usage() {
    cat << EOF
Squash vs Rebase Decision Helper

Usage:
  $0                          Analyze current branch
  $0 --branch <name>          Analyze specific branch
  $0 --help                   Show this help

What this does:
  - Analyzes commit history and quality
  - Scores commits based on best practices
  - Recommends squash or rebase strategy
  - Provides detailed reasoning

Decision Factors:
  ✓ Number of commits
  ✓ Commit message quality (conventional format)
  ✓ WIP/fixup commits
  ✓ Commit granularity
  ✓ Feature cohesion
  ✓ Code review status

Examples:
  $0                          # Analyze current branch
  $0 --branch feature/login   # Analyze specific branch

EOF
}

check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository"
        exit 1
    fi
}

get_base_branch() {
    # Try to detect base branch (main, master, develop)
    local base=""

    if git show-ref --verify --quiet refs/heads/main; then
        base="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        base="master"
    elif git show-ref --verify --quiet refs/heads/develop; then
        base="develop"
    else
        # Fallback: use the most common ancestor
        base=$(git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null | cut -d'/' -f2 || echo "main")
    fi

    echo "$base"
}

analyze_commits() {
    local branch="${1:-HEAD}"
    local base_branch=$(get_base_branch)

    echo ""
    print_header "Squash vs Rebase Decision Helper"
    echo ""

    # Get commit count
    local commit_count=$(git rev-list --count "$base_branch..$branch" 2>/dev/null || echo "0")

    if [ "$commit_count" -eq 0 ]; then
        print_warning "No commits found on branch"
        echo ""
        echo "This branch has no commits ahead of $base_branch"
        exit 0
    fi

    echo -e "${BLUE}Branch:${NC} $branch"
    echo -e "${BLUE}Base:${NC} $base_branch"
    echo -e "${BLUE}Commits:${NC} $commit_count"
    echo ""

    # Initialize scoring
    local score=0
    local reasons=()

    # Factor 1: Number of commits
    echo -e "${CYAN}═══ Factor 1: Commit Count ===${NC}"
    if [ "$commit_count" -gt 10 ]; then
        ((score+=3))
        reasons+=("${YELLOW}+3${NC} Many commits ($commit_count) - suggests work-in-progress history")
        echo -e "  ${YELLOW}+3${NC} Many commits ($commit_count)"
    elif [ "$commit_count" -gt 5 ]; then
        ((score+=1))
        reasons+=("${YELLOW}+1${NC} Moderate commits ($commit_count)")
        echo -e "  ${YELLOW}+1${NC} Moderate commits ($commit_count)"
    elif [ "$commit_count" -le 3 ]; then
        ((score-=2))
        reasons+=("${GREEN}-2${NC} Few, focused commits ($commit_count)")
        echo -e "  ${GREEN}-2${NC} Few, focused commits ($commit_count)"
    else
        echo -e "  ${BLUE}=0${NC} Neutral commit count ($commit_count)"
    fi
    echo ""

    # Factor 2: WIP and fixup commits
    echo -e "${CYAN}═══ Factor 2: Commit Quality ===${NC}"
    local wip_count=$(git log --oneline "$base_branch..$branch" | grep -ciE "wip|fixup|fix typo|oops|temp" || echo "0")
    if [ "$wip_count" -gt 0 ]; then
        local wip_score=$((wip_count * 2))
        ((score+=wip_score))
        reasons+=("${YELLOW}+${wip_score}${NC} Found $wip_count WIP/fixup commits - should be squashed")
        echo -e "  ${YELLOW}+${wip_score}${NC} Found $wip_count WIP/fixup commits"
        echo ""
        echo "  WIP commits:"
        git log --oneline "$base_branch..$branch" | grep -iE "wip|fixup|fix typo|oops|temp" | sed 's/^/    /' || true
    else
        ((score-=1))
        reasons+=("${GREEN}-1${NC} No WIP/fixup commits - clean history")
        echo -e "  ${GREEN}-1${NC} No WIP/fixup commits"
    fi
    echo ""

    # Factor 3: Conventional commit format
    echo -e "${CYAN}═══ Factor 3: Conventional Commits ===${NC}"
    local total_commits=$commit_count
    local conventional_count=$(git log --oneline "$base_branch..$branch" | grep -cE "^[a-f0-9]+ (feat|fix|docs|style|refactor|perf|test|build|ci|chore)(\(.+\))?:" || echo "0")
    local conventional_percent=$((conventional_count * 100 / total_commits))

    if [ "$conventional_percent" -ge 80 ]; then
        ((score-=2))
        reasons+=("${GREEN}-2${NC} $conventional_percent% conventional commits - well structured")
        echo -e "  ${GREEN}-2${NC} $conventional_percent% following conventional format"
    elif [ "$conventional_percent" -ge 50 ]; then
        ((score-=1))
        reasons+=("${GREEN}-1${NC} $conventional_percent% conventional commits")
        echo -e "  ${GREEN}-1${NC} $conventional_percent% following conventional format"
    else
        ((score+=2))
        reasons+=("${YELLOW}+2${NC} Only $conventional_percent% conventional - inconsistent formatting")
        echo -e "  ${YELLOW}+2${NC} Only $conventional_percent% following conventional format"
    fi
    echo ""

    # Factor 4: Merge commits present
    echo -e "${CYAN}═══ Factor 4: Merge Commits ===${NC}"
    local merge_count=$(git log --oneline --merges "$base_branch..$branch" | wc -l)
    if [ "$merge_count" -gt 0 ]; then
        ((score+=2))
        reasons+=("${YELLOW}+2${NC} Contains $merge_count merge commits - history is complex")
        echo -e "  ${YELLOW}+2${NC} Contains $merge_count merge commits"
    else
        echo -e "  ${GREEN}=0${NC} No merge commits (clean history)"
    fi
    echo ""

    # Factor 5: File change patterns
    echo -e "${CYAN}═══ Factor 5: File Changes ===${NC}"
    local files_changed=$(git diff --name-only "$base_branch...$branch" | wc -l)
    local commits_per_file=$((commit_count * 10 / files_changed))

    if [ "$commits_per_file" -gt 20 ]; then
        ((score+=2))
        reasons+=("${YELLOW}+2${NC} Multiple commits per file - suggests iterative work")
        echo -e "  ${YELLOW}+2${NC} High commits-to-files ratio ($commits_per_file:10)"
    elif [ "$commits_per_file" -lt 5 ]; then
        ((score-=1))
        reasons+=("${GREEN}-1${NC} Clean commits-to-files ratio")
        echo -e "  ${GREEN}-1${NC} Low commits-to-files ratio ($commits_per_file:10)"
    else
        echo -e "  ${BLUE}=0${NC} Normal commits-to-files ratio"
    fi
    echo ""

    # Display all commits
    echo -e "${CYAN}═══ Commit History ===${NC}"
    echo ""
    git log --oneline --graph --decorate "$base_branch..$branch" | sed 's/^/  /'
    echo ""

    # Final recommendation
    print_header "Decision & Recommendation"
    echo ""
    echo -e "${BLUE}Total Score:${NC} $score"
    echo ""

    # Print reasoning
    echo -e "${CYAN}Scoring Breakdown:${NC}"
    for reason in "${reasons[@]}"; do
        echo -e "  • $reason"
    done
    echo ""

    # Make recommendation
    if [ "$score" -ge "$SQUASH_THRESHOLD" ]; then
        print_recommendation_squash "$branch" "$base_branch" "$commit_count"
    elif [ "$score" -le "$REBASE_THRESHOLD" ]; then
        print_recommendation_rebase "$branch" "$base_branch" "$commit_count"
    else
        print_recommendation_either "$branch" "$base_branch" "$commit_count"
    fi
}

print_recommendation_squash() {
    local branch="$1"
    local base="$2"
    local count="$3"

    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  RECOMMENDATION: SQUASH                                       ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Your commit history shows work-in-progress commits that should"
    echo "be consolidated into a single, clean commit for the PR."
    echo ""
    echo -e "${CYAN}Why Squash?${NC}"
    echo "  • Removes WIP/fixup commits from history"
    echo "  • Creates a clean, atomic commit for this feature"
    echo "  • Makes git history easier to understand"
    echo "  • Better for code review (single logical change)"
    echo ""
    echo -e "${CYAN}How to Squash:${NC}"
    echo ""
    echo "  ${GREEN}# Interactive rebase to squash$NC"
    echo "  git rebase -i $base"
    echo ""
    echo "  ${GREEN}# In the editor, change 'pick' to 'squash' (or 's') for all${NC}"
    echo "  ${GREEN}# commits except the first one${NC}"
    echo ""
    echo "  ${GREEN}# Write a new, comprehensive commit message${NC}"
    echo "  ${GREEN}# Following conventional commit format${NC}"
    echo ""
    echo -e "${CYAN}Alternative (simpler):${NC}"
    echo ""
    echo "  ${GREEN}# Soft reset to base, then commit everything${NC}"
    echo "  git reset --soft $base"
    echo "  git commit -m \"feat(scope): comprehensive description\""
    echo ""
}

print_recommendation_rebase() {
    local branch="$1"
    local base="$2"
    local count="$3"

    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  RECOMMENDATION: REBASE (Keep History)                        ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Your commit history is clean and well-structured. Each commit"
    echo "represents a logical step in development."
    echo ""
    echo -e "${CYAN}Why Rebase?${NC}"
    echo "  • Commits follow conventional format"
    echo "  • Each commit is atomic and logical"
    echo "  • History tells a clear story"
    echo "  • Valuable for future debugging (git bisect)"
    echo ""
    echo -e "${CYAN}How to Rebase:${NC}"
    echo ""
    echo "  ${GREEN}# Update your branch with latest base${NC}"
    echo "  git fetch origin"
    echo "  git rebase origin/$base"
    echo ""
    echo "  ${GREEN}# If conflicts occur, resolve and continue${NC}"
    echo "  git add <resolved-files>"
    echo "  git rebase --continue"
    echo ""
    echo -e "${CYAN}When to Merge:${NC}"
    echo ""
    echo "  ${GREEN}# For feature branches with valuable history${NC}"
    echo "  git checkout $base"
    echo "  git merge --no-ff $branch"
    echo ""
}

print_recommendation_either() {
    local branch="$1"
    local base="$2"
    local count="$3"

    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  RECOMMENDATION: Either Approach Works                        ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Your branch is in good shape. Both squash and rebase are"
    echo "valid options - choose based on your team's preferences."
    echo ""
    echo -e "${CYAN}Consider:${NC}"
    echo ""
    echo -e "${YELLOW}Squash if:${NC}"
    echo "  • You want a single commit in main branch"
    echo "  • Your team prefers clean, linear history"
    echo "  • Individual commits aren't important for future reference"
    echo ""
    echo -e "${GREEN}Rebase if:${NC}"
    echo "  • You want to preserve development steps"
    echo "  • Commits tell a valuable story"
    echo "  • Team uses git bisect for debugging"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo ""
    echo "  ${YELLOW}# Squash all commits${NC}"
    echo "  git reset --soft $base"
    echo "  git commit -m \"feat: complete feature description\""
    echo ""
    echo "  ${GREEN}# Keep history with rebase${NC}"
    echo "  git rebase origin/$base"
    echo ""
}

# Main
main() {
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --branch)
            if [ $# -lt 2 ]; then
                print_error "Missing branch name"
                show_usage
                exit 1
            fi
            check_git_repo
            analyze_commits "$2"
            ;;
        "")
            check_git_repo
            analyze_commits
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
