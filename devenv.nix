{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  ifi = inputs.ifiokjr-nixpkgs.packages.${pkgs.stdenv.system};
in

{
  packages =
    with pkgs;
    [
      ifi.mdt
      ifi.monochange
      ifi.melos
      dprint
      fontforge
      fvm
      gitleaks
      libiconv
      nixfmt
      ripgrep
      shfmt
    ]
    ++ lib.optionals stdenv.isDarwin [
      coreutils
    ];

  dotenv.disableHint = true;

  # Rely on the global sdk for now as the nix apple sdk is not working for me.
  apple.sdk = null;

  scripts = {
    "flutter" = {
      exec = ''
        # Unset Nix toolchain variables that conflict with Xcode builds
        unset CC CXX LD AR NM RANLIB STRIP OBJCOPY OBJDUMP SIZE STRINGS
        unset NIX_CC NIX_BINTOOLS NIX_CFLAGS_COMPILE NIX_LDFLAGS
        unset NIX_HARDENING_ENABLE NIX_ENFORCE_NO_NATIVE
        unset NIX_DONT_SET_RPATH NIX_DONT_SET_RPATH_FOR_BUILD NIX_NO_SELF_RPATH
        unset NIX_IGNORE_LD_THROUGH_GCC
        unset NIX_BINTOOLS_WRAPPER_TARGET_HOST_arm64_apple_darwin
        unset NIX_CC_WRAPPER_TARGET_HOST_arm64_apple_darwin
        unset NIX_PKG_CONFIG_WRAPPER_TARGET_HOST_arm64_apple_darwin
        unset SDKROOT MACOSX_DEPLOYMENT_TARGET
        unset CFLAGS CXXFLAGS LDFLAGS ARCHFLAGS
        unset PKG_CONFIG PKG_CONFIG_PATH
        unset LD_LIBRARY_PATH LD_DYLD_PATH
        unset cmakeFlags
        set -e
        fvm flutter $@
      '';
      description = "Run flutter commands.";
    };
    "dart" = {
      exec = ''
        set -e
        fvm dart $@
      '';
      description = "Run dart commands.";
    };
    "melos" = {
      exec = ''
        set -e
        dart run melos $@
      '';
      description = "Run the melos cli.";
    };
    # NOTE: no devenv script for `mc` — the monochange nix package already
    # provides the real binary; a same-named script here would shadow it and
    # recurse into itself (fork bomb) inside devenv shells.
    "dartfmt" = {
      exec = ''
        set -e
        dart format -o show $@ | head -n -1
      '';
      description = "The dart format executable for formatting the workspace.";
      binary = "bash";
    };
    "install:all" = {
      exec = ''
        set -e
        install:dart
      '';
      description = "Run all install scripts.";
      binary = "bash";
    };
    "install:dart" = {
      exec = ''
        set -e
        dart pub get
        flutter pub get
      '';
      description = "Install dart dependencies";
      binary = "bash";
    };
    # NOTE: fix:docs runs before fix:format so dprint normalizes any markdown
    # freshly synced by mdt update (no mdt/dprint formatter convergence issue).
    "fix:all" = {
      exec = ''
        set -e
        fix:docs
        fix:format
        fix:lint
      '';
      description = "Fix all fixable issues.";
      binary = "bash";
    };
    "fix:format" = {
      exec = ''
        set -e
        dprint fmt --config "$DEVENV_ROOT/dprint.json"
      '';
      description = "Fix formatting for entire project.";
    };
    "fix:lint" = {
      exec = ''
        set -e
        melos exec -- dart fix --apply
      '';
      description = "Fix lint issues across all packages.";
      binary = "bash";
    };
    "fix:docs" = {
      exec = ''
        set -e
        mdt update
      '';
      description = "Sync MDT template blocks to fix documentation drift.";
    };
    "lint:all" = {
      exec = ''
        set -e
        lint:format
        lint:analyze
        lint:docs
      '';
      description = "Run all lint checks.";
      binary = "bash";
    };
    "lint:format" = {
      exec = ''
        set -e
        dprint check
      '';
      description = "Check all formatting is correct.";
    };
    "lint:analyze" = {
      exec = ''
        set -e
        melos exec -- dart analyze --fatal-warnings .
      '';
      description = "Run dart analyze across all packages (warnings are fatal).";
      binary = "bash";
    };
    "lint:docs" = {
      exec = ''
        set -e
        mdt check
      '';
      description = "Check MDT template blocks are up to date.";
    };
    "test:all" = {
      exec = ''
        set -e
        melos exec --dir-exists=test --depends-on=flutter --concurrency=1 -- flutter test --concurrency=4
      '';
      description = "Run all unit and widget tests in Flutter packages.";
      binary = "bash";
    };
    "test:coverage" = {
      exec = ''
        set -e
        repo_root="$DEVENV_ROOT"
        cd "$repo_root"

        rm -rf coverage
        mkdir -p coverage

        echo "Generating coverage for Flutter packages..."
        melos exec --dir-exists=test --flutter -- \
          'rm -rf coverage && flutter test --coverage'

        echo "Merging LCOV reports..."
        : > coverage/lcov.info

        lcov_files="$(find packages -type f -path "*/coverage/lcov.info" | sort)"
        if [[ -z "$lcov_files" ]]; then
          echo "No package coverage reports were generated." >&2
          exit 1
        fi

        while IFS= read -r lcov_file; do
          sed -e "s|SF:$repo_root/|SF:|g" "$lcov_file" >> coverage/lcov.info
        done <<< "$lcov_files"

        echo "Merged coverage report: $repo_root/coverage/lcov.info"
      '';
      description = "Generate merged LCOV coverage for all packages.";
      binary = "bash";
    };
    "update:deps" = {
      exec = ''
        set -e
        devenv update
        flutter pub upgrade
      '';
      description = "Update devenv and pub dependencies.";
      binary = "bash";
    };
    "docs:site:serve" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/docs/site"
        dart pub get
        dart run jaspr_cli:jaspr serve $@
      '';
      description = "Serve the docs site locally.";
      binary = "bash";
    };
    "docs:site:build" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/docs/site"
        dart pub get
        dart run jaspr_cli:jaspr build $@
      '';
      description = "Build static docs output for GitHub Pages.";
      binary = "bash";
    };
  };
}
