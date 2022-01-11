import { TrainingCase } from './training-case.model';
import { Sample } from '@utils/sampling';
import { Alg } from 'cubing/alg';

export interface Scramble {
  readonly tag: 'scramble';
  readonly scramble: Alg;
}

export function scramble(alg: Alg): Scramble {
  return {
    tag: 'scramble',
    scramble: alg,
  };
}

export interface TrainingCaseSample {
  readonly tag: 'sample';
  readonly sample: Sample<TrainingCase>;
}

export function sample(trainingCaseSample: Sample<TrainingCase>): TrainingCaseSample {
  return {
    tag: 'sample',
    sample: trainingCaseSample,
  };
}

export type ScrambleOrSample = Scramble | TrainingCaseSample;

export function isScramble(scrambleOrSample: ScrambleOrSample): scrambleOrSample is Scramble {
  return scrambleOrSample.tag === 'scramble';
}

export function isSample(scrambleOrSample: ScrambleOrSample): scrambleOrSample is TrainingCaseSample {
  return scrambleOrSample.tag === 'sample';
}
