# claude-workflow

A Claude Code plugin for project and task management using PRP (Project Requirement Plans) and filesystem-based tracking.

## What it does

Provides a structured workflow for planning, implementing, and tracking development projects and tasks within Claude Code. The plugin adds 14 slash commands and an auto-loaded workflow guide that teaches Claude how to manage projects using the PRP methodology.

### Features

- **Project management**: Create, list, continue, and verify projects with full PRP structure
- **Task management**: Create, list, and move tasks through planning/approved/in-progress/completed workflow
- **Auto-loaded workflow guide**: Claude automatically follows the PRP planning methodology
- **ai-playground**: Filesystem-based project tracking that persists across conversations
- **Works everywhere**: Compatible with both Claude Code CLI and Claude Code Desktop

## Installation

### Option 1: Load for current session

```bash
git clone https://github.com/wraithrmm/claude-workflow.git
claude --plugin-dir ./claude-workflow
```

### Option 2: Install at user scope (all projects)

```bash
git clone https://github.com/wraithrmm/claude-workflow.git
claude plugin install --plugin-dir ./claude-workflow --scope user
```

### Option 3: Install at project scope (shared with team)

```bash
git clone https://github.com/wraithrmm/claude-workflow.git
claude plugin install --plugin-dir ./claude-workflow --scope project
```

## Commands

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
