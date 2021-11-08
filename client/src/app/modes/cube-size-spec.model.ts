export interface CubeSizeSpec {
  readonly min: number;
  readonly max: number;
  readonly default: number;
  readonly oddAllowed: boolean;
  readonly evenAllowed: boolean;
}
