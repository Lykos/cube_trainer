import { Alg, ParityTwist, Parity, ThreeCycle, EvenCycle, DoubleSwap } from './alg';

export class AlgTrace {
  constructor(readonly algs: Alg[]) {}

  prefixParityTwist(parityTwist: ParityTwist) {
    const prefix: Alg[] = [parityTwist];
    return new AlgTrace(prefix.concat(this.algs));
  }

  prefixParity(parity: Parity) {
    const prefix: Alg[] = [parity];
    return new AlgTrace(prefix.concat(this.algs));
  }

  prefixThreeCycle(cycle: ThreeCycle) {
    const prefix: Alg[] = [cycle];
    return new AlgTrace(prefix.concat(this.algs));
  }

  prefixEvenCycle(cycle: EvenCycle) {
    const prefix: Alg[] = [cycle];
    return new AlgTrace(prefix.concat(this.algs));
  }

  prefixDoubleSwap(doubleSwap: DoubleSwap) {
    const prefix: Alg[] = [doubleSwap];
    return new AlgTrace(prefix.concat(this.algs));
  }
}

export function emptyAlgTrace() {
  return new AlgTrace([]);
}
