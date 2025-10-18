# Custom packages overlay for local development and experimentation
#
# This overlay is for packages that are:
# - In active development
# - Being prototyped/tested
# - Not yet ready for GitHub migration
#
# Workflow:
# 1. Develop packages here for quick iteration
# 2. Test locally with nixos-rebuild
# 3. When stable, migrate to GitHub repository (see docs/custom-package-workflow.md)
#
# Example structure:
# custom-pkgs/
# ├── overlay.nix           # This file
# ├── my-package/
# │   └── default.nix
# └── another-tool/
#     └── default.nix

final: prev: {
  openai-codex = prev.callPackage ./openai-codex { };
}
