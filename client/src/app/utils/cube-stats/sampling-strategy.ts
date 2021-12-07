import { ScrambleGroup } from './scramble-group';
import { Probabilistic } from './probabilistic';

export interface SamplingStrategy {
  groups(): Probabilistic<ScrambleGroup>;
}
