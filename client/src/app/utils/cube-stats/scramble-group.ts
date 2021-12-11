import { Optional, hasValue, mapOptional, orElseCall, orElse, forceValue, some, none } from '../optional';
import { assert, assertEqual } from '../assert';
import { Piece } from './piece';
import { ParityTwist, Parity, ThreeCycle, EvenCycle, DoubleSwap } from './alg';
import { findIndex, sum, indexOf, only } from '../utils';
import { deterministic, Probabilistic, ProbabilisticPossibility } from './probabilistic';
import { pMapSecond, pSecondNot } from './solver-utils';
import { BigScrambleGroup } from './big-scramble-group';
import { Solvable } from './solvable';
import { solvedOrientedType, orientedType, OrientedType } from './oriented-type';

class PartiallyFixedCycle {
  constructor(
    readonly definingPiece: Optional<Piece>,
    readonly nextPiece: Optional<Piece>,
    readonly orientedType: Optional<OrientedType>,
    readonly length: number) {
    assert(this.length >= 2);
  }

  get isCompletelyFixed() {
    return this.length === 2 && hasValue(this.definingPiece) && hasValue(this.nextPiece);
  }

  get isCompletelyUnfixed() {
    return !hasValue(this.definingPiece) && !hasValue(this.nextPiece);
  }

  get unfixedLength() {
    return this.length - (hasValue(this.definingPiece) ? 1 : 0) - (hasValue(this.nextPiece) ? 1 : 0);
  }

  maybeNextPiece(piece: Piece): Optional<Piece> {
    const definingPiece = forceValue(this.definingPiece);
    assert(definingPiece === piece);
    return this.nextPiece;
  }

  withIncrementedLength(): PartiallyFixedCycle {
    return new PartiallyFixedCycle(this.definingPiece, this.nextPiece, this.orientedType, this.length + 1);
  }

  withDecrementedLength(): PartiallyFixedCycle {
    return new PartiallyFixedCycle(this.definingPiece, this.nextPiece, this.orientedType, this.length - 1);
  }

  // Removes all but the first and last piece of this cycle.
  withFirstAndLastPiece(): PartiallyFixedCycle {
    return new PartiallyFixedCycle(this.definingPiece, none, this.orientedType, 2);
  }

  withDefiningPiece(piece: Piece): PartiallyFixedCycle {
    assert(!hasValue(this.definingPiece));
    assert(!hasValue(this.nextPiece));
    return new PartiallyFixedCycle(some(piece), none, this.orientedType, this.length);
  }

  // This is used for cycle breaks.
  // We put the given piece as the defining piece and put the previous defining piece as the last piece.
  withDefiningPieceInserted(piece: Piece): PartiallyFixedCycle {
    assert(!hasValue(this.nextPiece));
    return new PartiallyFixedCycle(some(piece), this.definingPiece, this.orientedType, this.length);
  }

  withOrientedType(orientedType: OrientedType) {
    assert(!hasValue(this.orientedType));
    return new PartiallyFixedCycle(this.definingPiece, this.nextPiece, some(orientedType), this.length);
  }

  withNextPiece(piece: Piece, definingPiece: Piece) {
    assert(forceValue(this.definingPiece) === definingPiece);
    assert(!hasValue(this.nextPiece), 'tried to fix adjacent piece a second time');
    return new PartiallyFixedCycle(some(definingPiece), some(piece), this.orientedType, this.length);
  }

  // Removes the given piece from the "next piece" position (but doesn't change the length).
  withoutNextPiece(piece: Piece): PartiallyFixedCycle {
    assert(forceValue(this.nextPiece) === piece);
    return new PartiallyFixedCycle(this.definingPiece, none, this.orientedType, this.length);
  }

  hasDefiningPiece(piece: Piece) {
    return orElse(mapOptional(this.definingPiece, p => piece === p), false);
  }

  containsPiece(piece: Piece) {
    const isNextPiece = orElse(mapOptional(this.nextPiece, p => piece === p), false);
    return this.hasDefiningPiece(piece) || isNextPiece;
  }
}

function emptyPartiallyFixedCycle(length: number): PartiallyFixedCycle {
  return new PartiallyFixedCycle(none, none, none, length);
}

// Represents one group of similar scrambles, i.e.
// * same number of pieces solved
// * same number of pieces twisted or flipped
// * same number of pieces permuted
// * some pieces may have fixed equal positions or orientations.
export class ScrambleGroup implements Solvable<ScrambleGroup> {
  constructor(private readonly solved: Piece[],
              private readonly unorientedByType: readonly (readonly Piece[])[],
              private readonly solvedOrPermuted: readonly Piece[],
              private readonly permuted: readonly Piece[],
	      private readonly numSecretlySolved: number,
              private readonly partiallyFixedCycles: PartiallyFixedCycle[]) {
    const totalCycleLength = sum(this.partiallyFixedCycles.map(cycle => cycle.length));
    if (totalCycleLength !== this.numPermuted) {
      console.log(this);
    }
    assert(totalCycleLength === this.numPermuted, `cycles do not cover permuted pieces (${totalCycleLength} vs ${this.numPermuted})`);
    assert(this.solvedOrPermuted.every(piece => !partiallyFixedCycles.some(c => c.containsPiece(piece))), 'solvedOrPermuted piece in cycle');
    assert(this.solved.every(piece => !partiallyFixedCycles.some(c => c.containsPiece(piece))), 'solved piece in cycle');
    assert(this.unoriented().every(piece => !partiallyFixedCycles.some(c => c.containsPiece(piece))), 'unoriented piece in cycle');
    // If no permuted pieces are left, the orientations have to add up.
    if (this.numPermuted === 0) {
      const orientedSum = sum(this.unorientedByType.map((unorientedForType, unorientedType) => {
        const orientedType = unorientedType + 1;
        return unorientedForType.length * orientedType;
      }));
      assert(orientedSum % (this.unorientedByType.length + 1) === 0, 'invalid orientation');
    }
    if (this.solvedOrPermuted.length === numSecretlySolved) {
      // All of them are actually solved.
      this.solved = this.solved.concat(this.solvedOrPermuted);
      this.solvedOrPermuted = [];
    }
    // Note that we can't mark all solvedOrPermuted as permuted because that could mess up future steps where we set
    // a certain secret number of them as solved.
  }

  private get numPermuted() {
    return this.solvedOrPermuted.length + this.permuted.length - this.numSecretlySolved;
  }
  
  private get parityTime() {
    return this.numPermuted === 2;
  }

  private get orientedTypes(): OrientedType[] {
    return [solvedOrientedType].concat(this.unorientedByType.map((_, index) => orientedType(index)));
  }

  private unoriented(): Piece[] {
    return this.unorientedByType.flat(1);
  }

  decideHasPermuted(): Probabilistic<[ScrambleGroup, boolean]> {
    return deterministic([this, this.numPermuted === 0]);
  }

  decideUnorientedByType(): Probabilistic<[ScrambleGroup, readonly (readonly Piece[])[]]> {
    return deterministic([this, this.unorientedByType]);
  }

  decideIsParityTime(): Probabilistic<[ScrambleGroup, boolean]> {
    return deterministic([this, this.parityTime]);
  }

  decideIsSolved(piece: Piece): Probabilistic<[ScrambleGroup, boolean]> {
    if (this.solved.includes(piece)) {
      return deterministic([this, true]);
    }
    if (!this.solvedOrPermuted.includes(piece) || this.permuted.includes(piece)) {
      return deterministic([this, false]);
    }
    if (this.numSecretlySolved === 0) {
      return deterministic([this, false]);
    }
    const solvedProbability = this.numSecretlySolved / this.solvedOrPermuted.length;
    const solvedOrPermuted = this.solvedOrPermuted.filter(p => p !== piece);
    const withSolved = new ScrambleGroup(this.solved.concat([piece]), this.unorientedByType, solvedOrPermuted, this.permuted, this.numSecretlySolved - 1, this.partiallyFixedCycles);
    const withPermuted = new ScrambleGroup(this.solved, this.unorientedByType, solvedOrPermuted, this.permuted.concat([piece]), this.numSecretlySolved, this.partiallyFixedCycles);
    return new Probabilistic([
      [[withSolved, true], solvedProbability],
      [[withPermuted, false], 1 - solvedProbability]]);
  }
  
  decideIsPermuted(piece: Piece): Probabilistic<[ScrambleGroup, boolean]> {
    if (this.permuted.includes(piece)) {
      return deterministic([this, true]);
    }
    if (!this.solvedOrPermuted.includes(piece) || this.solved.includes(piece)) {
      return deterministic([this, false]);
    }
    return pSecondNot(this.decideIsSolved(piece));
  }

  decideIsOriented(piece: Piece): Probabilistic<[ScrambleGroup, boolean]> {
    return deterministic([this, this.unorientedByType.some(unorientedForType => unorientedForType.includes(piece))]);
  }

  decideOnlyUnoriented(): Probabilistic<[ScrambleGroup, Optional<Piece>]> {
    const unoriented = this.unoriented();
    const onlyUnoriented = unoriented.length === 1 ? some(unoriented[0]) : none;
    return deterministic([this, onlyUnoriented]);
  }

  decideOnlyUnorientedExcept(piece: Piece): Probabilistic<[ScrambleGroup, Optional<Piece>]> {
    const unoriented = this.unoriented();
    assert(unoriented.includes(piece));
    const onlyOtherUnoriented = unoriented.length === 2 ? some(only(unoriented.filter(p => p !== piece))) : none;
    return deterministic([this, onlyOtherUnoriented]);
  }


  decideCycleLength(piece: Piece): Probabilistic<[ScrambleGroup, number]> {
    assert(this.couldBePermuted(piece));
    return pMapSecond(this.cycleIndex(piece), cycleIndex => {
      const cycle = this.partiallyFixedCycles[cycleIndex];
      return cycle.length;
    });
  }

  decideNextPiece(piece: Piece): Probabilistic<[ScrambleGroup, Piece]> {
    assert(this.couldBePermuted(piece));
    return this.cycleIndex(piece).flatMap(([group, index]) => {
      return group.nextPieceWithCycleIndex(piece, index);
    });
  }

  private nextPieceWithCycleIndex(piece: Piece, cycleIndex: number) {
    const maybeNextPiece = this.partiallyFixedCycles[cycleIndex].maybeNextPiece(piece);
    return this.deterministicOrElseProbabilistic(
      maybeNextPiece,
      () => {
        const probability = 1 / this.solvedOrPermuted.length;
        const possibilities: ProbabilisticPossibility<[ScrambleGroup, Piece]>[] = this.solvedOrPermuted.map(
          potentialNextPiece => {
            const groupWithAnswer: [ScrambleGroup, Piece] =
              [this.withNextPieceInCycle(potentialNextPiece, cycleIndex, piece), potentialNextPiece];
            return [groupWithAnswer, probability]
          }
        );
        return new Probabilistic<[ScrambleGroup, Piece]>(possibilities);
      });
  }

  deterministicOrElseProbabilistic<X>(
    maybeDeterministicAnswer: Optional<X>,
    computeProbabilisticAnswer: () => Probabilistic<[ScrambleGroup, X]>): Probabilistic<[ScrambleGroup, X]> {
    return orElseCall(
      mapOptional(maybeDeterministicAnswer, answer => deterministic([this, answer])),
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
      const cycle = this.partiallyFixedCycles[index];
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
    assertEqual(sum(result.map(x => x[1])), this.solvedOrPermuted.length);
    return result;
  }

  private cycleIndex(piece: Piece): Probabilistic<[ScrambleGroup, number]> {
    assert(this.couldBePermuted(piece));
    const maybeIndex = findIndex(this.partiallyFixedCycles, c => c.hasDefiningPiece(piece));
    return this.deterministicOrElseProbabilistic(
      maybeIndex,
      () => {
        return new Probabilistic<[ScrambleGroup, number]>(this.relevantCyclesWithWeights().map(cycleIndexWithWeight => {
          const [cycleIndex, cycleWeight] = cycleIndexWithWeight;
          const groupWithAnswer: [ScrambleGroup, number] = [this.withDefiningPieceInCycle(piece, cycleIndex), cycleIndex];
          const probability = cycleWeight / this.solvedOrPermuted.length;
          return [groupWithAnswer, probability];
        }));
      });
  }

  private withChangedCycle(cycleIndex: number, cycle: PartiallyFixedCycle): ScrambleGroup {
    assert(cycle.length === this.partiallyFixedCycles[cycleIndex].length);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat([cycle]).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(this.solved, this.unorientedByType, this.solvedOrPermuted, this.permuted, this.numSecretlySolved, partiallyFixedCycles);
  }

  private withDefiningPieceInCycle(piece: Piece, cycleIndex: number): ScrambleGroup {
    assert(this.isSolvedOrPermuted(piece));
    const permuted = this.permuted.concat([piece]);
    const solvedOrPermuted = this.solvedOrPermuted.filter(p => p !== piece);
    const cycle = this.partiallyFixedCycles[cycleIndex];
    const changedCycle = cycle.withDefiningPiece(piece);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat([changedCycle]).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(this.solved, this.unorientedByType, solvedOrPermuted, permuted, this.numSecretlySolved, partiallyFixedCycles);
  }

  private withNextPieceInCycle(piece: Piece, cycleIndex: number, otherPiece: Piece): ScrambleGroup {
    assert(this.isPermuted(piece));
    assert(this.isSolvedOrPermuted(otherPiece));
    const permuted = this.permuted.concat([piece]);
    const solvedOrPermuted = this.solvedOrPermuted.filter(p => p !== piece && p !== piece);
    const cycle = this.partiallyFixedCycles[cycleIndex];
    const changedCycle = cycle.withNextPiece(piece, otherPiece);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat([changedCycle]).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(this.solved, this.unorientedByType, solvedOrPermuted, permuted, this.numSecretlySolved, partiallyFixedCycles);
  }

  applyCycleBreakFromUnpermuted(cycle: ThreeCycle): ScrambleGroup {
    assert(!this.couldBePermuted(cycle.firstPiece));
    assert(this.isPermuted(cycle.secondPiece));
    assert(this.isPermuted(cycle.thirdPiece));
    const brokenCycleIndex = forceValue(findIndex(this.partiallyFixedCycles, c => c.hasDefiningPiece(cycle.secondPiece)));
    const brokenCycle = this.partiallyFixedCycles[brokenCycleIndex].withDecrementedLength().withDefiningPieceInserted(cycle.firstPiece);
    // A buffer that was solved or twisted becomes permuted.
    const solved = this.solved.filter(p => p !== cycle.firstPiece).concat([cycle.thirdPiece]);
    const unorientedByType = this.unorientedByTypeWithoutPiece(this.unorientedByType, cycle.firstPiece);
    const solvedOrPermuted = this.solvedOrPermuted.filter(piece => piece !== cycle.secondPiece);
    const permuted = this.permuted.filter(piece => piece !== cycle.secondPiece).concat([cycle.firstPiece]);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, brokenCycleIndex).concat([brokenCycle]).concat(this.partiallyFixedCycles.slice(brokenCycleIndex + 1));
    return new ScrambleGroup(solved, unorientedByType, solvedOrPermuted, permuted, this.numSecretlySolved, partiallyFixedCycles);
  }

  applyCycleBreakFromSwap(cycle: ThreeCycle): ScrambleGroup {
    assert(this.isPermuted(cycle.firstPiece));
    assert(this.isPermuted(cycle.secondPiece));
    assert(this.isPermuted(cycle.thirdPiece));
    const solvedCycleIndex = forceValue(findIndex(this.partiallyFixedCycles, c => c.hasDefiningPiece(cycle.firstPiece)));
    const brokenCycleIndex = forceValue(findIndex(this.partiallyFixedCycles, c => c.hasDefiningPiece(cycle.thirdPiece)));
    const brokenCycle = this.partiallyFixedCycles[brokenCycleIndex].withIncrementedLength().withDefiningPieceInserted(cycle.firstPiece);
    const solved = this.solved.concat([cycle.secondPiece]);
    const solvedOrPermuted = this.solvedOrPermuted.filter(piece => piece !== cycle.secondPiece && piece !== cycle.thirdPiece);
    const permuted = this.permuted.filter(piece => piece !== cycle.secondPiece);
    const partiallyFixedCycles = this.partiallyFixedCycles.filter((_, index) => index !== solvedCycleIndex && index !== brokenCycleIndex).concat([brokenCycle]);
    const sortedPartiallyFixedCycles = partiallyFixedCycles.sort((a, b) => (b.length - a.length) * 3 + ((b.isCompletelyUnfixed ? 1 : 0) - (a.isCompletelyUnfixed ? 1 : 0)));
    return new ScrambleGroup(solved, this.unorientedByType, solvedOrPermuted, permuted, this.numSecretlySolved, sortedPartiallyFixedCycles);
  }

  applyPartialDoubleSwap(doubleSwap: DoubleSwap): ScrambleGroup {
    assert(this.isPermuted(doubleSwap.firstPiece));
    assert(this.isPermuted(doubleSwap.secondPiece));
    assert(this.isPermuted(doubleSwap.thirdPiece));
    assert(this.isPermuted(doubleSwap.fourthPiece));
    const firstSwap = new Parity(doubleSwap.firstPiece, doubleSwap.secondPiece);
    const secondSwap = new Parity(doubleSwap.firstPiece, doubleSwap.secondPiece);
    return this.applyParity(firstSwap, solvedOrientedType).applyPartialParity(secondSwap);
  }

  applyCompleteDoubleSwap(doubleSwap: DoubleSwap, orientedType: OrientedType): ScrambleGroup {
    assert(this.isPermuted(doubleSwap.firstPiece));
    assert(this.isPermuted(doubleSwap.secondPiece));
    assert(this.isPermuted(doubleSwap.thirdPiece));
    assert(this.isPermuted(doubleSwap.fourthPiece));
    const firstSwap = new Parity(doubleSwap.firstPiece, doubleSwap.secondPiece);
    const secondSwap = new Parity(doubleSwap.firstPiece, doubleSwap.secondPiece);
    return this.applyParity(firstSwap, solvedOrientedType).applyParity(secondSwap, orientedType);
  }

  applyPartialEvenCycle(evenCycle: EvenCycle): ScrambleGroup {
    assert(this.isPermuted(evenCycle.firstPiece));
    const numSecretlySolved = this.numSecretlySolved - evenCycle.numRemainingPieces - 1;
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasDefiningPiece(evenCycle.firstPiece)));
    const cycle = this.partiallyFixedCycles[cycleIndex];
    assert(cycle.length === evenCycle.length + 1, 'partial even cycle is not partial');
    const changedCycle = cycle.withFirstAndLastPiece();
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat([changedCycle]).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(this.solved, this.unorientedByType, this.solvedOrPermuted, this.permuted, numSecretlySolved, partiallyFixedCycles);
  }

  private unorientedByTypeWithPiece(orientedType: OrientedType, piece: Piece) {
    if (orientedType.isSolved) {
      return this.unorientedByType;
    }
    return this.unorientedByType.map(
      (unorientedForType, i) => i === orientedType.index ? unorientedForType.concat([piece]) : unorientedForType);
  }

  private unorientedByTypeWithoutPiece(unorientedByType: readonly (readonly Piece[])[], piece: Piece): readonly (readonly Piece[])[] {
    return unorientedByType.map(unorientedForType => {
      const maybeWithoutPiece = mapOptional(
        indexOf(unorientedForType, piece),
        index => unorientedForType.slice(0, index).concat(unorientedForType.slice(index + 1)));
      return orElse(maybeWithoutPiece, unorientedForType);
    });
  }

  applyCompleteEvenCycle(evenCycle: EvenCycle, orientedType: OrientedType): ScrambleGroup {
    assert(this.isPermuted(evenCycle.firstPiece));
    const numSecretlySolved = this.numSecretlySolved - evenCycle.numRemainingPieces - 1;
    const solved = orientedType.isSolved ? this.solved.concat([evenCycle.firstPiece]) : this.solved;
    const unorientedByType = this.unorientedByTypeWithPiece(orientedType, evenCycle.firstPiece);
    const solvedOrPermuted = this.solvedOrPermuted.filter(p => p !== evenCycle.firstPiece);
    const permuted = this.permuted.filter(p => p !== evenCycle.firstPiece);
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasDefiningPiece(evenCycle.firstPiece)));
    assertEqual(forceValue(this.partiallyFixedCycles[cycleIndex].orientedType), orientedType);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(solved, unorientedByType, solvedOrPermuted, permuted, numSecretlySolved, partiallyFixedCycles);
  }

  // Apply a parity alg that only solves the second piece.
  private applyPartialParity(parity: Parity): ScrambleGroup {
    assert(this.isPermuted(parity.firstPiece));
    assert(this.isPermuted(parity.lastPiece));
    const solved = this.solved.concat([parity.lastPiece]);
    const solvedOrPermuted = this.solvedOrPermuted.filter(piece => piece !== parity.lastPiece);
    const permuted = this.permuted.filter(piece => piece !== parity.lastPiece);
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasDefiningPiece(parity.firstPiece)));
    const cycle = this.partiallyFixedCycles[cycleIndex].withoutNextPiece(parity.lastPiece).withDecrementedLength();
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat([cycle]).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(solved, this.unorientedByType, solvedOrPermuted, permuted, this.numSecretlySolved, partiallyFixedCycles);
  }

  applyParity(parity: Parity, orientedType: OrientedType): ScrambleGroup {
    assert(this.isPermuted(parity.firstPiece));
    assert(this.isPermuted(parity.lastPiece));
    const newSolved = orientedType.isSolved ? parity.pieces : [parity.lastPiece];
    const solved = this.solved.concat(newSolved);
    const unorientedByType = this.unorientedByTypeWithPiece(orientedType, parity.firstPiece);
    const solvedOrPermuted = this.solvedOrPermuted.filter(piece => piece !== parity.firstPiece && piece !== parity.lastPiece);
    const permuted = this.permuted.filter(piece => piece !== parity.firstPiece && piece !== parity.lastPiece);
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasDefiningPiece(parity.firstPiece)));
    assertEqual(forceValue(this.partiallyFixedCycles[cycleIndex].orientedType), orientedType);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(solved, unorientedByType, solvedOrPermuted, permuted, this.numSecretlySolved, partiallyFixedCycles);
  }

  applyParityTwist(parityTwist: ParityTwist, orientedType: OrientedType): ScrambleGroup {
    assert(this.isPermuted(parityTwist.firstPiece));
    assert(this.isPermuted(parityTwist.lastPiece));
    assert(this.isUnoriented(parityTwist.unoriented));
    const newSolved = orientedType.isSolved ? parityTwist.pieces : [parityTwist.lastPiece, parityTwist.unoriented];
    const solved = this.solved.concat(newSolved);
    const unorientedByTypeWithBuffer = this.unorientedByTypeWithPiece(orientedType, parityTwist.firstPiece);
    const unorientedByType = this.unorientedByTypeWithoutPiece(unorientedByTypeWithBuffer, parityTwist.unoriented);
    const solvedOrPermuted = this.solvedOrPermuted.filter(piece => piece !== parityTwist.firstPiece && piece !== parityTwist.lastPiece);
    const permuted = this.permuted.filter(piece => piece !== parityTwist.firstPiece && piece !== parityTwist.lastPiece);
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasDefiningPiece(parityTwist.firstPiece)));
    assertEqual(forceValue(this.partiallyFixedCycles[cycleIndex].orientedType), orientedType);
    const partiallyFixedCycles = this.partiallyFixedCycles.slice(0, cycleIndex).concat(this.partiallyFixedCycles.slice(cycleIndex + 1));
    return new ScrambleGroup(solved, unorientedByType, solvedOrPermuted, permuted, this.numSecretlySolved, partiallyFixedCycles);
  }

  isSolved(piece: Piece) {
    return this.solved.includes(piece)
  }

  isUnoriented(piece: Piece) {
    return this.unorientedByType.some(unorientedForType => unorientedForType.includes(piece));
  }

  couldBePermuted(piece: Piece) {
    assert(this.numPermuted > 0);
    return this.isPermuted(piece) || this.isSolvedOrPermuted(piece);
  }

  isPermuted(piece: Piece) {
    assert(this.numPermuted > 0);
    return this.permuted.includes(piece);
  }

  isSolvedOrPermuted(piece: Piece) {
    assert(this.numPermuted > 0);
    return this.solvedOrPermuted.includes(piece);
  }

  decideOrientedTypeForPieceCycle(piece: Piece): Probabilistic<[ScrambleGroup, OrientedType]> {
    const cycleIndex = forceValue(findIndex(this.partiallyFixedCycles, cycle => cycle.hasDefiningPiece(piece)));
    const maybeOrientedType = this.partiallyFixedCycles[cycleIndex].orientedType;
    return this.deterministicOrElseProbabilistic(
      maybeOrientedType,
      () => {
        const cycle = this.partiallyFixedCycles[cycleIndex];
        if (this.partiallyFixedCycles.length === 1) {
          const unorientedSum = sum(this.unorientedByType.map((unorientedForType, unorientedType) => unorientedForType.length * (unorientedType + 1))) % (this.unorientedByType.length + 1);
          const orientedIndex = unorientedSum === 0 ? 0 : this.unorientedByType.length + 1 - unorientedSum;
          const orientedType = this.orientedTypes[orientedIndex];
          const group = this.withChangedCycle(cycleIndex, cycle.withOrientedType(orientedType));
          return deterministic<[ScrambleGroup, OrientedType]>([group, orientedType]);
        } else {
          const probability = 1 / (this.orientedTypes.length);
          return new Probabilistic<[ScrambleGroup, OrientedType]>(
            this.orientedTypes.map(orientedType => {
              const group = this.withChangedCycle(cycleIndex, cycle.withOrientedType(orientedType));
              const groupWithAnswer: [ScrambleGroup, OrientedType] = [group, orientedType];
              return [groupWithAnswer, probability];
            }));
        }
      });
  }
}

export function bigScrambleGroupToScrambleGroup(group: BigScrambleGroup) {
  const cycles = group.sortedCycleLengths.map(emptyPartiallyFixedCycle);
  return new ScrambleGroup(group.solved, group.unorientedByType, group.permuted, [], 0, cycles);
}
