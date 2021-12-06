import { Piece } from './piece';

export class BufferState {
  constructor(readonly cycleBreaks: number, readonly previousBuffer?: Piece) {}

  withCycleBreak() {
    return new BufferState(this.cycleBreaks + 1, this.previousBuffer);
  }
}

export function emptyBufferState() {
  return new BufferState(0);
}

export function newBufferState(buffer: Piece) {
  return new BufferState(0, buffer);
}
