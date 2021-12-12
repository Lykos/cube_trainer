import { Solvable } from './solvable';
import { Probabilistic } from './probabilistic';

export interface SamplingStrategy<T extends Solvable<T>> {
  groups(): Probabilistic<T>;
}
