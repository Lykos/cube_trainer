import { NewResult } from './new-result.model';

export interface Result extends NewResult {
  readonly id: number;
  readonly createdAt: string;
}
