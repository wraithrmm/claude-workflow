---
name: create-project
description: Create a new project with full PRP structure (plan, progress, status, notes) in ai-playground. Use for larger implementations with multiple tasks or complex planning.
disable-model-invocation: true
argument-hint: <project-name>
---

# Create a new project with a full PRP structure

## Usage
```
/create-project <project-name>
```

## Description
Creates a new project directory in the ai-playground with all required PRP files. Projects are for larger implementations that may contain multiple tasks or complex planning requirements.

### **MANDATORY**: Goals

Your goal is to generate a new PRP (or collection thereof) for a specific project.

Always identify and separate Infrastructure vs Application-Level concerns so that tasks can be assigned to DevOps and Dev respectively.

#### Project Workflow

1. Get the project name if not already provided (**MANDATORY**: You may not proceed without a project name).
2. Create the project with this command:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/create-project $ARGUMENTS
   ```
3. Before planning, note which available skills cover parts of the work; they carry the implementation patterns for those parts.
4. Start planning with the user:
   a. Present the plan to the user.
   b. **MANDATORY**: If the plan contains a "Questions for Clarification" section or any unresolved questions, you MUST explicitly ask these questions to the user NOW before proceeding.
   c. Ask them for feedback or approval.
5. **CRITICAL STOP POINT**: Do NOT proceed to create any tasks, supporting files, or additional documentation until:
  - The user has answered all questions
  - The plan has been explicitly approved
  - You have updated the plan with any clarifications
6. If the user approved the plan, stop planning and skip to step 7, otherwise return to step 4
7. Verify! Once you have the plan laid out, and every time you change it, you must return to step 4 to get user approval
8. Scan the plan and identify tasks within it that an available skill covers, e.g. a task that adds Playwright tests uses the `e2e-testing` skill, and name that skill in the task.
9. Edit plan.md to define requirements using the established PRP format
10. Update the status to "approved" when approved for implementation

**IMPORTANT:** You are not implementing. Your success criteria is that you have created a project PRP with all supporting tasks with a master plan in it that the user has approved.

## Parameters
- `$ARGUMENTS`: The name of the project (used as directory name)

## Example
```
/create-project ecommerce-checkout-redesign
```

This creates:
```
ai-playground/projects/ecommerce-checkout-redesign/
├── plan.md         # Project PRP with file map and objectives
├── progress.md     # Progress tracking log
├── status.json     # Project metadata
└── notes.md        # Design decisions and issues
```

## Files Created

### plan.md
The main PRP document containing project overview and goals, supporting PRP files, file map (new, modified, deleted files), implementation steps, success criteria, risk assessment, and dependencies.

### progress.md
A chronological log of progress with timestamped entries, completed items, in-progress items, and blockers or issues.

### status.json
Machine-readable project metadata:
```json
{
    "project": "project-name",
    "created": "timestamp",
    "status": "planning|active|blocked|complete",
    "completion_percent": 0-100,
    "last_updated": "timestamp",
    "summary": "brief description"
}
```

### notes.md
Additional documentation for design decisions and rationale, issues encountered and solutions, and references to tickets, docs, etc.

## Related Skills
- `/list-projects` - View all projects and statuses
- `/continue-project <project-name|number>` - Resume work on a project by name or number
- `/create-task` - Create a smaller, focused task
