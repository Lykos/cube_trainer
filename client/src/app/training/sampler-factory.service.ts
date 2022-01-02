import { Injectable } from '@angular/core';
import { Sampler, NewSampler, CombinedSampler, RepeatWeighter, RevisitWeighter, ForgottenWeighter, WeightedSampler, PrioritizedSampler } from '@utils/sampling';
import { TrainingSession } from './training-session.model';

interface SamplingConfig {
  readonly revisitNewItems: boolean;
  readonly newItemsWeight: number;
  readonly forgottenExponentialBackoffBase: number;
  readonly repeatExponentialBackoffBase: number;
  readonly revisitExponentialBackoffBase: number;
  readonly recencyThreshold: number;
}

// TODO: Read this from the training session.
const samplingConfig: SamplingConfig = {
  revisitNewItems: true,
  newItemsWeight: 1,
  forgottenExponentialBackoffBase: 2,
  repeatExponentialBackoffBase: 2,
  revisitExponentialBackoffBase: 2,
  recencyThreshold: 2,
}

function createSampler(config: SamplingConfig) {
  const sampler = new PrioritizedSampler([
    new WeightedSampler(new ForgottenWeighter(config.forgottenExponentialBackoffBase), config.recencyThreshold),
    new CombinedSampler([
      { weight: config.newItemsWeight, sampler: new NewSampler() },
    ]),
  ]);
  if (!config.revisitNewItems) {
    return sampler;
  }
  return new PrioritizedSampler([
    new WeightedSampler(new RevisitWeighter(config.revisitExponentialBackoffBase), config.recencyThreshold),
    new WeightedSampler(new RepeatWeighter(config.repeatExponentialBackoffBase), config.recencyThreshold),
    sampler,
  ]);
}

@Injectable({
  providedIn: 'root',
})
export class SamplerFactory {
  readonly samplers = new Map<number, Sampler>();

  sampler(trainingSession: TrainingSession) {
    const existingSampler = this.samplers.get(trainingSession.id);
    if (existingSampler) {
      return existingSampler;
    }
    const newSampler = createSampler(samplingConfig);
    this.samplers.set(trainingSession.id, newSampler);
    return newSampler;
  }
}
