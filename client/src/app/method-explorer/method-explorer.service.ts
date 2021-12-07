import { Injectable } from '@angular/core';
import { MethodDescription } from '../utils/cube-stats/method-description';
import { expectedAlgCounts } from '../utils/cube-stats/cube-stats';
import { valueOrElseThrow, ifError } from '../shared/or-error.type';
import { WorkerRequest } from './worker-request.model';
import { WorkerResponse } from './worker-response.model';
import { AlgCounts } from '../utils/cube-stats/alg-counts';
import { Observable, of, throwError, ReplaySubject } from 'rxjs';
import { map, first } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class MethodExplorerService {
  private id = 0;
  private algCountsWithId$ = new ReplaySubject<WorkerResponse<AlgCounts>>();
  worker: Worker | undefined;

  constructor() {
    if (typeof Worker !== 'undefined') {
      // Create a new worker.
      this.worker = new Worker(new URL('./cube-stats.worker', import.meta.url));
      this.worker.onmessage = ({ data }) => {
        const response: WorkerResponse<AlgCounts> = data;
        this.algCountsWithId$.next(response);
      };
    } else {
      // Web workers are not supported in this environment.
      // We execute expensive calculations synchronously.
    }
  }

  expectedAlgCounts(methodDescription: MethodDescription): Observable<AlgCounts> {
    const currentId = ++this.id;
    if (this.worker) {
      const request: WorkerRequest<MethodDescription> = {data: methodDescription, id: currentId};
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
        return of(expectedAlgCounts(methodDescription));
      } catch (error) {
        return throwError(error);
      }
    }
  }
}
