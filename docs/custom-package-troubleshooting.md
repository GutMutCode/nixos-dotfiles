# Custom Package Troubleshooting Guide

This document contains solutions to common issues encountered when packaging custom software for NixOS.

## Issue: Bun-based Binary Shows Bun Help Instead of Application Help

### Symptoms
- Binary builds successfully but shows incorrect output
- Running `binary --help` shows Bun runtime help instead of application help
- Binary version shows Bun version (e.g., `1.3.0`) instead of application version

### Example Case: OpenCode v0.15.7
```bash
$ opencode --help
# Expected: opencode help
# Actual: "Bun is a fast JavaScript runtime..." (Bun help)

$ opencode --version
# Expected: 0.15.7
# Actual: 1.3.0 (Bun version)
```

### Root Cause
NixOS build hooks (`autoPatchelfHook`, `strip`) corrupt Bun-based binaries by:
1. **autoPatchelfHook**: Modifies ELF binary internals beyond just fixing dependencies
2. **strip**: Removes symbols that Bun runtime requires for proper execution

### Evidence
```bash
# Original binary hash
$ sha256sum /path/to/original/binary
7228503a3613f7edf1ecae82c48c93b27acb0d28ccd74ed2f46cf7e1bfed1d94

# After autoPatchelfHook + strip
$ sha256sum /nix/store/.../binary
940f9e5b04f32950dbac9e55fb73869be9d24e3089a4182332f6ddf1d1a2b27e  # Different!
```

### Solution

**DO NOT** use `autoPatchelfHook` for Bun-based binaries. Instead:

1. Disable all automatic patching
2. Manually patch only the ELF interpreter using `patchelf`

#### Correct Implementation

```nix
{ lib
, stdenv
, fetchurl
, patchelf
, glibc
}:

stdenv.mkDerivation {
  pname = "bun-based-app";
  version = "1.0.0";

  src = fetchurl {
    url = "https://example.com/app.tgz";
    sha256 = "...";
  };

  # Only use patchelf, NOT autoPatchelfHook
  nativeBuildInputs = [ patchelf ];

  # Disable all default fixup phases that might corrupt the binary
  dontStrip = true;              # CRITICAL: Prevents symbol stripping
  dontPatchELF = true;            # CRITICAL: Prevents automatic ELF patching
  dontPatchShebangs = true;       # Optional: Skip shebang patching

  installPhase = ''
    runHook preInstall

    # Install binary
    install -Dm755 bin/app $out/bin/app

    # Only patch the interpreter, nothing else
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 $out/bin/app

    runHook postInstall
  '';
}
```

#### Wrong Implementation (DO NOT USE)

```nix
# ❌ WRONG: This will corrupt Bun binaries
stdenv.mkDerivation {
  nativeBuildInputs = [ autoPatchelfHook ];  # ❌ Corrupts binary
  buildInputs = [ glibc ];

  # Default fixup phases will run and corrupt the binary
}
```

### Verification Steps

1. **Check binary hash before and after build**
   ```bash
   # Original binary
   sha256sum /path/to/original/binary

   # Nix-built binary
   sha256sum ./result/bin/binary

   # Should match if dontStrip = true and dontPatchELF = true
   ```

2. **Test binary functionality**
   ```bash
   ./result/bin/binary --help     # Should show app help, not Bun help
   ./result/bin/binary --version  # Should show app version, not Bun version
   ```

3. **Check ELF interpreter**
   ```bash
   patchelf --print-interpreter ./result/bin/binary
   # Should show: /nix/store/.../glibc-.../lib/ld-linux-x86-64.so.2
   ```

### Related Issues
- Similar issues can occur with other embedded runtime binaries:
  - Deno-based applications
  - Node.js single-executable applications (SEA)
  - Go binaries with embedded assets
  - Rust binaries with certain linking configurations

### Key Takeaways
1. ✅ Always test binary functionality after packaging
2. ✅ Compare binary hashes before/after build for embedded runtimes
3. ✅ Use `dontStrip = true` and `dontPatchELF = true` for embedded runtimes
4. ✅ Manually patch only the interpreter with `patchelf`
5. ❌ Never use `autoPatchelfHook` on Bun/Deno/embedded runtime binaries

### References
- OpenCode package: `custom-pkgs/opencode/default.nix`
- GitHub Issue: sst/opencode#2527 (similar Bun help issue)
- NixOS Wiki: https://nix.dev/permalink/stub-ld

---

**Last Updated**: 2025-10-18
**Related Packages**: opencode, factory-cli
