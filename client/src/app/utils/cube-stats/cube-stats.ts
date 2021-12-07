import { createSolver, Solver } from './solver';
import { CORNER, EDGE } from './piece-description';
import { ExecutionOrder, MethodDescription } from './method-description';
import { assert } from '../assert';
import { Decider } from './decider';
import { sum } from '../utils';
import { PiecePermutationDescription } from './piece-permutation-description';
import { bigScrambleGroupToScrambleGroup } from './scramble-group';
import { Probabilistic, ProbabilisticPossibility, flattenProbabilistic, expectedValue } from './probabilistic';
import { BigScrambleGroup } from './big-scramble-group';
import { AlgCounts } from './alg-counts'

class SolvingMethod {
  private readonly solver: Solver;

  constructor(readonly piecePermutationDescription: PiecePermutationDescription,
              readonly decider: Decider) {
    this.solver = createSolver(this.decider, this.piecePermutationDescription.pieceDescription);
  }

  private algCountsWithProbabilityForGroup(group: BigScrambleGroup): ProbabilisticPossibility<Probabilistic<AlgCounts>> {
    const probability = group.count / this.piecePermutationDescription.count;
    const scrambleGroup = bigScrambleGroupToScrambleGroup(group);
    const algsForGroup = this.solver.algCounts(scrambleGroup);
    return [algsForGroup, probability];
  }

  private algCounts(): Probabilistic<AlgCounts> {
    const groups = this.piecePermutationDescription.groups();
    const directComputed = this.piecePermutationDescription.count;
    const groupSum = sum(groups.map(group => group.count));
    assert(Math.round(directComputed) === Math.round(groupSum), `directComputed === groupSum (${directComputed} vs ${groupSum})`)
    return flattenProbabilistic(new Probabilistic<Probabilistic<AlgCounts>>(groups.map(
      group => this.algCountsWithProbabilityForGroup(group)
    )));
  }

  expectedAlgCounts(): AlgCounts {
    return expectedValue(this.algCounts());
  }
}

export function expectedAlgCounts(methodDescription: MethodDescription): AlgCounts {
  switch (methodDescription.executionOrder) {
    case ExecutionOrder.EC: {
      const edgePermutationDescription = new PiecePermutationDescription(EDGE, false);
      const cornerPermutationDescription = new PiecePermutationDescription(CORNER, true);
      return new SolvingMethod(edgePermutationDescription, new Decider(edgePermutationDescription)).expectedAlgCounts().plus(
        new SolvingMethod(cornerPermutationDescription, new Decider(cornerPermutationDescription)).expectedAlgCounts());
    }
    case ExecutionOrder.CE: {
      const cornerPermutationDescription = new PiecePermutationDescription(CORNER, false);
      const edgePermutationDescription = new PiecePermutationDescription(EDGE, true);
      return new SolvingMethod(edgePermutationDescription, new Decider(edgePermutationDescription)).expectedAlgCounts().plus(
        new SolvingMethod(cornerPermutationDescription, new Decider(cornerPermutationDescription)).expectedAlgCounts());
    }
  }
}
