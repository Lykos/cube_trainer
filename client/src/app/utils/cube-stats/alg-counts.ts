import { VectorSpaceElement } from './vector-space-element';

export class AlgCounts implements VectorSpaceElement<AlgCounts> {
  constructor(
    readonly cycles: number,
    readonly doubleSwaps: number,
    readonly parities: number,
    readonly parityTwists: number) {}

  times(factor: number): AlgCounts {
    return new AlgCounts(this.cycles * factor, this.doubleSwaps * factor, this.parities * factor, this.parityTwists * factor);
  }

  plus(that: AlgCounts): AlgCounts {
    return new AlgCounts(this.cycles + that.cycles, this.doubleSwaps + that.doubleSwaps, this.parities + that.parities, this.parityTwists + that.parityTwists);
  }

  get total() {
    return this.cycles + this.doubleSwaps + this.parities + this.parityTwists;
  }
}

export class AlgCountsBuilder {
  cycles = 0;
  doubleSwaps = 0;
  parities = 0;
  parityTwists = 0;

  incrementCycles() {
    ++this.cycles;
    return this;
  }

  incrementDoubleSwaps() {
    ++this.doubleSwaps;
    return this;
  }

  incrementParities() {
    ++this.parities;
    return this;
  }

  incrementParityTwists() {
    ++this.parityTwists;
    return this;
  }

  build(): AlgCounts {
    return new AlgCounts(this.cycles, this.doubleSwaps, this.parities, this.parityTwists);
  }
}
