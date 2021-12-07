import { ncr } from './combinatorics-utils';
import { Optional, ifPresent, hasValue, mapOptional, orElseCall, orElse, forceValue, flatMapOptional, orElseTryCall, some, none } from '../optional';
import { assert, assertEqual } from '../assert';
import { Piece } from './piece';
import { ParityTwist, Parity, ThreeCycle, EvenCycle, DoubleSwap } from './alg';
import { contains, findIndex, count, sum, indexOf, combination } from '../utils';
import { Probabilistic, ProbabilisticPossibility, deterministic } from './probabilistic';
import { BigScrambleGroup } from './big-scramble-group';

type ScrambleGroupWithAnswer<X> = [ScrambleGroup, X];

type PossibleScrambleGroupWithAnswer<X> = ProbabilisticPossibility<ScrambleGroupWithAnswer<X>>;

export class ProbabilisticAnswer<X> {
  constructor(private readonly probabilisticGroupAndAnswer: Probabilistic<ScrambleGroupWithAnswer<X>>) {}

  removeGroups(): Probabilistic<X> {
    return this.probabilisticGroupAndAnswer.map(groupWithAnswer => {
      const [_, answer] = groupWithAnswer;
      return answer;
    });
  }

  mapAnswer<Y>(f: (x: X) => Y): ProbabilisticAnswer<Y> {
    return new ProbabilisticAnswer<Y>(this.probabilisticGroupAndAnswer.map(groupAndAnswer => {
      const [group, x] = groupAndAnswer;
      return [group, f(x)];
    }));
  }

  flatMap<Y>(f: (group: ScrambleGroup, x: X) => ProbabilisticAnswer<Y>): ProbabilisticAnswer<Y> {
    return new ProbabilisticAnswer<Y>(this.probabilisticGroupAndAnswer.flatMap(groupAndAnswer => {
      const [group, x] = groupAndAnswer;
      return f(group, x).probabilisticGroupAndAnswer;
    }));
  }

  assertDeterministicAnswer(): X {
    return this.probabilisticGroupAndAnswer.assertDeterministic()[1];
  }
}

export function deterministicAnswer<X>(group: ScrambleGroup, x: X) {
  return new ProbabilisticAnswer<X>(deterministic([group, x]));
}

export function probabilisticAnswer<X>(groupsWithAnswers: PossibleScrambleGroupWithAnswer<X>[]): ProbabilisticAnswer<X> {
  return new ProbabilisticAnswer<X>(new Probabilistic<ScrambleGroupWithAnswer<X>>(groupsWithAnswers));
}

function sortPieces(pieces: Piece[]) {
  return pieces.sort((a, b) => b.pieceId - a.pieceId);
}

class PartiallyFixedCycle {
  // Pieces sorted by their id, not necessarily in the order they appear in the cycle.
  readonly sortedFixedPieces: Piece[];

  constructor(
    fixedPieces: Piece[],
    readonly definingPiece: Optional<Piece>,
    readonly pieceAfter: Optional<Piece>,
    readonly pieceBefore: Optional<Piece>,
    readonly orientedType: Optional<PartiallyFixedOrientedType>,
    readonly length: number) {
    assert(this.length >= 2);
    assert(fixedPieces.length <= this.length);
    this.sortedFixedPieces = sortPieces(fixedPieces);
    ifPresent(this.definingPiece, piece => assert(this.containsPiece(piece)));
    ifPresent(this.pieceAfter, piece => assert(this.containsPiece(piece)));
    ifPresent(this.pieceBefore, piece => assert(this.containsPiece(piece)));
    if (length === 2) {
      ifPresent(this.pieceAfter, pieceAfter => {
        ifPresent(this.pieceBefore, pieceBefore => assert(pieceBefore === pieceAfter));
      });
    }
  }

  get isCompletelyUnfixed() {
    return this.sortedFixedPieces.length === 0;
  }

  get isCompletelyFixed() {
    return this.sortedFixedPieces.length === this.length;
  }

  get unfixedLength() {
    return this.length - this.sortedFixedPieces.length;
  }

  hasExactlyFixedPieces(pieces: Piece[]) {
    return pieces.every(p => this.containsPiece(p)) && pieces.length === this.length;
  }

  nextPiece(piece: Piece): Optional<Piece> {
    assert(this.containsPiece(piece));
    return flatMapOptional(this.definingPiece, definingPiece => {
      assert(definingPiece === piece);
      return orElseTryCall(this.pieceAfter, () => this.length === 2 ? this.pieceBefore : none);
    });
  }

  previousPiece(piece: Piece): Optional<Piece> {
    assert(this.containsPiece(piece));
    return flatMapOptional(this.definingPiece, definingPiece => {
      assert(definingPiece === piece);
      return orElseTryCall(this.pieceBefore, () => this.length === 2 ? this.pieceAfter : none);
    });
  }

  private definingPieceCompatible(piece: Piece) {
    assert(this.containsPiece(piece));
    return orElse(mapOptional(this.definingPiece, definingPiece => definingPiece === piece), true);
  }

  withIncrementedLength(): PartiallyFixedCycle {
    return new PartiallyFixedCycle(this.sortedFixedPieces, this.definingPiece, this.pieceAfter, this.pieceBefore, this.orientedType, this.length + 1);
  }

  withDecrementedLength(): PartiallyFixedCycle {
    assert(!this.isCompletelyFixed);
    return new PartiallyFixedCycle(this.sortedFixedPieces, this.definingPiece, this.pieceAfter, this.pieceBefore, this.orientedType, this.length - 1);
  }

  withoutPieceAfter(piece: Piece): PartiallyFixedCycle {
    assert(this.containsPiece(piece));
    assertEqual(forceValue(this.pieceAfter), piece);
    const pieces = this.sortedFixedPieces.filter(p => p !== piece);
    return new PartiallyFixedCycle(pieces, this.definingPiece, none, this.definingPiece, this.orientedType, this.length);
  }

  // This is used for cycle breaks.
  // We put the given pieceas the defining piece and put the previous defining piece as the last piece.
  withDefiningPiece(piece: Piece): PartiallyFixedCycle {
    assert(!hasValue(this.pieceBefore));
    return new PartiallyFixedCycle(this.sortedFixedPieces.concat([piece]), some(piece), this.pieceAfter, this.definingPiece, this.orientedType, this.length);
  }

  withPieces(pieces: Piece[]) {
    assert(pieces.length + this.sortedFixedPieces.length <= this.length, 'too many additional pieces');
    assert(pieces.every(piece => !this.containsPiece(piece)), 'pieces already in the cycle');
    return new PartiallyFixedCycle(this.sortedFixedPieces.concat(pieces), this.definingPiece, this.pieceAfter, this.pieceBefore, this.orientedType, this.length);
  }

  withOrientedType(orientedType: PartiallyFixedOrientedType) {
    assert(!hasValue(this.orientedType));
    return new PartiallyFixedCycle(this.sortedFixedPieces, this.definingPiece, this.pieceAfter, this.pieceBefore, some(orientedType), this.length);
  }

  withPieceAdjacent(piece: Piece, definingPiece: Piece, adjacentType: AdjacentType) {
    assert(this.containsPiece(piece));
    assert(this.containsPiece(definingPiece));
    assert(!hasValue(adjacentType === AdjacentType.NEXT ? this.pieceAfter : this.pieceBefore), 'tried to fix adjacent piece a second time');
    assert(this.definingPieceCompatible(definingPiece));
    if (adjacentType === AdjacentType.NEXT) {
      return new PartiallyFixedCycle(this.sortedFixedPieces, some(definingPiece), some(piece), this.pieceBefore, this.orientedType, this.length);
    } else {
      return new PartiallyFixedCycle(this.sortedFixedPieces, some(definingPiece), this.pieceAfter, some(piece), this.orientedType, this.length);
    }
  }

  containsPiece(piece: Piece): boolean {
    return contains(this.sortedFixedPieces, piece);
  }
}

function emptyPartiallyFixedCycle(length: number): PartiallyFixedCycle {
  return new PartiallyFixedCycle([], none, none, none, none, length);
}

enum AdjacentType {
  NEXT, PREVIOUS
}

// Represents an orientation type like CW or CCW.
// Except for the special value -1, it may or may not be known which of these maps to CW and which to CCW.
export class PartiallyFixedOrientedType {
  constructor(
    readonly isSolved: boolean,
    readonly index: number) {}
}

const solvedOrientedType = new PartiallyFixedOrientedType(true, -1);

function unfixedOrientedType(index: number) {
  return new PartiallyFixedOrientedType(false, index);
}

// Represents one group of similar scrambles, i.e.
// * same number of pieces solved
// * same number of pieces twisted or flipped
// * same number of pieces permuted
// * some pieces may have fixed equal positions or orientations.
export class ScrambleGroup {
  readonly unorientedTypes: number;
  readonly unfixedPieces: Piece[];

  constructor(readonly solved: Piece[],
              readonly unorientedByType: Piece[][],
              readonly permuted: Piece[],
              private readonly partiallyFixedCycles: PartiallyFixedCycle[]) {
    const totalCycleLength = sum(this.partiallyFixedCycles.map(cycle => cycle.length));
    assert(totalCycleLength === this.permuted.length, `cycles do not cover permuted pieces (${totalCycleLength} vs ${this.permuted.length})`);
    this.unorientedTypes = count(this.unorientedByType, unorientedForType => unorientedForType.length > 0);
    for (let cycle of this.partiallyFixedCycles) {
      assert(cycle.sortedFixedPieces.every(p => this.isPermuted(p)));
    }
    this.unfixedPieces = permuted.filter(piece => !partiallyFixedCycles.some(cycle => cycle.containsPiece(piece)));
  }

  get unoriented(): Piece[] {
    return this.unorientedByType.flat(1);
  }

  get parityTime() {
    return this.permuted.length === 2;
  }

  cycleLength(piece: Piece): ProbabilisticAnswer<number> {
    assert(this.isPermuted(piece));
    return this.cycleIndex(piece).mapAnswer(cycleIndex => {
      const cycle = this.partiallyFixedCycles[cycleIndex];
      return cycle.length;
    });
  }
  
  nextPiece(piece: Piece): ProbabilisticAnswer<Piece> {
    assert(this.isPermuted(piece));
    return this.cycleIndex(piece).flatMap((group, index) => {
      return group.adjacentPieceWithCycleIndex(piece, index, AdjacentType.NEXT);
    });
  }

  lastPiece(piece: Piece): ProbabilisticAnswer<Piece> {
    assert(this.isPermuted(piece));
    return this.cycleIndex(piece).flatMap((group, index) => {
      return group.adjacentPieceWithCycleIndex(piece, index, AdjacentType.PREVIOUS);
    });
  }

  private adjacentPieceWithCycleIndex(piece: Piece, cycleIndex: number, adjacentType: AdjacentType) {
    const maybeNextPiece = this.partiallyFixedCycles[cycleIndex].nextPiece(piece);
    return this.deterministicOrElseProbabilistic(
      maybeNextPiece,
      () => {
        const cycle = this.partiallyFixedCycles[cycleIndex];
        const probabilityToUseThisFixedPiece = 1 / (cycle.length - 1);
        const fromSameCycle: PossibleScrambleGroupWithAnswer<Piece>[] = cycle.sortedFixedPieces.flatMap(
          potentialNextPiece => {
            if (potentialNextPiece === piece) {
              return [];
            }
            const groupWithAnswer: ScrambleGroupWithAnswer<Piece> =
              [this.withPieceInCycleAdjacent(potentialNextPiece, cycleIndex, piece, adjacentType), potentialNextPiece];
            return [[groupWithAnswer, probabilityToUseThisFixedPiece]];
          }
        );
        const slotsRemaining = cycle.length - cycle.sortedFixedPieces.length;
        const probabilityToUseAnyUnfixedPiece = slotsRemaining / (cycle.length - 1);
        const probabilityToUseThisUnfixedPiece = probabilityToUseAnyUnfixedPiece / this.unfixedPieces.length;
        const fromUnfixed: PossibleScrambleGroupWithAnswer<Piece>[] = slotsRemaining === 0 ? [] : this.unfixedPieces.map(
          potentialNextPiece => {
            const groupWithAnswer: ScrambleGroupWithAnswer<Piece> =
              [this.withPieceInCycle(potentialNextPiece, cycleIndex).withPieceInCycleAdjacent(potentialNextPiece, cycleIndex, piece, adjacentType), potentialNextPiece];
            return [groupWithAnswer, probabilityToUseThisUnfixedPiece]
          }
        );
        return probabilisticAnswer<Piece>(fromSameCycle.concat(fromUnfixed));
      });
  }

  unsortedPiecesInCycle(piece: Piece): ProbabilisticAnswer<Piece[]> {
    assert(this.isPermuted(piece));
    return this.cycleIndex(piece).flatMap((group, index) => {
      return group.unsortedPiecesInCycleWithIndex(piece, index);
    });
  }
  
  evenPermutationCyclePart(piece: Piece): ProbabilisticAnswer<Piece[]> {
    assert(this.isPermuted(piece));
    return this.cycleIndex(piece).flatMap((group, index) => {
      return group.unsortedPiecesInCycleWithIndex(piece, index);
    });
  }

  evenPermutationCyclePartWithIndex(piece: Piece, cycleIndex: number): ProbabilisticAnswer<Piece[]> {
    const cycle = this.partiallyFixedCycles[cycleIndex];
    assert(cycle.length % 2 === 0);
    return this.unsortedPiecesInCycle(piece).flatMap((group, unsortedPieces) => {
      return group.evenPermutationCyclePartWithUnsortedPieces(piece, unsortedPieces);
    });
  }

  evenPermutationCyclePartWithUnsortedPieces(piece: Piece, unsortedPieces: Piece[]): ProbabilisticAnswer<Piece[]> {
    return this.lastPiece(piece).flatMap((group, lastPiece) => {
      return group.evenPermutationCyclePartWithUnsortedPiecesAndLastPiece(piece, unsortedPieces, lastPiece);
    });
  }

  evenPermutationCyclePartWithUnsortedPiecesAndLastPiece(piece: Piece, unsortedPieces: Piece[], lastPiece: Piece): ProbabilisticAnswer<Piece[]> {
    assert(piece !== lastPiece);
    const index = forceValue(indexOf(unsortedPieces, lastPiece));
    const pieces = unsortedPieces.slice(0, index).concat(unsortedPieces.slice(index + 1));
    return deterministicAnswer(this, pieces);
  }
  
  private unsortedPiecesInCycleWithIndex(piece: Piece, cycleIndex: number): ProbabilisticAnswer<Piece[]> {
    const cycle = this.partiallyFixedCycles[cycleIndex];
    const slotsRemaining = cycle.length - cycle.sortedFixedPieces.length;
    if (slotsRemaining === 0) {
      return deterministicAnswer(this, cycle.sortedFixedPieces);
    }
    const probability = ncr(this.unfixedPieces.length, slotsRemaining);
    return probabilisticAnswer(combination(this.unfixedPieces, slotsRemaining).map(
      pieces => {
        const group = this.withPiecesInCycle(pieces, cycleIndex);
        const allCyclePieces = group.partiallyFixedCycles[cycleIndex].sortedFixedPieces;
        const groupWithAnswer: ScrambleGroupWithAnswer<Piece[]> = [group, allCyclePieces];
        return [groupWithAnswer, probability]
      }
    ));
  }
  
  deterministicOrElseProbabilistic<X>(
    maybeDeterministicAnswer: Optional<X>,
    computeProbabilisticAnswer: () => ProbabilisticAnswer<X>): ProbabilisticAnswer<X> {
    return orElseCall(
      mapOptional(maybeDeterministicAnswer, answer => deterministicAnswer(this, answer)),
      computeProbabilisticAnswer);
  }

  // Returns relevant cycles where a next element could end up in with their weights.
  // If there are multiple cycles that have no elements fixed yet, we treat them as equal
  // and only consider one of them relevant, but we give the weight sum of all of them to
  // that cycle.
  private relevantCyclesWithWeights(): [number, number][] {
    const result: [number, number][] = [];
    let lastNCompletelyUnfixed = 0;
    let lastCycleLength = 0;
    for (let index = this.partiallyFixedCycles.length - 1; index >= 0; --index) {
      const cycle = this.partiallyFixedCycles[index]
      if (!cycle.isCompletelyUnfixed || cycle.length !== lastCycleLength) {
        if (lastNCompletelyUnfixed > 0) {
          result.push([index + 1, lastCycleLength * lastNCompletelyUnfixed]);
          lastNCompletelyUnfixed = 0;
        }
      }
      if (cycle.isCompletelyUnfixed) {
        ++lastNCompletelyUnfixed;
      } else if (!cycle.isCompletelyFixed) {
        result.push([index, cycle.unfixedLength]);
      }
      lastCycleLength = cycle.length;
    }
    if (lastNCompletelyUnfixed > 0) {
      result.push([0, lastCycleLength * lastNCompletelyUnfixed]);
    }
    assertEqual(sum(result.map(x => x[1])), this.unfixedPieces.length);
    return result;
  }
  
  private cycleIndex(piece: Piece): ProbabilisticAnswer<number> {
    assert(this.isPermuted(piece));
    const maybeIndex = findIndex(this.partiallyFixedCycles, cycle => cycle.containsPiece(piece));
    return this.deterministicOrElseProbabilistic(
      maybeIndex,
      () => {
        return probabilisticAnswer<number>(this.relevantCyclesWithWeights().map(cycleIndexWithWeight => {
          const [cycleIndex, cycleWeight] = cycleIndexWithWeight;
          const groupWithAnswer: ScrambleGroupWithAnswer<number> = [this.withPieceInCycle(piece, cycleIndex), cycleIndex];
          const probability = cycleWeight / this.unfixedPieces.length;
          return [groupWithAnswer, probability];
        }));
      });
  }

  private withChangedCycle(cycleIndex: number, cycle: PartiallyFixedCycle) {
    assert(cycle.length === this.partiallyFixedCycles[cycleIndex].length);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat([cycle]).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(this.solved, this.unorientedByType, this.permuted, partiallyFixedCycles);
  }

  private withPieceInCycle(piece: Piece, cycleIndex: number) {
    return this.withPiecesInCycle([piece], cycleIndex);
  }

  private withPiecesInCycle(pieces: Piece[], cycleIndex: number) {
    assert(pieces.every(piece => this.isPermuted(piece)));
    assert(pieces.every(piece => contains(this.unfixedPieces, piece)));
    const cycle = this.partiallyFixedCycles[cycleIndex];
    const changedCycle = cycle.withPieces(pieces);
    return this.withChangedCycle(cycleIndex, changedCycle);
  }

  private withPieceInCycleAdjacent(piece: Piece, cycleIndex: number, otherPiece: Piece, adjacentType: AdjacentType) {
    assert(this.isPermuted(piece));
    assert(this.isPermuted(otherPiece));
    const cycle = this.partiallyFixedCycles[cycleIndex];
    assert(cycle.containsPiece(piece));
    const changedCycle = cycle.withPieceAdjacent(piece, otherPiece, adjacentType);
    return this.withChangedCycle(cycleIndex, changedCycle);
  }

  breakCycleFromUnpermuted(cycle: ThreeCycle): ScrambleGroup {
    assert(!this.isPermuted(cycle.firstPiece));
    assert(this.isPermuted(cycle.secondPiece));
    assert(this.isPermuted(cycle.thirdPiece));
    const brokenCycleIndex = forceValue(findIndex(this.partiallyFixedCycles, c => c.containsPiece(cycle.secondPiece)));
    const brokenCycle = this.partiallyFixedCycles[brokenCycleIndex].withoutPieceAfter(cycle.thirdPiece).withDecrementedLength().withDefiningPiece(cycle.firstPiece);
    const solved = this.solved.filter(p => p !== cycle.firstPiece).concat([cycle.thirdPiece]);
    const unorientedByType = this.unorientedByTypeWithoutPiece(this.unorientedByType, cycle.firstPiece);
    const permuted = this.permuted.filter(piece => piece !== cycle.secondPiece).concat([cycle.firstPiece]);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, brokenCycleIndex).concat([brokenCycle]).concat(this.partiallyFixedCycles.slice(brokenCycleIndex + 1));
    return new ScrambleGroup(solved, unorientedByType, permuted, partiallyFixedCycles);
  }
  
  breakCycleFromSwap(cycle: ThreeCycle): ScrambleGroup {
    assert(this.isPermuted(cycle.firstPiece));
    assert(this.isPermuted(cycle.secondPiece));
    assert(this.isPermuted(cycle.thirdPiece));
    const swappedPieces = [cycle.firstPiece, cycle.secondPiece];
    const solvedCycleIndex = forceValue(findIndex(this.partiallyFixedCycles, c => c.hasExactlyFixedPieces(swappedPieces)));
    const brokenCycleIndex = forceValue(findIndex(this.partiallyFixedCycles, c => c.containsPiece(cycle.thirdPiece)));
    const brokenCycle = this.partiallyFixedCycles[brokenCycleIndex].withIncrementedLength().withDefiningPiece(cycle.firstPiece);
    const solved = this.solved.concat([cycle.secondPiece]);
    const permuted = this.permuted.filter(piece => piece !== cycle.secondPiece);
    const partiallyFixedCycles = this.partiallyFixedCycles.filter((_, index) => index !== solvedCycleIndex && index !== brokenCycleIndex).concat([brokenCycle]);
    const sortedPartiallyFixedCycles = partiallyFixedCycles.sort((a, b) => (b.length - a.length) * 3 + ((b.isCompletelyUnfixed ? 1 : 0) - (a.isCompletelyUnfixed ? 1 : 0)));
    return new ScrambleGroup(solved, this.unorientedByType, permuted, sortedPartiallyFixedCycles);
  }

  partiallySolveDoubleSwap(doubleSwap: DoubleSwap): ScrambleGroup {
    assert(this.isPermuted(doubleSwap.firstPiece));
    assert(this.isPermuted(doubleSwap.secondPiece));
    assert(this.isPermuted(doubleSwap.thirdPiece));
    assert(this.isPermuted(doubleSwap.fourthPiece));
    const firstSwap = new Parity(doubleSwap.firstPiece, doubleSwap.secondPiece);
    const secondSwap = new Parity(doubleSwap.firstPiece, doubleSwap.secondPiece);
    return this.solveParity(firstSwap, solvedOrientedType).partiallySolveParity(secondSwap);
  }

  solveDoubleSwap(doubleSwap: DoubleSwap, orientedType: PartiallyFixedOrientedType): ScrambleGroup {
    assert(this.isPermuted(doubleSwap.firstPiece));
    assert(this.isPermuted(doubleSwap.secondPiece));
    assert(this.isPermuted(doubleSwap.thirdPiece));
    assert(this.isPermuted(doubleSwap.fourthPiece));
    const firstSwap = new Parity(doubleSwap.firstPiece, doubleSwap.secondPiece);
    const secondSwap = new Parity(doubleSwap.firstPiece, doubleSwap.secondPiece);
    return this.solveParity(firstSwap, solvedOrientedType).solveParity(secondSwap, orientedType);
  }

  solvePartialEvenCycle(evenCycle: EvenCycle): ScrambleGroup {
    assert(evenCycle.pieces.every(piece => this.isPermuted(piece)));
    const solvedPieces = evenCycle.pieces.slice(1, -1);
    const solved = this.solved.concat(solvedPieces);
    const permuted = this.permuted.filter(piece => !contains(solvedPieces, piece));
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasExactlyFixedPieces(evenCycle.pieces)));
    const cycle = this.partiallyFixedCycles[cycleIndex];
    const firstUnsolvedPiece = evenCycle.pieces[0];
    const secondUnsolvedPiece = evenCycle.pieces[evenCycle.pieces.length - 1];
    const changedCycle = new PartiallyFixedCycle([firstUnsolvedPiece, secondUnsolvedPiece], some(firstUnsolvedPiece), none, none, cycle.orientedType, 2);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat([changedCycle]).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(solved, this.unorientedByType, permuted, partiallyFixedCycles);
  }

  unorientedByTypeWithPiece(orientedType: PartiallyFixedOrientedType, piece: Piece) {
    if (orientedType.isSolved) {
      return this.unorientedByType;
    }
    return this.unorientedByType.map(
      (unorientedForType, i) => i === orientedType.index ? unorientedForType.concat([piece]) : unorientedForType);
  }

  unorientedByTypeWithoutPiece(unorientedByType: Piece[][], piece: Piece): Piece[][] {
    return unorientedByType.map(unorientedForType => {
      const maybeWithoutPiece = mapOptional(
        indexOf(unorientedForType, piece),
        index => unorientedForType.slice(0, index).concat(unorientedForType.slice(index + 1)));
      return orElse(maybeWithoutPiece, unorientedForType);
    });
  }

  solveEvenCycle(evenCycle: EvenCycle, orientedType: PartiallyFixedOrientedType): ScrambleGroup {
    assert(evenCycle.pieces.every(piece => this.isPermuted(piece)));
    const newSolved = orientedType.isSolved ? evenCycle.pieces : evenCycle.pieces.slice(1);
    const solved = this.solved.concat(newSolved);
    const unorientedByType = this.unorientedByTypeWithPiece(orientedType, evenCycle.pieces[0]);
    const permuted = this.permuted.filter(piece => !contains(evenCycle.pieces, piece));
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasExactlyFixedPieces(evenCycle.pieces)));
    assertEqual(forceValue(this.partiallyFixedCycles[cycleIndex].orientedType), orientedType);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(solved, unorientedByType, permuted, partiallyFixedCycles);
  }

  partiallySolveParity(parity: Parity): ScrambleGroup {
    assert(this.isPermuted(parity.firstPiece));
    assert(this.isPermuted(parity.lastPiece));
    const solved = this.solved.concat([parity.lastPiece]);
    const permuted = this.permuted.filter(piece => piece !== parity.lastPiece);
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasExactlyFixedPieces(parity.pieces)));
    const cycle = this.partiallyFixedCycles[cycleIndex].withoutPieceAfter(parity.lastPiece).withDecrementedLength();
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat([cycle]).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(solved, this.unorientedByType, permuted, partiallyFixedCycles);
  }

  solveParity(parity: Parity, orientedType: PartiallyFixedOrientedType): ScrambleGroup {
    assert(this.isPermuted(parity.firstPiece));
    assert(this.isPermuted(parity.lastPiece));
    const newSolved = orientedType.isSolved ? parity.pieces : [parity.lastPiece];
    const solved = this.solved.concat(newSolved);
    const unorientedByType = this.unorientedByTypeWithPiece(orientedType, parity.firstPiece);
    const permuted = this.permuted.filter(piece => piece !== parity.firstPiece && piece !== parity.lastPiece);
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasExactlyFixedPieces(parity.pieces)));
    assertEqual(forceValue(this.partiallyFixedCycles[cycleIndex].orientedType), orientedType);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(solved, unorientedByType, permuted, partiallyFixedCycles);
  }

  solveParityTwist(parityTwist: ParityTwist, orientedType: PartiallyFixedOrientedType): ScrambleGroup {
    assert(this.isPermuted(parityTwist.firstPiece));
    assert(this.isPermuted(parityTwist.lastPiece));
    assert(this.isUnoriented(parityTwist.unoriented));
    const newSolved = orientedType.isSolved ? parityTwist.pieces : [parityTwist.lastPiece, parityTwist.unoriented];
    const solved = this.solved.concat(newSolved);
    const unorientedByTypeWithBuffer = this.unorientedByTypeWithPiece(orientedType, parityTwist.firstPiece);
    const unorientedByType = this.unorientedByTypeWithoutPiece(unorientedByTypeWithBuffer, parityTwist.unoriented);
    const permuted = this.permuted.filter(piece => piece !== parityTwist.firstPiece && piece !== parityTwist.lastPiece);
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasExactlyFixedPieces(parityTwist.swappedPieces)));
    assertEqual(forceValue(this.partiallyFixedCycles[cycleIndex].orientedType), orientedType);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(solved, unorientedByType, permuted, partiallyFixedCycles);
  }

  isSolved(piece: Piece) {
    return this.solved.includes(piece)
  }

  isUnoriented(piece: Piece) {
    return this.unorientedByType.some(unorientedForType => unorientedForType.includes(piece));
  }
  
  isPermuted(piece: Piece) {
    return this.permuted.includes(piece);
  }

  get hasPermuted() {
    return this.permuted.length > 0;
  }
  
  get hasUnoriented() {
    return this.unoriented.length > 0;
  }

  get orientedTypes(): PartiallyFixedOrientedType[] {
    return [solvedOrientedType].concat(this.unorientedByType.map((_, index) => unfixedOrientedType(index)));
  }

  orientedTypeForPieces(pieces: Piece[]): ProbabilisticAnswer<PartiallyFixedOrientedType> {
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasExactlyFixedPieces(pieces)));
    const maybeOrientedType = this.partiallyFixedCycles[cycleIndex].orientedType;
    return this.deterministicOrElseProbabilistic(
      maybeOrientedType,
      () => {
        const cycle = this.partiallyFixedCycles[cycleIndex];
        if (this.partiallyFixedCycles.length === 1) {
          const unorientedSum = sum(this.unorientedByType.map((unorientedForType, unorientedType) => unorientedForType.length * (unorientedType + 1))) % (this.unorientedByType.length + 1);
          const orientedIndex = unorientedSum === 0 ? 0 : this.unorientedByType.length - unorientedSum;
          const orientedType = this.orientedTypes[orientedIndex];
          const group = this.withChangedCycle(cycleIndex, cycle.withOrientedType(orientedType));
          return deterministicAnswer<PartiallyFixedOrientedType>(group, orientedType);
        } else {
          return probabilisticAnswer<PartiallyFixedOrientedType>(
            this.orientedTypes.map(orientedType => {
              const group = this.withChangedCycle(cycleIndex, cycle.withOrientedType(orientedType));
              const groupWithAnswer: ScrambleGroupWithAnswer<PartiallyFixedOrientedType> = [group, orientedType];
              const probability = 1 / (this.orientedTypes.length);
              return [groupWithAnswer, probability];
            }));
        }
      });    
  }
}

export function bigScrambleGroupToScrambleGroup(group: BigScrambleGroup) {
  const cycles = group.sortedCycleLengths.map(emptyPartiallyFixedCycle);
  return new ScrambleGroup(group.solved, group.unorientedByType, group.permuted, cycles);
}
