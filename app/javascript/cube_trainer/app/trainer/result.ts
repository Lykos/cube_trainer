import { Duration } from '../utils/duration';
import { Instant } from '../utils/instant';

export interface Result {
  readonly id: number;
  readonly timestamp: Instant;
  readonly inputRepresentation: string;
  readonly duration: Duration;
}
