export function camelCaseToSnakeCase(camelCaseString: string): string {
  return camelCaseString.replace(/[A-Z]/g, (letter, index) => {
    return index == 0 ? letter.toLowerCase() : '_'+ letter.toLowerCase();
  });
}

export function snakeCaseToCamelCase(snakeCaseString: string): string {
  return snakeCaseString.replace(/_./g, letter => letter[1].toUpperCase());
}

export function camelCaseifyFields<X>(value: any): X {
  if (typeof value === "object") {
    if (value === null) {
      return null as unknown as X;
    } else if (Array.isArray(value)) {
      return value.map(camelCaseifyFields) as unknown as X;
    } else {
      const x: any = {};
      for (let [key, subValue] of Object.entries(value)) {
        x[snakeCaseToCamelCase(key)] = camelCaseifyFields(subValue);
      }
      return x as X;
    }    
  } else {
    return value as unknown as X;
  }
}
