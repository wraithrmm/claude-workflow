---
name: hello
description: Initialize a Claude Code conversation — verify project instructions are loaded, set up ai-playground, and ask what to work on.
user_invocable: true
---

# Begin Claude Code conversation workflows (always run this)

1. **Verify project instructions are loaded:**
   - Check if CLAUDE.md file content is in current context
   - If not present, read the project's CLAUDE.md file
   - Also load any project-specific instructions

2. **Run initialization script:**

   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/init-playground
   ```

Once you have done this, you should ask the user what they want to work on.
