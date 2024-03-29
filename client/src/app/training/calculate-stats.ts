import { StatTypeId } from './stat-type-id.model';
import { Stat } from './stat.model';
import { statTypes } from './stat-types.const';
import { CaseTrainingSession, TrainingSession } from './training-session.model';
import { seconds, zeroDuration, infiniteDuration, Duration } from '@utils/duration';
import { orElse } from '@utils/optional';
import { dnfStatPart, undefinedStatPart, durationStatPart, fractionStatPart, countStatPart, StatPart } from './stat-part.model';
import { Result } from './result.model';
import { RawStat } from './raw-stat.model';
import { GeneratorType } from './generator-type.model';
import { CubeAverage } from '@utils/cube-average';
import { fromDateString } from '@utils/instant';
import { find } from '@utils/utils';
import { Optional, mapOptional, hasValue, forceValue } from '@utils/optional';

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
  const name = `ao${n} of successes`;
  if (!results.length) {
    return undefinedStatPart(name);
  }
  const average = new CubeAverage(n);
  let i = 0;
  let successes = 0;
  while (i < results.length && successes < n) {
    if (results[i].success) {
      average.push(time(results[i]));
      ++successes;
    }
    ++i;
  }
  return durationOrDnfStatPart(name, orElse(average.average(), infiniteDuration));
}

function average(results: readonly Result[], n: number): StatPart {
  const name = `ao${n}`;
  if (!results.length) {
    return undefinedStatPart(name);
  }
  const average = new CubeAverage(n);
  const adjustedN = Math.min(n, results.length);
  for (let i = 0; i < adjustedN; ++i) {
    average.push(time(results[i]));
  }
  return durationOrDnfStatPart(name, orElse(average.average(), infiniteDuration));
}

function successRates(results: readonly Result[], n: number): StatPart {
  const name = `success rate of ${n}`;
  if (!results.length) {
    return undefinedStatPart(name);
  }
  let successes = 0;
  const adjustedN = Math.min(n, results.length);
  for (let i = 0; i < adjustedN; ++i) {
    if (results[i].success) {
      ++successes;
    }
  }
  return fractionStatPart(name, successes / adjustedN);
}

function mo3(results: readonly Result[]): StatPart {
  const name = 'mo3';
  if (!results.length) {
    return undefinedStatPart(name);
  }
  const adjustedN = Math.min(3, results.length);
  let sum = zeroDuration;
  for (let i = 0; i < adjustedN; ++i) {
    sum = sum.plus(time(results[i]));
  }
  return durationOrDnfStatPart(name, sum.times(1 / adjustedN));
}

function totalCases(trainingSession: CaseTrainingSession): StatPart {
  return countStatPart('total cases', trainingSession.trainingCases.length);
}

function casesSeen(trainingSession: CaseTrainingSession, results: readonly Result[]): StatPart {
  const caseKeys = new Set<string>();
  for (let r of results) {
    caseKeys.add(r.casee.key);
  }
  let casesSeen = 0;
  for (let c of trainingSession.trainingCases) {
    if (caseKeys.has(c.casee.key)) {
      ++casesSeen;
    }
  }
  return countStatPart('cases seen', casesSeen);
}

const NS = [5, 12, 50, 100, 1000];

function calculateStatParts(trainingSession: TrainingSession, statType: StatTypeId, results: readonly Result[]): StatPart[] {
  switch (statType) {
    case StatTypeId.Averages: return NS.map(n => average(results, n));
    case StatTypeId.SuccessAverages: return NS.map(n => successAverage(results, n));
    case StatTypeId.SuccessRates: return NS.map(n => successRates(results, n));
    case StatTypeId.Mo3: return [mo3(results)];
    case StatTypeId.Progress:
      if (trainingSession.generatorType !== GeneratorType.Case) {
	throw new Error(`Progress stat is only valid for case training sessions, not for one with generator type ${trainingSession.generatorType}.`);
      }
      return [casesSeen(trainingSession, results), totalCases(trainingSession)];      
    default:
      return [];
  }
}

function calculateStat(trainingSession: TrainingSession, rawStat: RawStat, results: readonly Result[]): Optional<Stat> {
  const maybeStatType = find(statTypes, s => s.id === rawStat.statType);
  return mapOptional(
    maybeStatType,
    statType => {
      const parts = calculateStatParts(trainingSession, statType.id, results);
      return { ...rawStat, timestamp: fromDateString(rawStat.createdAt), statType, parts };
    }
  );
}

export function calculateStats(trainingSession: TrainingSession, results: readonly Result[]): Stat[] {
  return trainingSession.stats.flatMap(s => calculateStat(trainingSession, s, results)).filter(hasValue).map(forceValue);
}
