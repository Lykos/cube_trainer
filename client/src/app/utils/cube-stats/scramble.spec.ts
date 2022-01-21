import { Scramble } from './scramble';
import { EvenCycle, ThreeCycle } from './alg';
import { solvedOrientedType } from './oriented-type';

const pieceA = { pieceId: 0 }
const pieceB = { pieceId: 1 }
const pieceC = { pieceId: 2 }
const pieceD = { pieceId: 3 }

describe('Scramble', () => {
  it('applies a complete even cycle', () => {
    const scramble = new Scramble(
      [pieceB, pieceC, pieceA, pieceD],
      [solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType],
    );
    const modifiedScramble = scramble.applyCompleteEvenCycle(new EvenCycle(pieceC, 2), solvedOrientedType);
    expect(modifiedScramble.pieces).toEqual([pieceA, pieceB, pieceC, pieceD]);
  });

  it('applies a partial even cycle', () => {
    const scramble = new Scramble(
      [pieceB, pieceC, pieceD, pieceA],
      [solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType],
    );
    const modifiedScramble = scramble.applyPartialEvenCycle(new EvenCycle(pieceA, 2));
    expect(modifiedScramble.pieces).toEqual([pieceD, pieceB, pieceC, pieceA]);
  });

  it('applies a cycle break from swap', () => {
    const scramble = new Scramble(
      [pieceB, pieceA, pieceD, pieceC],
      [solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType]
    );
    const modifiedScramble = scramble.applyCycleBreakFromSwap(new ThreeCycle(pieceA, pieceB, pieceC));
    expect(modifiedScramble.pieces).toEqual([pieceD, pieceB, pieceA, pieceC]);
  });

  it('applies a cycle break from unpermuted', () => {
    const scramble = new Scramble(
      [pieceA, pieceC, pieceD, pieceB],
      [solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType],
    );
    const modifiedScramble = scramble.applyCycleBreakFromSwap(new ThreeCycle(pieceA, pieceB, pieceC));
    expect(modifiedScramble.pieces).toEqual([pieceD, pieceA, pieceC, pieceB]);
  });

  it('computes the number of cycles correctly', () => {
    const scramble = new Scramble(
      [{ pieceId: 0 }, { pieceId: 2 }, { pieceId: 1 }, { pieceId: 4 }, { pieceId: 5 }, { pieceId: 3 }, { pieceId: 7 }, { pieceId: 6 }],
      [solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType],
    );
    expect(scramble.numCycles()).toEqual(3);
  });

  it('computes the length of cycles correctly', () => {
    const scramble = new Scramble(
      [{ pieceId: 0 }, { pieceId: 2 }, { pieceId: 1 }, { pieceId: 4 }, { pieceId: 5 }, { pieceId: 3 }, { pieceId: 7 }, { pieceId: 6 }],
      [solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType],
    );
    expect(scramble.cycleLength({ pieceId: 0 })).toEqual(1);
    expect(scramble.cycleLength({ pieceId: 1 })).toEqual(2);
    expect(scramble.cycleLength({ pieceId: 4 })).toEqual(3);
    expect(scramble.cycleLength({ pieceId: 7 })).toEqual(2);
  });

  it('returns the next piece correctly', () => {
    const scramble = new Scramble(
      [pieceA, pieceC, pieceD, pieceB],
      [solvedOrientedType, solvedOrientedType, solvedOrientedType, solvedOrientedType],
    );
    expect(scramble.nextPiece(pieceA)).toEqual(pieceA);
    expect(scramble.nextPiece(pieceB)).toEqual(pieceC);
    expect(scramble.nextPiece(pieceC)).toEqual(pieceD);
    expect(scramble.nextPiece(pieceD)).toEqual(pieceB);
  });
});
