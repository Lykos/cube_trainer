export interface Hint {
  readonly rows: string[];
}

export interface InputItem {
  readonly id: number;
  readonly inputRepresentation: string;
  readonly hints: Hint[];
}
