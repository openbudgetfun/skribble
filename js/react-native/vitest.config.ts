import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      "react-native-svg": fileURLToPath(new URL("./test/stubs/react-native-svg.tsx", import.meta.url)),
    },
  },
});
