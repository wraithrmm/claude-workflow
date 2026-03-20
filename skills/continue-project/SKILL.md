---
name: continue-project
description: Resume an existing project by reading all its PRP files and summarizing pending work.
user_invocable: true
argument-hint: <project-name|number>
---

# Continue an existing project you have underway

1. **Run the continue project script:**
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/continue-project $ARGUMENTS
   ```

2. **After script runs, read the project files** (the script will output their paths).

3. **Generate comprehensive summary:**
   - Extract objectives from plan.md
   - List completed tasks from progress.md (lines with ✅)
   - List pending tasks from progress.md (lines with ⏳)
   - Identify blockers from notes.md or status
   - Format output as:
     ```
     📋 Resuming Project: [name]

     Original Objectives:
     - [objective 1]
     - [objective 2]

     Completed Tasks: ✅
     - [completed task 1]

     Pending Tasks: ⏳
     - [pending task 1]

     Current Blockers: 🚧
     - [blocker if any]

     Next Steps:
     1. [specific next action]
     2. [following action]
     ```

4. **Update project files as you work:**
   - Use Edit/Write tools to update progress.md with completed tasks
   - Update status.json with new completion percentage and timestamp
   - Add any important decisions or issues to notes.md
