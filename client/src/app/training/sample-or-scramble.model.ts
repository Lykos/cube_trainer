import { TrainingCase } from './training-case.model.ts';
import { Sample } from '@utils/sampling';
import { Alg } from 'cubing/alg';

export interface Scramble {
  readonly tag: 'scramble';
  readonly scramble: Alg;
}

export interface TrainingCaseSample {
  readonly tag: 'training case sample';
  readonly sample: Sample<TrainingCase>;
}

export type SampleOrScramble = Scramble | TrainingCaseSample;
