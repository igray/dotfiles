NOTE: This was copied directly from [Matthias Benaet's](https://github.com/MatthiasBenaets/nixos-config)
amazing tutorial and repository.

- Guides

* [[./nixos.org][NixOS general guide]]
* [[./nix.org][Nix on other Linux distributions]]
* [[./darwin.org][Nix on MacOS with Nix-Darwin]]
* [[./contrib.org][Contribution to nixpkgs]]
* [[./shell.org][Using nix shells]]

- FAQ

* What is NixOS?
  - NixOS is a Linux distribution built on top of the Nix package manager.
  - It uses declarative configurations and allow reliable system upgrades.
* What is a Flake?
  - Flakes are an upcoming feature of the Nix package manager.
  - Flakes allow you to specify your major code dependencies in a declarative way.
  - It does this by creating a flake.lock file. Some major code dependencies are:
    - nixpkgs
    - home-manager
* What is Nix-Darwin?
  - Nix-Darwin is a way to use Nix modules on macOS using the Darwin Unix-based core set of components.
  - Just like NixOS, it allows to build declarative reproducible configurations.
* Should I switch to NixOS?
  - Is water wet?
* Where can I learn about everything Nix?
  - Nix and NixOS
    - [[file:nixos.org][My General Setup Guide]]
    - [[https://nixos.org/][Website]]
    - [[https://nixos.org/learn.html][Manuals]]
    - [[https://nixos.org/manual/nix/stable/introduction.html][Manual 2]]
    - [[https://search.nixos.org/packages][Packages]] and [[https://search.nixos.org/options?][Options]]
    - [[https://nixos.wiki/][Unofficial Wiki]]
    - [[https://nixos.wiki/wiki/Resources][Wiki Resources]]
    - [[https://nixos.org/guides/nix-pills/][Nix Pills]]
    - [[https://www.ianthehenry.com/posts/how-to-learn-nix/][Some]] [[https://christine.website/blog][Blogs]]
    - [[https://nixos.wiki/wiki/Configuration_Collection][Config Collection]]
    - [[https://nixos.wiki/wiki/Configuration_Collection][Config Collection]]
  - Home-manager
    - [[https://github.com/nix-community/home-manager][Official Repo]]
    - [[https://nix-community.github.io/home-manager/][Manual]]
    - [[https://nix-community.github.io/home-manager/options.html][Appendix A]]
    - [[https://nix-community.github.io/home-manager/nixos-options.html][Appendix B]]
    - [[https://nix-community.github.io/home-manager/tools.html][Appendix D]]
    - [[https://nixos.wiki/wiki/Home_Manager][NixOS wiki]]
  - Flakes
    - [[https://nixos.wiki/wiki/Flakes][NixOS wiki]]
    - [[https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html][Manual]]
    - [[https://www.tweag.io/blog/2020-05-25-flakes/][Some]] [[https://christine.website/blog/nix-flakes-3-2022-04-07][Blogs]]
  - Nix-Darwin
    - [[file:darwin.org][My General Setup Guide]]
    - [[https://github.com/LnL7/nix-darwin/][Official Repo]]
    - [[https://daiderd.com/nix-darwin/manual/index.html][Manual]]
    - [[https://github.com/LnL7/nix-darwin/wiki][Mini-Wiki]]
  - Videos
    - [[https://youtu.be/AGVXJ-TIv3Y][My Personal Mini-Course]]
    - [[https://www.youtube.com/watch?v=QKoQ1gKJY5A&list=PL-saUBvIJzOkjAw_vOac75v-x6EzNzZq][Wil T's Playlist]]
    - [[https://www.youtube.com/watch?v=NYyImy-lqaA&list=PLRGI9KQ3_HP_OFRG6R-p4iFgMSK1t5BHs][Burke Libbey's Nixology]]
    - [[https://www.youtube.com/user/elitespartan117j27/videos][John Ringer's Channel]]
