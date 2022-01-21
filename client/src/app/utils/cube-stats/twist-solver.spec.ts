import { PieceDescription } from './piece-description';
import { Twist } from './alg';
import { TwistWithCost } from './twist-with-cost';
import { createTwistSolverInternal } from './twist-solver';
import { solvedOrientedType, orientedType } from './oriented-type';
import { combination } from '../utils';

const topLayerCorners = new PieceDescription('top layer corners', 4, 3);
const cw = orientedType(1, 3);
const ccw = orientedType(2, 3);
const twoTwistsWithCosts: readonly TwistWithCost[] = combination(topLayerCorners.pieces, 2).flatMap(pieces => {
  const firstTwist = [solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType];
  firstTwist[pieces[0].pieceId] = cw;
  firstTwist[pieces[1].pieceId] = ccw;
  const secondTwist = [solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType];
  secondTwist[pieces[0].pieceId] = ccw;
  secondTwist[pieces[1].pieceId] = cw;
  return [
    {
      twist: new Twist(firstTwist),
      cost: 1,
    },
    {
      twist: new Twist(secondTwist),
      cost: 1,
    },
  ]
});

describe('TwistSolver', () => {
  it('should find the right 2 twist', () => {
    const solver = createTwistSolverInternal(twoTwistsWithCosts, topLayerCorners);
    const inputTwist = [cw, ccw, solvedOrientedType, solvedOrientedType];
    const actual = solver.algsForOrientedTypes(inputTwist).assertDeterministic();
    expect(actual.algs.length).toEqual(1);
    const alg = actual.algs[0];
    if (alg instanceof Twist) {
      expect(alg.orientedTypes[0]).toEqual(cw);
      expect(alg.orientedTypes[1]).toEqual(ccw);
    } else {
      expect(false).toEqual(true);
    }
  });

  it('should find two 2 twists', () => {
    const solver = createTwistSolverInternal(twoTwistsWithCosts, topLayerCorners);
    const inputTwist = [cw, cw, cw, solvedOrientedType];
    const actual = solver.algsForOrientedTypes(inputTwist).assertDeterministic();
    expect(actual.algs.length).toEqual(2);
  });

  it('should return an empty alg trace for the solved case', () => {
    const solver = createTwistSolverInternal(twoTwistsWithCosts, topLayerCorners);
    const solvedTwist = [solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType];
    const actual = solver.algsForOrientedTypes(solvedTwist).assertDeterministic();
    expect(actual.algs.length).toEqual(0);
  });
});
