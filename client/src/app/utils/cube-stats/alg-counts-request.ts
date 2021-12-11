import { MethodDescription } from './method-description';

export enum SamplingMethod {
  EXHAUSTIVE, SAMPLED
}

export interface AlgCountsRequest {
  readonly methodDescription: MethodDescription;
  readonly samplingMethod: SamplingMethod;
}
