---
name: verify-project
description: Verify that a project has all required PRP files (plan.md, progress.md, status.json, notes.md).
user_invocable: true
argument-hint: <project-name>
---

# Verify project structure

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/verify-project $ARGUMENTS
```

Checks that the project directory contains all required files:
- plan.md
- progress.md
- status.json
- notes.md

Reports which files exist and which are missing.

## Related Commands
- `/create-project` - Create a new project with all required files
- `/continue-project` - Resume work on a project
