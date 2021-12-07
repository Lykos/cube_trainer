import { VectorSpaceElement } from './vector-space-element';

function pointwisePlus(left: number[], right: number[]): number[] {
  if (right.length > left.length) {
    return pointwisePlus(right, left);
  }
  return left.map((e, i) => e + (i >= right.length ? 0 : right[i]));
}

export class AlgCounts implements VectorSpaceElement<AlgCounts> {
  constructor(
    readonly cycles: number,
    readonly doubleSwaps: number,
    readonly parities: number,
    readonly parityTwists: number,
    readonly twistsByNumUnoriented: number[]) {}

  times(factor: number): AlgCounts {
    return new AlgCounts(this.cycles * factor, this.doubleSwaps * factor, this.parities * factor, this.parityTwists * factor, this.twistsByNumUnoriented.map(t => t * factor));
  }

  plus(that: AlgCounts): AlgCounts {
    return new AlgCounts(this.cycles + that.cycles, this.doubleSwaps + that.doubleSwaps, this.parities + that.parities, this.parityTwists + that.parityTwists, pointwisePlus(this.twistsByNumUnoriented, that.twistsByNumUnoriented));
  }

  get total() {
    return this.cycles + this.doubleSwaps + this.parities + this.parityTwists;
  }
}

export class AlgCountsBuilder {
  twistsByNumUnoriented: number[] = [];
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

  incrementTwists(numUnoriented: number) {
    while (this.twistsByNumUnoriented.length < numUnoriented) {
      this.twistsByNumUnoriented.push(0);
    }
    ++this.twistsByNumUnoriented[numUnoriented];
    return this;
  }

  build(): AlgCounts {
    return new AlgCounts(this.cycles, this.doubleSwaps, this.parities, this.parityTwists, this.twistsByNumUnoriented);
  }
}
