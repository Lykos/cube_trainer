export interface VectorSpaceElement<X> {
  plus: (this: X, that: X) => X;
  times: (this: X, factor: number) => X;
}

export function sumVectorSpaceElements<X extends VectorSpaceElement<X>>(xs: X[], x?: X): X {
  if (x) {
    return xs.reduce((a, b) => a.plus(b), x);
  } else {
    return xs.reduce((a, b) => a.plus(b));
  }
}

export class NumberAsVectorSpaceElement implements VectorSpaceElement<NumberAsVectorSpaceElement> {
  constructor(readonly value: number) {}

  plus(that: NumberAsVectorSpaceElement) {
    return new NumberAsVectorSpaceElement(this.value + that.value);
  }
  
  times(factor: number) {
    return new NumberAsVectorSpaceElement(this.value * factor);
  }
}
