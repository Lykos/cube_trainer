import { Part } from './part.model';

export interface LetterSchemeMapping {
  readonly part: Part;
  readonly letter: string;
}

export enum WingLetteringMode {
  LikeEdges = 'like_edges',
  LikeCorners = 'like_corners',
  Custom = 'custom',
}

export interface LetterSchemeBase {
  readonly wingLetteringMode: WingLetteringMode;
  readonly xcentersLikeCorners: boolean;
  readonly tcentersLikeEdges: boolean;
  readonly midgesLikeEdges: boolean;
  readonly invertWingLetter: boolean;
  readonly invertTwists: boolean;
  readonly mappings: LetterSchemeMapping[];
}
