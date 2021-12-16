export interface Case {
  readonly key: number;
  readonly name: string;
  readonly hints: string[];
  readonly setup?: string;
}
