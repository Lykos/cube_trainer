import { Duration } from '../utils/duration';

export interface PartialResult {
  readonly duration: Duration;
  readonly numHints: number;
  readonly success: boolean;
}
