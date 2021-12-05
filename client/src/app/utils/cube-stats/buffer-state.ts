import { Piece } from './piece';
import { ParityTwist, Parity, ThreeCycle, EvenCycle } from './alg';
import { assert } from './assert';

export class BufferState {
  constructor(readonly previousBuffer?: Piece) {}

  withCycleBreak(cycle: ThreeCycle) {
    // TODO
    assert(false);
    return this;
  }

  withEvenCycle(cycle: EvenCycle) {
    // TODO
    assert(false);
    return this;
  }

  withParity(parity: Parity) {
    // TODO
    assert(false);
    return this;
  }

  withParityTwist(parityTwist: ParityTwist) {
    // TODO
    assert(false);
    return this;
  }

  withSwap(firstPiece: Piece, secondPiece: Piece) {
    // TODO
    assert(false);
    return this;
  }
}
