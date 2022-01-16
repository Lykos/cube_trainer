import { Duration } from '@utils/duration';

export interface StatPartBase {
  readonly name: string;  
}

export interface FractionStatPart extends StatPartBase {
  readonly tag: 'fraction';
  readonly fraction: number;
}

export interface CountStatPart extends StatPartBase {
  readonly tag: 'count';
  readonly count: number;
}

export interface DurationStatPart extends StatPartBase {
  readonly tag: 'duration';
  readonly duration: Duration;
}

export interface DnfStatPart extends StatPartBase {
  readonly tag: 'dnf';
}

export function fractionStatPart(name: string, fraction: number): FractionStatPart {
  return { tag: 'fraction', name, fraction };
}

export function countStatPart(name: string, count: number): CountStatPart {
  return { tag: 'count', name, count };
}

export function durationStatPart(name: string, duration: Duration): DurationStatPart {
  return { tag: 'duration', name, duration };
}

export function dnfStatPart(name: string): DnfStatPart {
  return { tag: 'dnf', name };
}

export function isFractionStatPart(statPart: StatPart): statPart is FractionStatPart {
  return statPart.tag === 'fraction'
}

export function isCountStatPart(statPart: StatPart): statPart is CountStatPart {
  return statPart.tag === 'count'
}

export function isDurationStatPart(statPart: StatPart): statPart is DurationStatPart {
  return statPart.tag === 'duration'
}

export function isDnfStatPart(statPart: StatPart): statPart is DnfStatPart {
  return statPart.tag === 'dnf'
}

export type StatPart = FractionStatPart | CountStatPart | DurationStatPart | DnfStatPart;
