import { Instant } from '../utils/instant';

export interface Message {
  readonly id: number;
  readonly title: string;
  readonly body: string;
  readonly read: boolean;
  readonly timestamp: Instant;
}
