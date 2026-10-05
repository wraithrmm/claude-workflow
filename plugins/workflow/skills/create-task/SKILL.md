---
name: create-task
description: Create a new standalone task PRP in the global ai-playground planning directory. Use for smaller, focused work that is not part of a larger project.
disable-model-invocation: true
argument-hint: <task-name>
---

# Create a new task in the planning directory

## Usage
```
/create-task <task-name>
```

## Description
Creates a new task file in the ai-playground's `tasks/planning/` directory with a standard PRP structure. The task starts in "planning" status and can be moved through the workflow using `/move-task`.

### **MANDATORY**: Goals

Your goal is to generate a new PRP for a specific task and create a document that can be used as a task to be completed.

1. Get the task name if not already provided (**MANDATORY**: You may not proceed without a task name).
2. Create the task with this command:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/create-task $ARGUMENTS
   ```
3. Check which available skills cover the kind of work the task needs; they carry the implementation patterns.
4. If one fits, name that skill in the task's Implementation Approach.
5. Complete the planning phase and populate the task PRP document.

**IMPORTANT:** You are not implementing. Your success criteria is that you have created a task with a plan in it that the user has approved.

## Parameters
- `$ARGUMENTS`: The name of the task (will be used as the filename without .md extension)

## Task Workflow
1. **planning** - Task is being defined
2. **approved** - Task is ready to begin
3. **in-progress** - Task is being worked on
4. **completed** - Task is finished

## Next Steps
After creating a task:
1. Edit the task file to add specific requirements
2. Name the skill that covers the work, if one applies
3. Always identify and separate Infrastructure vs Application-Level concerns
4. Use `/move-task <task-name> approved` when ready to begin

## Related Skills
- `/list-tasks` - View all tasks by status
- `/move-task` - Move a task to a different status
- `/create-project` - Create a larger project PRP
