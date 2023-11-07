interface Some<X> {
  readonly tag: "some";
  readonly value: X;
}

export function some<X>(value: X): Some<X> {
  return {tag: "some", value: value};
}

interface None {
  readonly tag: "none";
}

export const none: None = {tag: "none"};

export type Optional<X> = Some<X> | None;

export function mapOptional<X, Y>(optional: Optional<X>, f: (x: X) => Y): Optional<Y> {
  return flatMapOptional(optional, x => some(f(x)));
}

export function flatten<X>(optionalOptional: Optional<Optional<X>>): Optional<X> {
  switch (optionalOptional.tag) {
    case "some": return optionalOptional.value;
    case "none": return none;
  }
}

export function flatMapOptional<X, Y>(optional: Optional<X>, f: (x: X) => Optional<Y>): Optional<Y> {
  switch (optional.tag) {
    case "some": return f(optional.value);
    case "none": return none;
  }
}

export function ifPresentOrElse<X>(optional: Optional<X>, f: (x: X) => void, g: () => void): void {
  switch (optional.tag) {
    case "some": {
      f(optional.value);
      break;
    }
    case "none": {
      g();
      break;
    }
  }
}

export function ifPresent<X>(optional: Optional<X>, f: (x: X) => void): void {
  ifPresentOrElse(optional, f, () => {});
}

export function orElse<X>(optional: Optional<X>, x: X): X {
  switch (optional.tag) {
    case "some": return optional.value;
    case "none": return x;
  }
}

export function orElseCall<X>(optional: Optional<X>, f: () => X): X {
  switch (optional.tag) {
    case "some": return optional.value;
    case "none": return f();
  }
}

export function orElseTryCall<X>(optional: Optional<X>, f: () => Optional<X>): Optional<X> {
  switch (optional.tag) {
    case "some": return optional;
    case "none": return f();
  }
}

export function forceValue<X>(optional: Optional<X>): X {
  switch (optional.tag) {
    case "some": return optional.value;
    case "none": throw new Error("Tried to force value for None.");
  }
}

export function checkNone<X>(optional: Optional<X>): void {
  if (optional.tag == 'some') {
    throw new Error(`Checked None for ${optional}.`);
  }
}

export function hasValue<X>(optional: Optional<X>): boolean {
  switch (optional.tag) {
    case "some": return true;
    case "none": return false;
  }
}

export function ofNull<X>(orNull: X | null | undefined): Optional<X> {
  return orNull === null || orNull === undefined ? none : some(orNull);
}

export function equalsValue<X>(x: X, optY: Optional<X>) {
  return orElse(mapOptional(optY, y => y === x), false);
}
