{
  pkgs,
  lib,
  config,
  ...
}:

{
  packages =
    with pkgs;
    [
      dprint
      eget
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

  env = {
    EGET_CONFIG = "${config.env.DEVENV_ROOT}/.eget/.eget.toml";
    # Prefer the active shell SDK inside devenv so Melos does not depend on the
    # gitignored `.fvm/flutter_sdk` symlink being present.
    MELOS_SDK_PATH = "auto";
  };

  git-hooks = {
    package = pkgs.prek;
    hooks = {
      "secrets:commit" = {
        enable = true;
        name = "secrets:commit";
        description = "Scan staged changes for leaked secrets with gitleaks.";
        entry = "${pkgs.gitleaks}/bin/gitleaks protect --staged --verbose --redact --config .gitleaks.toml";
        pass_filenames = false;
        stages = [ "pre-commit" ];
      };
      "secrets:push" = {
        enable = true;
        name = "secrets:push";
        description = "Check entire git history for leaked secrets with gitleaks.";
        entry = "${pkgs.gitleaks}/bin/gitleaks detect --verbose --redact --config .gitleaks.toml";
        pass_filenames = false;
        stages = [ "pre-push" ];
      };
      ci-parity-commit = {
        enable = true;
        name = "ci-parity:commit";
        description = "Format staged files, apply Dart fixes in changed packages, and analyze staged Dart files.";
        entry = "bash ${config.env.DEVENV_ROOT}/scripts/git_hooks/pre_commit.sh";
        language = "system";
        pass_filenames = true;
        stages = [ "pre-commit" ];
      };
      ci-parity-push = {
        enable = true;
        name = "ci-parity:push";
        description = "Run CI-parity formatting, analysis, and unit/widget tests before push.";
        entry = "bash ${config.env.DEVENV_ROOT}/scripts/git_hooks/pre_push_ci.sh";
        language = "system";
        pass_filenames = false;
        stages = [ "pre-push" ];
      };
    };
  };

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
    "knope" = {
      exec = ''
        set -e
        $DEVENV_ROOT/.eget/bin/knope $@
      '';
      description = "The knope executable for changeset and release management.";
      binary = "bash";
    };
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
        install:eget
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
    "install:eget" = {
      exec = ''
        HASH=$(nix hash path --base32 ./.eget/.eget.toml)
        echo "HASH: $HASH"
        if [ ! -f ./.eget/bin/hash ] || [ "$HASH" != "$(cat ./.eget/bin/hash)" ]; then
          echo "Updating eget binaries"
          eget -D --to "$DEVENV_ROOT/.eget/bin"
          echo "$HASH" > ./.eget/bin/hash
        else
          echo "eget binaries are up to date"
        fi
      '';
      description = "Install github binaries with eget.";
    };
    "fix:all" = {
      exec = ''
        set -e
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
    "lint:all" = {
      exec = ''
        set -e
        lint:format
        lint:analyze
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
        melos analyze
      '';
      description = "Run dart analyze across all packages.";
      binary = "bash";
    };
    "test:all" = {
      exec = ''
        set -e
        melos exec --dir-exists=test --depends-on=flutter -- flutter test
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
  };
}
