---
name: verify-project
description: Verify that a project has all required PRP files (plan.md, progress.md, status.json, notes.md).
disable-model-invocation: true
argument-hint: <project-name>
---

# Verify that a project has all required files

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/verify-project $ARGUMENTS
```

## Parameters
- `$ARGUMENTS`: The name of the project to verify

Checks that the project directory contains all required files:
- plan.md
- progress.md
- status.json
- notes.md

Reports which files exist and which are missing. Primarily used internally by other skills like `/continue-project`.

## Exit Codes
- 0: Success (even if files are missing - this is just a verification tool)
- 1: Project directory not found

## Related Skills
- `/create-project` - Create a new project with all required files
- `/continue-project` - Resume work on a project (runs verify internally)
