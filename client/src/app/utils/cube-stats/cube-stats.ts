import { Solver } from './solver';
import { Piece } from './piece';
import { CORNER, EDGE } from './piece-description';
import { assert } from '../assert';
import { Decider } from './decider';
import { sum } from '../utils';
import { PiecePermutationDescription } from './piece-permutation-description';
import { bigScrambleGroupToScrambleGroup } from './scramble-group';
import { Probabilistic, ProbabilisticPossibility, flattenProbabilistic, expectedValue } from './probabilistic';
import { BigScrambleGroup } from './big-scramble-group';
import { AlgCounts } from './alg-counts'

function logRandomGroup(groups: BigScrambleGroup[]) {
  const group = groups[Math.floor(Math.random() * groups.length)];
  console.log(group, group.count);
}

function logRandomGroups(groups: BigScrambleGroup[]) {
  const interestingGroups = groups.filter(group => group.solved.length === 0 && group.unorientedByType[0].length === 0);
  for (let i = 0; i < 10; ++i) {
    logRandomGroup(interestingGroups);
  }
}

class SolvingMethod {
  private readonly solver: Solver;

  constructor(readonly piecePermutationDescription: PiecePermutationDescription,
              readonly pieces: Piece[],
              readonly decider: Decider) {
    this.solver = new Solver(this.decider, this.pieces);
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
    logRandomGroups(groups)
    console.log(groups.length);
    assert(Math.round(directComputed) === Math.round(groupSum), `directComputed === groupSum (${directComputed} vs ${groupSum})`)
    return flattenProbabilistic(new Probabilistic<Probabilistic<AlgCounts>>(groups.map(
      group => this.algCountsWithProbabilityForGroup(group)
    )));
  }

  expectedAlgCounts(): AlgCounts {
    return expectedValue(this.algCounts());
  }
}

export enum ExecutionOrder {
  CE, EC
}

export interface MethodDescription {
  readonly executionOrder: ExecutionOrder;
}

export function expectedAlgCounts(methodDescription: MethodDescription): AlgCounts {
  switch (methodDescription.executionOrder) {
    case ExecutionOrder.EC:
      return new SolvingMethod(new PiecePermutationDescription(EDGE, false), EDGE.pieces, new Decider()).expectedAlgCounts().plus(
        new SolvingMethod(new PiecePermutationDescription(CORNER, true), CORNER.pieces, new Decider()).expectedAlgCounts());
    case ExecutionOrder.CE:
      return new SolvingMethod(new PiecePermutationDescription(CORNER, false), CORNER.pieces, new Decider()).expectedAlgCounts().plus(
        new SolvingMethod(new PiecePermutationDescription(EDGE, true), EDGE.pieces, new Decider()).expectedAlgCounts());
  }
}
