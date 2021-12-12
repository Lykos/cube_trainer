import { Piece } from './piece';
import { TwistGroup } from './twist-group';
import { assert } from '../assert';
import { some, none, Optional, ifPresent, hasValue } from '../optional';
import { solvedOrientedType, orientedType, orientedSum } from './oriented-type';

// Returns an array of integers from `0` to `n`.
// e.g. `range(5) === [0, 1, 2, 3, 4, 5]`
function range(n: number): number[] {
  assert(n >= 0, 'n in range(n) has to be non-negative');
  return [...Array(n + 1).keys()];
}

export class PieceDescription {
  readonly pieces: readonly Piece[];
  constructor(readonly pluralName: string,
              readonly numPieces: number,
              readonly numOrientedTypes: number) {
    assert(this.numPieces >= 2, 'There have to be at least 2 pieces');
    assert(this.numOrientedTypes >= 1, 'The number of oriented types has to be non-negative');
    this.pieces = range(numPieces - 1).map(pieceId => { return {pieceId}; });
  }

  get hasOrientation() {
    return this.numOrientedTypes > 1;
  }

  twistGroups(): TwistGroup[] {
    let currentGroup = new TwistGroup(this.pieces.map(() => solvedOrientedType));
    const groups = [currentGroup];
    while (true) {
      const nextGroup = this.nextTwistGroup(currentGroup);
      ifPresent(nextGroup, group => {
        currentGroup = group;
        groups.push(group);
      });
      if (!hasValue(nextGroup)) {
        break;
      }
    }
    return groups;
  }

  private nextTwistGroup(group: TwistGroup): Optional<TwistGroup> {
    const increment = orientedType(1, this.numOrientedTypes);
    const orientedTypes = [...group.orientedTypes];
    for (let i = 1; i < orientedTypes.length; ++i) {
      const newOrientedType = orientedTypes[i].plus(increment);
      orientedTypes[i] = newOrientedType;
      if (!newOrientedType.isSolved) {
        orientedTypes[0] = orientedSum(orientedTypes.slice(1)).inverse;
        return some(new TwistGroup(orientedTypes));
      }
    }
    return none;
  }
}

export const CORNER = new PieceDescription('Corners', 8, 3);
export const EDGE = new PieceDescription('Edges', 12, 2);
