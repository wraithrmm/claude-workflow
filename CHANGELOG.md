# Changelog

## Unreleased

- Added the `branch-beacon` plugin: a coloured chip above the prompt with the current git branch and repo name, and `/toggle-branch-beacon`

### Added
- `e2e-testing` skill: Playwright E2E conventions (AC traceability, page objects, retrying assertions, data reset)
- `confluence-documentation` skill: Confluence front-matter, supported Markdown, local testing, and CI auto-publish
- Agents `workflow:lint-runner`, `workflow:unit-test-runner`, and `workflow:playwright-visual-tester`

### Changed
- The repository is now the `wraithrmm` marketplace; the plugin is `workflow` under `plugins/workflow/`
- Skill frontmatter uses documented fields: the command skills set `disable-model-invocation: true` (they run only when typed), and `workflow-guide` sets `user-invocable: false`
- Multi-argument skills reference their arguments as `$0`, `$1`, `$2`
- `workflow-guide` carries the full planning and implementation process: plan.md, status.json, progress.md and notes.md examples, when to use global or project tasks, timeline estimates, and the side-effects checklist
- `add-acceptance-criteria` points to the `e2e-testing` skill and the lint and test agents
- Planning names the skill that covers a task instead of reading `.claude/prp-templates`

### Removed
- PRP templates: skills replace them, and the unused `templates/create-claude-command.md` is gone

## [1.0.0] - 2026-03-20

### Added
- Initial release as standalone Claude Code plugin
- 14 slash commands for project and task management
- Auto-loaded workflow guide skill
- PRP-based planning templates
- Configurable ai-playground directory (auto-detected from git root)
- Compatible with Claude Code CLI and Desktop
