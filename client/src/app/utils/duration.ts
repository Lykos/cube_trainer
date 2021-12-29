import { maxBy, minBy } from './utils';

const numMillisPerSecond = 1000;
const numSecondsPerMinute = 60;
const numMinutesPerHour = 60;
const numHoursPerDay = 24;

function toDD(n: number) {
  if (n >= 100 || n < 0) {
    throw `n = ${n} is not valid for toDD`;
  } else {
    return (n >= 10 ? '' : '0') + n;
  }
}

export class Duration {
  // Internally, we store millis, but this shouldn't matter to any clients.
  constructor(private readonly millis: number) {}

  toMillis() {
    return this.millis;
  }

  toSeconds() {
    return this.toMillis() / numMillisPerSecond;
  }

  toMinutes() {
    return this.toSeconds() / numSecondsPerMinute;
  }

  toHours() {
    return this.toMinutes() / numMinutesPerHour;
  }

  toDays() {
    return this.toHours() / numHoursPerDay;
  }

  times(factor: number) {
    return new Duration(this.millis * factor);
  }

  dividedBy(that: Duration) {
    return this.millis / that.millis;
  }

  plus(that: Duration) {
    return new Duration(this.millis + that.millis);
  }

  minus(that: Duration) {
    return new Duration(this.millis - that.millis);
  }

  lessThan(that: Duration) {
    return this.millis < that.millis;
  }

  lessOrEqual(that: Duration) {
    return this.millis <= that.millis;
  }

  equals(that: Duration) {
    return this.millis === that.millis;
  }

  notEquals(that: Duration) {
    return this.millis !== that.millis;
  }

  greaterOrEqual(that: Duration) {
    return this.millis >= that.millis;
  }

  greaterThan(that: Duration) {
    return this.millis > that.millis;
  }

  min(that: Duration) {
    return this.lessOrEqual(that) ? this : that;
  }

  max(that: Duration) {
    return this.greaterOrEqual(that) ? this : that;
  }

  toString() {
    if (this.equals(infiniteDuration)) {
      return "infinity";
    } else if (this.equals(negativeInfiniteDuration)) {
      return "-infinity";
    }
    const days = Math.floor(this.toDays());
    const hours = Math.floor(this.toHours()) % numHoursPerDay;
    const minutes = Math.floor(this.toMinutes()) % numMinutesPerHour;
    const seconds = Math.round((this.toSeconds() % numSecondsPerMinute) * 100) / 100;
    const parts = [days, hours, minutes, seconds];
    while (parts.length > 1 && parts[0] === 0) {
      parts.shift();
    }
    return parts.map((v, i) => i == 0 ? `${v}` : toDD(v)).join(':');
  }
}

export function minDuration(durations: Duration[]) {
  return minBy(durations, d => d.toMillis());
}

export function maxDuration(durations: Duration[]) {
  return maxBy(durations, d => d.toMillis());
}

export function millis(ms: number) {
  return new Duration(ms);
}

export function seconds(s: number) {
  return millis(numMillisPerSecond * s);
}

export function minutes(m: number) {
  return seconds(numSecondsPerMinute * m);
}

export function hours(h: number) {
  return minutes(numMinutesPerHour * h);
}

export function days(d: number) {
  return hours(numHoursPerDay * d);
}

export function durationSum(...d: Duration[]) {
  return d.reduce((a, b) => a.plus(b), zeroDuration);
}

export const zeroDuration = new Duration(0);
export const nanDuration = new Duration(NaN);
export const negativeInfiniteDuration = new Duration(Infinity);
export const infiniteDuration = new Duration(Infinity);
