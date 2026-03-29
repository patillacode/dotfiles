---
description: Check current branch MR, get code review comments, and create resolution plan
argument-hint: ''
---

# Resolve Code Review Workflow

This workflow fetches code review comments from the current branch's GitLab MR and creates an actionable plan to resolve them.

## Execution Mode: ANALYSIS THEN PLAN

First analyze all comments, then present a comprehensive resolution plan for user approval.

## Workflow Phases

### Phase 1: Get Current Branch and MR

1. Get current branch name:

   ```bash
   git rev-parse --abbrev-ref HEAD
   ```

2. Find the MR for the current branch:

   ```bash
   glab mr view <branch-name> -F json
   ```

3. Extract MR information:
   - MR number (iid)
   - MR title
   - MR web URL
   - MR state (opened, merged, closed)

4. If no MR found for current branch:
   - Error: "No merge request found for branch: <branch-name>"
   - Suggest: "Create an MR first using /submit-mr or manually"
   - Exit workflow

5. If MR is merged or closed:
   - Note: "MR #<number> is <state>. Comments may already be addressed."
   - Ask user if they want to continue anyway

### Phase 2: Fetch MR Comments and Discussions

1. Get MR number from the MR view in Phase 1 (extract `project_id` and `iid`)

2. **Note**: Project paths with slashes must be URL-encoded (e.g., `foo/bar` → `foo%2Fbar`)

3. Fetch discussions to temporary file (handles pagination properly):

   ```bash
   # URL-encode the project path
   glab api "projects/<url-encoded-project-path>/merge_requests/<iid>/discussions" --paginate > /tmp/mr_discussions.json
   ```

4. Parse discussions with robust resolution detection:

   ```bash
   python3 << 'EOF'
   import json

   # Read and handle paginated concatenated JSON arrays
   with open('/tmp/mr_discussions.json', 'r') as f:
       content = f.read()

   json_parts = content.replace('][', ']\n[').split('\n')
   discussions = []
   for part in json_parts:
       if part.strip():
           discussions.extend(json.loads(part))

   # Find unresolved discussions
   for disc in discussions:
       if disc.get('individual_note', False):
           continue

       notes = disc.get('notes', [])
       if not notes:
           continue

       first_note = notes[0]

       # Skip system and bot notes
       if (first_note.get('system') or
           first_note.get('author', {}).get('username', '').endswith('_bot')):
           continue

       # Check if resolvable
       if not first_note.get('resolvable', False):
           continue

       # Robust resolution check (handle false, null, and missing)
       discussion_resolved = disc.get('resolved')
       note_resolved = first_note.get('resolved')

       is_unresolved = (
           discussion_resolved == False or
           note_resolved == False or
           (discussion_resolved is None and note_resolved == False)
       )

       if is_unresolved:
           position = first_note.get('position', {})
           print(f"ID: {first_note.get('id')}")
           print(f"Author: {first_note.get('author', {}).get('name')} (@{first_note.get('author', {}).get('username')})")
           if position:
               print(f"File: {position.get('new_path') or position.get('old_path')}")
               print(f"Line: {position.get('new_line') or position.get('old_line')}")
           print(f"Body: {first_note.get('body')}")
           print(f"Comments in thread: {len(notes)}")
           print('=' * 80)
   EOF
   ```

5. Parse the output to extract:
   - **File-specific comments**: Comments on specific lines with file path and line number
   - **General comments**: Comments on the MR overall (no position)
   - Author, body, thread size for each
   - **Already filtered**: System notes, bot comments, and resolved threads excluded

6. If no comments found:
   - Note: "No code review comments found on MR #<number>"
   - Display: "MR appears to have no feedback or all discussions are resolved"
   - Exit gracefully

### Phase 3: Categorize and Analyze Comments

1. Group comments by type:
   - **Critical**: Security issues, bugs, breaking changes
   - **Code Quality**: Refactoring suggestions, performance improvements
   - **Style/Convention**: Naming, formatting, best practices
   - **Question/Clarification**: Reviewer asking for explanation
   - **Suggestion**: Optional improvements
   - **Documentation**: Missing docs, unclear comments

2. Group comments by file/module:
   - List all affected files
   - Show line-specific comments grouped by file
   - Show general comments separately

3. Identify patterns:
   - Repeated concerns across multiple files
   - Architectural or design pattern feedback
   - Testing gaps
   - Missing error handling

### Phase 4: Create Resolution Plan

1. Generate a prioritized action plan with:
   - **Summary**: Total comments, breakdown by category
   - **Priority order**: Critical → Code Quality → Style → Other
   - **Specific actions**: For each comment, create actionable task
   - **File grouping**: Tasks grouped by file for efficiency

2. For each actionable comment, create a task with:
   - **Category & Priority**: [Critical|High|Medium|Low]
   - **File & Line**: Where the change needs to happen
   - **Comment Context**: What the reviewer said (quoted)
   - **Proposed Resolution**: Specific code change or action
   - **Estimated Effort**: [Quick|Medium|Complex]

3. Action plan format:

   ```markdown
   ## Code Review Resolution Plan

   **MR**: #<number> - <title>
   **URL**: <gitlab-url>
   **Total Comments**: <count> (<resolved-count> resolved, <unresolved-count> unresolved)

   ### Summary by Category

   - Critical: <count>
   - Code Quality: <count>
   - Style: <count>
   - Questions: <count>
   - Suggestions: <count>

   ### Priority 1: Critical Issues

   #### 1. [File: path/to/file.py:123]

   **Reviewer**: @username
   **Comment**:

   > Original reviewer comment text

   **Resolution**:

   - Specific action to take
   - Code change description

   **Effort**: Quick/Medium/Complex

   ---

   #### 2. [File: path/to/other.py:456]

   ...

   ### Priority 2: Code Quality

   ...

   ### Priority 3: Style & Conventions

   ...

   ### Questions to Answer

   - List questions from reviewers that need responses

   ### Implementation Order

   1. Fix critical security issue in auth.py:123
   2. Address N+1 query in views.py:456
   3. Refactor duplicated code in utils.py
      ...
   ```

4. Present plan to user and ask for approval:
   - Display the full resolution plan
   - Ask: "Would you like me to implement these changes? (yes/no/selective)"
   - If "selective": Allow user to choose which items to implement
   - If "no": Exit and let user handle manually

### Phase 5: Implementation (If Approved)

1. **IMPORTANT**: Only proceed if user approves the plan

2. For each approved task in priority order:
   - Use TodoWrite to track implementation progress
   - Read the affected file
   - Make the necessary code changes using Edit tool
   - Add tests if needed
   - Mark todo as completed

3. After implementing all changes:
   - Run linting: `just lint`
   - If tests are mentioned in comments, run them: `just test <module>`
   - Show summary of changes made

4. Suggest next steps:
   - Commit changes: `/commit-work`
   - Push to trigger CI: `git push`
   - Reply to reviewers on GitLab (user does this manually)
   - Request re-review (user does this manually)

## Edge Cases

### No MR Found

- Branch may not be pushed yet
- Branch name might not match remote
- Suggest using `glab mr list --source-branch <branch-name>` manually

### MR Already Merged/Closed

- Ask user if they still want to analyze comments
- May be useful for learning or porting changes to another branch

### All Comments Resolved

- Note: "All discussions are resolved!"
- Ask if user wants to see resolved comments anyway
- Suggest user can request re-review or merge

### Comments Without Line Numbers

- General MR comments (not on specific code)
- Group separately as "General Feedback"
- May be architectural or approach-level feedback

### Multiple MRs for Same Branch

- Unlikely but possible
- Use the most recent open MR
- Show warning if multiple found

### glab Command Failures

- If `glab` is not installed: Suggest `brew install glab`
- If authentication fails: Suggest `glab auth login`
- If 404 error: Check repo path matches GitLab structure and is URL-encoded (slashes as `%2F`)

### Comments Are Questions Only

- If reviewer is only asking questions:
- Create plan to respond with explanations
- May not require code changes
- Suggest adding code comments for clarity

## Strict Rules

1. **Never Auto-Implement**: Always present plan and get approval first
2. **Preserve Context**: Include full reviewer comment in plan for context
3. **Prioritize Safety**: Critical issues (security, bugs) always come first
4. **Respect Resolved Threads**: Skip resolved discussions unless user requests them
5. **No Assumptions**: If comment is unclear, flag for user clarification
6. **Link Back**: Include file:line references for easy navigation
7. **Test Awareness**: Suggest running tests after changes, don't auto-run without approval

## Output Format

Keep output organized and scannable:

```
Analyzing MR for branch: feature/vpt-760-add-procedure-endpoint

✓ Found MR #11032: Add consultation procedure creation endpoint
  https://gitlab.com/nordhealth/projects/veterinary/provet-cloud/provetcloud/-/merge_requests/11032

✓ Fetched 8 comments (6 unresolved, 2 resolved)

Analyzing comments...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Code Review Resolution Plan

**MR**: #11032 - Add consultation procedure creation endpoint
**URL**: https://gitlab.com/nordhealth/projects/veterinary/provet-cloud/provetcloud/-/merge_requests/11032
**Total Comments**: 8 (6 unresolved, 2 resolved)

### Summary by Category
- Critical: 1
- Code Quality: 3
- Style: 2
- Questions: 2

[... detailed plan follows ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Would you like me to implement these changes? (yes/no/selective)
```

## Notes

- This command focuses on **code review comments** from GitLab MR discussions
- It does NOT analyze the code itself (use `/code-review` for that)
- It helps systematically address reviewer feedback
- Can be run multiple times as new comments are added
- Works best with descriptive, actionable reviewer comments
