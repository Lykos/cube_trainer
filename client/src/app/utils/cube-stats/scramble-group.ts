import { ncr, factorial } from './combinatorics-utils';
import { none, Optional } from './optional';
import { Probabilistic } from './probabilistic';

// Returns an array of integers from `0` to `n`.
// e.g. `range(5) === [0, 1, 2, 3, 4, 5]`
function range(n: number): number[] {
  assert(n >= 0, 'n in range(n) has to be non-negative');
  return [...Array(n + 1).keys()];
}

class PieceDescription {
  readonly pieces: Piece[];
  constructor(readonly numPieces: number,
              readonly unorientedTypes: number) {
    assert(numPieces >= 2, 'There have to be at least 2 pieces');
    assert(unorientedTypes >= 0, 'The number of oriented types has to be non-negative');
    this.pieces = range(numPieces - 1).map(pieceId => { return {pieceId}; });
  }
}

export const CORNER = new PieceDescription(8, 2);
export const EDGE = new PieceDescription(12, 1);

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

// Represents one big group of similar scrambles, i.e.
// * same number of pieces solved
// * same number of pieces twisted or flipped
// * same number of pieces permuted
class BigScrambleGroup {
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

function sortPieces(pieces: Piece[]) {
  pieces.sort((a, b) => a.pieceId < b.pieceId);
}

class PartiallyFixedCycle {
  // Pieces sorted by their id, not necessarily in the order they appear in the cycle.
  readonly sortedPieces: Piece[];
  constructor(
    pieces: Piece[],
    readonly length: Optional<number>) {
    this.sortedPieces = sortPieces(pieces);
  }

  hasExactlyPieces(pieces: Piece[]) {
    return sortPieces(pieces) === sortedPieces;
  }
}

function scrambleGroupFromBigScrambleGroup(group: BigScrambleGroup): ScrambleGroup {
  assert(false);
}

type ScrambleGroupWithAnswer<X> = [ScrambleGroup, X];

export class ProbabilisticAnswer<X> {
  constructor(probabilisticGroupAndAnswer: Probabilistic<GroupWithAnswer<X>>) {}

  mapAnswer<Y>(f: (x: X) => Y): ProbabilisticAnswer<Y> {
    this.probabilisticGroupAndAnswer.map(groupAndAnswer => {
      [group, x] = groupAndAnswer;
      return [group, f(x)];
    });
  }

  flatMap<Y>(f: (group: ScrambleGroup, x: X) => ProbabilisticAnswer<Y>) {
    new ProbabilisticAnswer<Y>(this.probabilisticGroupAndAnswer.flatMap(f));
  }

  assertDeterministicAnswer(): X {
    return this.probabilisticGroupAndAnswer.assertDeterministic()[1];
  }
}

// Represents one group of similar scrambles, i.e.
// * same number of pieces solved
// * same number of pieces twisted or flipped
// * same number of pieces permuted
// * some pieces may have fixed equal positions or orientations.
export class ScrambleGroup {
  constructor(readonly solved: Piece[],
              readonly unoriented: Piece[][],
              readonly permuted: Piece[],
              readonly fixedUnorientedTypes: Optional<UnorietedType>[],
              readonly partiallyFixedCycles: PartiallyFixedCycle[]) {
    // fixedUnorientedTypes = unoriented.map(() => none);
  }

  get parityTime() {
    return this.permuted.length === 2;
  }

  nextPiece(buffer): ProbabilisticAnswer<Piece> {
    // TODO
    assert(false);
  }

  breakCycleFromUnpermuted(cycle: EvenCycle): ScrambleGroup {
    assert(cycle.isThreeCycle);
    assert(!this.isPermuted(cycle.firstThreeCyclePiece));
    // TODO
    assert(false);
    return this;
  }
  
  breakCycleFromSwap(cycle: EvenCycle): ScrambleGroup {
    assert(this.isPermuted(cycle.firstThreeCyclePiece));
    assert(this.isPermuted(cycle.secondThreeCyclePiece));
    const swappedPieces = [cycle.firstThreeCyclePiece, cycle.secondThreeCyclePiece];
    this.partiallyFixedCycles.find(cycle => cycle.hasExactlyPieces(swappedPieces));
    // TODO
    assert(false);
    return this;
  }

  solveDoubleSwap(doubleSwap: DoubleSwap): ScrambleGroup {
    // TODO
    assert(false);
    return this;
  }

  solveEvenCycle(evenCycle: EvenCycle): ScrambleGroup {
    // TODO
    assert(false);
    return this;
  }

  solveParity(parity: Parity): ScrambleGroup {
    assert(this.isPermuted(cycle.firstThreeCyclePiece));
    assert(this.isPermuted(cycle.secondThreeCyclePiece));
    const swappedPieces = [cycle.firstThreeCyclePiece, cycle.secondThreeCyclePiece];
    this.partiallyFixedCycles.find(cycle => cycle.hasExactlyPieces(swappedPieces));
    assert(false);
    return this
  }

  solveParityTwist(parityTwist: ParityTwist): ScrambleGroup {
    assert(this.isPermuted(cycle.firstThreeCyclePiece));
    assert(this.isPermuted(cycle.secondThreeCyclePiece));
    const swappedPieces = [cycle.firstThreeCyclePiece, cycle.secondThreeCyclePiece];
    this.partiallyFixedCycles.find(cycle => cycle.hasExactlyPieces(swappedPieces));
    // TODO
    assert(false);
    return this;
  }

  isSolved(piece: Piece) {
    return this.solved.includes(piece)
  }

  isUnoriented(piece: Piece) {
    return this.unoriented.some(unorientedForType => unorientedForType.includes(piece));
  }
  
  isPermuted(piece: Piece) {
    return this.permuted.includes(piece);
  }

  get hasPermuted() {
    return this.permuted.length > 0;
  }
  
  unorientedForInverseType(parity: Parity) {
    // TODO
    assert(false);
    return [];
  }
}
