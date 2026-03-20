---
name: list-project-tasks
description: List all tasks within a specific project, grouped by status.
user_invocable: true
argument-hint: <project-name>
---

# List tasks within a project

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/list-project-tasks $ARGUMENTS
```

## Parameters
- `<project-name>`: The name of the project whose tasks to list (required)

Displays all tasks organized by status (planning, approved, in-progress, completed) with creation dates and template references.

## Related Commands
- `/create-project-task` - Create a new task within a project
- `/move-project-task` - Move a project task between statuses
- `/list-projects` - List all projects
