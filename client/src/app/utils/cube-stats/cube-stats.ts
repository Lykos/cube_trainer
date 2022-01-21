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
import { now, Instant } from '../instant';
import { seconds } from '../duration';
import { find } from '../utils';
import { sumVectorSpaceElements } from './vector-space-element';

const numIterations = 20000;

class ProgressLogger {
  private readonly slowComputationThreshold = seconds(10);
  private readonly outputInterval = seconds(1);
  private computationsDone = 0;
  private lastOutput: Instant;

  constructor(private readonly totalComputations: number,
	      private readonly start: Instant) {
    this.lastOutput = start;
  }

  compute<X>(computation: () => X): X {
    const computationStart = now();
    const result = computation();
    const computationEnd = now();
    const computationElapsed = computationEnd.minusInstant(computationStart);
    const totalElapsed = computationEnd.minusInstant(this.start);
    const elapsedSinceLastOutput = computationEnd.minusInstant(this.lastOutput);
    if (elapsedSinceLastOutput.greaterThan(this.outputInterval)) {
      this.lastOutput = computationEnd;
      const computationsPerSecond = this.computationsDone / totalElapsed.toSeconds();
      // TODO: Get away from console.log
      console.log(`${this.computationsDone / this.totalComputations} done (${this.computationsDone} / ${this.totalComputations}) with a rate of ${computationsPerSecond} computations per second`);
    }
    if (computationElapsed.greaterThan(this.slowComputationThreshold)) {
      console.log(`Slow computation (${computationElapsed.toSeconds()} seconds)`, computation);
    }
    ++this.computationsDone;
    return result;
  }
}

function expectedAlgCountsForPieces(pieces: PiecePermutationDescription, methodDescription: PieceMethodDescription, samplingMethod: SamplingMethod): AlgCounts {
  const solver = createSolver(new Decider(pieces, methodDescription), pieces.pieceDescription);
  const samplingStrategy = samplingMethod === SamplingMethod.EXHAUSTIVE ? new ExhaustiveSamplingStrategy(pieces) : new RandomSamplingStrategy(pieces, numIterations);
  const groups = samplingStrategy.groups();
  const progressLogger = new ProgressLogger(groups.length, now());
  return expectedValue(groups.flatMap(group => {
    return progressLogger.compute(() => solver.algCounts(group));
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
