// Represents an orientation type like CW or CCW.
// Except for the special value 0, it may or may not be known which of these maps to CW and which to CCW.
export class OrientedType {
  constructor(readonly index: number) {}

  get isSolved() {
    return this.index === 0;
  }
}

export const solvedOrientedType = new OrientedType(0);

export function unfixedOrientedType(index: number) {
  return new PartiallyFixedOrientedType(false, index);
}
