import type { Beacon } from '../types'

export const CHIP_COLOURS = [
  '#6ea8fe',
  '#c58af9',
  '#4fd1c5',
  '#f78fb3',
  '#a3e635',
  '#fbbf24',
  '#fb923c',
  '#93c5fd',
] as const

export const CHIP_TEXT = '#111111'
export const NO_REPO_BACKGROUND = '#3a3844'

// FNV-1a keeps a branch on the same colour in every session and terminal.
export const colourFor = (branch: string): string => {
  let hash = 0x811c9dc5
  for (let i = 0; i < branch.length; i += 1) {
    hash ^= branch.charCodeAt(i)
    hash = Math.imul(hash, 0x01000193)
  }

  return CHIP_COLOURS[(hash >>> 0) % CHIP_COLOURS.length] ?? CHIP_COLOURS[0]
}

const lastSegment = (path: string): string => {
  const parts = path.replace(/[\\/]+$/, '').split(/[\\/:]/)

  return (parts[parts.length - 1] ?? '').replace(/\.git$/, '')
}

// Every container mounts its repo at the same path, so the remote names the repo more reliably than the folder.
export const repoName = (remote: string | null, root: string): string => {
  const fromRemote = remote ? lastSegment(remote.trim()) : ''

  return fromRemote || lastSegment(root) || 'repo'
}

const BRANCH_CHANGING = /\bgit\s+(?:-\S+\s+(?:\S+\s+)?)*(?:checkout|switch|worktree|rebase|pull|merge|reset|stash|branch)\b|\bgh\s+pr\s+checkout\b/

export const changesBranch = (command: string): boolean => BRANCH_CHANGING.test(command)

export const chipLabel = (beacon: Beacon): string => {
  switch (beacon.kind) {
    case 'branch':
      return ` ⎇ ${beacon.branch} `
    case 'detached':
      return ` ⎇ detached @ ${beacon.sha} `
    case 'none':
      return ' ⎇ not a git repo '
  }
}
