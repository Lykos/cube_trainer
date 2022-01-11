import { Part } from './part.model';

export interface AlgSet {
  readonly id: number;
  readonly owner: string;
  readonly buffer: Part;
}
