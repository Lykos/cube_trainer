import { Piece } from './piece';
import { sum } from '../utils';

export class TwistGroup {
  constructor(readonly unorientedByType: Piece[][]) {}

  get numUnoriented() {
    return sum(this.unorientedByType.map(unorientedForType => unorientedForType.length));
  }
}
