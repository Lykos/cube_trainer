/// <reference lib="webworker" />

import { AlgCountsRequest } from '@utils/cube-stats/alg-counts-request';
import { AlgCountsResponse } from '@utils/cube-stats/alg-counts-response';
import { expectedAlgCounts } from '@utils/cube-stats/cube-stats';
import { value, error } from '@shared/or-error.type';
import { WorkerRequest } from './worker-request.model';
import { WorkerResponse } from './worker-response.model';

addEventListener('message', ({ data }) => {
  const request: WorkerRequest<AlgCountsRequest> = data;
  try {
    const algCounts = expectedAlgCounts(request.data);
    const response: WorkerResponse<AlgCountsResponse> = {dataOrError: value(algCounts), id: request.id};
    postMessage(response);
  } catch (err) {    
    const response: WorkerResponse<AlgCountsResponse> = {dataOrError: error(err), id: request.id};
    postMessage(response);
  }
});
