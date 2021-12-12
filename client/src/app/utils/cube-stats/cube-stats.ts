import { createSolver } from './solver';
import { forceValue } from '../optional';
import { CORNER, EDGE } from './piece-description';
import { Decider } from './decider';
import { ExecutionOrder, PieceMethodDescription } from './method-description';
import { PiecePermutationDescription } from './piece-permutation-description';
import { expectedValue } from './probabilistic';
import { AlgCounts } from './alg-counts'
import { AlgCountsRequest, SamplingMethod } from './alg-counts-request'
import { AlgCountsResponse } from './alg-counts-response'
import { ExhaustiveSamplingStrategy } from './exhaustive-sampling-strategy';
import { RandomSamplingStrategy } from './random-sampling-strategy';
import { now } from '../instant';
import { seconds } from '../duration';
import { find } from '../utils';
import { sumVectorSpaceElements } from './vector-space-element';

const numIterations = 10000;
const slowGroupThreshold = seconds(10);
const outputInterval = seconds(1);

function expectedAlgCountsForPieces(pieces: PiecePermutationDescription, methodDescription: PieceMethodDescription, samplingMethod: SamplingMethod): AlgCounts {
  const solver = createSolver(new Decider(pieces, methodDescription), pieces.pieceDescription);
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

function piecePermutationDescriptions(executionOrder: ExecutionOrder): PiecePermutationDescription[] {
  switch (executionOrder) {
    case ExecutionOrder.EC: {
      return [
        new PiecePermutationDescription(EDGE, false),
        new PiecePermutationDescription(CORNER, true),
      ]
    }
    case ExecutionOrder.CE: {
      return [
        new PiecePermutationDescription(CORNER, false),
        new PiecePermutationDescription(EDGE, true),
      ]
    }
    default:
      throw new Error(`Unsupported execution order ${executionOrder}.`);
  }
}

export function expectedAlgCounts(request: AlgCountsRequest): AlgCountsResponse {
  const descriptions =
    piecePermutationDescriptions(request.methodDescription.executionOrder);
  const piecesWithAlgCounts: readonly [PiecePermutationDescription, AlgCounts][] =
    descriptions.map(pieces => {
      const pieceMethodDescription = forceValue(find(request.methodDescription.pieceMethodDescriptions, m => m.pluralName === pieces.pluralName));
      return [pieces, expectedAlgCountsForPieces(pieces, pieceMethodDescription, request.samplingMethod)];
    });
  const pieceNamesWithAlgCounts = piecesWithAlgCounts.map(([pieces, algCounts]) => {
    return { pluralName: pieces.pluralName, algCounts: algCounts.serializableAlgCounts };
  });
  const totalAlgCounts = sumVectorSpaceElements(piecesWithAlgCounts.map(e => e[1])).serializableAlgCounts;
  const totalRow = { pluralName: 'total', algCounts: totalAlgCounts };
  return {byPieces: pieceNamesWithAlgCounts.concat([totalRow])};
}
