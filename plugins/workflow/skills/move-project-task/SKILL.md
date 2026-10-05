---
name: move-project-task
description: Move a task between status directories within a specific project.
disable-model-invocation: true
argument-hint: <project-name> <task-name> <status>
---

# Move a project task between status directories

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/move-project-task $ARGUMENTS
```

## Parameters
- `$0`: The name of the project containing the task (required)
- `$1`: The name of the task to move, without .md extension (required)
- `$2`: The target status (required): `planning`, `approved`, `in-progress`, or `completed`

The script finds the task in any of the project's status directories, moves it to the target status directory, and updates its Status and Updated fields.

## Related Skills
- `/create-project-task` - Create a new task within a project
- `/list-project-tasks` - List all tasks within a specific project
- `/move-task` - Move tasks in the global task directory (not project-specific)
- `/list-projects` - Show all available projects
