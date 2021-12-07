import { PiecePermutationDescription } from './piece-permutation-description';
import { SamplingStrategy } from './sampling-strategy';
import { randomScramble } from './scramble';
import { ScrambleGroup, scrambleToScrambleGroup } from './scramble-group';
import { Probabilistic, ProbabilisticPossibility } from './probabilistic';

export class RandomSamplingStrategy implements SamplingStrategy {
  constructor(readonly numIterations: number, readonly piecePermutationDescription: PiecePermutationDescription) {}  

  groups(): Probabilistic<ScrambleGroup> {
    const possibilities: ProbabilisticPossibility<ScrambleGroup>[] = [];
    const probability = 1 / numIterations;
    for (let i = 0; i < this.numIterations; ++i) {
      const group = scrambleToScrambleGroup(randomScramble(piecePermutationDescription));
      possibilities.push([group, probability]);
    }
    return new Probabilistic<ScrambleGroup>(possibilities);
  }
}
