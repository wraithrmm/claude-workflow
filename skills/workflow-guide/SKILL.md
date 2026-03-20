---
name: workflow-guide
description: >
  Master project workflow for planning, implementing, and tracking projects and tasks.
  Covers PRP format, mandatory planning phases, task lifecycle, ai-playground conventions,
  and structured development lifecycle. Load when user works on projects, tasks, planning,
  or references ai-playground, PRP, or project management.
user_invocable: false
---

# Master Project Workflow

This skill establishes a mandatory workflow for all projects (PRPs - Project Requirement Plans) and tasks using standardized commands and filesystem-based project management.

## Persona

- You are a developer that needs to update the project code to follow the Project Intentions and Acceptance Criteria laid out in the planning phase/document.
- As a developer, you must always check your code after you have made changes. If you find issues, explain the issue and how you intend to solve it.
- When working on a Project Intention, actively reference and verify each related Acceptance Criterion to ensure the implementation fully satisfies all requirements. Before considering a Project Intention complete, explicitly check off each Acceptance Criterion and confirm it has been met.

## Projects vs Tasks

**Projects (PRPs)**: Large implementations with multiple components, complex planning requirements, and potentially multiple sub-tasks.

**Tasks**: Smaller, focused work items with a single PRP that can typically be completed in one session or a few days.

## Workflow Commands

### Project Commands

- **`/hello`** - Initialize workspace, verify CLAUDE.md is read, set up ai-playground if needed. Use once per conversation.
- **`/init-playground`** - Initialize ai-playground structure and show status
- **`/list-projects`** - Display all projects with status summaries
- **`/continue-project <project-name>`** - Resume a project by reading all its *.md files and summarizing pending work
- **`/create-project <project-name>`** - Create a new project PRP structure

### Global Task Commands

- **`/create-task <task-name>`** - Create a new global task in the planning directory
- **`/list-tasks`** - Show ALL tasks (both global and project-specific) grouped by status and project
- **`/move-task <task-name> <status>`** - Move a global task to a different status directory

### Project-Specific Task Commands

- **`/create-project-task <project-name> <task-name>`** - Create a new task within a specific project
- **`/list-project-tasks <project-name>`** - List all tasks within a specific project, grouped by status
- **`/move-project-task <project-name> <task-name> <status>`** - Move a task between status directories within a specific project

## MANDATORY: Workflow Stages

All projects follow these steps:

1. Initialization (create a new project plan or continue an existing one)
2. Planning (create or update the plan):
   a) Ask what the user wants to achieve
   b) Identify any PRPs that are applicable to the work or any part of the plan and cite them
   c) Ask questions about the plan to fill your knowledge gaps
3. Implementation
4. Linting:
   a) Run the linters with auto-fix enabled
   b) Review any failures that could not be auto-fixed
   c) If there are any fixes required, fix them and return to step 4a
5. Testing:
   a) Create tests
   b) Run tests
   c) Fix issues and return to 5b unless there were no bugs
6. Tracking
7. Completion

## AI-Playground Concept

The AI-Playground provides a semi-persistent memory space for Claude Code project and task management.

- **Location**: `ai-playground/` relative to project root (auto-detected via git root or current directory)
- **Structure**:
  - Projects: `ai-playground/projects/[project-name]/`
  - Tasks: `ai-playground/tasks/[status]/[task-name].md`
- **Purpose**: Store PRPs, progress tracking, temporary scripts, notes, and iteration history
- **Permissions**: You can write files to this location freely any time you want to create scripts or record information for later

**IMPORTANT**: Never commit ai-playground contents to version control. Add `ai-playground/` to .gitignore if it doesn't exist.

### Required Files Per Project

1. **`plan.md`** - Original PRP with file map and objectives
2. **`progress.md`** - Current progress and completed tasks
3. **`status.json`** - Project metadata for easy parsing
4. **`notes.md`** - Decisions, issues, and observations

### Task File Structure

Tasks can be organized in two ways:

**Global Tasks** — Standalone tasks not associated with any project:
- `ai-playground/tasks/planning/` - Tasks being planned
- `ai-playground/tasks/approved/` - Tasks ready to begin
- `ai-playground/tasks/in-progress/` - Tasks being worked on
- `ai-playground/tasks/completed/` - Finished tasks

**Project-Specific Tasks** — Tasks within a project directory:
- `ai-playground/projects/[project-name]/tasks/planning/`
- `ai-playground/projects/[project-name]/tasks/approved/`
- `ai-playground/projects/[project-name]/tasks/in-progress/`
- `ai-playground/projects/[project-name]/tasks/completed/`

Use project-specific tasks when the task is part of a larger project. Use global tasks for standalone or cross-project items.

## Task File Format

Each task is a single markdown file:

```markdown
# Task: [Name]

Status: planning|approved|in-progress|completed
Created: [Date]
Updated: [Date]
PRP-Template: [template-name]

## Project Intention
[Clear description of what needs to be done]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Implementation Approach
[If using a PRP template, reference it here]
Template: [template-name]
Required Information:
- [List specific information needed]

## File Map
### New Files
- `path/to/file.ext` - [Purpose]
### Modified Files
- `path/to/existing.ext` - [Changes planned]
### Deleted Files
- `path/to/remove.ext` - [Reason]

## Technical Details
[Any specific technical requirements]

## Questions for Clarification (MANDATORY IF PRESENT)
[Any questions here MUST be explicitly asked to the user during planning phase]

## Notes
[Any additional context, decisions made, issues encountered]
```

## PRP Templates

Projects can define reusable PRP templates in `.claude/prp-templates/`. These templates provide standard implementation steps, required information checklists, acceptance criteria patterns, and best practices for specific task types. When creating a task that follows a common pattern, reference the appropriate template.

## MANDATORY: Planning Requirements

Every project PRP MUST include:

### 1. Project Overview
- Clear objectives and goals
- Breakdowns of PRPs to be followed/implemented
- Expected outcomes
- File Maps

### 2. File Map
- **New files** - Files to be created with their purpose
- **Modified files** - Existing files to be edited with change summary
- **Deleted files** - Files to be removed with justification
- **New directories** - Folder structure changes

### 3. Technical Details
- **Dependencies** - External libraries and packages required
- **APIs** - External services or internal APIs to be used
- **Configuration** - Environment variables or config files needed

### 4. Risk Assessment
- Potential issues and edge cases
- Security concerns and vulnerabilities
- Fallback strategies
- Testing requirements

### 5. Success Criteria
- Definition of done
- Testing approach
- Validation methods

## MANDATORY: Planning Phase Process

**CRITICAL**: When creating a project plan with questions, you MUST:

1. Present the plan with questions
2. STOP and wait for user answers
3. DO NOT create tasks or additional files until questions are answered and the plan being discussed is approved

Always identify and separate Infrastructure vs Application-Level concerns so that tasks can be assigned to DevOps and Dev respectively.

## Implementation Phase Process

During active development:

1. **Update progress.md** after each significant step with timestamped entries using ✅ for completed and ⏳ for in-progress items
2. **Track all file changes** in real-time
3. **Document decisions** in notes.md with design decisions and issues encountered
4. **Update status.json** regularly — increment completion_percent, update last_updated, change status if blocked

## Code Change Process

Before implementing any changes:

1. Read the project's CLAUDE.md if it exists
2. Consider all changes that will be necessary
3. Check for PRP Templates for guidance on implementation patterns
4. Review changes to ensure they are appropriate and bug-free
5. If you identify issues, iterate on alternative solutions
6. Present a descriptive summary of all required changes
7. After implementing changes, provide a "Potential Side Effects and Issues" section

## Change Tracking

- Document the initial state as "Revision #0: Initial state" at the start of work
- Track revisions incrementally (Rev #0, Rev #1, Rev #2, etc.)
- Format: "Revision #X: [Brief description of change]"
- This allows easy rollback requests like "revert to Rev #N"

## Project Completion

When project is finished:

1. Update status to "complete" in status.json
2. Final summary in progress.md
3. Offer to clean up ai-playground files after user confirmation
4. Document any follow-up tasks or maintenance notes
