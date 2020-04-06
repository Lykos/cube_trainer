import { NewMode } from './new-mode';

export interface Mode extends NewMode {
  readonly id: number;
}
