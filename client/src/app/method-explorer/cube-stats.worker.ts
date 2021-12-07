/// <reference lib="webworker" />

import { AlgCounts } from '../utils/cube-stats/alg-counts';
import { MethodDescription } from '../utils/cube-stats/method-description';
import { expectedAlgCounts } from '../utils/cube-stats/cube-stats';
import { value, error } from '../shared/or-error.type';
import { WorkerRequest } from './worker-request.model';
import { WorkerResponse } from './worker-response.model';

addEventListener('message', ({ data }) => {
  const request: WorkerRequest<MethodDescription> = data;
  try {
    const algCounts = expectedAlgCounts(request.data);
    const response: WorkerResponse<AlgCounts> = {dataOrError: value(algCounts), id: request.id};
    postMessage(response);
  } catch (err) {    
    const response: WorkerResponse<AlgCounts> = {dataOrError: error(err), id: request.id};
    postMessage(response);
  }
});
