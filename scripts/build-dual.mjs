/**
 * Builds a js/ package twice: the ESM bundle in `dist/` and a CommonJS
 * bundle in `dist/cjs/`, then marks the CJS directory with a
 * `{"type":"commonjs"}` package.json so its `.js` files load under
 * `require()` even though the package is `"type": "module"`.
 *
 * The final step requires the CJS entry from plain Node: a broken interop
 * path fails the build instead of the first consumer. React Native packages
 * stub their native dependencies for that check, because Node cannot execute
 * the Flow-typed react-native entry outside Metro.
 */
import { execFileSync } from "node:child_process";
import Module from "node:module";
import { readFileSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const packageDir = join(here, "..", "js", process.argv[2] ?? "");
const manifest = JSON.parse(readFileSync(join(packageDir, "package.json"), "utf8"));

// The workspace-local compiler, the same one `pnpm run typecheck` uses.
const tsc = join(packageDir, "node_modules", ".bin", process.platform === "win32" ? "tsc.cmd" : "tsc");

function run(args) {
  execFileSync(tsc, args, { cwd: packageDir, stdio: "inherit" });
}

run(["-p", "tsconfig.build.json"]);
run(["-p", "tsconfig.cjs.json"]);

writeFileSync(join(packageDir, "dist", "cjs", "package.json"), '{"type":"commonjs"}\n');

const require = createRequire(join(packageDir, "package.json"));
if (manifest.peerDependencies && "react-native" in manifest.peerDependencies) {
  const originalLoad = Module._load;
  const stub = { Path: () => null, Svg: () => null };
  Module._load = (request, ...rest) =>
    request === "react-native" || request === "react-native-svg"
      ? stub
      : originalLoad.call(Module, request, ...rest);
  try {
    require("./dist/cjs/index.js");
  } finally {
    Module._load = originalLoad;
  }
} else {
  require("./dist/cjs/index.js");
}
