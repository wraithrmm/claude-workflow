---
name: move-task
description: Move a global task between workflow status directories (planning, approved, in-progress, completed).
disable-model-invocation: true
argument-hint: <task-name> <status>
---

# Move a task to a different status in the workflow

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/move-task $ARGUMENTS
```

## Parameters
- `$0`: The name of the task to move
- `$1`: The target status: `planning`, `approved`, `in-progress`, or `completed`

## Workflow Best Practices
1. **planning -> approved**: Task requirements are clear and complete
2. **approved -> in-progress**: You're starting work on the task
3. **in-progress -> completed**: All acceptance criteria are met
4. Tasks can move backwards if revision is needed

## Related Skills
- `/create-task` - Create a new task
- `/list-tasks` - View all tasks by status
- `/create-project` - Create a larger project PRP
