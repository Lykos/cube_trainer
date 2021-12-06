export enum Color {
  White = 'white',
  Yellow = 'yellow',
  Red = 'red',
  Orange = 'orange',
  Blue = 'blue',
  Green = 'green',
}

const oppositeColorPairs = [
  [Color.White, Color.Yellow],
  [Color.Red, Color.Orange],
  [Color.Blue, Color.Green],
];

export function neighborColors(color: Color): Color[] {
  return oppositeColorPairs.filter(pair => !pair.includes(color)).reduce((a, b) => a.concat(b));
}
