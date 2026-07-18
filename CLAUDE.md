# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS and Home Manager dotfiles configuration for two Framework machines: a laptop (framework-amd-ai-300-series) and a work-server (framework-13-7040-amd). The repository uses Nix flakes to manage system and user configurations declaratively.

## Core Architecture

- **flake.nix**: Main entry point defining system and home configurations
- **hosts/**: Per-host entry points (`hosts/<name>/default.nix` + `hardware-configuration.nix`)
- **nixos/**: Shared and host-specific system-level NixOS modules (imported by the host entry points)
- **home-manager/**: User-level configuration modules (applications, dotfiles, packages)
- **bin/**: Custom scripts (mainly restic backup scripts)

The configuration targets a single user (igray) with the username variable defined in flake.nix.

## Key Configuration Structure

The system is split into two main configuration contexts, each defined per-host:

### NixOS Configuration (`nixosConfigurations.{laptop,"work-server"}`)

- Two hosts, each with an entry point at `hosts/<name>/default.nix` that imports `nixos/common.nix` (shared) plus host-specific modules.
- Hostnames set in the host entry points: `"laptop"` in `hosts/laptop/default.nix`, `"work-server"` in `nixos/work-server.nix` (imported by `hosts/work-server/default.nix`).
- Hardware profiles via nixos-hardware: laptop on `framework-amd-ai-300-series`, work-server on `framework-13-7040-amd`.
- Uses the nixos-unstable channel.

### Home Manager Configuration (`homeConfigurations.{"igray@laptop","igray@work-server"}`)

- User-space application and dotfile management
- Imports nixvim for Neovim configuration via external flake
- Uses the same nixos-unstable nixpkgs channel as the system

## Common Commands

### Rebuild System Configuration

```bash
# On the target machine — hostname auto-selects the config:
sudo nixos-rebuild switch --show-trace --flake .

# Or name a host explicitly (e.g. building the server from the laptop):
sudo nixos-rebuild switch --show-trace --flake .#laptop
sudo nixos-rebuild switch --show-trace --flake .#work-server
```

### Rebuild Home Manager Configuration

```bash
home-manager switch --flake .                 # auto-selects igray@$(hostname)
home-manager switch --flake .#igray@laptop    # explicit
```

### Rebuild both

```bash
rebuild   # fish function: nixos-rebuild switch + home-manager switch
```

### Update Flake Inputs

```bash
nix flake update
```

### Test Configuration Changes

```bash
# Test NixOS config without switching
sudo nixos-rebuild build --show-trace --flake .#laptop

# Test home-manager config
home-manager build --show-trace --flake .#igray@laptop
```

## Key Configuration Details

- **Terminal**: Ghostty (vars.terminal in flake.nix)
- **Shell**: Fish (enabled system-wide and in home-manager)
- **Editor**: Neovim with custom nixvim configuration from external repository
- **Package Management**: nixpkgs nixos-unstable channel
- **Hardware**: Framework laptops with AMD graphics, includes power management

## Development Workflow

The configuration uses a modular approach where each application/service has its own .nix file in the appropriate directory (nixos/ for system, home-manager/ for user). When making changes:

1. Edit the relevant module file
2. Test the configuration
3. Use `--show-trace` flag for debugging configuration issues
4. Do not ever rebuild (switch) configuration yourself

## Special Notes

- Cachix is configured for faster builds (cosmic and nix-community caches)
- Experimental nix features (flakes, nix-command) are enabled
- Docker and virtualization (libvirtd, waydroid) are configured
- Automatic garbage collection runs weekly, keeping 2 days of generations

