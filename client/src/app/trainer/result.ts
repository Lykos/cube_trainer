import { Instant } from '../utils/instant';
import { PartialResult } from './partial-result';

export interface Result extends PartialResult {
  readonly id: number;
  readonly timestamp: Instant;
  readonly inputRepresentation: string;
}
