import { Part } from './part.model';

export interface PartType {
  readonly name: string;
  readonly parts: Part[];
}
