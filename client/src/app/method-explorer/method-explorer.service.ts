import { Injectable } from '@angular/core';
import { expectedAlgCounts, MethodDescription } from '../utils/cube-stats/cube-stats';
import { MethodDescriptionWithId } from './method-description-with-id.model';
import { AlgCountsWithId } from './alg-counts-with-id.model';
import { AlgCounts } from '../utils/cube-stats/alg-counts';
import { Observable, of, ReplaySubject } from 'rxjs';
import { map, filter } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class MethodExplorerService {
  private id = 0;
  private algCountsWithId$ = new ReplaySubject<AlgCountsWithId>();
  worker: Worker | undefined;

  constructor() {
    if (typeof Worker !== 'undefined') {
      // Create a new worker.
      this.worker = new Worker(new URL('./cube-stats.worker', import.meta.url));
      this.worker.onmessage = ({ data }) => {
        this.algCountsWithId$.next(data);
      };
    } else {
      // Web workers are not supported in this environment.
      // We execute expensive calculations synchronously.
    }
  }

  expectedAlgCounts(methodDescription: MethodDescription): Observable<AlgCounts> {
    const currentId = ++this.id;
    if (this.worker) {
      const methodDescriptionWithId: MethodDescriptionWithId = {methodDescription, id: currentId};
      this.worker.postMessage(methodDescriptionWithId);
      return this.algCountsWithId$.pipe(
        filter(algCountsWithId => algCountsWithId.id === currentId),
        map(algCountsWithId => algCountsWithId.algCounts),
      );
    } else {
      return of(expectedAlgCounts(methodDescription));
    }
  }
}
