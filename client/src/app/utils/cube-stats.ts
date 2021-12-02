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
1
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

class Piece {
  constructor(
    readonly id: number,
    readonly bufferPriority?: number,
    readonly avoidAsTwistedIfWeCanFloat: boolean) {}

  get isBuffer() {
    return !!bufferPriority;
  }
}

class BufferState {}

function emptyBufferState(): BufferState {}

class Decider {
  nextCycleBreakOnSecondPiece(buffer: Piece, firstPiece: Piece, unsolvedPieces: Piece[]): Piece {
  }

  nextCycleBreakOnFirstPiece(buffer: Piece, unsolvedPieces: Piece[]): Piece {
  }

  canParityTwist(buffer, otherPiece, piece) {}

  // Buffers that are used up first due to not being avoided twists.
  isFirstPassBuffer(piece: Piece) {
    return piece.isBuffer && (this.group.isPermuted(piece) || !piece.avoidAsTwistedIfWeCanFloat && this.group.isTwisted(piece));
  }

  // Buffers that are used up second due to not being solved.
  isSecondPassBuffer(piece: Piece) {
    return piece.isBuffer && !isSolved(piece);
  }
}

class SolveState {
  constructor(readonly decider: Decider, readonly group: PermutationGroup, readonly bufferState: BufferState, readonly pieces: Piece[]) {}

  get twists() {
    return this.group.twists;
  }

  get normalTargets() {
    return this.group.normalTargets;
  }

  get buffers() {
    this.pieces.filter(piece => piece.isBuffer);
  }

  private nextBuffer(): Piece {
    const previousBuffer = bufferState.previousBuffer;
    if (previousBuffer && !this.decider.canChangeBuffer(bufferState)) {
      return previousBuffer;
    }
    const firstPassBuffers = this.buffers.filter(piece => this.decider.isFirstPassBuffer(piece));
    const secondPassBuffers = this.buffers.filter(piece => this.decider.isSecondPassBuffer(piece));
    const bufferChoices = firstPassBuffers.length > 0 ? firstPassBuffers : (secondPassBuffers > 0 ? secondPassBuffers : this.buffers);
    const buffer = minBy(bufferChoices, piece => decider.bufferPriority(piece) || -Infinity);
    assert(decider.isBuffer(buffer), 'At least one buffer is needed.');
    return buffer;
  }

  algsWithVanillaParity(parity: Parity) {
    // If they want to do one other twist first, that can be done.
    const twists = this.group.twists
    if (twistsAllowed && twists.length === 1) {
      const twist = twists[0];
      if (decider.doTwistBeforeParity(parity, twist)) {
        const cycleBreak = this.group.cycleBreak(parity.firstPiece, parity.lastPiece, twist);
        const remainingGroup = this.group.solveCycle(cycleBreak);
        const bufferState = bufferState.withCycleBreak(cycleBreak);
        const parity = this.group.parity(parity.firstPiece, twist);
        const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algsWithParity(parity);
        return remainingTrace.prefixCycle(cycleBreak);
      }
    }
    const remainingGroup = this.group.solveParity(parity);
    const bufferState = bufferState.withParity(parity);
    const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algs();
    return remainingTrace.prefixParity(parityTwist);
  }

  algsWithParityTwist(parityTwist: ParityTwist) {
    // If they want to do one other twist first, that can be done.
    const twists = this.group.twists
    if (twistsAllowed && twists.length === 1) {
      const twist = twists[0];
      if (decider.doTwistBeforeParityTwist(parityTwist, twist)) {
        const cycleBreak = this.group.cycleBreak(parityTwist.firstPiece, parityTwist.lastPiece, twist);
        const remainingGroup = this.group.solveCycle(cycleBreak);
        const bufferState = bufferState.withCycleBreak(cycleBreak);
        const parity = this.group.parity(parity.firstPiece, twist);
        return remainingTrace.prefixCycle(cycleBreak);
      }
    }
    const bufferState = bufferState.withParityTwist(parityTwist);
    const remainingGroup = this.group.solveParityTwist(parityTwist);
    const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algs();
    return remainingTrace.prefixParityTwist(parityTwist);
  }

  algsWithParity(parity: Parity) {
    const otherPiece = parity.lastPiece;
    const parityTwistPieces = this.group.unorientedForType(parity.unorientedType.invert).filter(piece => this.decider.canParityTwist(buffer, otherPiece, piece));
    if (parityTwistPieces.length > 0) {
      const parityTwistPiece = minBy(parityTwistPieces, piece => this.decider.parityTwistPriority(buffer, otherPiece, piece));
      const parityTwist = this.group.parityTwist(buffer, otherPiece, parityTwistPiece);
      return algsWithParityTwist(buffer, parityTwist);
    } else {
      return algsWithVanillaParity(parity);
    }
  }

  algsWithDoubleSwap(buffer, otherPiece, cycleBreak, nextPiece) {
    const doubleSwap = this.group.doubleSwap(buffer, otherPiece, cycleBreak, nextPiece);
    const remainingGroup = this.group.solveDoubleSwap(doubleSwap);
    const bufferState = this.swapBufferState(cycleBreak, nextPiece);
    const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algs();
    return remainingTrace.prefixDoubleSwap(doubleSwap);
  }

  algsWithCycleBreak(buffer, otherPiece, cycleBreak) {
    const cycleBreak = this.group.cycleBreak(buffer, otherPiece, cycleBreak);
    const remainingGroup = this.group.solveCycle(cycleBreak);
    const bufferState = bufferState.withCycleBreak(cycleBreak);
    const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algs();
    return remainingTrace.prefixCycle(cycleBreak);
  }

  algsWithEvenCycle(cycle: EvenCycle) {
    const remainingGroup = this.group.solveCycle(evenPermutationCycle);
    const bufferState = this.bufferState.withCycle(evenPermutationCycle);
    const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algs();
    return remainingTrace.prefixCycle(evenPermutationCycle);
  }

  private twistAlgs(): AlgTrace {
    assert(!this.group.hasPermuted, 'Twists cannot permute');
    // TODO
  }

  algs(): AlgTrace {
    const buffer = this.nextBuffer();
    if (this.group.isSolved(buffer) && this.group.hasPermuted) {
      const cycleBreak = this.decider.nextCycleBreakOnFirstPiece(buffer);
      const nextPiece = this.group.cycle(cycleBreak).secondPiece;
      this.algsWithCycleBreak(buffer, cycleBreak, nextPiece);
    } else if (this.group.isPermuted(buffer)) {
      const cycle = this.group.cycle(buffer);
      if (cycle.length === 2) {
        const otherPiece = cycle.lastPiece;
        if (this.group.parityTime) {
          this.algsWithParity(parity);
        } else {
          const cycleBreak = this.decider.nextCycleBreakOnSecondPiece(buffer, otherPiece);
          const nextPiece = this.group.cycle(cycleBreak).secondPiece;
          if (this.decider.canChangeBuffer(bufferState) && this.decider.canDoubleSwap(buffer, otherPiece, cycleBreak, nextPiece)) {
            return this.algsWithDoubleSwap(buffer, otherPiece, cycleBreak, nextPiece);
          }
          return this.algsWithCycleBreak(buffer, otherPiece, cycleBreak);
        }
      } else {
        const evenPermutationCycle = cycle.evenPermutationPart();
        return this.algsWithEvenCycle(evenPermutationCycle);
      }
    }
  } else if (this.group.hasTwists) {
    return this.twistAlgs();
  } else {
    assert(this.group.isSolved, 'Nothing to do but not solved');
    return emptyAlgTrace();
  }
}

class AlgTrace {
}

// TODO: Potentially skip twisted buffers if you have another floating one.
class SolvingMethod {
  constructor(readonly piecePermutationDescription: PiecePermutationDescription,
              readonly piece: Piece[]) {
    assert(buffers >= 1, 'There has to be at least one buffer');
  }

  expectedAlgs(): number {
    const groups = this.piecePermutationDescription.groups();
    const directComputed = this.piecePermutationDescription.count;
    const groupSum = sum(groups.map(group => group.count()));
    assert(Math.round(directComputed) === Math.round(groupSum), `${directComputed} === ${groupSum} (direct computed vs group sum)`)
    return sum(groups.map(group => {
      const probability = group.count() / this.piecePermutationDescription.count;
      const algsForGroup = new SolveState(group, this.pieces).algs();
      return probability * algsForGroup;
    }));
  }

  importantGroup(group: PermutationGroup) {
    const probability = group.count() / this.piecePermutationDescription.count;
    return probability > 0.01;
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
