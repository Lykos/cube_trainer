import { StatType } from './stat-type.model';
import { StatTypeId } from './stat-type-id.model';

export const statTypes: readonly StatType[] = [
  {
    id: StatTypeId.Averages,
    name: 'Averages',
    description: 'Averages like ao5, ao12, ao50, etc..',
    needsBoundedInputs: false,
  },
  {
    id: StatTypeId.SuccessAverages,
    name: 'Averages of Successes',
    description: 'Averages like ao5, ao12, ao50, etc..',
    needsBoundedInputs: false,
  },
  {
    id: StatTypeId.SuccessRates,
    name: 'Success Rates',
    description: 'Success Rates in the last 5, 12 50, etc. solves.',
    needsBoundedInputs: false,
  },
  {
    id: StatTypeId.Mo3,
    name: 'Mean of 3',
    needsBoundedInputs: false,
  },
  {
    id: StatTypeId.Progress,
    name: 'Progress',
    needsBoundedInputs: true,
  }
];
