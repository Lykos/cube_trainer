import { Instant } from '../utils/instant';

export interface Message {
  readonly id: number;
  readonly title: string;
  readonly text: string;
  readonly read: boolean;
  readonly timestamp: Instant;
}
