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
