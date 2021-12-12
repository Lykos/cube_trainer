import { BigScrambleGroup } from './big-scramble-group';
import { PieceDescription } from './piece-description';
import { subsets } from '../utils';
import { factorial } from './combinatorics-utils';
import { assert } from '../assert';

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

export class PiecePermutationDescription {
  constructor(readonly pieceDescription: PieceDescription,
              readonly allowOddPermutations: boolean) {
    assert(this.numOrientedTypes <= 3, 'unsupported number of unoriented types');
  }

  get pluralName() {
    return this.pieceDescription.pluralName;
  }

  get pieces() {
    return this.pieceDescription.pieces;
  }

  get numOrientedTypes() {
    return this.pieceDescription.numOrientedTypes;
  }

  get count() {
    const divisor = this.allowOddPermutations ? 1 : 2;
    // Every piece except the last has a choice for the orientation.
    const orientations = this.numOrientedTypes ** (this.pieces.length - 1);
    const permutations = factorial(this.pieceDescription.pieces.length);
    return orientations * permutations / divisor;
  }

  groups(): BigScrambleGroup[] {
    return subsets(this.pieces).flatMap(solvedOrUnoriented => {
      const remainingPieces = this.pieces.filter(p => !solvedOrUnoriented.includes(p));
      return sortedCycleLengthPossibilities(remainingPieces.length, this.allowOddPermutations).map(
        cycleLengths => new BigScrambleGroup(this, solvedOrUnoriented, remainingPieces, cycleLengths)
      );      
    });
  }
}
