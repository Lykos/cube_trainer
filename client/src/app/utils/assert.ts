export function assertEqual<X>(a: X, b: X): void {
  assert(a === b, `${a} === ${b}`);
}

const EPSILON = 0.00001;

export function assertApproxEqual(a: number, b: number): void {
  assert(Math.abs((a - b) / Math.min(Math.abs(a), Math.abs(b))) < EPSILON, `${a} =~ ${b}`);
}

export function assert(condition: boolean, message?: string): asserts condition {
  if (!condition) {
    if (message) {
      throw new Error(`Assertion failed: ${message}`);
    } else {
      throw new Error('Assertion failed.');
    }
  }
}

