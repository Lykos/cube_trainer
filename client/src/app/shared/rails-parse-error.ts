// Represents errors that happened when parsing the responses from Rails.
export class RailsParseError extends Error {
  constructor(message: string) { super(message); }
}

export class FieldMissingError extends RailsParseError {
  constructor(field: string, messageName: string, message: object) {
    super(`Field ${field} is missing in ${messageName} ${JSON.stringify(message)}`);
  }
}

export class FieldTypeError extends RailsParseError {
  constructor(field: string, type: string, messageName: string, message: object) {
    super(`Field ${field} is not of type ${type} in ${messageName} ${JSON.stringify(message)}`);
  }
}

export class ObjectTypeError extends RailsParseError {
  constructor(messageName: string, message: unknown) {
    super(`Object ${messageName} is not of type object: ${JSON.stringify(message)}`);
  }
}

export class ArrayTypeError extends RailsParseError {
  constructor(messageName: string, message: unknown) {
    super(`Array ${messageName} is not an array: ${JSON.stringify(message)}`);
  }
}

export class FieldArrayTypeError extends RailsParseError {
  constructor(field: string, messageName: string, message: object) {
    super(`Field ${field} is not of type array in ${messageName} ${JSON.stringify(message)}`);
  }
}

export class FieldArrayElementsTypeError extends RailsParseError {
  constructor(field: string, type: string, messageName: string, message: object) {
    super(`Field ${field} contains elements not of type ${type} in ${messageName} ${JSON.stringify(message)}`);
  }
}

export class ArrayElementsTypeError extends RailsParseError {
  constructor(type: string, arrayName: string, array: unknown[]) {
    super(`Array ${arrayName} contains elements not of type ${type} in ${JSON.stringify(array)}`);
  }
}
