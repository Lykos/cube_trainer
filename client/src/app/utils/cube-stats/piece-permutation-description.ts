import { BigScrambleGroup } from './big-scramble-group';
import { Piece } from './piece';
import { PieceDescription } from './piece-description';
import { subsets, sum, contains } from '../utils';
import { factorial } from './combinatorics-utils';
import { assert } from '../assert';

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

function sortedCycleLengthPossibilities(remainingPieces: number, allowOddPermutations: boolean): number[][] {
  return sortedCycleLengthPossibilitiesWithPrefix(remainingPieces, allowOddPermutations, [], true);
}

function sortedCycleLengthPossibilitiesWithPrefix(remainingPieces: number, allowOddPermutations: boolean, prefix: number[], prefixEven: boolean): number[][] {
  if (remainingPieces === 0) {
    if (prefixEven || allowOddPermutations) {
      // That's valid. Nothing left to permute, so the prefix is all there is.
      return [prefix];
    } else {
      // Parity. So it's impossible, so 0 possibilities.
      return [];
    }
  }
  // Each cycle has to be at least as long as the previous one.
  const minLength = prefix.length > 0 ? prefix[prefix.length - 1] : 2;
  let possibilities: number[][] = [];
  for (let i = minLength; i <= remainingPieces; ++i) {
    const newPrefix = prefix.concat([i]);
    const newPrefixEven = prefixEven === (i % 2 === 1)
    possibilities = possibilities.concat(sortedCycleLengthPossibilitiesWithPrefix(remainingPieces - i, allowOddPermutations, newPrefix, newPrefixEven));
  }
  return possibilities;
}

type SolvedUnorientedSplit = [Piece[], Piece[][]];

export class PiecePermutationDescription {
  constructor(readonly pieceDescription: PieceDescription,
              readonly allowOddPermutations: boolean) {
    assert(this.unorientedTypes <= 2, 'unsupported number of unoriented types');
  }

  get pieces() {
    return this.pieceDescription.pieces;
  }

  get unorientedTypes() {
    return this.pieceDescription.unorientedTypes;
  }

  get count() {
    const divisor = this.allowOddPermutations ? 1 : 2;
    // Every piece except the last has a choice for the orientation.
    const orientations = (this.unorientedTypes + 1) ** (this.pieces.length - 1);
    const permutations = factorial(this.pieceDescription.pieces.length);
    return orientations * permutations / divisor;
  }

  groups(): BigScrambleGroup[] {
    const splits = this.solvedUnorientedSplits();
    return splits.flatMap(solvedUnorientedSplit => {
      const [solved, unorientedByType] = solvedUnorientedSplit;
      const remainingPieces = this.pieces.filter(p => !solved.includes(p) && !unorientedByType.some(unorientedForType => contains(unorientedForType, p)));
      return sortedCycleLengthPossibilities(remainingPieces.length, this.allowOddPermutations).map(
        cycleLengths => new BigScrambleGroup(this, solved, unorientedByType, remainingPieces, cycleLengths)
      );      
    });
  }

  private solvedUnorientedSplits(): SolvedUnorientedSplit[] {
    return subsets(this.pieces).flatMap(solved => this.splitsWithSolvedAndUnorientedPrefix(solved, []));
  }
  
  private splitsWithSolvedAndUnorientedPrefix(solved: Piece[], unorientedByType: Piece[][]): SolvedUnorientedSplit[] {
    assert(unorientedByType.length <= this.unorientedTypes, `unorientedByType.length <= this.unorientedTypes (${unorientedByType.length} vs ${this.unorientedTypes})`);
    const remainingPieces = this.pieces.filter(p => !solved.includes(p) && !unorientedByType.some(unorientedForType => contains(unorientedForType, p)));
    if (unorientedByType.length === this.unorientedTypes) {
      if (remainingPieces.length === 0 && unorientationSum(unorientedByType) !== 0) {
        // Invalid twist. So it's impossible, so 0 possibilities.
        // If we have remaining unsolved, the twist can be in that part.
        return [];
      } else if (remainingPieces.length === 1) {
        // It's impossible to have 1 permuted piece, so 0 possibilities.
        return [];
      } else {
        return [[solved, unorientedByType]];
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
      return this.splitsWithSolvedAndUnorientedPrefix(solved, unorientedByType.concat([unorientedForType]));
    });
  }
}
