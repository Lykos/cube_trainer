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
  switch (optional.tag) {
    case "some": return some(f(optional.value));
    case "none": return none;
  }
}

export function orElse<X>(optional: Optional<X>, x: X): X {
  switch (optional.tag) {
    case "some": return optional.value;
    case "none": return x;
  }
}

export function forceValue<X>(optional: Optional<X>): X {
  switch (optional.tag) {
    case "some": return optional.value;
    case "none": throw "Tried to force value for None.";
  }
}

export function checkNone<X>(optional: Optional<X>): void {
  if (optional.tag == "some") {
    throw `Checked None for ${optional}.`;
  }
}

export function hasValue<X>(optional: Optional<X>): boolean {
  switch (optional.tag) {
    case "some": return true;
    case "none": return false;
  }
}

export function ofNull<X>(orNull: X | null | undefined): Optional<X> {
  return orNull ? some(orNull) : none;
}
