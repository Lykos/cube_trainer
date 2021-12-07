import { createSolver } from './solver';
import { CORNER, EDGE } from './piece-description';
import { ExecutionOrder, MethodDescription } from './method-description';
import { Decider } from './decider';
import { PiecePermutationDescription } from './piece-permutation-description';
import { expectedValue } from './probabilistic';
import { AlgCounts } from './alg-counts'
import { ExhaustiveSamplingStrategy } from './exhaustive-sampling-strategy';

function expectedAlgCountsForPieces(pieces: PiecePermutationDescription): AlgCounts {
  const solver = createSolver(new Decider(pieces), pieces.pieceDescription);
  const samplingStrategy = new ExhaustiveSamplingStrategy(pieces);
  return expectedValue(samplingStrategy.groups().flatMap(group => solver.algCounts(group)));
}

export function expectedAlgCounts(methodDescription: MethodDescription): AlgCounts {
  switch (methodDescription.executionOrder) {
    case ExecutionOrder.EC: {
      const edges = new PiecePermutationDescription(EDGE, false);
      const corners = new PiecePermutationDescription(CORNER, true);
      return expectedAlgCountsForPieces(edges).plus(expectedAlgCountsForPieces(corners));
    }
    case ExecutionOrder.CE: {
      const corners = new PiecePermutationDescription(CORNER, false);
      const edges = new PiecePermutationDescription(EDGE, true);
      return expectedAlgCountsForPieces(corners).plus(expectedAlgCountsForPieces(edges));
    }
  }
}
