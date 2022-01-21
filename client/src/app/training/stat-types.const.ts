import { StatType } from './stat-type.model';

export const statTypes: readonly StatType[] = [
  {
    id: 'averages',
    name: 'Averages',
    description: 'Averages like ao5, ao12, ao50, etc..',
    needsBoundedInputs: false,
  },
  {
    id: 'success_averages',
    name: 'Averages of Successes',
    description: 'Averages like ao5, ao12, ao50, etc..',
    needsBoundedInputs: false,
  },
  {
    id: 'success_rates',
    name: 'Success Rates',
    description: 'Success Rates in the last 5, 12 50, etc. solves.',
    needsBoundedInputs: false,
  },
  {
    id: 'mo3',
    name: 'Mean of 3',
    needsBoundedInputs: false,
  },
  {
    id: 'progress',
    name: 'Progress',
    needsBoundedInputs: true,
  }
];
