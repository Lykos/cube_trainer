import { createSolver } from './solver';
import { CORNER, EDGE } from './piece-description';
import { ExecutionOrder, MethodDescription } from './method-description';
import { Decider } from './decider';
import { PiecePermutationDescription } from './piece-permutation-description';
import { expectedValue } from './probabilistic';
import { AlgCounts } from './alg-counts'
import { ExhaustiveSamplingStrategy } from './exhaustive-sampling-strategy';
import { RandomSamplingStrategy } from './random-sampling-strategy';
import { now } from '../instant';
import { seconds } from '../duration';

const numIterations = 1000;
const slowGroupThreshold = seconds(10);
const outputInterval = seconds(1);

function expectedAlgCountsForPieces(pieces: PiecePermutationDescription, samplingMethod: SamplingMethod): AlgCounts {
  const solver = createSolver(new Decider(pieces), pieces.pieceDescription);
  const samplingStrategy = samplingMethod === SamplingMethod.EXHAUSTIVE ? new ExhaustiveSamplingStrategy(pieces) : new RandomSamplingStrategy(pieces, numIterations);
  const groups = samplingStrategy.groups();
  let groupsDone = 0;
  const start = now()
  let lastOutput = start;
  return expectedValue(groups.flatMap(group => {
    const groupStart = now();
    const algCounts = solver.algCounts(group);
    const groupEnd = now();
    ++groupsDone;
    const elapsedSinceLastOutput = groupEnd.minusInstant(lastOutput);
    const groupElapsed = groupEnd.minusInstant(groupStart);
    const totalElapsed = groupEnd.minusInstant(start);
    if (elapsedSinceLastOutput.greaterThan(outputInterval)) {
      lastOutput = groupEnd;
      const groupsPerSecond = groupsDone / totalElapsed.toSeconds();
      console.log(`${groupsDone / groups.length} done (${groupsDone} / ${groups.length}) with a rate of ${groupsPerSecond} groups per second`);
    }
    if (groupElapsed.greaterThan(slowGroupThreshold)) {
      console.log(`Slow group (${groupElapsed.toSeconds()} seconds)`, group);
    }
    return algCounts;
  }));
}

export enum SamplingMethod {
  EXHAUSTIVE, SAMPLED
}

export interface CubeStatsRequest {
  methodDescription: MethodDescription;
  samplingMethod: SamplingMethod;
}

export function expectedAlgCounts(request: CubeStatsRequest): AlgCounts {
  switch (request.methodDescription.executionOrder) {
    case ExecutionOrder.EC: {
      const edges = new PiecePermutationDescription(EDGE, false);
      const corners = new PiecePermutationDescription(CORNER, true);
      return expectedAlgCountsForPieces(edges, request.samplingMethod).plus(expectedAlgCountsForPieces(corners, request.samplingMethod));
    }
    case ExecutionOrder.CE: {
      const corners = new PiecePermutationDescription(CORNER, false);
      const edges = new PiecePermutationDescription(EDGE, true);
      return expectedAlgCountsForPieces(corners, request.samplingMethod).plus(expectedAlgCountsForPieces(edges, request.samplingMethod));
    }
  }
}
