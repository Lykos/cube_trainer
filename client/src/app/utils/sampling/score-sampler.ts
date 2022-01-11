import { Sampler } from './sampler';
import { Scorer } from './scorer';

export class ScoreSampler<X> implements Sampler<X> {
  constructor(private readonly scorer: Scorer) {}  
}
