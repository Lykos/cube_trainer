import { BigScrambleGroup } from './big-scramble-group';
import { Piece } from './piece';
import { PieceDescription } from './piece-description';
import { subsets, sum, contains } from '../utils';
import { factorial } from './combinatorics-utils';
import { assert } from '../assert';

function sortedCycleLengthPossibilities(remainingPieces: number, allowOddPermutations: boolean): number[][] {
  return sortedCycleLengthPossibilitiesWithPrefix(remainingPieces, allowOddPermutations, [], true);
}

function containsPieceIndexAtMost(pieces: Piece[], piece: Piece) {
  return pieces.some(p => p.pieceId <= piece.pieceId);
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
    if (unorientedByType.length === this.unorientedTypes) {
      // This only works if there are at most 2 unoriented types. This has to be fixed otherwise.
      const unorientationSum = sum(unorientedByType.map((unorientedForType, unorientedType) => unorientedForType.length * (unorientedType + 1))) % (unorientedByType.length + 1);
      const remainingPieces = this.pieces.filter(p => !solved.includes(p) && !unorientedByType.some(unorientedForType => contains(unorientedForType, p)));
      if (remainingPieces.length === 0 && unorientationSum !== 0) {
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
    // We assume that the groups of unoriented elements are ordered by their minimum piece index. So we exclude variations that would violate this.
    const remainingPiecesForUnoriented = this.pieces.filter(p => !solved.includes(p) && !unorientedByType.some(unorientedForType => containsPieceIndexAtMost(unorientedForType, p)));
    return subsets(remainingPiecesForUnoriented).flatMap(
      unorientedForType => this.splitsWithSolvedAndUnorientedPrefix(solved, unorientedByType.concat([unorientedForType]))
    );
  }
}
