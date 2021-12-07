import { AlgCounts } from '../utils/cube-stats/alg-counts';

export interface AlgCountsWithId {
  readonly algCounts: AlgCounts;
  readonly id: number;
}
