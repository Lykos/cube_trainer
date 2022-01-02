import { ObjectTypeError, ArrayElementsTypeError, FieldArrayElementsTypeError } from '@shared/rails-parse-error';

export function checkObjectType(messageName: string, message: unknown) {
  if (typeof message !== 'object') {
    throw new ObjectTypeError(messageName, message);
  }
}

export function checkFieldArrayElementTypes(field: string, type: string, messageName: string, message: object, array: unknown[]) {
  if (array.some(e => typeof e !== type)) {
    throw new FieldArrayElementsTypeError(field, type, messageName, message);
  }
}

export function checkArrayElementTypes(type: string, messageName: string, array: unknown[]) {
  if (array.some(e => typeof e !== type)) {
    throw new ArrayElementsTypeError(type, messageName, array);
  }
}
