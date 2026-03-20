---
name: list-projects
description: List all projects in the ai-playground with status summaries.
user_invocable: true
---

# List all projects you have underway

1. **Run the list projects script:**
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/list-projects
   ```

2. **Review the output:**
   - Projects are numbered for easy reference
   - Status information shows progress and current state
   - Summary provides quick context

3. **Next steps:**
   - Use `/continue-project <name>` or `/continue-project <number>` to resume a project
   - Use `/create-project <name>` to start a new project
