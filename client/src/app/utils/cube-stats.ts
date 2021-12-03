import { some, none, Optional, orElseCall } from './optional';

interface Piece {
  id: number;
}

// Represents one group of similar permutations, i.e.
// * same number of pieces solved
// * same number of pieces twisted or flipped
// * same number of pieces permuted
class PermutationGroup {
  constructor(
    readonly description: PiecePermutationDescription,
    // Solved pieces.
    readonly solved: Piece[],
    // Only used for corners, edges and midges.
    // It's an array because there can be multiple types of unoriented.
    // (clockwise and counter-clockwise for corners)
    readonly unoriented: Piece[][],
    // Permuted pieces
    readonly permuted: Piece[]) {
    assert(description.pieces.length === this.solved.length + sum(this.unoriented.map(e => e.length)) + this.permuted.length, 'inconsistent number of pieces');
  }

  get orientationTypes() {
    return this.unoriented.length;
  }

  get pieces() {
    return this.description.pieces;
  }

  // Number of permutations in this group.
  get probability() {
    const solvedChoices = ncr(this.pieces.length, this.solved.length);
    let remainingPieces = this.pieces.length - this.solved.length;
    let unorientedChoices = 1;
    this.unoriented.forEach(unorientedForType => {
      unorientedChoices *= ncr(remainingPieces, unorientedForType.length);
      remainingPieces -= unorientedForType.length;
    });
    return solvedChoices * unorientedChoices / this.description.count;
  }
}

class ScrambleGroup {
  constructor(readonly solved: Piece[],
              readonly unoriented: Piece[][],
              readonly permuted: Piece[]) {}

  isSolved(piece: Piece) {
    return this.solved.includes(piece)
  }

  isUnoriented(piece: Piece) {
    return this.unoriented.some(unorientedForType => unorientedForType.includes(piece));
  }
  
  isPermuted(piece: Piece) {
    return this.permuted.includes(piece);
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
  readonly pieces: Piece[];
  constructor(readonly numPieces: number,
              readonly unorientedTypes: number) {
    assert(numPieces >= 2, 'There have to be at least 2 pieces');
    assert(unorientedTypes >= 0, 'The number of oriented types has to be non-negative');
    this.pieces = range(numPieces - 1).map(id => { return {id}; });
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
    // Every piece except the last has a choice for the orientation.
    const orientations = (this.unorientedTypes + 1) ** (this.pieces.length - 1);
    const permutations = factorial(this.pieceDescription.pieces.length);
    return orientations * permutations / divisor;
  }

  groups(): PermutationGroup[] {
    return subsets(this.pieces).flatMap(solved => this.groupsWithSolvedAndUnoriented(solved, []));
  }

  private groupsWithSolvedAndUnoriented(solved: Piece[], unoriented: Piece[][]): PermutationGroup[] {
    assert(unoriented.length <= this.unorientedTypes, 'unoriented.length <= this.unorientedTypes');
    const remainingPieces = this.pieces.filter(p => !solved.includes(p) && !unoriented.some(unorientedForType => unorientedForType.includes(p)));
    if (unoriented.length === this.unorientedTypes) {
      if (remainingPieces.length === 1 || remainingPieces.length === 2 && !this.allowOddPermutations) {
        // Parity. So it's impossible, so 0 possibilities.
        return [];
      }
      if (remainingPieces.length === 0 && sum(unoriented.map((unorientedForType, unorientedType) => unorientedForType.length * (unorientedType + 1))) % (unoriented.length + 1) != 0) {
        // Invalid twist. So it's impossible, so 0 possibilities. If we have remaining unsolved, the twist can be in that part.
        return [];
      }
      return [new PermutationGroup(this, solved, unoriented, remainingPieces)];
    }
    return subsets(remainingPieces).flatMap(
      unorientedForType => this.groupsWithSolvedAndUnoriented(solved, unoriented.concat([unorientedForType]))
    );
  }
}

function subsets<X>(xs: X[]): X[][] {
  let result: X[][] = [[]];
  for (let x of xs) {
    result = result.concat(result.map(ys => ys.concat([x])));
  }
  return result;
}

class BufferState {
  constructor(readonly previousBuffer?: Piece) {}
}

class ParityTwist {
  constructor(
    readonly buffer: Piece,
    readonly parityPiece: Piece,
    readonly unoriented: Piece) {}
}

class Parity {
  constructor(
    readonly buffer: Piece,
    readonly parityPiece: Piece) {}
}

class EvenCycle {
  constructor(
    readonly pieces: Piece[]) {
    assert(pieces.length % 2 === 1, 'uneven cycle');
  }
}

class DoubleSwap {
  constructor(readonly firstPiece: Piece,
              readonly secondPiece: Piece,
              readonly orientationType: number,
              readonly thirdPiece: Piece,
              readonly fourthPiece: Piece) {}
}

class Decider {
  nextCycleBreakOnSecondPiece(buffer: Piece, firstPiece: Piece, unsolvedPieces: Piece[]): Piece {
    return unsolvedPieces[0];
  }

  nextCycleBreakOnFirstPiece(buffer: Piece, unsolvedPieces: Piece[]): Piece {
    return unsolvedPieces[0];
  }

  canParityTwist(parityTwist: ParityTwist) {
    return false;
  }

  isBuffer(piece: Piece) {
    return true;
  }

  bufferPriority(piece: Piece) {
    return piece.id;
  }

  stayWithSolvedBuffer(piece: Piece) {
    return true;
  }

  canChangeBuffer(bufferState: BufferState) {
    return true;
  }

  get avoidUnorientedIfWeCanFloat() {
    return true;
  }
}

type ScrambleGroupWithAnswer<X> = [ScrambleGroup, X, number];

class ProbabilisticAnswer<X> {
  constructor(readonly answerPossibilities: ScrambleGroupWithAnswer<X>[]) {}

  mapAnswer<Y>(f: (x: X) => Y): ProbabilisticAnswer<Y> {
    return new ProbabilisticAnswer<Y>(this.answerPossibilities.map(
      (x: ScrambleGroupWithAnswer<X>) => {
        const [group, answer, probability] = x;
        return [group, f(answer), probability];
      }
    ));
  }

  flatMap<Y>(f: (group: ScrambleGroup, x: X) => ProbabilisticAnswer<Y>): ProbabilisticAnswer<Y> {
    return new ProbabilisticAnswer<Y>(this.answerPossibilities.flatMap(
      (x: ScrambleGroupWithAnswer<X>) => {
        const [group, answer, probability] = x;
        return f(group, answer).timesProbability(probability).answerPossibilities;
      }
    ));
  }

  timesProbability(probabilityFactor: number) {
    return new ProbabilisticAnswer<X>(this.answerPossibilities.map(
      (x: ScrambleGroupWithAnswer<X>) => {
        const [group, answer, probability] = x;
        return [group, answer, probability * probabilityFactor];
      }
    ));
  }
}

function certainAnswer<X>(group: ScrambleGroup, answer: X): ProbabilisticAnswer<X> {
  return new ProbabilisticAnswer([[group, answer, 1]]);
}

function first<X>(xs: X[]): Optional<X> {
  if (xs.length >= 1) {
    return some(xs[0]);
  } else {
    return none;
  }
}

class Solver {
  constructor(readonly decider: Decider, readonly pieces: Piece[]) {}

  get orderedBuffers() {
    return this.pieces.filter(piece => this.decider.isBuffer(piece)).sort((left, right) => this.decider.bufferPriority(right) - this.decider.bufferPriority(left));
  }

  get favoriteBuffer() {
    return this.orderedBuffers[0];
  }
  
  private nextBufferAvoidingSolved(bufferState: BufferState, group: ScrambleGroup): Piece {
    const unsolvedBuffer = first(this.orderedBuffers.filter(piece => !group.isSolved(piece)));
    return orElseCall(unsolvedBuffer, () => {
      const previousBuffer = bufferState.previousBuffer;
      if (previousBuffer && this.decider.stayWithSolvedBuffer(previousBuffer)) {
        return previousBuffer;
      } else {
        return this.favoriteBuffer;
      }
    });
  }

  private nextBufferAvoidingUnoriented(bufferState: BufferState, group: ScrambleGroup): Piece {
    const permutedBuffer = first(this.orderedBuffers.filter(buffer => group.isPermuted(buffer)));
    return orElseCall(permutedBuffer, () => this.nextBufferAvoidingSolved(bufferState, group));
  }

  private nextBuffer(bufferState: BufferState, group: ScrambleGroup): Piece {
    const previousBuffer = bufferState.previousBuffer;
    if (previousBuffer && !this.decider.canChangeBuffer(bufferState)) {
      return certainAnswer(group, previousBuffer);
    }
    if (this.decider.avoidUnorientedIfWeCanFloat) {
      return this.nextBufferAvoidingUnoriented(bufferState, group);
    } else {
      return this.nextBufferAvoidingSolved(bufferState, group);
    }
  }

  algsWithVanillaParity(parity: Parity) {
    // If they want to do one other twist first, that can be done.
    const unorienteds = this.group.unorienteds;
    if (unorienteds.length === 1) {
      const unoriented = unorienteds[0];
      if (decider.doUnorientedBeforeParity(parity, unoriented)) {
        const cycleBreak = new EvenCycle(parity.firstPiece, parity.lastPiece, unoriented);
        const remainingGroup = this.group.breakCycle(cycleBreak);
        const bufferState = bufferState.withCycleBreak(cycleBreak);
        const parity = this.group.parity(parity.firstPiece, unoriented);
        const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algsWithParity(parity);
        return remainingTrace.prefixCycle(cycleBreak);
      }
    }
    const remainingGroup = this.group.solveParity(parity);
    const bufferState = bufferState.withParity(parity);
    const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algs();
    return remainingTrace.prefixParity(parityUnoriented);
  }

  algsWithParityUnoriented(parityUnoriented: ParityUnoriented) {
    // If they want to do one other unoriented first, that can be done.
    const unoriented = this.group.unoriented;
    if (unorientedsAllowed && unorienteds.length === 1) {
      const unoriented = unorienteds[0];
      if (decider.doUnorientedBeforeParityUnoriented(parityUnoriented, unoriented)) {
        const cycleBreak = new EvenCycle(parityUnoriented.firstPiece, parityUnoriented.lastPiece, unoriented);
        const remainingGroup = this.group.breakCycle(cycleBreak);
        const bufferState = bufferState.withCycleBreak(cycleBreak);
        const parity = new Parity(parity.firstPiece, unoriented);
        const remainingTrace: algsWithParity(parity);
        return remainingTrace.prefixCycle(cycleBreak);
      }
    }
    const bufferState = bufferState.withParityUnoriented(parityUnoriented);
    const remainingGroup = this.group.solveParityUnoriented(parityUnoriented);
    const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algs();
    return remainingTrace.prefixParityUnoriented(parityUnoriented);
  }

  algsWithParity(parity: Parity) {
    const otherPiece = parity.lastPiece;
    const parityUnorientedPieces = this.group.unorientedForType(parity.unorientedType.invert).filter(piece => this.decider.canParityUnoriented(buffer, otherPiece, piece));
    if (parityUnorientedPieces.length > 0) {
      const parityUnorientedPiece = minBy(parityUnorientedPieces, piece => this.decider.parityUnorientedPriority(buffer, otherPiece, piece));
      const parityUnoriented = new ParityUnoriented(buffer, otherPiece, parityUnorientedPiece);
      return algsWithParityUnoriented(buffer, parityUnoriented);
    } else {
      return algsWithVanillaParity(parity);
    }
  }

  algsWithDoubleSwap(doubleSwap: DoubleSwap) {
    const remainingGroup = this.group.solveDoubleSwap(doubleSwap);
    const bufferState = this.swapBufferState(cycleBreak, nextPiece);
    const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algs();
    return remainingTrace.prefixDoubleSwap(doubleSwap);
  }

  algsWithCycleBreak(cycleBreak: EvenCycle) {
    const remainingGroup = this.group.breakCycle(cycleBreak);
    const bufferState = bufferState.withCycleBreak(cycleBreak);
    const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algs();
    return remainingTrace.prefixCycle(cycleBreak);
  }

  algsWithEvenCycle(cycle: EvenCycle) {
    const remainingGroup = this.group.solveCycle(cycle);
    const bufferState = this.bufferState.withCycle(cycle);
    const remainingTrace = new SolveState(this.decider, this.pieces, bufferState, remainingGroup).algs();
    return remainingTrace.prefixCycle(cycle);
  }

  private unorientedAlgs(group: ScrambleGroup): AlgTrace {
    assert(!group.hasPermuted, 'Unorienteds cannot permute');
    // TODO
  }

  private algsWithBufferAndCycleLength(bufferState, group, buffer, cycleLength) {
    if (cycleLength === 2) {
      if (this.group.parityTime) {
        const otherPiece = assertDeterministic(group.nextPiece(buffer));
        this.algsWithParity(group, new Parity(buffer, otherPiece));
      } else {
        const cycleBreak = this.decider.nextCycleBreakOnSecondPiece(buffer, otherPiece, this.group.permutedPieces);
        this.group.nextPiece(cycleBreak).flatMap((group, nextPiece) => {
          const doubleSwap = new DoubleSwap(buffer, otherPiece, cycleBreak, nextPiece);
          if (this.decider.canChangeBuffer(bufferState) && this.decider.canDoubleSwap(doubleSwap)) {
            return this.algsWithDoubleSwap(bufferState, group, doubleSwap);
          }
          return this.algsWithCycleBreak(bufferState, group, new EvenCycle(buffer, otherPiece, cycleBreak));
        });
      }
    } else {
      group.evenPermutationCyclePart(buffer).flatMap((group, evenPermutationCycle) => {
        return this.algsWithEvenCycle(evenPermutationCycle);
      });
    }
  }
  
  private algs(bufferState: BufferState, group: ScrambleGroup): ProbabilisticAnswer<AlgTrace> {
    const buffer = this.nextBuffer();
    if (this.group.isSolved(buffer) && this.group.hasPermuted) {
      const cycleBreakPiece = this.decider.nextCycleBreakOnFirstPiece(buffer, this.group.permutedPieces);
      return this.group.nextPiece(cycleBreakPiece).flatMap((group, nextPiece) => {
        return this.algsWithCycleBreak(bufferState, group, new EvenCycle(buffer, cycleBreakPiece, nextPiece));
      });
    } else if (this.group.isPermuted(buffer)) {
      this.group.cycleLength(buffer).flatMap((group, cycleLength) => {
        return this.algsWithBufferAndCycleLength(bufferState, group, buffer, cycleLength);
      });
    }
  } else if (this.group.hasUnorienteds) {
    return this.unorientedAlgs();
  } else {
    assert(this.group.isSolved, 'Nothing to do but not solved');
    return emptyAlgTrace();
  }
}

class AlgTrace {
}

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
