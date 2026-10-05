---
name: list-project-tasks
description: List all tasks within a specific project, grouped by workflow status.
disable-model-invocation: true
argument-hint: <project-name>
---

# List tasks within a specific project

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/list-project-tasks $ARGUMENTS
```

## Parameters
- `$ARGUMENTS`: The name of the project whose tasks to list (required)

Displays all tasks organized by status (planning, approved, in-progress, completed) with creation dates and template references.

## Related Skills
- `/list-projects` - List all projects
- `/create-project-task` - Create a new task within a project
- `/move-project-task` - Move a project task between statuses
- `/list-tasks` - List all global tasks (not project-specific)
- `/continue-project` - Resume work on a project and see its tasks
