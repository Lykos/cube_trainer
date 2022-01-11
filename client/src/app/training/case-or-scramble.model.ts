import { TrainingCase } from './training-case.model.ts';
import { Alg } from 'cubing/alg';

export interface Scramble {
  readonly tag: 'scramble';
  readonly scramble: Alg;
}

export interface TrainingCase {
  readonly tag: 'training case';
  readonly scramble: Alg;
}
