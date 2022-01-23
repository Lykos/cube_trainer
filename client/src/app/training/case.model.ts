// Represents case that we train to get better on, e.g. one 3-cycle, one parity case,
// one twist case etc.
// This represents the abstract case independent of its solution.
// For the specific case attached to a training session with a specific solution, see TrainingCase.
export interface Case {
  readonly key: string;
  readonly name: string;
  readonly rawName: string;
}
