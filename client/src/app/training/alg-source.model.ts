export interface OriginalAlg {
  readonly tag: 'original';
}

export interface InferredAlg {
  readonly tag: 'inferred';
}

export interface FixedAlg {
  readonly tag: 'fixed';
}

export interface OverriddenAlg {
  readonly tag: 'overridden';
  readonly algOverrideId: number;
}

export type AlgSource = OriginalAlg | FixedAlg | InferredAlg | OverriddenAlg;

