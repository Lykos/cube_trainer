import { Optional, forceValue, some, none } from '../optional';
import { assert } from '../assert';
import { count, sum } from '../utils';
import { Piece } from './piece';
import { ParityTwist, Parity, ThreeCycle, EvenCycle, DoubleSwap } from './alg';
import { Probabilistic } from './probabilistic';
import { BigScrambleGroup } from './big-scramble-group';
import { Solvable } from './solvable';
import { OrientedType } from './oriented-type';

class PieceState {
  constructor(readonly isPermuted: boolean,
              readonly orientedType: Optional<OrientedType>,
              readonly cycleIndex: Optional<number>,
              readonly nextPiece: Optional<Piece>) {}
}

function orientedPieceState(orientedType: OrientedType) {
  return new PieceState(false, some(orientedType), none, none);  
}

function solvedOrUnorientedPieceState() {
  return new PieceState(false, none, none, none);  
}

function permutedPieceState() {
  return new PieceState(true, none, none, none);  
}

// Represents one group of similar scrambles.
export class ScrambleGroup implements Solvable<ScrambleGroup> {
  constructor(private readonly pieceStates: readonly PieceState[],
              private readonly numSecretlySolved: number,
              private readonly cycleLengths: readonly number[]) {
    assert(sum(this.cycleLengths) === this.numPermuted());
  }

  numPermuted() {
    return count(this.pieceStates, p => p.isPermuted) - this.numSecretlySolved;
  }

  numCycles() {
    return this.cycleLengths.length;
  }
  
  private pieceState(piece: Piece) {
    return this.pieceStates[piece.pieceId];
  }

  applyCycleBreakFromSwap(cycleBreak: ThreeCycle): ScrambleGroup {
    // TODO
    assert(false);
  }

  applyCycleBreakFromUnpermuted(cycleBreak: ThreeCycle): ScrambleGroup {
    // TODO
    assert(false);
  }
  
  applyParity(parity: Parity, orientedType: OrientedType): ScrambleGroup {
    // TODO
    assert(false);
  }
  
  applyParityTwist(parity: ParityTwist, orientedType: OrientedType): ScrambleGroup {
    // TODO
    assert(false);
  }
  
  applyPartialDoubleSwap(doubleSwap: DoubleSwap): ScrambleGroup {
    // TODO
    assert(false);
  }
  
  applyCompleteDoubleSwap(doubleSwap: DoubleSwap, orientedType: OrientedType): ScrambleGroup {
    // TODO
    assert(false);
  }
  
  applyCompleteEvenCycle(evenCycle: EvenCycle, orientedType: OrientedType): ScrambleGroup {
    const piece = evenCycle.firstPiece;
    const state = this.pieceState(piece);
    assert(state.isPermuted);
    const cycleIndex = forceValue(state.cycleIndex);
    const pieceStates = [...this.pieceStates];
    pieceStates[piece.pieceId] = orientedPieceState(orientedType);
    const numSecretlySolved = this.numSecretlySolved - evenCycle.numRemainingPieces;
    const cycleLengths = this.cycleLengths.slice(0, cycleIndex).concat(this.cycleLengths.slice(cycleIndex + 1));
    return new ScrambleGroup(pieceStates, numSecretlySolved, cycleLengths);
  }
  
  applyPartialEvenCycle(evenCycle: EvenCycle): ScrambleGroup {
    // TODO
    assert(false);
  }

  decideIsParityTime(): Probabilistic<[ScrambleGroup, boolean]> {
    // TODO
    assert(false);
  }

  decideIsSolved(piece: Piece): Probabilistic<[ScrambleGroup, boolean]> {
    // TODO
    assert(false);
  }

  decideIsPermuted(piece: Piece): Probabilistic<[ScrambleGroup, boolean]> {
    // TODO
    assert(false);
  }

  decideIsOriented(piece: Piece): Probabilistic<[ScrambleGroup, boolean]> {
    // TODO
    assert(false);
  }

  decideHasPermuted(): Probabilistic<[ScrambleGroup, boolean]> {
    // TODO
    assert(false);
  }

  decideOnlyUnoriented(): Probabilistic<[ScrambleGroup, Optional<Piece>]> {
    // TODO
    assert(false);
  }

  decideOnlyUnorientedExcept(piece: Piece): Probabilistic<[ScrambleGroup, Optional<Piece>]> {
    // TODO
    assert(false);
  }

  decideOrientedTypeForPieceCycle(piece: Piece): Probabilistic<[ScrambleGroup, OrientedType]> {
    // TODO
    assert(false);
  }

  decideOrientedTypes(): Probabilistic<[ScrambleGroup, readonly OrientedType[]]> {
    // TODO
    assert(false);
  }

  decideCycleLength(piece: Piece): Probabilistic<[ScrambleGroup, number]> {
    // TODO
    assert(false);
  }

  decideNextPiece(piece: Piece): Probabilistic<[ScrambleGroup, Piece]> {
    // TODO
    assert(false);
  }
}

export function bigScrambleGroupToScrambleGroup(group: BigScrambleGroup): ScrambleGroup {
  const pieceStates = group.pieces.map(() => solvedOrUnorientedPieceState());
  group.permuted.forEach(p => pieceStates[p.pieceId] = permutedPieceState());
  return new ScrambleGroup(pieceStates, 0, group.sortedCycleLengths);
}
