import { Injectable } from '@angular/core';
import {
  Sampler,
  NewSampler,
  CombinedSampler,
  RepeatWeighter,
  RevisitWeighter,
  ForgottenWeighter,
  BadnessWeighter,
  UniformWeighter,
  ManyItemsNotSeenWeighter,
  WeightedSampler,
  PrioritizedSampler
} from '@utils/sampling';
import { TrainingSession } from './training-session.model';
import { seconds, Duration } from '@utils/duration';

interface SamplingConfig {
  readonly revisitNewItems: boolean;
  readonly goalBadness: Duration,
  readonly badnessBase: number,
  readonly newItemsWeight: number;
  readonly badItemsWeight: number;
  readonly longNotSeenItemsWeight: number;
  readonly forgottenExponentialBackoffBase: number;
  readonly repeatExponentialBackoffBase: number;
  readonly revisitExponentialBackoffBase: number;
  readonly recencyThreshold: number;
  readonly longNotSeenThreshold: number;
  readonly forgottenRepetitions: number;
  readonly manyItemsNotSeenExponent: number;
}

function samplingConfig(trainingSession: TrainingSession): SamplingConfig {
  if (trainingSession.goalBadness === undefined) {
    throw new Error('goalBadness is undefined even though we need it for this training session');
  }
  // TODO: Read everything from the training session.
  return {
    revisitNewItems: !trainingSession.known,
    goalBadness: seconds(trainingSession.goalBadness),
    badnessBase: 10,
    newItemsWeight: trainingSession.known ? 15 : 4,
    badItemsWeight: 5,
    longNotSeenItemsWeight: 1,
    forgottenExponentialBackoffBase: 2,
    repeatExponentialBackoffBase: 2,
    revisitExponentialBackoffBase: 2,
    recencyThreshold: 4,
    longNotSeenThreshold: 100,
    forgottenRepetitions: 5,
    manyItemsNotSeenExponent: 2,
  };
}

function createSampler(config: SamplingConfig) {
  const badnessSampler = new PrioritizedSampler([
    new WeightedSampler('badness', new BadnessWeighter(config.goalBadness, config.badnessBase), config.recencyThreshold),
    new WeightedSampler('uniform', new UniformWeighter(), config.recencyThreshold),
  ]);
  const sampler = new PrioritizedSampler([
    new WeightedSampler('forgotten', new ForgottenWeighter(config.forgottenExponentialBackoffBase, config.forgottenRepetitions), config.recencyThreshold),
    new CombinedSampler([
      { weight: config.newItemsWeight, sampler: new NewSampler('new') },
      { weight: config.badItemsWeight, sampler: badnessSampler },
      { weight: config.longNotSeenItemsWeight, sampler: new WeightedSampler('long not seen', new ManyItemsNotSeenWeighter(config.manyItemsNotSeenExponent), config.longNotSeenThreshold) },
    ]),
  ]);
  if (!config.revisitNewItems) {
    return sampler;
  }
  return new PrioritizedSampler([
    new WeightedSampler('revisit', new RevisitWeighter(config.revisitExponentialBackoffBase), config.recencyThreshold),
    new WeightedSampler('repeat', new RepeatWeighter(config.repeatExponentialBackoffBase), config.recencyThreshold),
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
    const newSampler = createSampler(samplingConfig(trainingSession));
    this.samplers.set(trainingSession.id, newSampler);
    return newSampler;
  }
}
