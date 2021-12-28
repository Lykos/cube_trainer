import { Piece } from '@utils/cube-stats/piece';
import { EDGE, CORNER, PieceDescription } from '@utils/cube-stats/piece-description';
import { zip } from '@utils/utils';

export interface PieceWithName {
  readonly piece: Piece;
  readonly name: string;
}

const EDGE_NAMES = ['UF', 'UR', 'UL', 'UB', 'FR', 'FL', 'DF', 'DB', 'DR', 'DL', 'RB', 'LB'];
const CORNER_NAMES = ['UFR', 'UBR', 'UFL', 'UBL', 'DFR', 'DBR', 'DFL', 'DBL'];

function pieceWithName([piece, name]: [Piece, string]) {
  return { piece, name };
}

// Note that the mapping between these and the pieces surprisingly doesn't matter.
// We need to have a mapping, but the calculations don't really care which is which, so any mapping works.
const EDGES: readonly PieceWithName[] = zip(EDGE.pieces, EDGE_NAMES).map(pieceWithName);
const CORNERS: readonly PieceWithName[] = zip(CORNER.pieces, CORNER_NAMES).map(pieceWithName);

export function piecesWithNames(pieceDescription: PieceDescription): readonly PieceWithName[] {
  if (pieceDescription === EDGE) {
    return EDGES;
  } else if (pieceDescription === CORNER) {
    return CORNERS;
  } else {
    throw new Error('unknown piece description');
  }
}

