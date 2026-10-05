---
name: count-projects
description: Return the number of projects currently in the ai-playground. Utility used internally by other skills and for quick checks.
disable-model-invocation: true
---

# Count the number of projects in the ai-playground

Run the script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/count-projects
```

Returns a single number: the count of project directories directly under `ai-playground/projects/`. Files and nested directories are not counted, and it returns 0 if the projects directory doesn't exist. Primarily used internally by other scripts but useful for quick checks.

## Related Skills
- `/list-projects` - Show detailed information about all projects
- `/init-playground` - Initialize the ai-playground structure
