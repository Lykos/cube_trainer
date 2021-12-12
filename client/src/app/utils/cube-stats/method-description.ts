import { Piece } from './piece';

export enum ExecutionOrder {
  CE = 'CE',
  EC = 'EC',
}

export interface BufferDescription {
  readonly buffer: Piece;
  readonly fiveCycles: boolean;
  readonly stayWithSolvedBuffer: boolean;
  readonly maxTwistLength: number;
  readonly canDoParityTwists: boolean;
}

export interface PieceMethodDescription {
  readonly pluralName: string;
  readonly sortedBufferDescriptions: readonly BufferDescription[];
  readonly avoidUnorientedIfWeCanFloat: boolean;
  readonly maxFloatingTwistLength: number;
}

export interface MethodDescription {
  readonly executionOrder: ExecutionOrder;
  readonly pieceMethodDescriptions: readonly PieceMethodDescription[];
}
