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

function expectedAlgCountsForPieces(pieces: PiecePermutationDescription, useExhaustiveSampling: boolean): AlgCounts {
  const solver = createSolver(new Decider(pieces), pieces.pieceDescription);
  const samplingStrategy = useExhaustiveSampling ? new ExhaustiveSamplingStrategy(pieces) : new RandomSamplingStrategy(pieces, numIterations);
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

export function expectedAlgCounts(methodDescription: MethodDescription, useExhaustiveSampling?: boolean): AlgCounts {
  switch (methodDescription.executionOrder) {
    case ExecutionOrder.EC: {
      const edges = new PiecePermutationDescription(EDGE, false);
      const corners = new PiecePermutationDescription(CORNER, true);
      return expectedAlgCountsForPieces(edges, true).plus(expectedAlgCountsForPieces(corners, true));
    }
    case ExecutionOrder.CE: {
      const corners = new PiecePermutationDescription(CORNER, false);
      const edges = new PiecePermutationDescription(EDGE, true);
      return expectedAlgCountsForPieces(corners, useExhaustiveSampling).plus(expectedAlgCountsForPieces(edges, useExhaustiveSampling));
    }
  }
}
