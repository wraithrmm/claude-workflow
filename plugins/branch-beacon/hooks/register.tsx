import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Beacon } from '../types'
import { CHIP_TEXT, NO_REPO_BACKGROUND, changesBranch, chipLabel, colourFor, repoName } from './beacon'

const COMMAND = 'toggle-branch-beacon'

const beaconAtom = atom({ plugin: 'branch-beacon', key: 'beacon' } as const, null)
const isHidden = atom({ plugin: 'branch-beacon', key: 'isHidden' } as const, false)

type Git = (...args: string[]) => ReturnType<EngineInterface['process']['run']>

// BRANCH_BEACON_REPO names the repo when the session runs outside it (a container that starts in /workspace with the repo at /workspace/project).
// That repo is owned by the host user, which git refuses without safe.directory.
const gitFor = async ($: EngineInterface): Promise<Git> => {
  const cwd = (await $.env.get('BRANCH_BEACON_REPO')) || undefined

  return (...args) => $.process.run(['git', '-c', 'safe.directory=*', ...args], { cwd, timeoutMs: 5000 })
}

const readBeacon = async ($: EngineInterface): Promise<Beacon> => {
  const git = await gitFor($)
  const symbolic = await git('symbolic-ref', '--short', '-q', 'HEAD')
  if (symbolic.exitCode !== 0 && symbolic.exitCode !== 1) {
    return { kind: 'none' }
  }

  const [root, remote] = await Promise.all([
    git('rev-parse', '--show-toplevel'),
    git('config', '--get', 'remote.origin.url'),
  ])
  const repo = repoName(remote.exitCode === 0 ? remote.stdout : null, root.stdout.trim())

  if (symbolic.exitCode === 0) {
    return { kind: 'branch', branch: symbolic.stdout.trim(), repo }
  }

  const sha = await git('rev-parse', '--short', 'HEAD')

  return { kind: 'detached', sha: sha.exitCode === 0 ? sha.stdout.trim() : 'unborn', repo }
}

const refresh = async ($: EngineInterface) => {
  try {
    const beacon = await readBeacon($)
    await update($, beaconAtom, () => beacon)
  } catch {
    await update($, beaconAtom, () => ({ kind: 'none' }) as const)
  }
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: COMMAND,
      description: 'Hide or show the git branch chip above the prompt',
    })
    void refresh($)

    return next(e)
  })

  // A branch switched outside Claude (another terminal, the host) shows at the next prompt or turn end.
  on('prompt.submit', async ($, e, next) => {
    void refresh($)

    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    void refresh($)

    return next(e)
  })

  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    const result = await next(e)
    if (changesBranch(e.command)) {
      await refresh($)
    }

    return result
  })

  on('command.run', { command: COMMAND }, async $ => {
    const hidden = await update($, isHidden, was => !was)
    if (!hidden) {
      await refresh($)
    }

    return {
      text: hidden
        ? `Branch Beacon hidden. Run /${COMMAND} to show it again.`
        : 'Branch Beacon shown.',
    }
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const beacon = await read($, beaconAtom)
    if (e.props.hasSurvey || beacon === null || (await read($, isHidden))) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const isRepo = beacon.kind !== 'none'
    const background = beacon.kind === 'branch' ? colourFor(beacon.branch) : isRepo ? colourFor(beacon.sha) : NO_REPO_BACKGROUND

    return (
      <Box flexDirection="row">
        <Text bold backgroundColor={background} color={isRepo ? CHIP_TEXT : undefined} dimColor={!isRepo} wrap="truncate-end">
          {chipLabel(beacon)}
        </Text>
        {isRepo && (
          <Text dimColor wrap="truncate-end">
            {' '}
            {beacon.repo}
          </Text>
        )}
      </Box>
    )
  })
}
