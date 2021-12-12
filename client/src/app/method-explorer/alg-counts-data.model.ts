import { AlgCounts } from '../utils/cube-stats/alg-counts';
import { AlgCountsResponse } from '../utils/cube-stats/alg-counts-response';

export interface AlgCountsRow {
  readonly pluralName: string;
  readonly algCounts: AlgCounts;
}

// Wrapper around alg counts response that makes it easier to work with.
export class AlgCountsData {
  readonly rows: readonly AlgCountsRow[];

  constructor(algCountsResponse: AlgCountsResponse) {
    this.rows = algCountsResponse.byPieces.map(row => {
      return {
        ...row,
        algCounts: new AlgCounts(row.algCounts),
      };
    });
  }
}
