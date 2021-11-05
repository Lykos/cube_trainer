import { ModeBase } from './mode-base';

export interface Mode extends ModeBase {
  readonly id: number;
  readonly numResults: number;
}
