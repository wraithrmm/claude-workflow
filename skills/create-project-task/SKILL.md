---
name: create-project-task
description: Create a new task within a specific project's task directory.
user_invocable: true
argument-hint: <project-name> <task-name>
---

# Create a new task within a project

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/create-project-task $ARGUMENTS
```

## Parameters
- `<project-name>`: The name of the existing project (required)
- `<task-name>`: The name of the new task (required)

Creates a task file in the project's `tasks/planning/` directory. The task follows the standard PRP template format.

## Notes
- The project must already exist (use `/create-project` first)
- Task names should use hyphens for spaces (e.g., `implement-feature`)
- Consider referencing PRP templates when filling out task details

## Related Commands
- `/create-project` - Create a new project before adding tasks
- `/move-project-task` - Move task between workflow states
- `/list-project-tasks` - List all tasks within a project
