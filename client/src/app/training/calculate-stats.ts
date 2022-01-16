import { Stat } from './stat.model';
import { TrainingSession } from './training-session.model';
import { StatType } from './stat-type.model';
import { seconds, zeroDuration, infiniteDuration, Duration } from '@utils/duration';
import { orElse } from '@utils/optional';
import { dnfStatPart, durationStatPart, fractionStatPart, countStatPart, StatPart } from './stat-part.model';
import { Result } from './result.model';
import { UncalculatedStat } from './uncalculated-stat.model';
import { CubeAverage } from '@utils/cube-average';

function time(result: Result) {
  return result.success ? seconds(result.timeS) : infiniteDuration;
}

function durationOrDnfStatPart(name: string, duration: Duration): StatPart {
  if (duration.equals(infiniteDuration)) {
    return dnfStatPart(name);
  } else {
    return durationStatPart(name, duration);
  }
}

function successAverage(results: readonly Result[], n: number): StatPart {
  const average = new CubeAverage(n);
  let i = results.length - 1;
  let successes = 0;
  while (i >= 0 && successes < n) {
    if (results[i].success) {
      average.push(time(results[i]));
      ++successes;
    }
    --i;
  }
  const name = `ao${n} of successes`;
  return durationOrDnfStatPart(name, orElse(average.average(), infiniteDuration));
}

function average(results: readonly Result[], n: number): StatPart {
  const average = new CubeAverage(n);
  const adjustedN = Math.min(n, results.length);
  for (let i = results.length - 1; i >= results.length - adjustedN; --i) {
    average.push(time(results[i]));
  }
  const name = `ao${n}`;
  return durationOrDnfStatPart(name, orElse(average.average(), infiniteDuration));
}

function successRates(results: readonly Result[], n: number): StatPart {
  let successes = 0;
  const adjustedN = Math.min(n, results.length);
  for (let i = results.length - 1; i >= results.length - adjustedN; --i) {
    if (results[i].success) {
      ++successes;
    }
  }
  const name = `success rate of ${n}`;
  return fractionStatPart(name, successes / adjustedN);
}

function mo3(results: readonly Result[]): StatPart {
  const adjustedN = Math.min(3, results.length);
  let average = zeroDuration;
  for (let i = results.length - 1; i >= results.length - adjustedN; --i) {
    average = average.plus(time(results[i]));
  }
  return durationOrDnfStatPart('mo3', average.times(1 / adjustedN));
}

function totalCases(trainingSession: TrainingSession): StatPart {
  return countStatPart('total cases', trainingSession.trainingCases.length);
}

function casesSeen(trainingSession: TrainingSession, results: readonly Result[]): StatPart {
  const caseKeys = new Set<string>();
  for (let r of results) {
    caseKeys.add(r.caseKey);
  }
  let casesSeen = 0;
  for (let c of trainingSession.trainingCases) {
    if (caseKeys.has(c.caseKey)) {
      ++casesSeen;
    }
  }
  return countStatPart('cases seen', casesSeen);
}

const NS = [5, 12, 50, 100, 1000];

function calculateStatParts(trainingSession: TrainingSession, uncalculatedStat: StatType, results: readonly Result[]): StatPart[] {
  switch (uncalculatedStat.id) {
    case 'averages': return NS.map(n => average(results, n));
    case 'success_averages': return NS.map(n => successAverage(results, n));
    case 'success_rates': return NS.map(n => successRates(results, n));
    case 'mo3': return [mo3(results)];
    case 'progress': return [casesSeen(trainingSession, results), totalCases(trainingSession)];
    default:
      return [];
  }
}

function calculateStat(trainingSession: TrainingSession, uncalculatedStat: UncalculatedStat, results: readonly Result[]): Stat {
  const parts = calculateStatParts(trainingSession, uncalculatedStat.statType, results);
  return { ...uncalculatedStat, parts };
}

export function calculateStats(trainingSession: TrainingSession, results: readonly Result[]): Stat[] {
  return trainingSession.stats.flatMap(s => calculateStat(trainingSession, s, results));
}
