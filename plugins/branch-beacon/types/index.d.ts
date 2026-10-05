export type Beacon =
  | { kind: 'branch'; branch: string; repo: string }
  | { kind: 'detached'; sha: string; repo: string }
  | { kind: 'none' }

declare module 'claude-code' {
  interface PluginState {
    'branch-beacon': { beacon: Beacon | null; isHidden: boolean }
  }
}
