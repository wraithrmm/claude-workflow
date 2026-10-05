---
name: create-project-task
description: Create a new task within a specific project's directory structure, as part of a larger project plan.
disable-model-invocation: true
argument-hint: <project-name> <task-name>
---

# Create a task within a specific project

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/create-project-task $ARGUMENTS
```

## Parameters
- `$0`: The name of the existing project where the task should be created (required)
- `$1`: The name of the new task to create (required)

Creates a task file in the project's `tasks/planning/` directory, rather than the global task directory. The task follows the standard task file format with sections for Project Intention, Acceptance Criteria, Implementation Approach, Technical Details, and Notes.

## Notes
- The project must already exist (use `/create-project` first)
- The task starts in `planning` status and must be approved before implementation
- Task names should use hyphens for spaces (e.g., `implement-feature`)
- If an available skill covers the kind of work in the task, name that skill in the task's Implementation Approach

## Related Skills
- `/create-project` - Create a new project before adding tasks
- `/move-project-task` - Move task between workflow states (planning -> approved -> in-progress -> completed)
- `/list-project-tasks` - List all tasks within a project
- `/list-projects` - View all projects and their status
- `/create-task` - Create a task in the global tasks directory (not project-specific)
