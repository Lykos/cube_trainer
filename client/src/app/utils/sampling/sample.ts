export interface Sample<X> {
  readonly item: X;
  readonly samplerName: string;
}

export function mapSample<X, Y>(sample: Sample<X>, f: (x: X) => Y): Sample<Y> {
  return { ...sample, item: f(sample.item) };
}
