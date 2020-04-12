import { CollectionViewer, DataSource } from '@angular/cdk/collections';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { catchError, finalize } from 'rxjs/operators';
import { Result } from './result';
import { ResultService } from './result.service';

export class ResultsDataSource implements DataSource<Result> {

  private resultsSubject = new BehaviorSubject<Result[]>([]);
  private loadingSubject = new BehaviorSubject<boolean>(false);
  public loading$ = this.loadingSubject.asObservable();

  constructor(private readonly resultService: ResultService) {}

  connect(collectionViewer: CollectionViewer): Observable<Result[]> {
    return this.resultsSubject.asObservable();
  }

  disconnect(collectionViewer: CollectionViewer): void {
    this.resultsSubject.complete();
    this.loadingSubject.complete();
  }

  loadResults(modeId: number, pageNumber = 0, pageSize = 100) {
    this.loadingSubject.next(true);
    this.resultService.list(modeId, pageNumber, pageSize).pipe(
      catchError(() => of([])),
      finalize(() => this.loadingSubject.next(false))
    )
      .subscribe((results: Result[]) => {
	this.loadingSubject.next(false);
	return this.resultsSubject.next(results);
      });
  }    
}
