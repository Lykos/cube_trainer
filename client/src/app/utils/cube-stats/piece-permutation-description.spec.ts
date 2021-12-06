import { PiecePermutationDescription } from './piece-permutation-description';
import { sum } from '../utils';
import { CORNER, EDGE } from './piece-description';

describe('PiecePermutationDescription', () => {
  for (let pieceDescription of [CORNER, EDGE]) {
    for (let allowOddPermutations of [false, true]) {
      const piecePermutationDescription = new PiecePermutationDescription(pieceDescription, allowOddPermutations);

      it('should compute groups whose counts sum up to the total count', () => {
        const groups = piecePermutationDescription.groups();
        const totalCount = piecePermutationDescription.count;
        const groupCountSum = sum(groups.map(group => group.count));
        expect(groupCountSum).toEqual(totalCount);
      });
    }
  }
});
