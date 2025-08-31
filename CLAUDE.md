# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS and Home Manager dotfiles configuration for a Framework 13 7040 AMD laptop. The repository uses Nix flakes to manage system and user configurations declaratively.

## Core Architecture

- **flake.nix**: Main entry point defining system and home configurations
- **nixos/**: System-level NixOS configuration modules
- **home-manager/**: User-level configuration modules (applications, dotfiles, packages)
- **bin/**: Custom scripts (mainly restic backup scripts)

The configuration targets a single user (igray) with the username variable defined in flake.nix:37.

## Key Configuration Structure

The system is split into two main configuration contexts:

### NixOS Configuration (`nixosConfigurations."nixos"`)

- Hostname: "laptop" (nixos/configuration.nix:121)
- Hardware profile: Framework 13 7040 AMD via nixos-hardware
- Modules loaded from nixos/ directory
- Uses NixOS 25.05 stable channel

### Home Manager Configuration (`homeConfigurations."${vars.username}"`)

- User-space application and dotfile management
- Imports nixvim for Neovim configuration via external flake
- Uses both stable and unstable nixpkgs channels

## Common Commands

### Rebuild System Configuration

```bash
sudo nixos-rebuild switch --show-trace --flake .#nixos
```

### Rebuild Home Manager Configuration

```bash
home-manager switch --flake .#igray
```

### Update Flake Inputs

```bash
nix flake update
```

### Test Configuration Changes

```bash
# Test NixOS config without switching
sudo nixos-rebuild build --show-trace --flake .#nixos

# Test home-manager config
home-manager build --show-trace --flake .#igray
```

## Key Configuration Details

- **Terminal**: Ghostty (vars.terminal in flake.nix:39)
- **Shell**: Fish (enabled system-wide and in home-manager)
- **Editor**: Neovim with custom nixvim configuration from external repository
- **Package Management**: Mixed stable (25.05) and unstable channels
- **Hardware**: Framework laptop with AMD graphics, includes power management

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

