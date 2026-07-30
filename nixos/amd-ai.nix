{ inputs, vars, ... }:
{
  imports = [ inputs.nix-amd-ai.nixosModules.default ];

  # Scoped here rather than to the shared cachixSettings in flake.nix: only the
  # laptop has the NPU, so work-server has no use for this cache.
  nix.settings = {
    substituters = [ "https://nix-amd-ai.cachix.org" ];
    trusted-public-keys = [
      "nix-amd-ai.cachix.org-1:F4OU4vw/lV2oiG6SBHZ+nqjl4EFJuqI4X9A7pvaBmhQ="
    ];
  };

  hardware.amd-npu = {
    enable = true;

    # Ryzen AI 9 HX 370 is Strix Point, so the XDNA 2 NPU path applies.
    enableNPU = true;
    enableFastFlowLM = true;
    enableLemonade = true;

    # Both GPU backends: upstream measures Vulkan ~26% faster at decode and
    # ROCm ~15% faster at prefill on this gfx1150 iGPU, so keep both available
    # and pick per model — Vulkan for chat, ROCm for large-prompt coding agents.
    enableROCm = true;
    enableVulkan = true;

    lemonade = {
      user = vars.username;
      # The Tauri desktop shell is the only part of lemonade needing a Rust +
      # npm build. The lemond server, CLI and web UI all work without it.
      desktopApp.enable = false;
    };
  };
}
