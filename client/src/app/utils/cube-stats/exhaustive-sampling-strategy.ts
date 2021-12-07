import { PiecePermutationDescription } from './piece-permutation-description';
import { SamplingStrategy } from './sampling-strategy';
import { ScrambleGroup, bigScrambleGroupToScrambleGroup } from './scramble-group';
import { BigScrambleGroup } from './big-scramble-group';
import { Probabilistic, ProbabilisticPossibility } from './probabilistic';
import { sum, shuffle } from '../utils';
import { assert } from '../assert';

export class ExhaustiveSamplingStrategy implements SamplingStrategy {
  constructor(readonly piecePermutationDescription: PiecePermutationDescription) {}  

  private scrambleGroupWithProbability(group: BigScrambleGroup): ProbabilisticPossibility<ScrambleGroup> {
    const probability = group.count / this.piecePermutationDescription.count;
    const scrambleGroup = bigScrambleGroupToScrambleGroup(group);
    return [scrambleGroup, probability];
  }

  groups(): Probabilistic<ScrambleGroup> {
    const groups = this.piecePermutationDescription.groups();
    const directComputed = this.piecePermutationDescription.count;
    const groupSum = sum(groups.map(group => group.count));
    assert(Math.round(directComputed) === Math.round(groupSum), `directComputed === groupSum (${directComputed} vs ${groupSum})`);
    const possibilities = groups.map(group => this.scrambleGroupWithProbability(group));
    shuffle(possibilities);
    return new Probabilistic<ScrambleGroup>(possibilities);
  }
}
