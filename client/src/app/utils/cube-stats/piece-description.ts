import { Piece } from './piece';
import { TwistGroup } from './twist-group';
import { assert } from '../assert';
import { contains, sum, subsets } from '../utils';

function unorientationSum(unorientedByType: Piece[][]) {
  // This only works if there are at most 2 unoriented types. This has to be fixed otherwise.
  assert(unorientedByType.length <= 2);
  // The unoriented types plus the solved case.
  const orientedTypes = unorientedByType.length + 1;
  return sum(unorientedByType.map((unorientedForType, unorientedType) => {
    const orientedType = unorientedType + 1;
    return unorientedForType.length * orientedType;
  })) % orientedTypes;
}

// Returns an array of integers from `0` to `n`.
// e.g. `range(5) === [0, 1, 2, 3, 4, 5]`
function range(n: number): number[] {
  assert(n >= 0, 'n in range(n) has to be non-negative');
  return [...Array(n + 1).keys()];
}

export class PieceDescription {
  readonly pieces: readonly Piece[];
  constructor(readonly numPieces: number,
              readonly unorientedTypes: number) {
    assert(numPieces >= 2, 'There have to be at least 2 pieces');
    assert(unorientedTypes >= 0, 'The number of oriented types has to be non-negative');
    this.pieces = range(numPieces - 1).map(pieceId => { return {pieceId}; });
  }

  get orientedTypes() {
    return this.unorientedTypes + 1;
  }

  twistGroups(): TwistGroup[] {
    return this.twistGroupsWithPrefix([]);
  }

  private twistGroupsWithPrefix(unorientedByType: readonly (readonly Piece[])[]): TwistGroup[] {
    assert(unorientedByType.length <= this.unorientedTypes, `unorientedByType.length <= this.unorientedTypes (${unorientedByType.length} vs ${this.unorientedTypes})`);
    const remainingPieces = this.pieces.filter(p => !unorientedByType.some(unorientedForType => contains(unorientedForType, p)));
    if (unorientedByType.length === this.unorientedTypes) {
      if (unorientationSum(unorientedByType) !== 0) {
        // Invalid twist. So it's impossible, so 0 possibilities.
        // If we have remaining unsolved, the twist can be in that part.
        return [];
      } else {
        return [new TwistGroup(unorientedByType)];
      }
    }
    return subsets(remainingPieces).flatMap(unorientedForType => {
      // To avoid double counting, we assume that the groups of unoriented elements are ordered by
      // their length and then their minimum piece index.
      // So we exclude cases that would violate this.
      if (unorientedByType.length > 0) {
        const unorientedForPreviousType = unorientedByType[unorientedByType.length - 1];
        const currentLength = unorientedForType.length;
        const previousLength = unorientedForPreviousType.length;
        if (previousLength > currentLength) {
          return [];
        }
        if (previousLength === currentLength && currentLength > 0 &&
            unorientedForPreviousType[0].pieceId > unorientedForType[0].pieceId) {
          return [];
        }
      }
      return this.twistGroupsWithPrefix(unorientedByType.concat([unorientedForType]));
    });
  }
}

export const CORNER = new PieceDescription(8, 2);
export const EDGE = new PieceDescription(12, 1);
