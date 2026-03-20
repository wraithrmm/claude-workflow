---
name: move-task
description: Move a global task to a different status (planning, approved, in-progress, completed).
user_invocable: true
argument-hint: <task-name> <status>
---

# Move a task to a different status

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/move-task $ARGUMENTS
```

## Parameters
- `<task-name>`: The name of the task to move
- `<status>`: Target status — `planning`, `approved`, `in-progress`, or `completed`

## Workflow Best Practices
1. **planning → approved**: Task requirements are clear and complete
2. **approved → in-progress**: You're starting work on the task
3. **in-progress → completed**: All acceptance criteria are met
4. Tasks can move backwards if revision is needed

## Related Commands
- `/create-task` - Create a new task
- `/list-tasks` - View all tasks by status
