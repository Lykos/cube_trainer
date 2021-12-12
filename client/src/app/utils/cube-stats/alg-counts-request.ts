import { MethodDescription } from './method-description';

export enum SamplingMethod {
  EXHAUSTIVE = 'exhaustive',
  SAMPLED = 'sampled',
}

export interface AlgCountsRequest {
  readonly methodDescription: MethodDescription;
  readonly samplingMethod: SamplingMethod;
}
