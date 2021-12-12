import { count } from '../utils';
import { assert } from '../assert';
import { OrientedType, orientedSum } from './oriented-type';

export class TwistGroup {
  constructor(readonly orientedTypes: readonly OrientedType[]) {
    assert(orientedSum(this.orientedTypes).isSolved);
  }

  get numUnoriented() {
    return count(this.orientedTypes, o => !o.isSolved);
  }
}
