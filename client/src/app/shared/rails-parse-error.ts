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
