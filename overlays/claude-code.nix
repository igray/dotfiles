{ inputs }:
[
  inputs.claude-code.overlays.default

  # Provide a Python interpreter to claude-code as a PATH *fallback*.
  #
  # Some plugins run hooks that shell out to `python3`. On NixOS there is no
  # global `python`, so those hooks fail with "No working Python found". We wrap
  # the `claude` binary to append a python3 to its PATH.
  #
  # The interpreter is built with `claude-agent-sdk` already importable. This:
  #   * satisfies the `remember` plugin, which just needs any python3, and
  #   * lets the `security-guidance` plugin's `ensure_agent_sdk.py` no-op: it
  #     runs `importlib.util.find_spec("claude_agent_sdk")` and, when that
  #     succeeds, skips its venv + `pip install` bootstrap entirely (which is
  #     against NixOS philosophy and unreliable with native wheels).
  #
  # `--suffix` (not `--prefix`) is deliberate: this python3 is only used when
  # nothing else on PATH provides one, so per-project devenv / `nix develop`
  # interpreters still take precedence and project isolation is preserved.
  # We use `withPackages` rather than exporting PYTHONPATH so the SDK rides on
  # THIS interpreter's own sys.path and never shadows project deps in other
  # python invocations the agent makes.
  (final: prev: {
    claude-code = final.symlinkJoin {
      name = "claude-code-wrapped-${prev.claude-code.version or "unknown"}";
      paths = [ prev.claude-code ];
      nativeBuildInputs = [ final.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/claude \
          --suffix PATH : ${
            final.lib.makeBinPath [
              (final.python3.withPackages (ps: [ ps.claude-agent-sdk ]))
            ]
          }
      '';
    };
  })
]
