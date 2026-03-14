#!/usr/bin/env -S deno run -A

import { chromium } from "npm:playwright-core@1.54.2";

declare const DOMParser: any;
declare const document: any;

type Task = {
  input: string;
  output: string;
  seed: number | null;
};

const kDefaultSvg2roughUrl =
  "https://unpkg.com/svg2roughjs@3.2.3/dist/svg2roughjs.umd.min.js";

function printUsage(): void {
  console.log(`svg2roughjs Deno wrapper

Usage:
  deno run -A tool/deno/svg2roughjs_cli.ts --input <svg> --output <svg> [--seed <int>]
  deno run -A tool/deno/svg2roughjs_cli.ts --manifest <json>

Options:
  --input <path>         Input SVG path.
  --output <path>        Output SVG path.
  --seed <int>           Deterministic seed.
  --manifest <path>      JSON array of { input, output, seed } tasks.
  --svg2rough-url <url>  Override the svg2roughjs UMD URL.
  --help                 Show this help.
`);
}

function parseArgs(argv: string[]): Map<string, string> {
  const args = new Map<string, string>();

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index]!;

    if (!argument.startsWith("--")) {
      throw new Error(`Unexpected argument: ${argument}`);
    }

    if (argument === "--help") {
      args.set("--help", "true");
      continue;
    }

    const [key, inlineValue] = argument.split("=", 2);
    const value = inlineValue ?? argv[index + 1];
    if (value == null) {
      throw new Error(`Missing value for ${key}`);
    }

    args.set(key, value);
    if (inlineValue == null) {
      index += 1;
    }
  }

  return args;
}

function parseSeed(value: string | undefined): number | null {
  if (value == null || value.length === 0) {
    return null;
  }
  const parsed = Number.parseInt(value, 10);
  if (Number.isNaN(parsed)) {
    throw new Error(`Invalid seed: ${value}`);
  }
  return parsed;
}

async function fileExists(path: string): Promise<boolean> {
  try {
    await Deno.stat(path);
    return true;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      return false;
    }
    throw error;
  }
}

async function resolveChromeExecutablePath(): Promise<string> {
  const candidates = [
    Deno.env.get("CHROME_PATH"),
    Deno.env.get("GOOGLE_CHROME_BIN"),
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/usr/bin/google-chrome",
    "/usr/bin/google-chrome-stable",
    "/usr/bin/chromium",
    "/usr/bin/chromium-browser",
  ].filter((item): item is string => item != null && item.length > 0);

  for (const candidate of candidates) {
    if (await fileExists(candidate)) {
      return candidate;
    }
  }

  throw new Error(
    "Unable to find Chrome/Chromium executable. Set CHROME_PATH explicitly.",
  );
}

async function parseTasks(args: Map<string, string>): Promise<Task[]> {
  const manifestPath = args.get("--manifest");
  if (manifestPath != null) {
    const raw = await Deno.readTextFile(manifestPath);
    const decoded = JSON.parse(raw);
    if (!Array.isArray(decoded)) {
      throw new Error("--manifest must contain a JSON array");
    }

    return decoded.map((item, index) => {
      if (typeof item !== "object" || item == null) {
        throw new Error(`Manifest item ${index} is invalid`);
      }

      const input = Reflect.get(item, "input");
      const output = Reflect.get(item, "output");
      const seedValue = Reflect.get(item, "seed");

      if (typeof input !== "string" || input.length === 0) {
        throw new Error(`Manifest item ${index} missing valid input`);
      }
      if (typeof output !== "string" || output.length === 0) {
        throw new Error(`Manifest item ${index} missing valid output`);
      }

      return {
        input,
        output,
        seed: seedValue == null ? null : parseSeed(String(seedValue)),
      } satisfies Task;
    });
  }

  const input = args.get("--input");
  const output = args.get("--output");
  if (input == null || input.length === 0) {
    throw new Error("--input is required when --manifest is omitted");
  }
  if (output == null || output.length === 0) {
    throw new Error("--output is required when --manifest is omitted");
  }

  return [
    {
      input,
      output,
      seed: parseSeed(args.get("--seed")),
    },
  ];
}

function outputDirectory(path: string): string {
  const slashIndex = Math.max(path.lastIndexOf("/"), path.lastIndexOf("\\"));
  if (slashIndex <= 0) {
    return ".";
  }
  return path.slice(0, slashIndex);
}

async function main(): Promise<void> {
  const args = parseArgs(Deno.args);
  if (args.has("--help")) {
    printUsage();
    return;
  }

  const tasks = await parseTasks(args);
  if (tasks.length === 0) {
    return;
  }

  const svg2roughUrl = args.get("--svg2rough-url") ?? kDefaultSvg2roughUrl;
  const chromeExecutablePath = await resolveChromeExecutablePath();

  const browser = await chromium.launch({
    executablePath: chromeExecutablePath,
    headless: true,
  });

  try {
    const page = await browser.newPage();
    await page.setContent(
      '<!doctype html><html><head></head><body><div id="output"></div></body></html>',
    );
    await page.addScriptTag({ url: svg2roughUrl });

    for (const task of tasks) {
      const sourceSvg = await Deno.readTextFile(task.input);
      const roughSvg = await page.evaluate(
        async ({ sourceSvg, seed }) => {
          const parser = new DOMParser();
          const sourceDocument = parser.parseFromString(
            sourceSvg,
            "image/svg+xml",
          );
          const sourceRoot = sourceDocument.documentElement;
          if (sourceRoot?.tagName?.toLowerCase() !== "svg") {
            throw new Error("Input document is not an SVG");
          }

          const outputContainer = document.getElementById("output");
          if (outputContainer == null) {
            throw new Error("Missing output container");
          }
          outputContainer.replaceChildren();

          // deno-lint-ignore no-explicit-any
          const converter = new (window as any).svg2roughjs.Svg2Roughjs(
            outputContainer,
            // deno-lint-ignore no-explicit-any
            (window as any).svg2roughjs.OutputType.SVG,
          );
          converter.randomize = false;
          converter.svg = sourceRoot;
          if (seed != null) {
            converter.seed = seed;
          }
          await converter.sketch(true);

          const outputSvg = outputContainer.querySelector("svg");
          if (outputSvg == null) {
            throw new Error("svg2roughjs did not produce SVG output");
          }
          return outputSvg.outerHTML;
        },
        {
          sourceSvg,
          seed: task.seed,
        },
      );

      await Deno.mkdir(outputDirectory(task.output), { recursive: true });
      await Deno.writeTextFile(task.output, roughSvg);
    }
  } finally {
    await browser.close();
  }
}

if (import.meta.main) {
  main().catch((error) => {
    console.error(String(error?.stack ?? error));
    Deno.exit(1);
  });
}
