import { Piece } from './piece';

export enum ExecutionOrder {
  CE = 'CE',
  EC = 'EC',
}

export enum UniformAlgSetMode {
  ALL = 'All',
  ONLY_ORIENTED = 'OnlyOriented',
  NONE = 'None',
}

export interface UniformAlgSet {
  readonly tag: 'uniform';
  readonly mode: UniformAlgSetMode;
}

export interface PieceSpecificSubset<X> {
  readonly piece: Piece;
  readonly subset: X;
}

export interface PartialAlgSet<X> {
  readonly tag: 'partial';
  readonly subsets: readonly PieceSpecificSubset<X>[];
}

export type HierarchicalAlgSet<X> = UniformAlgSet | PartialAlgSet<X>;

export interface BufferDescription {
  readonly buffer: Piece;
  readonly fiveCycles: boolean;
  readonly stayWithSolvedBuffer: boolean;
  readonly maxTwistLength: number;
  readonly canDoParityTwists: boolean;
  readonly doUnorientedBeforeParity: boolean;
  readonly doUnorientedBeforeParityTwist: boolean;
}

export interface PieceMethodDescription {
  readonly pluralName: string;
  readonly sortedBufferDescriptions: readonly BufferDescription[];
  readonly avoidUnorientedIfWeCanFloat: boolean;
  readonly maxFloatingTwistLength: number;
  readonly doubleSwaps: HierarchicalAlgSet<HierarchicalAlgSet<HierarchicalAlgSet<HierarchicalAlgSet<UniformAlgSet>>>>;
}

export interface MethodDescription {
  readonly executionOrder: ExecutionOrder;
  readonly pieceMethodDescriptions: readonly PieceMethodDescription[];
}
