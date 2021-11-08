import { CollectionViewer, DataSource } from '@angular/cdk/collections';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { catchError, finalize } from 'rxjs/operators';
import { Result } from './result.model';
import { ResultsService } from './results.service';

export class ResultsDataSource implements DataSource<Result> {

  private resultsSubject = new BehaviorSubject<Result[]>([]);
  private loadingSubject = new BehaviorSubject<boolean>(false);
  public loading$ = this.loadingSubject.asObservable();

  constructor(private readonly resultsService: ResultsService) {}

  get data() {
    return this.resultsSubject.value;
  }

  connect(collectionViewer: CollectionViewer): Observable<Result[]> {
    return this.resultsSubject.asObservable();
  }

  disconnect(collectionViewer: CollectionViewer): void {
    this.resultsSubject.complete();
    this.loadingSubject.complete();
  }

  loadResults(modeId: number, pageNumber = 0, pageSize = 100) {
    this.loadingSubject.next(true);
    this.resultsService.list(modeId, pageNumber, pageSize).pipe(
      catchError(() => of([])),
      finalize(() => this.loadingSubject.next(false))
    )
      .subscribe((results: Result[]) => {
	return this.resultsSubject.next(results);
      });
  }    
}
