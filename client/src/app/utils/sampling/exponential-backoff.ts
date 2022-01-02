function distortedExponentialBackoff(base: number, occurrences: number) {
  const repetitionIndex = base ** occurrences;
  // Do a bit of random distortion to avoid completely mechanic repetition.
  const distorted = distort(repetitionIndex, 0.2);
  // At last one item should always come in between.
  return distorted < 1 ? 1 : distorted;
}
