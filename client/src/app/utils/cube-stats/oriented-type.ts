import { sum } from '../utils';
import { assert } from '../assert';
import { VectorSpaceElement } from './vector-space-element';

// Represents an orientation type like CW or CCW.
// Except for the special value 0, it may or may not be known which of these maps to CW and which to CCW.
export class OrientedType implements VectorSpaceElement<OrientedType> {
  constructor(readonly index: number, readonly numOrientedTypes: number) {
    assert(this.index >= 0);
    assert(this.index < this.numOrientedTypes);
  }

  get isSolved() {
    return this.index === 0;
  }

  get inverse(): OrientedType {
    if (this.isSolved) {
      return this;
    }
    return new OrientedType(this.numOrientedTypes - this.index, this.numOrientedTypes);
  }

  plus(that: OrientedType) {
    if (this.isSolved) {
      return that;
    }
    if (that.isSolved) {
      return this;
    }
    assert(this.numOrientedTypes === that.numOrientedTypes);
    return new OrientedType((this.index + that.index) % this.numOrientedTypes, this.numOrientedTypes);
  }

  times(factor: number) {
    if (this.isSolved) {
      return this;
    }
    return new OrientedType((this.index * factor) % this.numOrientedTypes, this.numOrientedTypes);
  }
}

export const solvedOrientedType = new OrientedType(0, 1);

export function orientedType(index: number, numOrientedTypes: number) {
  return new OrientedType(index, numOrientedTypes);
}

export function numOrientedTypes(orientedTypes: readonly OrientedType[]): number {
  const unsolvedOrientedTypes = orientedTypes.filter(o => !o.isSolved);
  if (unsolvedOrientedTypes.length === 0) {
    return 1;
  }
  const calculatedNumOrientedTypes = unsolvedOrientedTypes[0].numOrientedTypes;
  assert(unsolvedOrientedTypes.every(o => o.numOrientedTypes === calculatedNumOrientedTypes), 'inconsistent numOrientedTypes');
  return calculatedNumOrientedTypes
}

export function orientedSum(orientedTypes: readonly OrientedType[]) {
  const calculatedNumOrientedTypes = numOrientedTypes(orientedTypes);
  const index = sum(orientedTypes.map(o => o.index)) % calculatedNumOrientedTypes;
  return orientedType(index, calculatedNumOrientedTypes);
}
