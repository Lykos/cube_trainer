import { Injectable } from '@angular/core';
import { MethodDescription } from '@utils/cube-stats/method-description';
import { expectedAlgCounts } from '@utils/cube-stats/cube-stats';
import { valueOrElseThrow, ifError } from '@shared/or-error.type';
import { WorkerRequest } from './worker-request.model';
import { WorkerResponse } from './worker-response.model';
import { AlgCountsRequest, SamplingMethod } from '@utils/cube-stats/alg-counts-request';
import { AlgCountsResponse } from '@utils/cube-stats/alg-counts-response';
import { AlgCountsData } from './alg-counts-data.model';
import { Observable, of, throwError, ReplaySubject } from 'rxjs';
import { map, first } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class MethodExplorerService {
  private id = 0;
  private algCountsWithId$ = new ReplaySubject<WorkerResponse<AlgCountsResponse>>();
  worker: Worker | undefined;

  constructor() {
    if (typeof Worker !== 'undefined') {
      // Create a new worker.
      this.worker = new Worker(new URL('./cube-stats.worker', import.meta.url));
      this.worker.onmessage = ({ data }) => {
        const response: WorkerResponse<AlgCountsResponse> = data;
        console.log('Got response', response);
        this.algCountsWithId$.next(response);
      };
    } else {
      // Web workers are not supported in this environment.
      // We execute expensive calculations synchronously.
    }
  }

  expectedAlgCounts(methodDescription: MethodDescription): Observable<AlgCountsData> {
    const request = {methodDescription, samplingMethod: SamplingMethod.SAMPLED};
    return this.expectedAlgCountsInternal(request).pipe(map(response => new AlgCountsData(response)));
  }

  private expectedAlgCountsInternal(algCountsRequest: AlgCountsRequest): Observable<AlgCountsResponse> {
    const currentId = ++this.id;
    if (this.worker) {
      const request: WorkerRequest<AlgCountsRequest> = {data: algCountsRequest, id: currentId};
      console.log('Sending request', request);
      this.worker.postMessage(request);
      return this.algCountsWithId$.pipe(
        first(response => response.id === currentId),
        map(response => {
          ifError(response.dataOrError, console.error);
          return valueOrElseThrow(response.dataOrError);
        }),
      );
    } else {
      try {
        return of(expectedAlgCounts(algCountsRequest));
      } catch (error) {
        return throwError(error);
      }
    }
  }
}
