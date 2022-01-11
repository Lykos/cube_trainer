export function camelCaseToSnakeCase(camelCaseString: string): string {
  return camelCaseString.replace(/[A-Z]/g, (letter, index) => {
    return index == 0 ? letter.toLowerCase() : '_'+ letter.toLowerCase();
  });
}

export function snakeCaseToCamelCase(snakeCaseString: string): string {
  return snakeCaseString.replace(/_./g, letter => letter[1].toUpperCase());
}

function transformFieldNames<X>(value: any, transform: (fieldName: string) => string): X {
  if (typeof value === "object") {
    if (value === null) {
      return null as unknown as X;
    } else if (Array.isArray(value)) {
      return value.map(subValue => transformFieldNames(subValue, transform)) as unknown as X;
    } else {
      const x: any = {};
      for (let [key, subValue] of Object.entries(value)) {
        x[transform(key)] = transformFieldNames(subValue, transform);
      }
      return x as X;
    }    
  } else {
    return value as unknown as X;
  }
}

export function snakeCaseifyFieldNames<X>(value: any): X {
  return transformFieldNames(value, camelCaseToSnakeCase);
}

export function camelCaseifyFieldNames<X>(value: any): X {
  return transformFieldNames(value, snakeCaseToCamelCase);
}
