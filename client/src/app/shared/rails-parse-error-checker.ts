import { FieldArrayElementsTypeError } from '@shared/rails-parse-error';

export function checkArrayElementTypes(field: string, type: string, messageName: string, message: object, array: unknown[]) {
  if (array.some(e => typeof e !== type)) {
    throw new FieldArrayElementsTypeError(field, type, messageName, message);
  }
}
