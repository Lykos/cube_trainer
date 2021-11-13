interface LetterSchemeMapping {
  readonly partType: string;
  readonly part: string;
  readonly letter: string;
}

export interface LetterSchemeBase {
  readonly name: string;
  readonly mappings: LetterSchemeMapping[];
}
