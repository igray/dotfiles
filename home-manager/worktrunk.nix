{
  programs.worktrunk = {
    enable = true;

    settings = {
      # Keep worktrees inside the repo: <repo>/.worktrees/<branch>
      worktree-path = "{{ repo_path }}/.worktrees/{{ branch | sanitize }}";

      # LLM commit messages during `wt merge` / `wt step commit`.
      commit.generation.command = "CLAUDECODE= MAX_THINKING_TOKENS=0 claude -p --no-session-persistence --model=haiku --tools='' --disable-slash-commands --setting-sources='' --system-prompt=''";

      projects."github.com/CareerPlug/ats".pre-start.claude =
        "rm -rf .claude && ln -s {{ primary_worktree_path }}/.claude .claude && ln -s {{ primary_worktree_path }}/CLAUDE.local.md CLAUDE.local.md";
    };
  };
}
