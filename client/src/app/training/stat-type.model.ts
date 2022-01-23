import { StatTypeId } from './stat-type-id.model';

export interface StatType {
  readonly id: StatTypeId;
  readonly name: string;
  readonly description?: string;
  readonly needsBoundedInputs: boolean;
}
