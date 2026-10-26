<script module lang="ts">
  // Shared mutable state the test drives from outside; module scope, so the
  // test file can import and mutate it.
  export const host = $state<{ class: string; seed: number; label: string }>({
    class: "a",
    seed: 3,
    label: "One",
  });
</script>

<script lang="ts">
  import Sketch from "../src/lib/Sketch.svelte";
  let { shape }: { shape: import("@skribble.dev/rough").Shape } = $props();
</script>

<Sketch {shape} width={100} height={50} seed={host.seed} class={host.class} label={host.label} data-testid="s" />
