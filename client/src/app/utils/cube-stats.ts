interface CycleGroup {
  length: number;
  count: number;
}

function cycleGroupsSum(cycleGroups: CycleGroup[]) {
  return sum(cycleGroups.map(cycleGroup => cycleGroup.count * cycleGroup.length));
}

function cycleGroupsParity(cycleGroups: CycleGroup[]) {
  return (cycleGroupsSum(cycleGroups) + cycleGroupsTotalCount(cycleGroups)) % 2;
}

function cycleGroupsTotalCount(cycleGroups: CycleGroup[]) {
  return sum(cycleGroups.map(cycleGroup => cycleGroup.count));
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
    readonly cycleGroups: CycleGroup[]) {
    this.twists = sum(this.unoriented);
    this.normalTargets = cycleGroupsSum(this.cycleGroups);
  }

  get pieces() {
    return this.solved + this.twists + this.normalTargets;
  }
  
  // Number of permutations in this group.
  count() {
    let result = ncr(this.pieces, this.solved);
    let remaining = this.pieces - this.solved;
    for (let unorientedForType of this.unoriented) {
      result *= ncr(remaining, unorientedForType);
      remaining -= unorientedForType;
    }
    for (let cycleGroup of this.cycleGroups) {
      for (let i = 0; i < cycleGroup.count; ++i) {
        result *= ncr(remaining, cycleGroup.length);
        // Number of possible cycles of length cycleGroup.
        result *= factorial(cycleGroup.length - 1);
        remaining -= cycleGroup.length;
      }
      // If we have multiple cycles of the same length,
      // we count different orderings of the cycles multiple times,
      // so we have to divide by the permutations of those cycles.
      result /= factorial(cycleGroup.count);
    }
    // For every unsolved piece except for the last one, we have a choice for the orientation.
    result *= (this.unoriented.length + 1) ** (this.normalTargets - 1)
    return result;
  }
}

function sum(numbers: number[]) {
  return numbers.reduce((a, b) => a + b, 0);
}

// Returns an array of integers from `0` to `n`.
// e.g. `range(5) === [0, 1, 2, 3, 4, 5]`
function range(n: number): number[] {
  assert(n >= 0, 'n in range(n) has to be non-negative');
  return [...Array(n + 1).keys()];
}

// Returns an array of integers from n to m, both ends included.
function doubleRange(n: number, m: number): number[] {
  assert(n >= 0, 'n >= 0 in doubleRange(n, m)');
  assert(m + 1 >= n, 'm + 1 >= n in doubleRange(n, m)');
  const result = [];
  for (let i = n; i <= m; ++i) {
    result.push(i);
  }
  return result;
}

// Multiplies integers between n and m, both ends included.
function rangeProduct(n: number, m: number) {
  assert(n >= 1, 'n >= 1 in rangeProduct(n, m)');
  assert(m + 1 >= n, 'm + 1 >= n in rangeProduct(n, m)');
  let result = 1;
  for (let i = n; i <= m; ++i) {
    result *= i;
  }
  return result;
}

function factorial(n: number) {
  assert(n >= 0, 'n in factorial(n) has to be positive');
  return rangeProduct(1, n);
}

function ncr(n: number, r: number) {
  assert(r >= 0, 'r >= 0 in range(n, r)');
  assert(n >= r, 'n >= r in range(n, r)');
  if (r > n - r) {
    r = n - r;
  }
  return rangeProduct(n - r + 1, n) / factorial(r);
}

function assert(b: boolean, message: string) {
  if (!b) {
    throw new Error(`Assertion failed: ${message}`);
  }
}

class PieceDescription {
  constructor(readonly pieces: number,
              readonly unorientedTypes: number) {
    assert(pieces >= 2, 'There have to be at least 2 pieces');
    assert(unorientedTypes >= 0, 'The number of oriented types has to be non-negative');
  }
}

const CORNER = new PieceDescription(8, 2);
const EDGE = new PieceDescription(12, 1);

class PiecePermutationDescription {
  constructor(readonly pieceDescription: PieceDescription,
              readonly allowOddPermutations: boolean) {}

  get pieces() {
    return this.pieceDescription.pieces;
  }

  get unorientedTypes() {
    return this.pieceDescription.unorientedTypes;
  }

  get count() {
    const divisor = this.allowOddPermutations ? 1 : 2;
    const orientations = (this.unorientedTypes + 1) ** (this.pieces - 1);
    const permutations = factorial(this.pieceDescription.pieces);
    return orientations * permutations / divisor;
  }

  groups(): PermutationGroup[] {
    return range(this.pieces).flatMap(
      solved => this.groupsWithSolvedAndUnoriented(solved, [])
    );
  }

  private groupsWithSolvedAndUnoriented(solved: number, unoriented: number[]): PermutationGroup[] {
    assert(unoriented.length <= this.unorientedTypes, 'unoriented.length <= this.unorientedTypes');
    if (unoriented.length === this.unorientedTypes) {
      const remainingUnsolved = this.pieces - solved - sum(unoriented);
      return this.possibleCycleGroups(remainingUnsolved).map(cycleGroups => {
        const group = new PermutationGroup(solved, unoriented, cycleGroups);
        assert(group.solved + group.twists + group.normalTargets === this.pieces, `${group.solved} + ${group.twists} + ${group.normalTargets} === ${this.pieces}`);
        return group;
      });
    }
    return range(this.pieces - solved - sum(unoriented)).flatMap(
      unorientedForType => this.groupsWithSolvedAndUnoriented(solved, unoriented.concat([unorientedForType]))
    );
  }

  private possibleCycleGroups(remainingUnsolved: number): CycleGroup[][] {
    return this.possibleCycleGroupsForPrefix(remainingUnsolved, []);
  }
  
  private possibleCycleGroupsForPrefix(remainingUnsolved: number, cycleGroupsPrefix: CycleGroup[]): CycleGroup[][] {
    const maxLength = cycleGroupsPrefix.length ? (cycleGroupsPrefix[cycleGroupsPrefix.length - 1].length - 1) : Infinity;
    if (remainingUnsolved === 0) {
      if (!this.allowOddPermutations && cycleGroupsParity(cycleGroupsPrefix) == 1) {
        return [];
      }
      return [cycleGroupsPrefix];
    } else if (remainingUnsolved === 1) {
      // One piece alone cannot be unsolved, so this is impossible, so 0 possibilities.
      return [];
    } else if (remainingUnsolved <= 3) {
      if (!this.allowOddPermutations && (cycleGroupsParity(cycleGroupsPrefix) + remainingUnsolved + 1) % 2 == 1) {
        // We don't allow odd permutations and this is one, so it's impossible, so 0 possibilities.
        return [];
      }
      if (remainingUnsolved > maxLength) {
        return [];
      }
      // This can only be one cycle, so 1 possibility. Make a cycle of the remaining pieces.
      return [cycleGroupsPrefix.concat([{count: 1, length: remainingUnsolved}])];
    }
    const result = this.possibleNextCycleGroups(remainingUnsolved, maxLength).flatMap(cycleGroup => {
      const newRemainingUnsolved = remainingUnsolved - cycleGroup.length * cycleGroup.count;
      const newPrefix = cycleGroupsPrefix.concat(cycleGroup);
      return this.possibleCycleGroupsForPrefix(newRemainingUnsolved, newPrefix);
    });
    return result;
  }
  
  private possibleNextCycleGroups(remainingUnsolved: number, maxLength: number): CycleGroup[] {
    const result: CycleGroup[] = [];
    for (let length = 2; length <= remainingUnsolved && length <= maxLength; ++length) {
      for (let count = 1; count * length <= remainingUnsolved; ++count) {
        result.push({count, length});
      }
    }
    return result;
  }
}

class FloatingState {
  constructor(readonly group: PermutationGroup, readonly remainingBuffers: number) {}

  get twists() {
    return this.group.twists;
  }

  get normalTargets() {
    return this.group.normalTargets;
  }
}

/*
interface ProbabilisticFloatingState {
  readonly floatingState: FloatingState;
  readonly probability: number;
}
*/

// TODO: Potentially skip twisted buffers if you have another floating one.
// TODO: Avoid buffers when doing cycle breaks
// TODO: Support multiple buffers
class SolvingMethod {
  constructor(readonly piecePermutationDescription: PiecePermutationDescription,
              readonly buffers: number) {
    assert(buffers >= 1, 'There has to be at least one buffer');
  }

  expectedAlgs(): number {
    const groups = this.piecePermutationDescription.groups();
    const directComputed = this.piecePermutationDescription.count;
    const groupSum = sum(groups.map(group => group.count()));
    assert(Math.round(directComputed) === Math.round(groupSum), `${directComputed} === ${groupSum} (direct computed vs group sum)`)
    return sum(groups.map(group => {
      const probability = group.count() / this.piecePermutationDescription.count;
      const expectedAlgsForGroup = this.expectedAlgsForGroup(group);
      return probability * expectedAlgsForGroup;
    }));
  }

  importantGroup(group: PermutationGroup) {
    const probability = group.count() / this.piecePermutationDescription.count;
    return probability > 0.01;
  }

  private expectedAlgsForGroup(group: PermutationGroup): number {
    const solved = group.solved
    const pieces = this.piecePermutationDescription.pieces;
    const minSolvedBuffers = Math.max(0, solved + this.buffers - pieces);
    const maxSolvedBuffers = Math.min(solved, this.buffers)
    return sum(doubleRange(minSolvedBuffers, maxSolvedBuffers).map(
      solvedBuffers => {
        const remainingBuffers = this.buffers - solvedBuffers;
        const probability = ncr(solved, solvedBuffers) *
          ncr(pieces - solved, remainingBuffers) /
          ncr(pieces, this.buffers);
        const expectedAlgs = this.expectedAlgsForState(new FloatingState(group, this.buffers - solvedBuffers));
        return probability * expectedAlgs;
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

  private expectedAlgsForState(floatingState: FloatingState) {
    assert(floatingState.remainingBuffers <= 1, 'There has to be at most 1 remaining buffer.');
    const twists = sum(floatingState.group.unoriented);
    const unsolvedPieces = cycleGroupsSum(floatingState.group.cycleGroups);
    const cycles = cycleGroupsTotalCount(floatingState.group.cycleGroups);
    if (floatingState.remainingBuffers === 0) {
      return this.algs(twists, unsolvedPieces, cycles);
    }
    let result = 0;
    {
      // Buffer is a twist.
      const probability = twists / (twists + unsolvedPieces);
      if (twists == 1 && unsolvedPieces == 0) {
        // In the special case that only one other is twisted and there are no other unsolved pieces,
        // it's 2 algs because there is no smart way to do the twist in one alg like otherwise.
        result += probability * 2;
      } else {
        // We can just ignore the twist of the buffer and pretend it's a solved piece.
        result += probability * this.algs(twists - 1, unsolvedPieces, cycles - 1);
      }
    }
    {
      // Buffer is an unsolved piece.
      const probability = unsolvedPieces / (twists + unsolvedPieces);
      // We have one less cycle break because the buffer is part of a cycle.
      result += probability * this.algs(twists, unsolvedPieces, cycles - 1);
    }
    return result;
  }
}

export enum ExecutionOrder {
  CE, EC
}

export interface MethodDescription {
  readonly executionOrder: ExecutionOrder;
}

export function expectedAlgs(methodDescription: MethodDescription): number {
  switch (methodDescription.executionOrder) {
    case ExecutionOrder.EC:
      return new SolvingMethod(new PiecePermutationDescription(EDGE, false), 1).expectedAlgs() +
        new SolvingMethod(new PiecePermutationDescription(CORNER, true), 1).expectedAlgs();
    case ExecutionOrder.CE:
      return new SolvingMethod(new PiecePermutationDescription(CORNER, false), 1).expectedAlgs() +
        new SolvingMethod(new PiecePermutationDescription(EDGE, true), 1).expectedAlgs();
  }      
}
