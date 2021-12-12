import { VectorSpaceElement } from './vector-space-element';
import { SerializableAlgCounts } from './serializable-alg-counts';
import { sum } from '../utils';

function pointwisePlus(left: number[], right: number[]): number[] {
  if (right.length > left.length) {
    return pointwisePlus(right, left);
  }
  return left.map((e, i) => e + (i >= right.length ? 0 : right[i]));
}

function times(numbers: number[], factor: number) {
  return numbers.map(n => n * factor);
}

// Wrapper class for alg counts because we want to be able to work with it
// but eventually we just want to return an interface over the network.
export class AlgCounts implements VectorSpaceElement<AlgCounts> {
  constructor(readonly serializableAlgCounts: SerializableAlgCounts) {}

  times(factor: number): AlgCounts {
    return new AlgCounts({
      cyclesByLength: times(this.cyclesByLength, factor),
      doubleSwaps: this.doubleSwaps * factor,
      parities: this.parities * factor,
      parityTwists: this.parityTwists * factor,
      twistsByNumUnoriented: times(this.twistsByNumUnoriented, factor)
    });
  }

  plus(that: AlgCounts): AlgCounts {
    return new AlgCounts({
      cyclesByLength: pointwisePlus(this.cyclesByLength, that.cyclesByLength),
      doubleSwaps: this.doubleSwaps + that.doubleSwaps,
      parities: this.parities + that.parities,
      parityTwists: this.parityTwists + that.parityTwists,
      twistsByNumUnoriented: pointwisePlus(this.twistsByNumUnoriented, that.twistsByNumUnoriented)
    });
  }

  get cyclesByLength() {
    return this.serializableAlgCounts.cyclesByLength;
  }

  get doubleSwaps() {
    return this.serializableAlgCounts.doubleSwaps;
  }

  get parities() {
    return this.serializableAlgCounts.parities;
  }

  get parityTwists() {
    return this.serializableAlgCounts.parityTwists;
  }

  get twistsByNumUnoriented() {
    return this.serializableAlgCounts.twistsByNumUnoriented;
  }

  get totalTwists() {
    return sum(this.twistsByNumUnoriented);
  }

  get total(): number {
    return sum(this.cyclesByLength) +
      this.doubleSwaps +
      this.parities +
      this.parityTwists +
      this.totalTwists;
  }
}

export class AlgCountsBuilder implements SerializableAlgCounts {
  twistsByNumUnoriented: number[] = [];
  cyclesByLength: number[] = [];
  doubleSwaps = 0;
  parities = 0;
  parityTwists = 0;

  incrementCycles(length: number) {
    while (this.cyclesByLength.length <= length) {
      this.cyclesByLength.push(0);
    }
    ++this.cyclesByLength[length];
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
    while (this.twistsByNumUnoriented.length <= numUnoriented) {
      this.twistsByNumUnoriented.push(0);
    }
    ++this.twistsByNumUnoriented[numUnoriented];
    return this;
  }

  build(): AlgCounts {
    return new AlgCounts(this);
  }
}
