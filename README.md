# wraithrmm Claude Code plugins

A Claude Code plugin marketplace named `wraithrmm`. It holds:

| Plugin | What it does |
|--------|--------------|
| `workflow` | Project and task management using PRP (Project Requirement Plans) and filesystem-based tracking in `ai-playground/` |
| `branch-beacon` | Shows the checked-out git branch and repo name as a coloured chip above the prompt, so you can tell terminals apart at a glance |

## Installation

Add the marketplace once, then install the plugins you want:

```bash
claude plugin marketplace add wraithrmm/claude-workflow
claude plugin install workflow@wraithrmm
claude plugin install branch-beacon@wraithrmm
```

The plugins don't pin a version, so `claude plugin update workflow@wraithrmm` (or auto-update, turned on under **Marketplaces** in `/plugin`) brings in the latest commit.

Skills answer to their plain names (`/create-project`), unless you already have a local skill with the same name. In that case use the full name (`/workflow:create-project`). Agents always use the full name, e.g. `workflow:lint-runner`.

To try a plugin without installing it, load its folder for one session:

```bash
git clone https://github.com/wraithrmm/claude-workflow.git
claude --plugin-dir ./claude-workflow/plugins/workflow
```

## branch-beacon plugin

Draws one row directly above the prompt: the branch as a solid chip, and the repo name beside it. Each branch keeps the same colour in every session, worked out from its name, so you can find a terminal by colour before reading it.

- **Detached HEAD** shows the short commit (`⎇ detached @ a1b2c3d`); outside a repository the chip is grey (`⎇ not a git repo`)
- **Repo name** comes from the `origin` remote, falling back to the repository folder name, so it stays right in containers that mount every repo at the same path
- **Stays current** after every turn, when you send a prompt, and straight after a Bash `git checkout`, `switch`, `worktree`, `rebase`, `pull`, `merge`, `reset`, `stash`, `branch` or `gh pr checkout`
- **Gives way** while Claude asks you a question, then comes back
- **`/toggle-branch-beacon`** hides or shows it for the session

Set `BRANCH_BEACON_REPO` to a repository folder when Claude runs from somewhere else (for example a container that starts in `/workspace` with the repo mounted at `/workspace/project`); otherwise it reads the session's folder.

It reads git with `-c safe.directory=*`, so it also works where git refuses a repository owned by another user (a mounted checkout in a container). It never changes your git config.

## workflow plugin

Provides a structured workflow for planning, implementing, and tracking development projects and tasks within Claude Code, plus a workflow guide skill that teaches Claude the PRP methodology.

- **Project management**: create, list, continue, and verify projects with full PRP structure
- **Task management**: create, list, and move tasks through planning/approved/in-progress/completed
- **ai-playground**: filesystem-based project tracking that persists across conversations

### Commands

| Command | Description |
|---------|-------------|
| `/hello` | Initialize workspace and ai-playground |
| `/init-playground` | Set up ai-playground directory structure |
| `/create-project <name>` | Create a new project with full PRP structure |
| `/continue-project <name\|number>` | Resume an existing project |
| `/list-projects` | List all projects with status summaries |
| `/count-projects` | Count projects in ai-playground |
| `/verify-project <name>` | Check project has all required files |
| `/create-task <name>` | Create a standalone task |
| `/list-tasks` | List all tasks grouped by status |
| `/move-task <name> <status>` | Move a task between statuses |
| `/create-project-task <project> <task>` | Create a task within a project |
| `/list-project-tasks <project>` | List tasks within a project |
| `/move-project-task <project> <task> <status>` | Move a project task |
| `/add-acceptance-criteria <feature> <use-case>` | Add AC, implement, and test |
| `/e2e-testing` | Playwright E2E test conventions (also loads on its own when Claude writes E2E tests) |
| `/confluence-documentation` | Write and publish Markdown docs to Confluence (also loads on its own for Confluence docs) |

The commands from `/hello` to `/move-project-task` run only when you type them. `workflow-guide` has no command: Claude loads it on its own when you work on projects or tasks.

### Agents

| Agent | What it does |
|-------|--------------|
| `workflow:lint-runner` | Runs the project's linters with auto-fix on changed files and reports ALL PASSED, ALL PASSED WITH SOME FIXES, or FAILED |
| `workflow:unit-test-runner` | Runs the project's unit tests and returns pass/coverage or a diagnostic report, without editing code |
| `workflow:playwright-visual-tester` | Drives a browser with Playwright and returns only the final screenshot or result |

Each agent reads the project's CLAUDE.md to find the right lint, test, or Playwright commands.

### Task Statuses

`planning` → `approved` → `in-progress` → `completed`

## Configuration

### Playground location

By default, the ai-playground directory is created at `<git-root>/ai-playground`. Override with:

```bash
export PLAYGROUND_DIR=/custom/path/to/ai-playground
```

Or override the project root detection:

```bash
export PROJECT_ROOT=/path/to/project
```

### .gitignore

Add `ai-playground/` to your `.gitignore` — these files should not be committed.

## ai-playground Structure

```
ai-playground/
├── projects/
│   └── my-project/
│       ├── plan.md          # Project PRP
│       ├── progress.md      # Progress log
│       ├── status.json      # Machine-readable status
│       ├── notes.md         # Decisions and issues
│       └── tasks/
│           ├── planning/
│           ├── approved/
│           ├── in-progress/
│           └── completed/
└── tasks/
    ├── planning/
    ├── approved/
    ├── in-progress/
    └── completed/
```

## License

PolyForm Shield License 1.0.0 — see [LICENSE](LICENSE).
