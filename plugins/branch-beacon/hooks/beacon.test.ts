import { describe, expect, test } from 'claude-code/testing'

import { CHIP_COLOURS, changesBranch, chipLabel, colourFor, repoName } from './beacon'

describe('repoName', () => {
  test('reads the repo from https, ssh and scp-style remotes', () => {
    expect(repoName('https://github.com/wraithrmm/claude-code-docker.git\n', '/workspace/project')).toBe('claude-code-docker')
    expect(repoName('git@github.com:wraithrmm/claude-workflow.git', '/workspace/project')).toBe('claude-workflow')
    expect(repoName('ssh://git@gitlab.example.com/team/hitl-n8n-monorepo/', '/workspace/project')).toBe('hitl-n8n-monorepo')
  })

  test('falls back to the repo root folder when there is no remote', () => {
    expect(repoName(null, '/Users/me/code/voice-agent-api')).toBe('voice-agent-api')
    expect(repoName('', '/workspace/project')).toBe('project')
  })
})

describe('colourFor', () => {
  test('gives a branch the same colour every time', () => {
    expect(colourFor('feature/ai-562-mcp-adoption')).toBe(colourFor('feature/ai-562-mcp-adoption'))
    expect(CHIP_COLOURS).toContain(colourFor('main'))
  })

  test('spreads different branches across the palette', () => {
    const names = ['main', 'develop', 'feature/a', 'feature/b', 'feature/c', 'bug/d', 'release/e', 'spike/f']
    const used = new Set(names.map(colourFor))
    expect(used.size).toBeGreaterThan(3)
  })
})

describe('changesBranch', () => {
  test('spots commands that can move HEAD', () => {
    for (const command of ['git checkout develop', 'git switch -c feature/x', 'git -C /repo checkout main', 'cd /x && git worktree add ../y', 'git rebase main', 'git pull', 'gh pr checkout 730']) {
      expect(changesBranch(command)).toBe(true)
    }
  })

  test('ignores commands that leave HEAD alone', () => {
    for (const command of ['git status', 'git log --oneline', 'git diff main', 'ls checkout/', 'npm run switch']) {
      expect(changesBranch(command)).toBe(false)
    }
  })
})

describe('chipLabel', () => {
  test('labels each state', () => {
    expect(chipLabel({ kind: 'branch', branch: 'main', repo: 'r' })).toBe(' ⎇ main ')
    expect(chipLabel({ kind: 'detached', sha: 'a1b2c3d', repo: 'r' })).toBe(' ⎇ detached @ a1b2c3d ')
    expect(chipLabel({ kind: 'none' })).toBe(' ⎇ not a git repo ')
  })
})
