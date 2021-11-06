export function camelCaseToSnakeCase(camelCaseString: string): string {
  return camelCaseString.replace(/[A-Z]/g, (letter, index) => {
    return index == 0 ? letter.toLowerCase() : '_'+ letter.toLowerCase();
  });
}
