interface CycleLength {
  length: number;
  count: number;
}

// Represents one group of similar permutations, i.e.
// * same number of pieces solved
// * same number of pieces twisted or flipped
// * same split into multiple cycles
class PermutationGroup {
  readonly twists: number;
  readonly normalTargets: number;

  constructor(
    // Number of solved pieces.
    readonly solved: number,
    // Only used for corners, edges and midges.
    // It's an array because there can be multiple types of unoriented.
    // (clockwise and counter-clockwise for corners)
    readonly unoriented: number[],
    // Lengths of permutation cycles in decreasing size.
    readonly cycleLengths: CycleLength[]) {
    twists = sum(oriented);
    normalTargets = sum(cycleLengths.map(cycleLength => cycleLength.count * cycleLength.length));
  }

  // Number of permutations in this group.
  get count() {
    let result = ncr(this.pieces, permutationGroup.solved);
    let remaining = this.pieces - permutationGroup.solved;
    for (let unorientedForType of permutationGroup.unoriented) {
      result *= ncr(remaining, unorientedForType);
      remaining -= unorientedForType;
    }
    for (let cycleLength of permutationGroup.cycleLengths) {
      for (let i = 0; i < cycleLength.count; ++i) {
        result *= ncr(remaining, cycleLength.length);
        // Number of possible cycles of length cycleLength.
        result *= factorial(cycleLength.length - 1);
        remaining -= cycleLength.length * cycleLength.count;
      }
      // If we have multiple cycles of the same length,
      // we count different orderings of the cycles multiple times,
      // so we have to divide by the permutations of those cycles.
      result /= factorial(cyclesWithLastLength);
    }
    return result;
  }
}

function sum(numbers: number[]) {
  return numbers.reduce((a, b) => a + b, 0);
}

// Returns an array of integers from `0` to `n`.
// e.g. `range(5) === [0, 1, 2, 3, 4, 5]`
function range(n): number[] {
  return [...Array(n + 1)];
}

// Multiplies integers between n and m, both ends included.
function rangeProduct(n: number, m: number) {
  let result = 1;
  for (let i = n; i < m; ++i) {
    result *= i;
  }
  return result;
}

function factorial(n: number) {
  return rangeProduct(1, m);
}

function ncr(n: number, r: number) {
  if (r > n - r) {
    r = n - r;
  }
  return rangeProduct(n - r, n) / factorial(r);
}

function checkPrecondition(b: boolean) {
  throw new Error('Precondition failed.');
}

class PieceDescription {
  constructor(readonly pieces: number,
              readonly unorientedTypes: number) {}
}

class PiecePermutationDescription {
  constructor(readonly pieceDescription: PieceDescription,
              readonly allowOddPermutations: boolean) {}

  get pieces() {
    this.pieceDescription.pieces;
  }

  get unorientedTypes() {
    this.pieceDescription.unorientedTypes;
  }

  permutationGroups(): PermutationGroupWithCount[] {
    return range(this.pieces).flatMap(
      solved => this.permutationGroupsWithSolvedAndUnoriented(solved, [])
    );
  }

  private permutationGroupsWithSolvedAndUnoriented(solved: number, unoriented: number[]): PermutationGroupWithCount[] {
    if (unoriented.length === this.unorientedTypes) {
      permutationGroupsWithSolvedAndUnorientedAndCycles(solved, unoriented, []);
    }
    return range(this.pieces - solved - sum(unoriented)).flatMap(
      unorientedForType => this.permutationGroupsWithSolvedAndUnoriented(solved, unoriented + [unorientedForType])
    );
  }

  private permutationGroupsWithSolvedAndUnorientedAndCycles(solved: number, unoriented: number[], cycleLengths: number[]): PermutationGroupWithCount[] {
    const remainingUnsolved = this.pieces - solved - sum(unoriented) - sum(cycleLengths);
    if (remainingUnsolved <= 1) {
      // One piece alone cannot be unsolved, so this is impossible, so 0 possibilities.
      return [];
    } else if (remainingUnsolved == 2 && !this.allowOddPermutations) {
      return [];
    } else if (remainingUnsolved <= 3) {
      // This can only be one cycle, so 1 possibility.
      return [new PermutationGroup(solved, unoriented, cycleLengths)];
    }
    // We cannot keep the last piece unsolved.
    return range(remainingUnsolved - 1).flatMap(
      cycleLength => this.permutationGroupsWithSolvedAndUnorientedAndCycles(solved, unoriented, cycleLengths + [cycleLength]);
    );
  }
}

class FloatingState {
  constructor(permutationGroup: PermutationGroup, readonly remainingBuffers: number) {}

  get twists() {
    this.permutationGroup.twists;
  }

  get normalTargets() {
    this.permutationGroup.normalTargets;
  }
}

interface ProbabilisticFloatingState {
  readonly floatingState: FloatingState;
  readonly probability: number;
}

// An additional trick (e.g. a corner twist alg set) can transform
// a permutation group into simpler permutation groups (e.g. one with corner twists removed).
// In general, how the simplifications work depend on some things
// (e.g. whether the buffer is one of the twisted corners),
// so the return value is a probability distribution of simplified permutation groups.
interface AdditionalTrick {
  probabilisticSimpflifications(permutationGroup: PermutationGroup): PermutationGroupWithProbability[] {}
}

// TODO: Potentially skip twisted buffers if you have another floating one.
// TODO: Avoid buffers when doing cycle breaks
// TODO: Support multiple buffers
class SolvingMethod {
  constructor(readonly piecePermutationDescription: PiecePermutationDescription,
              readonly buffers: number) {}

  expectedNumberOfAlgs(permutationGroup: PermutationGroup): number {
    sum(range(Math.min(permutationGroup.solved, this.buffers)).map(
      solvedBuffers => {
        const pieces = this.piecePermutationDescription.pieces;
        const remainingBuffers = this.buffers - solvedBuffers;
        const probability = ncr(solvedBuffers, solved) * ncr(remainingBuffers, pieces - solved) / ncr(buffers, pieces);
        return probability * expectedNumberOfAlgs(new FloatingState(permutationGroup, this.buffers - solvedBuffers));
      }
    ));
  }

  private algs(twists: number, unsolvedPieces: number, cycleBreaks: number) {
    // * We need one alg per two corner targets (cycle breaks count as additional targets)
    // * Potentially a parity alg for the last target (so we have to round up the division by 2)
    // * one alg per twisted corner (since we can either break into twisted corners or solve two of them with two algs)
    const nonTwistTargets = unsolvedPieces + cycleBreaks;
    return twists + Math.ceil(nonTwistTargets / 2);
  }

  private expectedNumberOfAlgs(floatingState: FloatingState) {
    check(floatingState.remainingBuffers <= 1);
    const twists = sum(floatingState.permutationGroup.unoriented);
    const unsolvedPieces = sum(floatingState.permutationGroup.cycleLengths);
    const cycles = floatingState.permutationGroup.cycleLenghts.length;
    if (floatingState.remainingBuffers === 0) {
      return algs(twists, unsolvedPieces, cycles);
    }
    let result = 0;
    {
      // Buffer is a twist.
      const probability = ncr(twists, twists + normalTargets) / factorial(twists + normalTargets);
      if (twists == 1 && unsolvedPieces == 0) {
        // In the special case that only one other is twisted and there are no other unsolved pieces,
        // it's 2 algs because there is no smart way to do the twist in one alg like otherwise.
        result += probability * 2;
      } else {
        // We can just ignore the twist of the buffer and pretend it's a solved piece.
        result += probability * algs(twists - 1, unsolvedPieces, cycles - 1);
      }
    }
    {
      // Buffer is an unsolved piece.
      const probability = ncr(normalTargets, twists + normalTargets) / factorial(twists + normalTargets);
      // We have one less cycle break because the buffer is part of a cycle.
      result += probability * algs(twists, unsolvedPieces, cycles - 1);
    }
    return result;
  }
}

