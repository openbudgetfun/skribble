import { svelte } from "@sveltejs/vite-plugin-svelte";
import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [svelte()],
  test: {
    projects: [
      {
        // Server rendering against the default (server) Svelte build.
        extends: true,
        test: { name: "server", environment: "node", include: ["test/sketch.test.ts"] },
      },
      {
        // Client mounting against the browser Svelte build, so the runes
        // runtime and its reactivity run for real in jsdom.
        extends: true,
        test: { name: "client", environment: "jsdom", include: ["test/memo.test.ts"] },
        resolve: { conditions: ["browser"] },
      },
    ],
  },
});
