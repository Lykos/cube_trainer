import { SerializableAlgCounts } from './serializable-alg-counts';

export interface AlgCountsResponse {
  readonly byPieces: {
    readonly pluralName: string;
    readonly algCounts: SerializableAlgCounts;
  }[];
}
