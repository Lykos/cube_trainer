import { PiecePermutationDescription } from './piece-permutation-description';
import { SamplingStrategy } from './sampling-strategy';
import { randomScramble } from './scramble';
import { ScrambleGroup, scrambleToScrambleGroup } from './scramble-group';
import { Probabilistic, ProbabilisticPossibility } from './probabilistic';

export class RandomSamplingStrategy implements SamplingStrategy {
  constructor(readonly piecePermutationDescription: PiecePermutationDescription, readonly numIterations: number) {}  

  groups(): Probabilistic<ScrambleGroup> {
    const possibilities: ProbabilisticPossibility<ScrambleGroup>[] = [];
    const probability = 1 / this.numIterations;
    for (let i = 0; i < this.numIterations; ++i) {
      const group = scrambleToScrambleGroup(randomScramble(this.piecePermutationDescription));
      possibilities.push([group, probability]);
    }
    return new Probabilistic<ScrambleGroup>(possibilities);
  }
}
