# PRP Template: Create New Claude Workflow Command

## Purpose
Create a new command for the claude-workflow plugin, including the script, skill documentation, and tests.

## Required Information Before Starting
- [ ] Command name (e.g., `list-tasks`, `create-project`)
- [ ] Command purpose and description
- [ ] Command parameters/arguments
- [ ] Expected output format
- [ ] Dependencies on other scripts or tools
- [ ] Error conditions to handle

## Implementation Steps

### 1. Create the Script
Create script in `scripts/[command-name]` (no .sh extension)

**Script Structure**:
```bash
#!/bin/bash
# [Brief description of what the script does]

# Define base directories (configurable)
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
PLAYGROUND_DIR="${PLAYGROUND_DIR:-$PROJECT_ROOT/ai-playground}"
PROJECTS_DIR="$PLAYGROUND_DIR/projects"
TASKS_DIR="$PLAYGROUND_DIR/tasks"

# Check for required arguments
if [ -z "$1" ]; then
    echo "Error: [Parameter] required"
    echo "Usage: [command-name] <parameter>"
    exit 1
fi

# Main logic here

# Exit codes:
# 0 - Success
# 1 - Error (missing args, invalid input, etc.)
```

**Script Guidelines**:
- Use consistent error messaging format
- Include usage instructions on error
- Use proper exit codes
- Paths must be configurable via env vars (never hardcode)
- Check for directory/file existence before operations
- Provide helpful output messages
- Use `$(dirname "$0")` to reference sibling scripts

### 2. Make Script Executable
```bash
chmod +x scripts/[command-name]
```

### 3. Create Skill Documentation
Create `skills/[command-name]/SKILL.md`

**Skill Template**:
```markdown
---
name: [command-name]
description: [Brief description of when to use this command]
user_invocable: true
argument-hint: <required-param>
---

# [Command Title]

Run the script:
\`\`\`bash
${CLAUDE_PLUGIN_ROOT}/scripts/[command-name] $ARGUMENTS
\`\`\`

## Parameters
- `<required-param>`: [Description]

## Related Commands
- `/[related-command]` - [How it relates]
```

### 4. Create Tests
Create `tests/[command-name].bats`

**Test Template**:
```bash
#!/usr/bin/env bats

# Tests for [command-name] script

setup() {
    TEST_DIR=$(mktemp -d)
    export PLAYGROUND_DIR="$TEST_DIR/ai-playground"
    export PROJECT_ROOT="$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "[command-name]: requires [parameter]" {
    run ./scripts/[command-name]

    [ "$status" -eq 1 ]
    [[ "$output" == *"Error:"* ]]
}

@test "[command-name]: [test description]" {
    mkdir -p "$PLAYGROUND_DIR"

    run ./scripts/[command-name] "test-value"

    [ "$status" -eq 0 ]
    [[ "$output" == *"[expected output]"* ]]
}
```

### 5. Update Plugin README
Add the command to the commands table in `README.md`.

## Acceptance Criteria
- [ ] Script created and executable
- [ ] Skill SKILL.md complete with frontmatter
- [ ] Tests written and passing
- [ ] README.md updated with new command
- [ ] Script handles all error conditions gracefully
- [ ] Output format is consistent with other commands
- [ ] All paths use env vars (no hardcoded paths)

## Common Patterns

### Error Message Format
```bash
echo "Error: [Specific error description]"
echo "Usage: [command-name] <parameter>"
exit 1
```

### Success Message Format
```bash
echo "✅ [Action completed successfully]"
echo ""
echo "Next steps:"
echo "1. [First next step]"
```

### Cross-Script References
```bash
SCRIPT_DIR="$(dirname "$0")"
"$SCRIPT_DIR/other-script" "$arg"
```

## Testing Checklist
- [ ] Test with no arguments
- [ ] Test with valid arguments
- [ ] Test with invalid arguments
- [ ] Test when directories don't exist
- [ ] Test when directories are empty
- [ ] Test with special characters in names
- [ ] Test output formatting
- [ ] Test with custom PLAYGROUND_DIR
- [ ] Test in non-git directory (pwd fallback)

## Notes
- Keep scripts simple and focused on one task
- Use existing scripts as reference for patterns
- All paths MUST be configurable via env vars for testing
- Follow bash best practices (set -e for error handling, quote variables)
