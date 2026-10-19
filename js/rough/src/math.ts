/** Dart's `num.clamp`: [value] limited to `[lower, upper]`. */
export function clamp(value: number, lower: number, upper: number): number {
  if (value < lower) return lower;
  if (value > upper) return upper;
  return value;
}

/** Dart's `double.roundToDouble`: ties round away from zero. */
export function roundHalfAway(value: number): number {
  return value < 0 ? -Math.round(-value) : Math.round(value);
}

/**
 * Sorts [items] in place the way Dart's `List.sort` does for short lists.
 *
 * Dart uses a plain insertion sort up to 33 elements. Matching it keeps the
 * order identical even for comparators that are not consistent, such as the
 * zig-zag filler's rounded-up distance comparison. Longer lists fall back to
 * the built-in sort.
 */
export function dartSort<T>(items: T[], compare: (a: T, b: T) => number): void {
  if (items.length > 33) {
    items.sort(compare);
    return;
  }
  for (let i = 1; i < items.length; i++) {
    const element = items[i] as T;
    let j = i;
    while (j > 0 && compare(items[j - 1] as T, element) > 0) {
      items[j] = items[j - 1] as T;
      j--;
    }
    items[j] = element;
  }
}

/** Dart's `double.toStringAsFixed`, trimmed of trailing zeros. */
export function formatNumber(value: number, digits: number): string {
  const fixed = value.toFixed(digits);
  const trimmed = fixed.includes(".") ? fixed.replace(/\.?0+$/, "") : fixed;
  return trimmed === "-0" ? "0" : trimmed;
}

/** Dart's `double.toString`, which keeps `.0` on whole numbers. */
export function dartDoubleToString(value: number): string {
  if (Number.isInteger(value) && Math.abs(value) < 1e21) {
    return Object.is(value, -0) ? "-0.0" : `${value}.0`;
  }
  return `${value}`;
}
