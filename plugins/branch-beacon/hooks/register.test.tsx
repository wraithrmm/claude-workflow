import { describe, expect, mock, test } from 'claude-code/testing'
import type { On, ProcessRunResult } from 'claude-code'

type Repo = { head: 'branch' | 'detached' | 'none'; branch: string; sha: string; remote: string | null; root: string }

const ok = (stdout: string): ProcessRunResult => ({ exitCode: 0, stdout, stderr: '', isStdoutTruncated: false, isStderrTruncated: false })
const fail = (exitCode: number): ProcessRunResult => ({ exitCode, stdout: '', stderr: 'fatal', isStdoutTruncated: false, isStderrTruncated: false })

const fakeGit = (on: On, repo: Repo) => {
  const calls: string[][] = []
  const cwds: (string | undefined)[] = []
  on('process.run', (_$, e) => {
    cwds.push(e.init?.cwd)

    return { value: answer(e.argv) }
  })
  const answer = (argv: readonly string[]): ProcessRunResult => {
    calls.push([...argv])
    const args = argv.slice(3).join(' ')
    if (repo.head === 'none') return fail(128)
    if (args === 'symbolic-ref --short -q HEAD') return repo.head === 'branch' ? ok(`${repo.branch}\n`) : fail(1)
    if (args === 'rev-parse --show-toplevel') return ok(`${repo.root}\n`)
    if (args === 'config --get remote.origin.url') return repo.remote ? ok(`${repo.remote}\n`) : fail(1)
    if (args === 'rev-parse --short HEAD') return ok(`${repo.sha}\n`)

    return fail(2)
  }

  return Object.assign(calls, { cwds })
}

const BAND_PROPS = { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 115, scroll: { offset: 0, bodyRows: 10 }, view: {} }
const BAND = { component: 'AbovePrompt', props: BAND_PROPS } as const
const START = { cwd: '/workspace/project', surface: 'terminal', isInteractive: true } as const
const SURFACES = ['terminal', 'desktop'] as const

const repo = (overrides: Partial<Repo> = {}): Repo => ({
  head: 'branch',
  branch: 'feature/ai-562-mcp-adoption',
  sha: 'a1b2c3d',
  remote: 'git@github.com:wraithrmm/claude-code-docker.git',
  root: '/workspace/project',
  ...overrides,
})

// The test stands in for the engine beneath the plugin.
const engine = (on: On, env: Readonly<Record<string, string>> = {}) => {
  mock.env(on, env)
  on('session.start', (_$, e) => ({ cwd: e.cwd }))
  on('command.register', (_$, e) => ({ value: { command: e.name } }))
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)

    return <Box key="engine" />
  })
}

// session.start refreshes in the background so startup never waits on git; tests wait one tick for it.
const { setTimeout } = globalThis as unknown as { setTimeout: (run: () => void, ms: number) => void }
const settle = () => new Promise<void>(resolve => setTimeout(resolve, 0))

type Drawing = { findAll: (query: { type: 'Text' }) => Promise<{ text?: string }[]> }

const chip = async (ui: Drawing) => (await ui.findAll({ type: 'Text' })).find(one => one.text?.startsWith(' ⎇'))
const repoText = async (ui: Drawing) => (await ui.findAll({ type: 'Text' })).find(one => !one.text?.startsWith(' ⎇'))


describe('branch chip', () => {
  test('shows the branch and repo name from session start', async ($, on) => {
    const calls = fakeGit(on, repo())
    engine(on)
    await $.session.start(START)
    await settle()

    for (const surface of SURFACES) {
      const ui = await $.ui.mount({ plugin: 'branch-beacon', surface, ...BAND })
      expect((await chip(ui))?.text).toBe(' ⎇ feature/ai-562-mcp-adoption ')
      expect((await repoText(ui))?.text).toContain('claude-code-docker')
      await ui.unmount()
    }
    expect(calls.every(argv => argv.slice(0, 3).join(' ') === 'git -c safe.directory=*')).toBe(true)
  })

  test('shows the short SHA on a detached HEAD', async ($, on) => {
    fakeGit(on, repo({ head: 'detached' }))
    engine(on)
    await $.session.start(START)
    await settle()

    const ui = await $.ui.mount({ plugin: 'branch-beacon', surface: 'terminal', ...BAND })
    expect((await chip(ui))?.text).toBe(' ⎇ detached @ a1b2c3d ')
  })

  test('shows a grey state outside a git repo', async ($, on) => {
    fakeGit(on, repo({ head: 'none' }))
    engine(on)
    await $.session.start(START)
    await settle()

    const ui = await $.ui.mount({ plugin: 'branch-beacon', surface: 'terminal', ...BAND })
    expect((await chip(ui))?.text).toBe(' ⎇ not a git repo ')
    expect(await repoText(ui)).toBeUndefined()
  })

  test('falls back to the root folder name with no remote', async ($, on) => {
    fakeGit(on, repo({ remote: null, root: '/Users/me/voice-agent-api' }))
    engine(on)
    await $.session.start(START)
    await settle()

    const ui = await $.ui.mount({ plugin: 'branch-beacon', surface: 'terminal', ...BAND })
    expect((await repoText(ui))?.text).toContain('voice-agent-api')
  })

  test('steps aside while a survey holds the band', async ($, on) => {
    fakeGit(on, repo())
    engine(on)
    await $.session.start(START)
    await settle()

    const ui = await $.ui.mount({ plugin: 'branch-beacon', surface: 'terminal', component: 'AbovePrompt', props: { ...BAND_PROPS, hasSurvey: true } })
    expect(await chip(ui)).toBeUndefined()
  })
})

describe('BRANCH_BEACON_REPO', () => {
  test('runs git in the named repo when set', async ($, on) => {
    const calls = fakeGit(on, repo())
    engine(on, { BRANCH_BEACON_REPO: '/workspace/project' })
    await $.session.start(START)
    await settle()

    expect(calls.cwds.length).toBeGreaterThan(0)
    expect(calls.cwds.every(cwd => cwd === '/workspace/project')).toBe(true)
  })

  test("runs git in the session's folder when unset", async ($, on) => {
    const calls = fakeGit(on, repo())
    engine(on)
    await $.session.start(START)
    await settle()

    expect(calls.cwds.every(cwd => cwd === undefined)).toBe(true)
  })
})

describe('refresh', () => {
  test('a git checkout through Bash updates the chip at once', async ($, on) => {
    const state = repo()
    fakeGit(on, state)
    engine(on)
    on('tool.call', () => ({ result: { isError: false, text: 'Switched to branch develop' } }) as never)
    await $.session.start(START)
    await settle()

    state.branch = 'develop'
    await $.tool.call({ tool: 'Bash', tool_use_id: 't1', command: 'git checkout develop' })

    const ui = await $.ui.mount({ plugin: 'branch-beacon', surface: 'terminal', ...BAND })
    expect((await chip(ui))?.text).toBe(' ⎇ develop ')
  })

  test('other Bash commands do not run git', async ($, on) => {
    const calls = fakeGit(on, repo())
    engine(on)
    on('tool.call', () => ({ result: { isError: false, text: '' } }) as never)
    await $.session.start(START)
    await settle()
    const before = calls.length

    await $.tool.call({ tool: 'Bash', tool_use_id: 't2', command: 'npm test' })
    expect(calls.length).toBe(before)
  })
})

describe('switches made outside Claude', () => {
  test('showing the chip again picks up the current branch', async ($, on) => {
    const state = repo()
    fakeGit(on, state)
    engine(on)
    await $.session.start(START)
    await settle()
    const run = { command: 'toggle-branch-beacon', args: '', origin: { kind: 'composer' }, presentation: { isFullscreen: false, columns: 120 } } as never

    await $.command.run(run)
    state.branch = 'develop'
    await $.command.run(run)

    const ui = await $.ui.mount({ plugin: 'branch-beacon', surface: 'terminal', ...BAND })
    expect((await chip(ui))?.text).toBe(' ⎇ develop ')
  })
})

describe('/toggle-branch-beacon', () => {
  test('hides and shows the chip, saying which', async ($, on) => {
    fakeGit(on, repo())
    engine(on)
    await $.session.start(START)
    await settle()
    const run = { command: 'toggle-branch-beacon', args: '', origin: { kind: 'composer' }, presentation: { isFullscreen: false, columns: 120 } } as never

    expect((await $.command.run(run)).text).toContain('hidden')
    const hidden = await $.ui.mount({ plugin: 'branch-beacon', surface: 'terminal', ...BAND })
    expect(await chip(hidden)).toBeUndefined()
    await hidden.unmount()

    expect((await $.command.run(run)).text).toBe('Branch Beacon shown.')
    const shown = await $.ui.mount({ plugin: 'branch-beacon', surface: 'terminal', ...BAND })
    expect(await chip(shown)).toBeDefined()
  })
})
