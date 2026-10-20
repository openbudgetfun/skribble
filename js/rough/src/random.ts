const MASK_64 = (1n << 64n) - 1n;
const TWO_32 = 4294967296;
const TWO_16 = 65536;
const MULTIPLIER = 0xffffda61;

/**
 * Thomas Wang's 64-bit integer mix, as the Dart VM uses it to seed `Random`.
 */
function mix64(seed: bigint): bigint {
  let n = BigInt.asUintN(64, seed);
  n = (~n + (n << 21n)) & MASK_64;
  n ^= n >> 24n;
  n = (n * 265n) & MASK_64;
  n ^= n >> 14n;
  n = (n * 21n) & MASK_64;
  n ^= n >> 28n;
  n = (n + (n << 31n)) & MASK_64;
  return n;
}

/**
 * A seedable pseudo-random number generator for deterministic rough drawing.
 *
 * The stream is the Dart VM's `Random(seed)` (multiply-with-carry, base
 * 2^32), reproduced bit for bit, so a seed draws exactly the shape skribble's
 * Flutter widgets and Jaspr components draw for it. Call {@link reset} to
 * replay the same sequence.
 */
export class Randomizer {
  readonly seed: number | bigint;
  private initialLow: number;
  private initialHigh: number;
  private low: number;
  private high: number;

  constructor(seed: number | bigint = 0) {
    if (typeof seed === "number" && !Number.isInteger(seed)) {
      throw new RangeError(`Randomizer seed must be an integer, got ${seed}`);
    }
    this.seed = seed;
    let state = mix64(BigInt(seed));
    if (state === 0n) state = 0x5a17n;
    this.low = Number(state & 0xffffffffn);
    this.high = Number(state >> 32n);
    // Dart cranks the generator four times to spread the seed's bits.
    for (let i = 0; i < 4; i++) this.nextState();
    this.initialLow = this.low;
    this.initialHigh = this.high;
  }

  // state = A * low + high, kept as two exact 32-bit halves.
  private nextState(): void {
    const lowHigh = Math.floor(this.low / TWO_16);
    const lowLow = this.low % TWO_16;
    // A * low = A * lowHigh * 2^16 + A * lowLow; each product stays below 2^48.
    const partLow = MULTIPLIER * lowLow + this.high;
    const partHigh = MULTIPLIER * lowHigh;
    const carryLow = partHigh % TWO_16;
    const carryHigh = Math.floor(partHigh / TWO_16);
    const sum = partLow + carryLow * TWO_16;
    this.low = sum % TWO_32;
    this.high = Math.floor(sum / TWO_32) + carryHigh;
  }

  /** The next value in `[0, 1)`. */
  next(): number {
    this.nextState();
    const high = this.low & 0x3ffffff;
    this.nextState();
    const low = this.low & 0x7ffffff;
    return (high * 134217728 + low) / 9007199254740992;
  }

  /** Rewinds the stream to its first value. */
  reset(): void {
    this.low = this.initialLow;
    this.high = this.initialHigh;
  }
}
