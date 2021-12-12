import { PieceDescription } from './piece-description';
import { Twist } from './alg';
import { createTwistSolver } from './twist-solver';
import { combination } from '../utils';

const topLayerCorners = new PieceDescription(4, 2);
const twoTwistsWithCosts = combination(topLayerCorners.pieces, 2).flatMap(pieces => {
  return [
    {
      twist: new Twist([[pieces[0]], [pieces[1]]]),
      cost: 1,
    },
    {
      twist: new Twist([[pieces[1]], [pieces[0]]]),
      cost: 1,
    },
  ]
});

describe('TwistSolver', () => {
  fit('should find the right 2 twist', () => {
    const solver = createTwistSolver(topLayerCorners, twoTwistsWithCosts);
    const inputTwist = [[topLayerCorners.pieces[0]], [topLayerCorners.pieces[1]]];
    const actual = solver.algs(inputTwist).assertDeterministic();
    expect(actual.algs.length).toEqual(1);
    const alg = actual.algs[0];
    if (alg instanceof Twist) {
      expect(alg.unorientedByType[0][0]).toEqual(topLayerCorners.pieces[0]);
      expect(alg.unorientedByType[1][0]).toEqual(topLayerCorners.pieces[1]);
    } else {
      expect(false).toEqual(true);
    }
  });

  it('should find two 2 twists', () => {
    const solver = createTwistSolver(topLayerCorners, twoTwistsWithCosts);
    const inputTwist = [[topLayerCorners.pieces[0], topLayerCorners.pieces[1], topLayerCorners.pieces[2]], []];
    const actual = solver.algs(inputTwist).assertDeterministic();
    expect(actual.algs.length).toEqual(2);
  });
});
