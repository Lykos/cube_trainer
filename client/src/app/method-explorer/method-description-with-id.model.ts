import { MethodDescription } from '../utils/cube-stats/cube-stats';

export interface MethodDescriptionWithId {
  readonly methodDescription: MethodDescription;
  readonly id: number;
}
