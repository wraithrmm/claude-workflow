---
name: move-project-task
description: Move a task between status directories within a specific project.
user_invocable: true
argument-hint: <project-name> <task-name> <status>
---

# Move a project task to a different status

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/move-project-task $ARGUMENTS
```

## Parameters
- `<project-name>`: The project containing the task (required)
- `<task-name>`: The task to move (required)
- `<status>`: Target status — `planning`, `approved`, `in-progress`, or `completed` (required)

## Related Commands
- `/create-project-task` - Create a new task within a project
- `/list-project-tasks` - List all tasks within a project
- `/move-task` - Move global tasks (not project-specific)
