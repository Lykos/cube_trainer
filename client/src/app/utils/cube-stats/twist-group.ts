import { Piece } from './piece';
import { sum } from '../utils';

export class TwistGroup {
  constructor(readonly unorientedByType: readonly (readonly Piece[])[]) {}

  get numUnoriented() {
    return sum(this.unorientedByType.map(unorientedForType => unorientedForType.length));
  }
}
