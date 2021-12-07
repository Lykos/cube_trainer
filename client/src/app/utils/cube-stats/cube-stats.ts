import { createSolver } from './solver';
import { CORNER, EDGE } from './piece-description';
import { ExecutionOrder, MethodDescription } from './method-description';
import { Decider } from './decider';
import { PiecePermutationDescription } from './piece-permutation-description';
import { expectedValue } from './probabilistic';
import { AlgCounts } from './alg-counts'
import { SamplingStrategy } from './sampling-strategy';
import { ExhaustiveSamplingStrategy } from './exhaustive-sampling-strategy';
import { RandomSamplingStrategy } from './random-sampling-strategy';

const numIterations = 1000;

function expectedAlgCountsForPieces(pieces: PiecePermutationDescription, useExhaustiveSampling: boolean): AlgCounts {
  const solver = createSolver(new Decider(pieces), pieces.pieceDescription);
  const samplingStrategy: SamplingStrategy = useExhaustiveSampling ? new ExhaustiveSamplingStrategy(pieces) : new RandomSamplingStrategy(pieces, numIterations);
  const groups = samplingStrategy.groups();
  let groupsDone = -1;
  const start = Date.now()
  return expectedValue(groups.flatMap(group => {
    ++groupsDone;
    const elapsedS = (Date.now() - start) / 1000;
    console.log(`${groupsDone / groups.length} done (${groupsDone} / ${groups.length}) with a rate of ${groupsDone / elapsedS} groups per second`);
    return solver.algCounts(group);
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
