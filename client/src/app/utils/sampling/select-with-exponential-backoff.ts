import { distort } from './distort';

// Returns how long we have to wait until an item should be repeated again based on its number of totalOccurrences.
// The exact meaning of totalOccurrences determines what the return value means, e.g.:
// * If totalOccurrences represents the total number of occurrences of an item,
//   this returns how many other items we have to wait until showing this item again.
// * If totalOccurrences represents the total number of different days an item occurred on,
//   this returns how many days we have to wait until showing this item again.
function repetitionIndex(exponentialBackoffBase: number, totalOccurrences: number): number {
  const repetitionIndex = exponentialBackoffBase ** totalOccurrences;
  // Do a bit of random distortion to avoid completely mechanic repetition.
  // Note that the distribution of this is linear here, but because it's called
  // once on each iteration, the observed distribution is different.
  const distorted = distort(repetitionIndex, 0.2);
  // At last one item should always come in between.
  return distorted < 1 ? 1 : distorted;
}

// Returns if this item should be 
// The exact meaning of totalOccurrences and moreRecentOtherOccurrences is variable, but
// it has to be compatible, e.g.:
// * If totalOccurrences represents the total number of occurrences of an item,
//   moreRecentOtherOccurrences has to be the total number of occurrences of other items after the last
//   occurrence of this item.
// * If totalOccurrences represents the total number of different days an item occurred on,
//   moreRecentOtherOccurrences has to be the number of days since the last occurrence of this item
export function selectWithExponentialBackoff(
  exponentialBackoffBase: number,
  totalOccurrences: number,
  moreRecentOtherOccurrences: number,
  maxOccurrences: number = Infinity): boolean {
  if (totalOccurrences === 0 || totalOccurrences > maxOccurrences) {
    return false;
  }
  const index = repetitionIndex(exponentialBackoffBase, totalOccurrences);
  return moreRecentOtherOccurrences > index;
}
