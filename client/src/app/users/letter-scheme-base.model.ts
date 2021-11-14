import { Part } from './part.model';

export interface LetterSchemeMapping {
  readonly part: Part;
  readonly letter: string;
}

export interface LetterSchemeBase {
  readonly mappings: LetterSchemeMapping[];
}
