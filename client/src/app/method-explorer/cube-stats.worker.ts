/// <reference lib="webworker" />

import { expectedAlgCounts } from '../utils/cube-stats/cube-stats';
import { MethodDescriptionWithId } from './method-description-with-id.model';
import { AlgCountsWithId } from './alg-counts-with-id.model';

addEventListener('message', ({ data }) => {
  const methodDescriptionWithId: MethodDescriptionWithId = data;
  const algCounts = expectedAlgCounts(methodDescriptionWithId.methodDescription);
  const algCountsWithId: AlgCountsWithId = {algCounts, id: methodDescriptionWithId.id};
  postMessage(algCountsWithId);
});
