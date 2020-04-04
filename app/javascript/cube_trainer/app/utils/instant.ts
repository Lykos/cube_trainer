import { Duration, seconds, millis, infiniteDuration, negativeInfiniteDuration, zeroDuration } from './duration';

// Represents one instant in time. Similar to Date, but less broken.
export class Instant {
  constructor(public readonly rep: Duration) {}

  toUnixMillis() {
    return this.rep.toMillis();
  }

  plus(that: Duration) {
    return new Instant(this.rep.plus(that));
  }

  minus(that: Duration) {
    return new Instant(this.rep.minus(that));
  }

  durationUntil(that: Instant) {
    return that.rep.minus(this.rep);
  }

  lessThan(that: Instant) {
    return this.rep.lessThan(that.rep);
  }

  lessOrEqual(that: Instant) {
    return this.rep.lessOrEqual(that.rep);
  }

  equals(that: Instant) {
    return this.rep.equals(that.rep);
  }

  notEquals(that: Instant) {
    return this.rep.notEquals(that.rep);
  }

  greaterOrEqual(that: Instant) {
    return this.rep.greaterOrEqual(that.rep);
  }

  greaterThan(that: Instant) {
    return this.rep.greaterThan(that.rep);
  }

  min(that: Instant) {
    return this.lessOrEqual(that) ? this : that;
  }

  max(that: Instant) {
    return this.greaterOrEqual(that) ? this : that;
  }

  toString() {
    if (this.equals(infiniteFuture)) {
      return "infiniteFuture";
    } else if (this.equals(infinitePast)) {
      return "infinitePast";
    }
    return this.toDate().toISOString();
  }

  toDate() {
    return new Date(this.toUnixMillis());
  }
}

export function fromUnixSeconds(n: number): Instant {
  return new Instant(seconds(n));
}

export function fromDate(date: Date): Instant {
  return new Instant(millis(date.getTime()));
}

export function fromDateString(dateString: string): Instant {
  if (dateString === "infiniteFuture") {
    return infiniteFuture;
  } else if (dateString === "infinitePast") {
    return infinitePast;
  }
  return fromDate(new Date(dateString));
}

export const unixEpoch = new Instant(zeroDuration);
export const infinitePast = new Instant(negativeInfiniteDuration);
export const infiniteFuture = new Instant(infiniteDuration);

export function now(): Instant {
  return fromDate(new Date());
}
