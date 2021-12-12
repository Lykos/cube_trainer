import { Piece } from './piece';

export enum ExecutionOrder {
  CE = 'CE',
  EC = 'EC',
}

export interface CompleteAlgSet {
  readonly tag: 'complete';
}

export interface PartialAlgSet<X> {
  readonly tag: 'partial';
  readonly subsetsForPieces: readonly [Piece, X][];
}

export type HierarchicalAlgSet<X> = PartialAlgSet<X> | CompleteAlgSet;

export interface CompleteTwistAlgSet {
  readonly tag: 'complete';
}

export interface PartialTwistAlgSet {
  readonly tag: 'partial';
  readonly subsetsForPieces: readonly [Piece, TwistAlgSet][];
}

export type TwistAlgSet = PartialTwistAlgSet | CompleteTwistAlgSet;

export interface TwistWithCostDescription {
  readonly twistOrientedTypeIndices: number[];
  readonly cost: number;
}

export interface PieceMethodDescription {
  readonly pluralName: string;
  readonly sortedBuffers: readonly Piece[];
  readonly twistsWithCosts: readonly TwistWithCostDescription[];
}

export interface MethodDescription {
  readonly executionOrder: ExecutionOrder;
  readonly pieceMethodDescriptions: readonly PieceMethodDescription[];
}
