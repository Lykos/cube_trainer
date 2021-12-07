interface Value<X> {
  readonly tag: 'value';
  readonly value: X;
}

interface Error {
  readonly tag: 'error';
  readonly error: any;
}

export type OrError<X> = Value<X> | Error;

export function value<X>(value: X): Value<X> {
  return {tag: 'value', value};
}

export function error(error: any): Error {
  return {tag: 'error', error};
}

export function valueOrElse<X, Y>(valueOrError: OrError<X>, elseValue: Y): X | Y {
  switch (valueOrError.tag) {
    case 'value': return valueOrError.value;
    case 'error': return elseValue;
  }
}

export function valueOrElseThrow<X, Y>(valueOrError: OrError<X>): X {
  switch (valueOrError.tag) {
    case 'value': return valueOrError.value;
    case 'error': throw valueOrError.error;
  }
}

export function errorOrElse<X>(valueOrError: OrError<X>, elseError: any): any {
  switch (valueOrError.tag) {
    case 'value': return elseError;
    case 'error': return valueOrError.error;
  }
}
