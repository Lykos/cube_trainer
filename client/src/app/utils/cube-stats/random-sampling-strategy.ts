import { PiecePermutationDescription } from './piece-permutation-description';
import { SamplingStrategy } from './sampling-strategy';
import { randomScramble, Scramble } from './scramble';
import { Probabilistic, ProbabilisticPossibility } from './probabilistic';

export class RandomSamplingStrategy implements SamplingStrategy<Scramble> {
  constructor(readonly piecePermutationDescription: PiecePermutationDescription, readonly numIterations: number) {}  

  groups(): Probabilistic<Scramble> {
    const possibilities: ProbabilisticPossibility<Scramble>[] = [];
    const probability = 1 / this.numIterations;
    for (let i = 0; i < this.numIterations; ++i) {
      const scramble = randomScramble(this.piecePermutationDescription);
      possibilities.push([scramble, probability]);
    }
    return new Probabilistic<Scramble>(possibilities);
  }
}
