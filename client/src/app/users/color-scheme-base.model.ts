import { Color } from './color.model';
import { Face } from './face.model';

export type ColorSchemeBase = {
  [face in Face]: Color;
}
