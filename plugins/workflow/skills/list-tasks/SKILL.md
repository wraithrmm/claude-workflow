---
name: list-tasks
description: Display all tasks (global and project-specific) grouped by their current workflow status.
disable-model-invocation: true
---

# Display all tasks grouped by their current status

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/list-tasks
```

Shows all tasks organized by status (planning, approved, in-progress, completed), including both global tasks and project-specific tasks.

## Task Status Meanings
- **planning**: Task is being defined, requirements gathering
- **approved**: Task is ready to begin implementation
- **in-progress**: Task is currently being worked on
- **completed**: Task has been finished

## Related Skills
- `/create-task` - Create a new task
- `/move-task` - Change a task's status
- `/create-project` - Create a larger project PRP
